package com.hotel.servlet.customer;

import com.google.gson.Gson;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.HotelDAO;
import com.hotel.dao.InvoiceDAO;
import com.hotel.dao.PaymentDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Hotel;
import com.hotel.model.Invoice;
import com.hotel.model.Payment;
import com.hotel.model.PaymentTransaction;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.service.EmailService;
import com.hotel.service.RazorpayPaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "RazorpayPaymentServlet", urlPatterns = {"/payment/razorpay", "/payment/razorpay-verify", "/api/payment/razorpay-order"})
public class RazorpayPaymentServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(RazorpayPaymentServlet.class);
    private final RazorpayPaymentService razorpayService = new RazorpayPaymentService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final HotelDAO hotelDAO = new HotelDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final EmailService emailService = new EmailService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + req.getRequestURI());
            return;
        }

        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
            return;
        }

        try {
            Long bookingId = Long.parseLong(bookingIdStr.trim());
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null || !booking.getUserId().equals(user.getId())) {
                resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
                return;
            }

            Invoice invoice = invoiceDAO.findByBookingId(bookingId);
            if (invoice == null) {
                resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
                return;
            }

            if (invoice.getPaymentStatus() == Invoice.PaymentStatus.PAID) {
                resp.sendRedirect(req.getContextPath() + "/customer/invoice?bookingId=" + bookingId);
                return;
            }

            PaymentTransaction tx = razorpayService.createOrder(booking, invoice);
            Hotel hotel = (booking.getHotelId() != null) ? hotelDAO.findById(booking.getHotelId()) : null;
            Room room = roomDAO.findById(booking.getRoomId());

            req.setAttribute("booking", booking);
            req.setAttribute("invoice", invoice);
            req.setAttribute("transaction", tx);
            req.setAttribute("hotel", hotel);
            req.setAttribute("room", room);
            req.setAttribute("razorpayKeyId", razorpayService.getKeyId());
            req.setAttribute("amountInPaise", invoice.getTotalPayable().multiply(new BigDecimal(100)).longValue());

            req.getRequestDispatcher("/WEB-INF/views/customer/payment-razorpay.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Error initiating Razorpay checkout", e);
            req.setAttribute("errorMessage", "Unable to start Razorpay payment checkout.");
            req.getRequestDispatcher("/WEB-INF/views/common/500.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String orderId = req.getParameter("razorpay_order_id");
        String paymentId = req.getParameter("razorpay_payment_id");
        String signature = req.getParameter("razorpay_signature");
        String bookingIdStr = req.getParameter("booking_id");

        if (orderId == null || paymentId == null || bookingIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
            return;
        }

        try {
            Long bookingId = Long.parseLong(bookingIdStr.trim());
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null || !booking.getUserId().equals(user.getId())) {
                resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
                return;
            }

            Invoice invoice = invoiceDAO.findByBookingId(bookingId);
            if (invoice == null) {
                resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
                return;
            }

            boolean isValid = razorpayService.verifyPaymentSignature(orderId, paymentId, signature);
            if (!isValid) {
                logger.warn("Razorpay signature verification failed for order {}", orderId);
                req.setAttribute("errorMessage", "Cryptographic signature verification failed. Payment was not authenticated.");
                req.setAttribute("bookingId", bookingId);
                req.getRequestDispatcher("/WEB-INF/views/customer/payment-failed.jsp").forward(req, resp);
                return;
            }

            // Create Payment record
            Payment payment = new Payment();
            payment.setInvoiceId(invoice.getId());
            payment.setBookingId(bookingId);
            payment.setPaymentReference("RZP-" + paymentId);
            payment.setAmount(invoice.getTotalPayable());
            payment.setPaymentMethod(Payment.PaymentMethod.RAZORPAY);
            payment.setPaymentStatus(Payment.RecordStatus.SUCCESS);
            payment.setTransactionNotes("Razorpay Online Checkout ID: " + paymentId + " (Order: " + orderId + ")");
            payment.setDemo(razorpayService.getKeyId().startsWith("rzp_test_"));

            paymentDAO.create(payment);

            // Update Invoice to PAID
            invoiceDAO.updatePaymentStatus(invoice.getId(), Invoice.PaymentStatus.PAID);

            // Update Booking status to CONFIRMED
            bookingDAO.updateStatus(bookingId, Booking.BookingStatus.CONFIRMED);

            // Trigger Email Notification asynchronously
            Hotel hotel = (booking.getHotelId() != null) ? hotelDAO.findById(booking.getHotelId()) : null;
            Room room = roomDAO.findById(booking.getRoomId());
            new Thread(() -> {
                try {
                    emailService.sendBookingConfirmation(booking.getGuestEmail(), booking, hotel, room);
                } catch (Exception e) {
                    logger.error("Failed to transmit email confirmation", e);
                }
            }).start();

            logger.info("Payment SUCCESS for booking {} via Razorpay ID {}", booking.getBookingReference(), paymentId);
            session.setAttribute("flashSuccess", "Payment verified and completed successfully via Razorpay! Reservation #" + booking.getBookingReference() + " is now confirmed.");
            resp.sendRedirect(req.getContextPath() + "/customer/invoice?bookingId=" + bookingId);

        } catch (Exception e) {
            logger.error("Error processing Razorpay payment callback", e);
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }
}

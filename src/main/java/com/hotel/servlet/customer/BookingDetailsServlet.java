package com.hotel.servlet.customer;

import com.hotel.model.Booking;
import com.hotel.model.Invoice;
import com.hotel.model.Payment;
import com.hotel.model.User;
import com.hotel.service.BillingService;
import com.hotel.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "BookingDetailsServlet", urlPatterns = {"/customer/booking-details"})
public class BookingDetailsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(BookingDetailsServlet.class);
    private final BookingService bookingService = new BookingService();
    private final BillingService billingService = new BillingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ref = req.getParameter("ref");
        String idStr = req.getParameter("id");

        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            Booking booking = null;
            if (ref != null && !ref.trim().isEmpty()) {
                booking = bookingService.getBookingByReference(ref.trim());
            } else if (idStr != null && !idStr.trim().isEmpty()) {
                booking = bookingService.getBookingById(Long.parseLong(idStr.trim()));
            }

            if (booking == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Reservation voucher not found.");
                return;
            }

            // Security check: only the customer who booked, or staff/admin, can view
            if (!currentUser.isStaff() && !booking.getUserId().equals(currentUser.getId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to reservation.");
                return;
            }

            Invoice invoice = billingService.getInvoiceByBookingId(booking.getId());
            List<Payment> payments = billingService.getPaymentsForBooking(booking.getId());

            req.setAttribute("booking", booking);
            req.setAttribute("invoice", invoice);
            req.setAttribute("payments", payments);

            if ("true".equals(req.getParameter("confirmed"))) {
                req.setAttribute("successMessage", "Reservation confirmed! Your booking voucher has been generated.");
            }

            req.getRequestDispatcher("/WEB-INF/views/customer/booking-details.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to retrieve booking details", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading reservation details.");
        }
    }
}

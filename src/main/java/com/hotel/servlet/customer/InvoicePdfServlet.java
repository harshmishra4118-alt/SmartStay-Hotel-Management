package com.hotel.servlet.customer;

import com.hotel.dao.BookingDAO;
import com.hotel.dao.HotelDAO;
import com.hotel.dao.InvoiceDAO;
import com.hotel.dao.PaymentDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Hotel;
import com.hotel.model.Invoice;
import com.hotel.model.Payment;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.util.InvoicePdfGenerator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "InvoicePdfServlet", urlPatterns = {"/customer/invoice/pdf"})
public class InvoicePdfServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(InvoicePdfServlet.class);
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final HotelDAO hotelDAO = new HotelDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + req.getRequestURI());
            return;
        }

        String invoiceIdStr = req.getParameter("invoiceId");
        String bookingIdStr = req.getParameter("bookingId");

        try {
            Invoice invoice = null;
            if (invoiceIdStr != null && !invoiceIdStr.trim().isEmpty()) {
                invoice = invoiceDAO.findById(Long.parseLong(invoiceIdStr.trim()));
            } else if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
                invoice = invoiceDAO.findByBookingId(Long.parseLong(bookingIdStr.trim()));
            }

            if (invoice == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Invoice not found.");
                return;
            }

            Booking booking = bookingDAO.findById(invoice.getBookingId());
            if (booking == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Associated booking not found.");
                return;
            }

            // Authorization: User must own the booking, or be Staff/Admin
            if (user.getRole() == User.Role.CUSTOMER && !booking.getUserId().equals(user.getId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to requested invoice.");
                return;
            }

            Hotel hotel = (booking.getHotelId() != null) ? hotelDAO.findById(booking.getHotelId()) : null;
            Room room = roomDAO.findById(booking.getRoomId());
            List<Payment> payments = paymentDAO.findByInvoiceId(invoice.getId());
            Payment latestPayment = (!payments.isEmpty()) ? payments.get(0) : null;

            byte[] pdfBytes = InvoicePdfGenerator.generateInvoicePdf(invoice, booking, hotel, room, latestPayment);

            String filename = "SmartStay-Invoice-" + invoice.getInvoiceNumber() + ".pdf";

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            resp.setContentLength(pdfBytes.length);

            try (OutputStream out = resp.getOutputStream()) {
                out.write(pdfBytes);
                out.flush();
            }

            logger.info("PDF invoice {} generated and downloaded for user {}", invoice.getInvoiceNumber(), user.getEmail());

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid invoice or booking identifier.");
        } catch (SQLException e) {
            logger.error("Error generating PDF invoice", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error generating PDF invoice.");
        }
    }
}


package com.hotel.servlet.customer;

import com.hotel.model.User;
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

@WebServlet(name = "CancelBookingServlet", urlPatterns = {"/customer/cancel-booking"})
public class CancelBookingServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(CancelBookingServlet.class);
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String bookingIdStr = req.getParameter("bookingId");
        String reason = req.getParameter("reason");

        try {
            Long bookingId = Long.parseLong(bookingIdStr.trim());
            bookingService.cancelReservation(
                    bookingId,
                    currentUser.getId(),
                    currentUser.isStaff(),
                    reason != null ? reason : "Cancelled by guest online",
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings?cancelled=true");
        } catch (IllegalArgumentException | IllegalStateException e) {
            req.getSession().setAttribute("sessionErrorMessage", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        } catch (Exception e) {
            logger.error("Failed to cancel reservation", e);
            req.getSession().setAttribute("sessionErrorMessage", "Unable to cancel booking at this time.");
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }
}

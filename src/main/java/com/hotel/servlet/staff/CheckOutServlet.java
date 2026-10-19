package com.hotel.servlet.staff;

import com.hotel.model.Booking;
import com.hotel.model.User;
import com.hotel.service.BookingService;
import com.hotel.service.CheckInService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet(name = "CheckOutServlet", urlPatterns = {"/staff/check-out"})
public class CheckOutServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(CheckOutServlet.class);
    private final CheckInService checkInService = new CheckInService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingRef = req.getParameter("ref");
        if (bookingRef != null && !bookingRef.trim().isEmpty()) {
            try {
                Booking booking = bookingService.getBookingByReference(bookingRef.trim());
                req.setAttribute("booking", booking);
            } catch (Exception e) {
                logger.error("Error finding booking for checkout", e);
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/staff/check-out.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentStaff = (User) session.getAttribute("currentUser");

        String bookingIdStr = req.getParameter("bookingId");
        try {
            Long bookingId = Long.parseLong(bookingIdStr.trim());
            checkInService.processCheckOut(bookingId, currentStaff.getId(), req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/staff/dashboard?checkOutSuccess=true");

        } catch (Exception e) {
            logger.error("Check-out execution error", e);
            req.setAttribute("errorMessage", "Check-out failed: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

package com.hotel.servlet.customer;

import com.hotel.model.Booking;
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
import java.util.List;

@WebServlet(name = "MyBookingsServlet", urlPatterns = {"/customer/my-bookings"})
public class MyBookingsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(MyBookingsServlet.class);
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            List<Booking> bookings = bookingService.getBookingsByUser(currentUser.getId());
            req.setAttribute("bookings", bookings);

            if ("true".equals(req.getParameter("registered"))) {
                req.setAttribute("successMessage", "Welcome to AuraStay! Your account has been created.");
            }
        } catch (Exception e) {
            logger.error("Failed to load user bookings", e);
            req.setAttribute("errorMessage", "Unable to load reservation history.");
        }

        req.getRequestDispatcher("/WEB-INF/views/customer/my-bookings.jsp").forward(req, resp);
    }
}

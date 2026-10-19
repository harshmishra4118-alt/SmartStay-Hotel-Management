package com.hotel.servlet.customer;

import com.hotel.model.Booking;
import com.hotel.model.User;
import com.hotel.service.BookingService;
import com.hotel.service.FeedbackService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet(name = "CustomerFeedbackServlet", urlPatterns = {"/customer/feedback"})
public class FeedbackServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(FeedbackServlet.class);
    private final FeedbackService feedbackService = new FeedbackService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingRef = req.getParameter("bookingRef");
        if (bookingRef == null || bookingRef.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            Booking booking = bookingService.getBookingByReference(bookingRef.trim());
            if (booking == null || !booking.getUserId().equals(currentUser.getId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to reservation review.");
                return;
            }

            req.setAttribute("booking", booking);
            req.getRequestDispatcher("/WEB-INF/views/customer/feedback-form.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load feedback form", e);
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String bookingIdStr = req.getParameter("bookingId");
        String ratingStr = req.getParameter("rating");
        String cleanStr = req.getParameter("cleanliness");
        String serviceStr = req.getParameter("service");
        String amenitiesStr = req.getParameter("amenities");
        String comments = req.getParameter("comments");

        try {
            Long bookingId = Long.parseLong(bookingIdStr.trim());
            int rating = Integer.parseInt(ratingStr.trim());
            int cleanliness = Integer.parseInt(cleanStr.trim());
            int service = Integer.parseInt(serviceStr.trim());
            int amenities = Integer.parseInt(amenitiesStr.trim());

            Long feedbackId = feedbackService.submitFeedback(
                    bookingId,
                    currentUser.getId(),
                    rating,
                    cleanliness,
                    service,
                    amenities,
                    comments,
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings?reviewSuccess=true");

        } catch (IllegalArgumentException | IllegalStateException e) {
            req.setAttribute("errorMessage", e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            logger.error("Error submitting guest feedback", e);
            req.setAttribute("errorMessage", "Error submitting your feedback. Please try again.");
            doGet(req, resp);
        }
    }
}

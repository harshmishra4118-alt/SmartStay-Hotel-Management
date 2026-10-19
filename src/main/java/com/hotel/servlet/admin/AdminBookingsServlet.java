package com.hotel.servlet.admin;

import com.hotel.model.Booking;
import com.hotel.model.User;
import com.hotel.service.BookingService;
import com.hotel.util.DateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "AdminBookingsServlet", urlPatterns = {"/admin/bookings"})
public class AdminBookingsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminBookingsServlet.class);
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String statusStr = req.getParameter("status");
        String dateStr = req.getParameter("date");
        String search = req.getParameter("search");
        String pageStr = req.getParameter("page");

        Booking.BookingStatus status = null;
        if (statusStr != null && !statusStr.trim().isEmpty()) {
            try { status = Booking.BookingStatus.valueOf(statusStr.trim()); } catch (Exception ignored) {}
        }

        LocalDate date = DateUtil.parseDate(dateStr);

        int page = 1;
        int pageSize = 20;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { page = Math.max(1, Integer.parseInt(pageStr.trim())); } catch (Exception ignored) {}
        }
        int offset = (page - 1) * pageSize;

        try {
            List<Booking> bookings = bookingService.listAllBookings(status, date, search, offset, pageSize);
            int total = bookingService.countAllBookings(status, date, search);
            int totalPages = (int) Math.ceil((double) total / pageSize);

            req.setAttribute("bookings", bookings);
            req.setAttribute("totalCount", total);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("selectedStatus", statusStr);
            req.setAttribute("selectedDate", dateStr);
            req.setAttribute("search", search);
            req.setAttribute("allStatuses", Booking.BookingStatus.values());

            req.getRequestDispatcher("/WEB-INF/views/admin/bookings.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load admin bookings", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading bookings.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("currentUser");

        String action = req.getParameter("action");
        String bookingIdStr = req.getParameter("bookingId");

        try {
            Long bookingId = Long.parseLong(bookingIdStr.trim());
            if ("cancel".equals(action)) {
                String reason = req.getParameter("reason");
                bookingService.cancelReservation(
                        bookingId,
                        currentAdmin.getId(),
                        true,
                        reason != null ? reason : "Cancelled by administrator",
                        req.getRemoteAddr()
                );
                resp.sendRedirect(req.getContextPath() + "/admin/bookings?cancelled=true");
                return;
            }
        } catch (Exception e) {
            logger.error("Failed administrative action on booking", e);
            req.setAttribute("errorMessage", e.getMessage());
            doGet(req, resp);
        }
    }
}

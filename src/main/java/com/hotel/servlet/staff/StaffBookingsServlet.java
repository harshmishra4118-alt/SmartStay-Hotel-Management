package com.hotel.servlet.staff;

import com.hotel.model.Booking;
import com.hotel.service.BookingService;
import com.hotel.util.DateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "StaffBookingsServlet", urlPatterns = {"/staff/bookings"})
public class StaffBookingsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(StaffBookingsServlet.class);
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

            req.getRequestDispatcher("/WEB-INF/views/staff/bookings.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load staff bookings list", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading bookings.");
        }
    }
}

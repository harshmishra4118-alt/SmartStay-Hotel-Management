package com.hotel.servlet.admin;

import com.hotel.dao.ReportDAO;
import com.hotel.model.Booking;
import com.hotel.service.BookingService;
import com.hotel.service.ReportService;
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
import java.util.Map;

@WebServlet(name = "AdminReportsServlet", urlPatterns = {"/admin/reports", "/admin/reports/export-csv"})
public class AdminReportsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminReportsServlet.class);
    private final ReportService reportService = new ReportService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/admin/reports/export-csv".equals(servletPath)) {
            exportCsv(req, resp);
            return;
        }

        try {
            ReportDAO.DashboardMetrics metrics = reportService.getDashboardMetrics();
            Map<String, java.math.BigDecimal> monthlyRevenue = reportService.getMonthlyRevenueForYear(LocalDate.now().getYear());
            List<Booking> bookings = bookingService.listAllBookings(null, null, null, 0, 50);

            req.setAttribute("metrics", metrics);
            req.setAttribute("monthlyRevenue", monthlyRevenue);
            req.setAttribute("bookings", bookings);

            req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load reports", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading financial & occupancy reports.");
        }
    }

    private void exportCsv(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String statusStr = req.getParameter("status");
        String dateStr = req.getParameter("date");
        String search = req.getParameter("search");

        Booking.BookingStatus status = null;
        if (statusStr != null && !statusStr.trim().isEmpty()) {
            try { status = Booking.BookingStatus.valueOf(statusStr.trim()); } catch (Exception ignored) {}
        }
        LocalDate date = DateUtil.parseDate(dateStr);

        try {
            List<Booking> bookings = bookingService.listAllBookings(status, date, search, 0, 1000);
            String csvContent = reportService.exportBookingsToCsv(bookings);

            resp.setContentType("text/csv; charset=UTF-8");
            resp.setHeader("Content-Disposition", "attachment; filename=\"SmartStay_bookings_" + LocalDate.now() + ".csv\"");
            resp.getWriter().write(csvContent);

        } catch (Exception e) {
            logger.error("CSV Export failure", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating CSV export.");
        }
    }
}

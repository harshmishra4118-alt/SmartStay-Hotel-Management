package com.hotel.servlet.admin;

import com.hotel.dao.ReportDAO;
import com.hotel.model.AuditLog;
import com.hotel.model.Booking;
import com.hotel.service.BookingService;
import com.hotel.service.ReportService;
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

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminDashboardServlet.class);
    private final ReportService reportService = new ReportService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            ReportDAO.DashboardMetrics metrics = reportService.getDashboardMetrics();
            List<Booking> recentBookings = bookingService.listAllBookings(null, null, null, 0, 6);
            List<AuditLog> recentLogs = reportService.getRecentAuditLogs(8);
            Map<String, java.math.BigDecimal> monthlyRevenue = reportService.getMonthlyRevenueForYear(LocalDate.now().getYear());

            req.setAttribute("metrics", metrics);
            req.setAttribute("recentBookings", recentBookings);
            req.setAttribute("recentLogs", recentLogs);
            req.setAttribute("monthlyRevenue", monthlyRevenue);

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load admin dashboard", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading executive dashboard.");
        }
    }
}

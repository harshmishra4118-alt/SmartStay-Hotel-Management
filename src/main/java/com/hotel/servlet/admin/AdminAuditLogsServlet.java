package com.hotel.servlet.admin;

import com.hotel.model.AuditLog;
import com.hotel.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminAuditLogsServlet", urlPatterns = {"/admin/audit-logs"})
public class AdminAuditLogsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminAuditLogsServlet.class);
    private final ReportService reportService = new ReportService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<AuditLog> logs = reportService.getRecentAuditLogs(100);
            req.setAttribute("auditLogs", logs);

            req.getRequestDispatcher("/WEB-INF/views/admin/audit-logs.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load audit logs", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading security audit logs.");
        }
    }
}

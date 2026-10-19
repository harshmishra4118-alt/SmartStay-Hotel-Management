package com.hotel.servlet.admin;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.CustomerProfileDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.CustomerProfile;
import com.hotel.model.User;
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

@WebServlet(name = "AdminCustomersServlet", urlPatterns = {"/admin/customers"})
public class AdminCustomersServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminCustomersServlet.class);
    private final UserDAO userDAO = new UserDAO();
    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String viewId = req.getParameter("viewId");
        if (viewId != null && !viewId.trim().isEmpty()) {
            try {
                Long uid = Long.parseLong(viewId.trim());
                User user = userDAO.findById(uid);
                CustomerProfile profile = profileDAO.findByUserId(uid);
                req.setAttribute("customerUser", user);
                req.setAttribute("customerProfile", profile);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-detail.jsp").forward(req, resp);
                return;
            } catch (Exception e) {
                logger.error("Failed to view customer profile", e);
            }
        }

        String search = req.getParameter("search");
        String statusStr = req.getParameter("status");
        User.Status status = null;
        if (statusStr != null && !statusStr.trim().isEmpty()) {
            try { status = User.Status.valueOf(statusStr.trim()); } catch (Exception ignored) {}
        }

        int page = 1;
        int pageSize = 20;
        int offset = (page - 1) * pageSize;

        try {
            List<User> customers = userDAO.listAll(User.Role.CUSTOMER, status, search, offset, pageSize);
            int total = userDAO.countAll(User.Role.CUSTOMER, status, search);

            req.setAttribute("customers", customers);
            req.setAttribute("totalCount", total);
            req.setAttribute("search", search);
            req.setAttribute("selectedStatus", statusStr);
            req.setAttribute("allStatuses", User.Status.values());

            req.getRequestDispatcher("/WEB-INF/views/admin/customers.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Error loading customers", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading customers.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("currentUser");

        String customerIdStr = req.getParameter("customerId");
        String statusStr = req.getParameter("status");

        try {
            Long customerId = Long.parseLong(customerIdStr.trim());
            User.Status newStatus = User.Status.valueOf(statusStr.trim());

            userDAO.updateStatus(customerId, newStatus);
            auditLogDAO.log(currentAdmin.getId(), "CUSTOMER_STATUS_CHANGED", "User", String.valueOf(customerId),
                    "Status updated to: " + newStatus, req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/admin/customers?updated=true");

        } catch (Exception e) {
            logger.error("Failed to update customer status", e);
            req.setAttribute("errorMessage", "Error updating customer: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

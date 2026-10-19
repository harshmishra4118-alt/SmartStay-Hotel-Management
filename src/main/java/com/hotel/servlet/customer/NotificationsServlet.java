package com.hotel.servlet.customer;

import com.hotel.model.Notification;
import com.hotel.model.User;
import com.hotel.service.NotificationService;
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

@WebServlet(name = "CustomerNotificationsServlet", urlPatterns = {"/customer/notifications"})
public class NotificationsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(NotificationsServlet.class);
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String markReadId = req.getParameter("markRead");
        String markAll = req.getParameter("markAll");

        try {
            if ("true".equals(markAll)) {
                notificationService.markAllRead(currentUser.getId());
            } else if (markReadId != null && !markReadId.trim().isEmpty()) {
                notificationService.markRead(Long.parseLong(markReadId.trim()), currentUser.getId());
            }

            List<Notification> notifications = notificationService.getUserNotifications(currentUser.getId(), 50);
            req.setAttribute("notifications", notifications);

            req.getRequestDispatcher("/WEB-INF/views/customer/notifications.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Error loading notifications", e);
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }
}

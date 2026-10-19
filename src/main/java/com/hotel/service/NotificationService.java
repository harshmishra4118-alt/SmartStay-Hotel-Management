package com.hotel.service;

import com.hotel.dao.NotificationDAO;
import com.hotel.model.Notification;

import java.sql.SQLException;
import java.util.List;

public class NotificationService {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    public void createNotification(Long userId, String title, String message,
                                   Notification.NotificationType type, String link) throws SQLException {
        Notification n = new Notification(userId, title, message, type, link);
        notificationDAO.create(n);
    }

    public List<Notification> getUserNotifications(Long userId, int limit) throws SQLException {
        return notificationDAO.listAllByUser(userId, limit);
    }

    public void markRead(Long notificationId, Long userId) throws SQLException {
        notificationDAO.markAsRead(notificationId, userId);
    }

    public void markAllRead(Long userId) throws SQLException {
        notificationDAO.markAllAsRead(userId);
    }

    public int getUnreadCount(Long userId) throws SQLException {
        return notificationDAO.countUnread(userId);
    }
}

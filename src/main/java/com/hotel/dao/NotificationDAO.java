package com.hotel.dao;

import com.hotel.model.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO extends BaseDAO {

    public Long create(Notification n) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, title, message, notification_type, is_read, reference_link, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, n.getUserId());
            stmt.setString(2, n.getTitle());
            stmt.setString(3, n.getMessage());
            stmt.setString(4, n.getNotificationType().name());
            stmt.setBoolean(5, n.isRead());
            stmt.setString(6, n.getReferenceLink());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    n.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public List<Notification> listAllByUser(Long userId, int limit) throws SQLException {
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY id DESC LIMIT ?";
        List<Notification> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public boolean markAsRead(Long id, Long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            stmt.setLong(2, userId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean markAllAsRead(Long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        }
    }

    public int countUnread(Long userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getLong("id"));
        n.setUserId(rs.getLong("user_id"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setNotificationType(Notification.NotificationType.valueOf(rs.getString("notification_type")));
        n.setRead(rs.getBoolean("is_read"));
        n.setReferenceLink(rs.getString("reference_link"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) n.setCreatedAt(c.toLocalDateTime());

        return n;
    }
}

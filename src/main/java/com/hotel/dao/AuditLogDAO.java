package com.hotel.dao;

import com.hotel.model.AuditLog;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO extends BaseDAO {

    public void log(Long userId, String action, String entityType, String entityId, String details, String ipAddress) {
        String sql = "INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, ip_address, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (userId != null) stmt.setLong(1, userId); else stmt.setNull(1, Types.BIGINT);
            stmt.setString(2, action);
            stmt.setString(3, entityType);
            stmt.setString(4, entityId);
            stmt.setString(5, details);
            stmt.setString(6, ipAddress);

            stmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("Failed to write audit log for action '{}'", action, e);
        }
    }

    public List<AuditLog> listRecent(int limit) throws SQLException {
        String sql = "SELECT a.*, u.email AS user_email, u.role AS user_role " +
                     "FROM audit_logs a " +
                     "LEFT JOIN users u ON a.user_id = u.id " +
                     "ORDER BY a.id DESC LIMIT ?";
        List<AuditLog> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setId(rs.getLong("id"));
                    long uid = rs.getLong("user_id");
                    if (!rs.wasNull()) log.setUserId(uid);
                    log.setAction(rs.getString("action"));
                    log.setEntityType(rs.getString("entity_type"));
                    log.setEntityId(rs.getString("entity_id"));
                    log.setDetails(rs.getString("details"));
                    log.setIpAddress(rs.getString("ip_address"));

                    Timestamp c = rs.getTimestamp("created_at");
                    if (c != null) log.setCreatedAt(c.toLocalDateTime());

                    log.setUserEmail(rs.getString("user_email"));
                    log.setUserRole(rs.getString("user_role"));
                    list.add(log);
                }
            }
        }
        return list;
    }
}

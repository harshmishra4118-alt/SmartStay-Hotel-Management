package com.hotel.dao;

import com.hotel.model.Hotel;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HotelStaffAssignmentDAO extends BaseDAO {

    public Long getAssignedHotelId(Long userId) throws SQLException {
        String sql = "SELECT hotel_id FROM hotel_staff_assignments WHERE user_id = ? LIMIT 1";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("hotel_id");
                }
            }
        }
        return null;
    }

    public Hotel getAssignedHotel(Long userId) throws SQLException {
        Long hotelId = getAssignedHotelId(userId);
        if (hotelId != null) {
            HotelDAO hotelDAO = new HotelDAO();
            return hotelDAO.findById(hotelId);
        }
        return null;
    }

    public boolean assignStaff(Long hotelId, Long userId, String role) throws SQLException {
        String sql = "INSERT INTO hotel_staff_assignments (hotel_id, user_id, assigned_role, assigned_at) " +
                     "VALUES (?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE hotel_id = VALUES(hotel_id), assigned_role = VALUES(assigned_role)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, hotelId);
            stmt.setLong(2, userId);
            stmt.setString(3, role != null ? role : "STAFF");
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean removeAssignment(Long userId) throws SQLException {
        String sql = "DELETE FROM hotel_staff_assignments WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean isStaffAssignedToHotel(Long userId, Long hotelId) throws SQLException {
        if (hotelId == null) return false;
        String sql = "SELECT 1 FROM hotel_staff_assignments WHERE user_id = ? AND hotel_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setLong(2, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }
}


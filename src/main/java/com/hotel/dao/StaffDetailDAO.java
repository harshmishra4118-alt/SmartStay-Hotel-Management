package com.hotel.dao;

import com.hotel.model.StaffDetail;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDetailDAO extends BaseDAO {

    public StaffDetail findByUserId(Long userId) throws SQLException {
        String sql = "SELECT s.*, u.full_name, u.email, u.phone, hsa.hotel_id, h.name AS hotel_name " +
                     "FROM staff_details s " +
                     "JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN hotel_staff_assignments hsa ON s.user_id = hsa.user_id " +
                     "LEFT JOIN hotels h ON hsa.hotel_id = h.id " +
                     "WHERE s.user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<StaffDetail> listAllStaff() throws SQLException {
        String sql = "SELECT s.*, u.full_name, u.email, u.phone, hsa.hotel_id, h.name AS hotel_name " +
                     "FROM staff_details s " +
                     "JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN hotel_staff_assignments hsa ON s.user_id = hsa.user_id " +
                     "LEFT JOIN hotels h ON hsa.hotel_id = h.id " +
                     "ORDER BY s.id DESC";
        List<StaffDetail> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<StaffDetail> listStaffByHotel(Long hotelId) throws SQLException {
        if (hotelId == null) {
            return listAllStaff();
        }
        String sql = "SELECT s.*, u.full_name, u.email, u.phone, hsa.hotel_id, h.name AS hotel_name " +
                     "FROM staff_details s " +
                     "JOIN users u ON s.user_id = u.id " +
                     "JOIN hotel_staff_assignments hsa ON s.user_id = hsa.user_id " +
                     "JOIN hotels h ON hsa.hotel_id = h.id " +
                     "WHERE hsa.hotel_id = ? " +
                     "ORDER BY s.id DESC";
        List<StaffDetail> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public boolean saveOrUpdate(StaffDetail detail) throws SQLException {
        String sql = "INSERT INTO staff_details " +
                     "(user_id, employee_code, department, hire_date, shift, emergency_phone, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW()) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "employee_code = VALUES(employee_code), " +
                     "department = VALUES(department), " +
                     "hire_date = VALUES(hire_date), " +
                     "shift = VALUES(shift), " +
                     "emergency_phone = VALUES(emergency_phone), " +
                     "updated_at = NOW()";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, detail.getUserId());
            stmt.setString(2, detail.getEmployeeCode());
            stmt.setString(3, detail.getDepartment().name());
            stmt.setDate(4, detail.getHireDate() != null ? Date.valueOf(detail.getHireDate()) : null);
            stmt.setString(5, detail.getShift().name());
            stmt.setString(6, detail.getEmergencyPhone());

            return stmt.executeUpdate() > 0;
        }
    }

    private StaffDetail mapRow(ResultSet rs) throws SQLException {
        StaffDetail s = new StaffDetail();
        s.setId(rs.getLong("id"));
        s.setUserId(rs.getLong("user_id"));
        s.setEmployeeCode(rs.getString("employee_code"));
        s.setDepartment(StaffDetail.Department.valueOf(rs.getString("department")));
        Date d = rs.getDate("hire_date");
        if (d != null) s.setHireDate(d.toLocalDate());
        s.setShift(StaffDetail.Shift.valueOf(rs.getString("shift")));
        s.setEmergencyPhone(rs.getString("emergency_phone"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) s.setCreatedAt(c.toLocalDateTime());
        Timestamp u = rs.getTimestamp("updated_at");
        if (u != null) s.setUpdatedAt(u.toLocalDateTime());

        s.setUserFullName(rs.getString("full_name"));
        s.setUserEmail(rs.getString("email"));
        s.setUserPhone(rs.getString("phone"));

        try {
            long hId = rs.getLong("hotel_id");
            if (!rs.wasNull()) {
                s.setAssignedHotelId(hId);
            }
        } catch (SQLException ignored) {}

        try {
            s.setAssignedHotelName(rs.getString("hotel_name"));
        } catch (SQLException ignored) {}

        return s;
    }
}

package com.hotel.dao;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

public class ReportDAO extends BaseDAO {

    public static class DashboardMetrics {
        public int totalRooms;
        public int activeRooms;
        public int occupiedRoomsToday;
        public int availableRoomsToday;
        public int maintenanceRooms;
        public int totalBookings;
        public int confirmedBookings;
        public int checkedInBookings;
        public int cancelledBookings;
        public int todayArrivalsCount;
        public int todayDeparturesCount;
        public BigDecimal totalRevenue = BigDecimal.ZERO;
        public BigDecimal todayRevenue = BigDecimal.ZERO;
        public double occupancyRate = 0.0;
    }

    public DashboardMetrics getDashboardMetrics() throws SQLException {
        DashboardMetrics m = new DashboardMetrics();

        try (Connection conn = getConnection()) {
            // Total & Active & Maintenance Rooms
            String roomSql = "SELECT " +
                             "COUNT(*) AS total, " +
                             "SUM(CASE WHEN operational_status = 'ACTIVE' THEN 1 ELSE 0 END) AS active, " +
                             "SUM(CASE WHEN operational_status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS maintenance " +
                             "FROM rooms";
            try (Statement s = conn.createStatement(); ResultSet rs = s.executeQuery(roomSql)) {
                if (rs.next()) {
                    m.totalRooms = rs.getInt("total");
                    m.activeRooms = rs.getInt("active");
                    m.maintenanceRooms = rs.getInt("maintenance");
                }
            }

            // Occupied rooms today (Confirmed or CheckedIn spanning today)
            String occSql = "SELECT COUNT(DISTINCT room_id) FROM bookings " +
                            "WHERE booking_status IN ('CONFIRMED', 'CHECKED_IN') " +
                            "AND check_in_date <= CURDATE() AND check_out_date > CURDATE()";
            try (Statement s = conn.createStatement(); ResultSet rs = s.executeQuery(occSql)) {
                if (rs.next()) {
                    m.occupiedRoomsToday = rs.getInt(1);
                }
            }

            m.availableRoomsToday = Math.max(0, m.activeRooms - m.occupiedRoomsToday);
            if (m.activeRooms > 0) {
                m.occupancyRate = Math.round(((double) m.occupiedRoomsToday / m.activeRooms * 100.0) * 10.0) / 10.0;
            }

            // Bookings breakdown
            String bSql = "SELECT " +
                          "COUNT(*) AS total, " +
                          "SUM(CASE WHEN booking_status = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed, " +
                          "SUM(CASE WHEN booking_status = 'CHECKED_IN' THEN 1 ELSE 0 END) AS checked_in, " +
                          "SUM(CASE WHEN booking_status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled " +
                          "FROM bookings";
            try (Statement s = conn.createStatement(); ResultSet rs = s.executeQuery(bSql)) {
                if (rs.next()) {
                    m.totalBookings = rs.getInt("total");
                    m.confirmedBookings = rs.getInt("confirmed");
                    m.checkedInBookings = rs.getInt("checked_in");
                    m.cancelledBookings = rs.getInt("cancelled");
                }
            }

            // Arrivals & Departures today
            String arrSql = "SELECT COUNT(*) FROM bookings WHERE check_in_date = CURDATE() AND booking_status = 'CONFIRMED'";
            try (Statement s = conn.createStatement(); ResultSet rs = s.executeQuery(arrSql)) {
                if (rs.next()) m.todayArrivalsCount = rs.getInt(1);
            }

            String depSql = "SELECT COUNT(*) FROM bookings WHERE check_out_date = CURDATE() AND booking_status = 'CHECKED_IN'";
            try (Statement s = conn.createStatement(); ResultSet rs = s.executeQuery(depSql)) {
                if (rs.next()) m.todayDeparturesCount = rs.getInt(1);
            }

            // Revenue total and today
            String revSql = "SELECT " +
                            "COALESCE(SUM(amount), 0.00) AS total_rev, " +
                            "COALESCE(SUM(CASE WHEN DATE(paid_at) = CURDATE() THEN amount ELSE 0.00 END), 0.00) AS today_rev " +
                            "FROM payments WHERE payment_status = 'SUCCESS'";
            try (Statement s = conn.createStatement(); ResultSet rs = s.executeQuery(revSql)) {
                if (rs.next()) {
                    m.totalRevenue = rs.getBigDecimal("total_rev");
                    m.todayRevenue = rs.getBigDecimal("today_rev");
                }
            }
        }

        return m;
    }

    public Map<String, BigDecimal> getMonthlyRevenueForYear(int year) throws SQLException {
        Map<String, BigDecimal> map = new HashMap<>();
        String sql = "SELECT DATE_FORMAT(paid_at, '%Y-%m') AS month_str, SUM(amount) AS monthly_total " +
                     "FROM payments " +
                     "WHERE payment_status = 'SUCCESS' AND YEAR(paid_at) = ? " +
                     "GROUP BY month_str ORDER BY month_str ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, year);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("month_str"), rs.getBigDecimal("monthly_total"));
                }
            }
        }
        return map;
    }
}

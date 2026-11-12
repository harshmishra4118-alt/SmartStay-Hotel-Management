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

        public int getTotalRooms() { return totalRooms; }
        public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }

        public int getActiveRooms() { return activeRooms; }
        public void setActiveRooms(int activeRooms) { this.activeRooms = activeRooms; }

        public int getOccupiedRoomsToday() { return occupiedRoomsToday; }
        public void setOccupiedRoomsToday(int occupiedRoomsToday) { this.occupiedRoomsToday = occupiedRoomsToday; }

        public int getAvailableRoomsToday() { return availableRoomsToday; }
        public void setAvailableRoomsToday(int availableRoomsToday) { this.availableRoomsToday = availableRoomsToday; }

        public int getMaintenanceRooms() { return maintenanceRooms; }
        public void setMaintenanceRooms(int maintenanceRooms) { this.maintenanceRooms = maintenanceRooms; }

        public int getTotalBookings() { return totalBookings; }
        public void setTotalBookings(int totalBookings) { this.totalBookings = totalBookings; }

        public int getConfirmedBookings() { return confirmedBookings; }
        public void setConfirmedBookings(int confirmedBookings) { this.confirmedBookings = confirmedBookings; }

        public int getCheckedInBookings() { return checkedInBookings; }
        public void setCheckedInBookings(int checkedInBookings) { this.checkedInBookings = checkedInBookings; }

        public int getCancelledBookings() { return cancelledBookings; }
        public void setCancelledBookings(int cancelledBookings) { this.cancelledBookings = cancelledBookings; }

        public int getTodayArrivalsCount() { return todayArrivalsCount; }
        public void setTodayArrivalsCount(int todayArrivalsCount) { this.todayArrivalsCount = todayArrivalsCount; }

        public int getTodayDeparturesCount() { return todayDeparturesCount; }
        public void setTodayDeparturesCount(int todayDeparturesCount) { this.todayDeparturesCount = todayDeparturesCount; }

        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

        public BigDecimal getTodayRevenue() { return todayRevenue; }
        public void setTodayRevenue(BigDecimal todayRevenue) { this.todayRevenue = todayRevenue; }

        public double getOccupancyRate() { return occupancyRate; }
        public void setOccupancyRate(double occupancyRate) { this.occupancyRate = occupancyRate; }
    }

    public DashboardMetrics getDashboardMetrics() throws SQLException {
        return getDashboardMetrics(null);
    }

    public DashboardMetrics getDashboardMetrics(Long hotelId) throws SQLException {
        DashboardMetrics m = new DashboardMetrics();

        try (Connection conn = getConnection()) {
            // Rooms
            String roomSql = hotelId != null
                ? "SELECT COUNT(*) AS total, " +
                  "SUM(CASE WHEN operational_status = 'ACTIVE' THEN 1 ELSE 0 END) AS active, " +
                  "SUM(CASE WHEN operational_status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS maintenance " +
                  "FROM rooms WHERE hotel_id = ?"
                : "SELECT COUNT(*) AS total, " +
                  "SUM(CASE WHEN operational_status = 'ACTIVE' THEN 1 ELSE 0 END) AS active, " +
                  "SUM(CASE WHEN operational_status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS maintenance " +
                  "FROM rooms";
            try (PreparedStatement s = conn.prepareStatement(roomSql)) {
                if (hotelId != null) s.setLong(1, hotelId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) {
                        m.totalRooms = rs.getInt("total");
                        m.activeRooms = rs.getInt("active");
                        m.maintenanceRooms = rs.getInt("maintenance");
                    }
                }
            }

            // Occupied
            String occSql = hotelId != null
                ? "SELECT COUNT(DISTINCT room_id) FROM bookings " +
                  "WHERE hotel_id = ? AND booking_status IN ('CONFIRMED', 'CHECKED_IN') " +
                  "AND check_in_date <= CURDATE() AND check_out_date > CURDATE()"
                : "SELECT COUNT(DISTINCT room_id) FROM bookings " +
                  "WHERE booking_status IN ('CONFIRMED', 'CHECKED_IN') " +
                  "AND check_in_date <= CURDATE() AND check_out_date > CURDATE()";
            try (PreparedStatement s = conn.prepareStatement(occSql)) {
                if (hotelId != null) s.setLong(1, hotelId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) {
                        m.occupiedRoomsToday = rs.getInt(1);
                    }
                }
            }

            m.availableRoomsToday = Math.max(0, m.activeRooms - m.occupiedRoomsToday);
            if (m.activeRooms > 0) {
                m.occupancyRate = Math.round(((double) m.occupiedRoomsToday / m.activeRooms * 100.0) * 10.0) / 10.0;
            }

            // Bookings breakdown
            String bSql = hotelId != null
                ? "SELECT COUNT(*) AS total, " +
                  "SUM(CASE WHEN booking_status = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed, " +
                  "SUM(CASE WHEN booking_status = 'CHECKED_IN' THEN 1 ELSE 0 END) AS checked_in, " +
                  "SUM(CASE WHEN booking_status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled " +
                  "FROM bookings WHERE hotel_id = ?"
                : "SELECT COUNT(*) AS total, " +
                  "SUM(CASE WHEN booking_status = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed, " +
                  "SUM(CASE WHEN booking_status = 'CHECKED_IN' THEN 1 ELSE 0 END) AS checked_in, " +
                  "SUM(CASE WHEN booking_status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled " +
                  "FROM bookings";
            try (PreparedStatement s = conn.prepareStatement(bSql)) {
                if (hotelId != null) s.setLong(1, hotelId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) {
                        m.totalBookings = rs.getInt("total");
                        m.confirmedBookings = rs.getInt("confirmed");
                        m.checkedInBookings = rs.getInt("checked_in");
                        m.cancelledBookings = rs.getInt("cancelled");
                    }
                }
            }

            // Arrivals & departures
            String arrSql = hotelId != null
                ? "SELECT COUNT(*) FROM bookings WHERE hotel_id = ? AND check_in_date = CURDATE() AND booking_status = 'CONFIRMED'"
                : "SELECT COUNT(*) FROM bookings WHERE check_in_date = CURDATE() AND booking_status = 'CONFIRMED'";
            try (PreparedStatement s = conn.prepareStatement(arrSql)) {
                if (hotelId != null) s.setLong(1, hotelId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) m.todayArrivalsCount = rs.getInt(1);
                }
            }

            String depSql = hotelId != null
                ? "SELECT COUNT(*) FROM bookings WHERE hotel_id = ? AND check_out_date = CURDATE() AND booking_status = 'CHECKED_IN'"
                : "SELECT COUNT(*) FROM bookings WHERE check_out_date = CURDATE() AND booking_status = 'CHECKED_IN'";
            try (PreparedStatement s = conn.prepareStatement(depSql)) {
                if (hotelId != null) s.setLong(1, hotelId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) m.todayDeparturesCount = rs.getInt(1);
                }
            }

            // Revenue
            String revSql = hotelId != null
                ? "SELECT COALESCE(SUM(p.amount), 0.00) AS total_rev, " +
                  "COALESCE(SUM(CASE WHEN DATE(p.paid_at) = CURDATE() THEN p.amount ELSE 0.00 END), 0.00) AS today_rev " +
                  "FROM payments p JOIN bookings b ON p.booking_id = b.id " +
                  "WHERE b.hotel_id = ? AND p.payment_status = 'SUCCESS'"
                : "SELECT COALESCE(SUM(p.amount), 0.00) AS total_rev, " +
                  "COALESCE(SUM(CASE WHEN DATE(p.paid_at) = CURDATE() THEN p.amount ELSE 0.00 END), 0.00) AS today_rev " +
                  "FROM payments p WHERE p.payment_status = 'SUCCESS'";
            try (PreparedStatement s = conn.prepareStatement(revSql)) {
                if (hotelId != null) s.setLong(1, hotelId);
                try (ResultSet rs = s.executeQuery()) {
                    if (rs.next()) {
                        m.totalRevenue = rs.getBigDecimal("total_rev");
                        m.todayRevenue = rs.getBigDecimal("today_rev");
                    }
                }
            }
        }

        return m;
    }

    public Map<String, BigDecimal> getMonthlyRevenueForYear(int year) throws SQLException {
        return getMonthlyRevenueForYear(year, null);
    }

    public Map<String, BigDecimal> getMonthlyRevenueForYear(int year, Long hotelId) throws SQLException {
        Map<String, BigDecimal> map = new HashMap<>();
        String sql = hotelId != null
            ? "SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS month_str, SUM(p.amount) AS monthly_total " +
              "FROM payments p JOIN bookings b ON p.booking_id = b.id " +
              "WHERE b.hotel_id = ? AND p.payment_status = 'SUCCESS' AND YEAR(p.paid_at) = ? " +
              "GROUP BY month_str ORDER BY month_str ASC"
            : "SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS month_str, SUM(p.amount) AS monthly_total " +
              "FROM payments p " +
              "WHERE p.payment_status = 'SUCCESS' AND YEAR(p.paid_at) = ? " +
              "GROUP BY month_str ORDER BY month_str ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (hotelId != null) {
                stmt.setLong(1, hotelId);
                stmt.setInt(2, year);
            } else {
                stmt.setInt(1, year);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("month_str"), rs.getBigDecimal("monthly_total"));
                }
            }
        }
        return map;
    }
}

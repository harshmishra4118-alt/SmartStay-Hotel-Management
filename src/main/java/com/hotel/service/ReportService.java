package com.hotel.service;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.ReportDAO;
import com.hotel.model.AuditLog;
import com.hotel.model.Booking;
import com.hotel.util.DateUtil;
import com.hotel.util.ValidationUtil;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ReportService {

    private final ReportDAO reportDAO = new ReportDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public ReportDAO.DashboardMetrics getDashboardMetrics() throws SQLException {
        return reportDAO.getDashboardMetrics(null);
    }

    public ReportDAO.DashboardMetrics getDashboardMetrics(Long hotelId) throws SQLException {
        return reportDAO.getDashboardMetrics(hotelId);
    }

    public List<AuditLog> getRecentAuditLogs(int limit) throws SQLException {
        return auditLogDAO.listRecent(limit);
    }

    public Map<String, java.math.BigDecimal> getMonthlyRevenueForYear(int year) throws SQLException {
        return reportDAO.getMonthlyRevenueForYear(year, null);
    }

    public Map<String, java.math.BigDecimal> getMonthlyRevenueForYear(int year, Long hotelId) throws SQLException {
        return reportDAO.getMonthlyRevenueForYear(year, hotelId);
    }

    /**
     * Generates CSV export protected against CSV spreadsheet formula injection.
     */
    public String exportBookingsToCsv(List<Booking> bookings) {
        StringBuilder sb = new StringBuilder();
        // CSV Header
        sb.append(ValidationUtil.escapeForCsv("Booking Reference")).append(",")
          .append(ValidationUtil.escapeForCsv("Guest Name")).append(",")
          .append(ValidationUtil.escapeForCsv("Guest Email")).append(",")
          .append(ValidationUtil.escapeForCsv("Guest Phone")).append(",")
          .append(ValidationUtil.escapeForCsv("Room Number")).append(",")
          .append(ValidationUtil.escapeForCsv("Room Name")).append(",")
          .append(ValidationUtil.escapeForCsv("Nights")).append(",")
          .append(ValidationUtil.escapeForCsv("Check-In Date")).append(",")
          .append(ValidationUtil.escapeForCsv("Check-Out Date")).append(",")
          .append(ValidationUtil.escapeForCsv("Total Amount (INR)")).append(",")
          .append(ValidationUtil.escapeForCsv("Booking Status")).append(",")
          .append(ValidationUtil.escapeForCsv("Payment Status")).append(",")
          .append(ValidationUtil.escapeForCsv("Created Date"))
          .append("\r\n");

        if (bookings != null) {
            for (Booking b : bookings) {
                sb.append(ValidationUtil.escapeForCsv(b.getBookingReference())).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getGuestName())).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getGuestEmail())).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getGuestPhone())).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getRoomNumber())).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getRoomName())).append(",")
                  .append(ValidationUtil.escapeForCsv(String.valueOf(b.getTotalNights()))).append(",")
                  .append(ValidationUtil.escapeForCsv(DateUtil.formatDate(b.getCheckInDate()))).append(",")
                  .append(ValidationUtil.escapeForCsv(DateUtil.formatDate(b.getCheckOutDate()))).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getTotalAmount() != null ? b.getTotalAmount().toPlainString() : "0.00")).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getBookingStatus() != null ? b.getBookingStatus().name() : "")).append(",")
                  .append(ValidationUtil.escapeForCsv(b.getPaymentStatus() != null ? b.getPaymentStatus().name() : "UNPAID")).append(",")
                  .append(ValidationUtil.escapeForCsv(DateUtil.formatDisplayDateTime(b.getCreatedAt())))
                  .append("\r\n");
            }
        }

        return sb.toString();
    }
}

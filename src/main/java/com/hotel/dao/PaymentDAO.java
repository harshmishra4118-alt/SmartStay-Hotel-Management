package com.hotel.dao;

import com.hotel.model.Payment;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO extends BaseDAO {

    public Long create(Payment payment, Connection conn) throws SQLException {
        String sql = "INSERT INTO payments " +
                     "(payment_reference, invoice_id, booking_id, amount, payment_method, payment_status, " +
                     "transaction_notes, is_demo, paid_at, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, payment.getPaymentReference());
            stmt.setLong(2, payment.getInvoiceId());
            stmt.setLong(3, payment.getBookingId());
            stmt.setBigDecimal(4, payment.getAmount());
            stmt.setString(5, payment.getPaymentMethod().name());
            stmt.setString(6, payment.getPaymentStatus().name());
            stmt.setString(7, payment.getTransactionNotes());
            stmt.setBoolean(8, payment.isDemo());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    payment.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public List<Payment> findByInvoiceId(Long invoiceId) throws SQLException {
        String sql = "SELECT * FROM payments WHERE invoice_id = ? ORDER BY id DESC";
        List<Payment> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, invoiceId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Payment> findByBookingId(Long bookingId) throws SQLException {
        String sql = "SELECT * FROM payments WHERE booking_id = ? ORDER BY id DESC";
        List<Payment> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public BigDecimal getTotalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0.00) FROM payments WHERE payment_status = 'SUCCESS'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        }
        return BigDecimal.ZERO;
    }

    public List<Payment> getRecentPayments(int limit) throws SQLException {
        String sql = "SELECT p.*, i.invoice_number, b.booking_reference " +
                     "FROM payments p " +
                     "JOIN invoices i ON p.invoice_id = i.id " +
                     "JOIN bookings b ON p.booking_id = b.id " +
                     "ORDER BY p.id DESC LIMIT ?";
        List<Payment> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Payment p = mapRow(rs);
                    p.setInvoiceNumber(rs.getString("invoice_number"));
                    p.setBookingReference(rs.getString("booking_reference"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setId(rs.getLong("id"));
        p.setPaymentReference(rs.getString("payment_reference"));
        p.setInvoiceId(rs.getLong("invoice_id"));
        p.setBookingId(rs.getLong("booking_id"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setPaymentMethod(Payment.PaymentMethod.valueOf(rs.getString("payment_method")));
        p.setPaymentStatus(Payment.RecordStatus.valueOf(rs.getString("payment_status")));
        p.setTransactionNotes(rs.getString("transaction_notes"));
        p.setDemo(rs.getBoolean("is_demo"));

        Timestamp paid = rs.getTimestamp("paid_at");
        if (paid != null) p.setPaidAt(paid.toLocalDateTime());
        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) p.setCreatedAt(c.toLocalDateTime());

        return p;
    }
}

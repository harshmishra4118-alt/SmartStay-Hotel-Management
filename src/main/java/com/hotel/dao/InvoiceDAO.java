package com.hotel.dao;

import com.hotel.model.Invoice;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InvoiceDAO extends BaseDAO {

    public Long create(Invoice invoice, Connection conn) throws SQLException {
        String sql = "INSERT INTO invoices " +
                     "(invoice_number, booking_id, user_id, issue_date, subtotal_amount, tax_rate, tax_amount, " +
                     "discount_amount, total_payable, payment_status, notes, created_at, updated_at) " +
                     "VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, invoice.getInvoiceNumber());
            stmt.setLong(2, invoice.getBookingId());
            stmt.setLong(3, invoice.getUserId());
            stmt.setBigDecimal(4, invoice.getSubtotalAmount());
            stmt.setBigDecimal(5, invoice.getTaxRate());
            stmt.setBigDecimal(6, invoice.getTaxAmount());
            stmt.setBigDecimal(7, invoice.getDiscountAmount());
            stmt.setBigDecimal(8, invoice.getTotalPayable());
            stmt.setString(9, invoice.getPaymentStatus().name());
            stmt.setString(10, invoice.getNotes());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    invoice.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public Invoice findById(Long id) throws SQLException {
        String sql = getJoinedInvoiceSql() + "WHERE i.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public Invoice findByBookingId(Long bookingId) throws SQLException {
        String sql = getJoinedInvoiceSql() + "WHERE i.booking_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public Invoice findByInvoiceNumber(String invoiceNumber) throws SQLException {
        String sql = getJoinedInvoiceSql() + "WHERE i.invoice_number = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, invoiceNumber.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public boolean updatePaymentStatus(Long id, Invoice.PaymentStatus status, Connection conn) throws SQLException {
        String sql = "UPDATE invoices SET payment_status = ?, updated_at = NOW() WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Invoice> listInvoices(Invoice.PaymentStatus statusFilter, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(getJoinedInvoiceSql());
        List<Object> params = new ArrayList<>();

        if (statusFilter != null) {
            sql.append("WHERE i.payment_status = ? ");
            params.add(statusFilter.name());
        }

        sql.append("ORDER BY i.id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Invoice> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    private String getJoinedInvoiceSql() {
        return "SELECT i.*, b.booking_reference, b.guest_name AS customer_name, " +
               "u.email AS customer_email, r.room_number " +
               "FROM invoices i " +
               "JOIN bookings b ON i.booking_id = b.id " +
               "JOIN users u ON i.user_id = u.id " +
               "JOIN rooms r ON b.room_id = r.id ";
    }

    private Invoice mapRow(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setId(rs.getLong("id"));
        inv.setInvoiceNumber(rs.getString("invoice_number"));
        inv.setBookingId(rs.getLong("booking_id"));
        inv.setUserId(rs.getLong("user_id"));

        Timestamp issue = rs.getTimestamp("issue_date");
        if (issue != null) inv.setIssueDate(issue.toLocalDateTime());

        inv.setSubtotalAmount(rs.getBigDecimal("subtotal_amount"));
        inv.setTaxRate(rs.getBigDecimal("tax_rate"));
        inv.setTaxAmount(rs.getBigDecimal("tax_amount"));
        inv.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        inv.setTotalPayable(rs.getBigDecimal("total_payable"));
        inv.setPaymentStatus(Invoice.PaymentStatus.valueOf(rs.getString("payment_status")));
        inv.setNotes(rs.getString("notes"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) inv.setCreatedAt(c.toLocalDateTime());
        Timestamp u = rs.getTimestamp("updated_at");
        if (u != null) inv.setUpdatedAt(u.toLocalDateTime());

        inv.setBookingReference(rs.getString("booking_reference"));
        inv.setCustomerName(rs.getString("customer_name"));
        inv.setCustomerEmail(rs.getString("customer_email"));
        inv.setRoomNumber(rs.getString("room_number"));

        return inv;
    }
}

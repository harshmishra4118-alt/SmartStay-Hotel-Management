package com.hotel.dao;

import com.hotel.model.PaymentTransaction;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentTransactionDAO extends BaseDAO {

    public Long create(PaymentTransaction tx) throws SQLException {
        String sql = "INSERT INTO payment_transactions (booking_id, transaction_reference, gateway_order_id, " +
                     "gateway_payment_id, gateway_signature, amount, currency, status, payment_method, " +
                     "refund_id, refund_amount, error_description, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, tx.getBookingId());
            stmt.setString(2, tx.getTransactionReference());
            stmt.setString(3, tx.getGatewayOrderId());
            stmt.setString(4, tx.getGatewayPaymentId());
            stmt.setString(5, tx.getGatewaySignature());
            stmt.setBigDecimal(6, tx.getAmount());
            stmt.setString(7, tx.getCurrency() != null ? tx.getCurrency() : "INR");
            stmt.setString(8, tx.getStatus().name());
            stmt.setString(9, tx.getPaymentMethod() != null ? tx.getPaymentMethod() : "RAZORPAY");
            stmt.setString(10, tx.getRefundId());
            stmt.setBigDecimal(11, tx.getRefundAmount() != null ? tx.getRefundAmount() : BigDecimal.ZERO);
            stmt.setString(12, tx.getErrorDescription());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    tx.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public boolean update(PaymentTransaction tx) throws SQLException {
        String sql = "UPDATE payment_transactions SET gateway_order_id = ?, gateway_payment_id = ?, " +
                     "gateway_signature = ?, amount = ?, status = ?, payment_method = ?, refund_id = ?, " +
                     "refund_amount = ?, error_description = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, tx.getGatewayOrderId());
            stmt.setString(2, tx.getGatewayPaymentId());
            stmt.setString(3, tx.getGatewaySignature());
            stmt.setBigDecimal(4, tx.getAmount());
            stmt.setString(5, tx.getStatus().name());
            stmt.setString(6, tx.getPaymentMethod());
            stmt.setString(7, tx.getRefundId());
            stmt.setBigDecimal(8, tx.getRefundAmount());
            stmt.setString(9, tx.getErrorDescription());
            stmt.setLong(10, tx.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    public PaymentTransaction findByReference(String ref) throws SQLException {
        String sql = "SELECT * FROM payment_transactions WHERE transaction_reference = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ref);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public PaymentTransaction findByOrderId(String orderId) throws SQLException {
        String sql = "SELECT * FROM payment_transactions WHERE gateway_order_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<PaymentTransaction> findByBookingId(Long bookingId) throws SQLException {
        String sql = "SELECT * FROM payment_transactions WHERE booking_id = ? ORDER BY created_at DESC";
        List<PaymentTransaction> list = new ArrayList<>();
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

    public List<PaymentTransaction> findAll() throws SQLException {
        String sql = "SELECT * FROM payment_transactions ORDER BY created_at DESC";
        List<PaymentTransaction> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    private PaymentTransaction mapRow(ResultSet rs) throws SQLException {
        PaymentTransaction tx = new PaymentTransaction();
        tx.setId(rs.getLong("id"));
        tx.setBookingId(rs.getLong("booking_id"));
        tx.setTransactionReference(rs.getString("transaction_reference"));
        tx.setGatewayOrderId(rs.getString("gateway_order_id"));
        tx.setGatewayPaymentId(rs.getString("gateway_payment_id"));
        tx.setGatewaySignature(rs.getString("gateway_signature"));
        tx.setAmount(rs.getBigDecimal("amount"));
        tx.setCurrency(rs.getString("currency"));
        try {
            tx.setStatus(PaymentTransaction.Status.valueOf(rs.getString("status")));
        } catch (Exception e) {
            tx.setStatus(PaymentTransaction.Status.PENDING);
        }
        tx.setPaymentMethod(rs.getString("payment_method"));
        tx.setRefundId(rs.getString("refund_id"));
        tx.setRefundAmount(rs.getBigDecimal("refund_amount"));
        tx.setErrorDescription(rs.getString("error_description"));

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) tx.setCreatedAt(cat.toLocalDateTime());
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) tx.setUpdatedAt(uat.toLocalDateTime());

        return tx;
    }
}


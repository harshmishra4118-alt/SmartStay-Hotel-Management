package com.hotel.dao;

import com.hotel.model.OtpVerification;

import java.sql.*;
import java.time.LocalDateTime;

public class OtpVerificationDAO extends BaseDAO {

    public Long create(OtpVerification otp) throws SQLException {
        String sql = "INSERT INTO otp_verifications (email, otp_hash, otp_type, attempts, resend_count, " +
                     "is_used, expires_at, last_sent_at, user_metadata, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, otp.getEmail().trim().toLowerCase());
            stmt.setString(2, otp.getOtpHash());
            stmt.setString(3, otp.getOtpType().name());
            stmt.setInt(4, otp.getAttempts());
            stmt.setInt(5, otp.getResendCount());
            stmt.setBoolean(6, otp.isUsed());
            stmt.setTimestamp(7, Timestamp.valueOf(otp.getExpiresAt()));
            stmt.setTimestamp(8, Timestamp.valueOf(otp.getLastSentAt()));
            stmt.setString(9, otp.getUserMetadata());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    otp.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public OtpVerification findLatestActive(String email, OtpVerification.OtpType type) throws SQLException {
        String sql = "SELECT * FROM otp_verifications " +
                     "WHERE email = ? AND otp_type = ? AND is_used = FALSE AND expires_at > NOW() " +
                     "ORDER BY created_at DESC LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email.trim().toLowerCase());
            stmt.setString(2, type.name());

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public boolean incrementAttempts(Long id) throws SQLException {
        String sql = "UPDATE otp_verifications SET attempts = attempts + 1 WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean incrementResendCount(Long id, LocalDateTime newExpiresAt) throws SQLException {
        String sql = "UPDATE otp_verifications SET resend_count = resend_count + 1, last_sent_at = NOW(), expires_at = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, Timestamp.valueOf(newExpiresAt));
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean markUsed(Long id) throws SQLException {
        String sql = "UPDATE otp_verifications SET is_used = TRUE WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean invalidatePrior(String email, OtpVerification.OtpType type) throws SQLException {
        String sql = "UPDATE otp_verifications SET is_used = TRUE WHERE email = ? AND otp_type = ? AND is_used = FALSE";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email.trim().toLowerCase());
            stmt.setString(2, type.name());
            return stmt.executeUpdate() >= 0;
        }
    }

    public int countRecentRequests(String email, int minutesAgo) throws SQLException {
        String sql = "SELECT COUNT(*) FROM otp_verifications WHERE email = ? AND created_at >= (NOW() - INTERVAL ? MINUTE)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email.trim().toLowerCase());
            stmt.setInt(2, minutesAgo);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private OtpVerification mapRow(ResultSet rs) throws SQLException {
        OtpVerification otp = new OtpVerification();
        otp.setId(rs.getLong("id"));
        otp.setEmail(rs.getString("email"));
        otp.setOtpHash(rs.getString("otp_hash"));
        try {
            otp.setOtpType(OtpVerification.OtpType.valueOf(rs.getString("otp_type")));
        } catch (Exception e) {
            otp.setOtpType(OtpVerification.OtpType.LOGIN);
        }
        otp.setAttempts(rs.getInt("attempts"));
        otp.setResendCount(rs.getInt("resend_count"));
        otp.setUsed(rs.getBoolean("is_used"));

        Timestamp exp = rs.getTimestamp("expires_at");
        if (exp != null) otp.setExpiresAt(exp.toLocalDateTime());

        Timestamp ls = rs.getTimestamp("last_sent_at");
        if (ls != null) otp.setLastSentAt(ls.toLocalDateTime());

        otp.setUserMetadata(rs.getString("user_metadata"));

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) otp.setCreatedAt(cat.toLocalDateTime());

        return otp;
    }
}


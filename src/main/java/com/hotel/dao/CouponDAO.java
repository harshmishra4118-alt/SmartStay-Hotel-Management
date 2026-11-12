package com.hotel.dao;

import com.hotel.model.Coupon;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CouponDAO extends BaseDAO {

    public Coupon findByCode(String code) throws SQLException {
        if (code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT * FROM coupons WHERE UPPER(code) = UPPER(?) AND is_active = TRUE";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, code.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public boolean incrementUsage(Long couponId) throws SQLException {
        String sql = "UPDATE coupons SET used_count = used_count + 1 WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, couponId);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Coupon> findAll() throws SQLException {
        String sql = "SELECT * FROM coupons ORDER BY is_active DESC, valid_to DESC";
        List<Coupon> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public Long create(Coupon coupon) throws SQLException {
        String sql = "INSERT INTO coupons (code, description, discount_type, discount_value, min_booking_amount, " +
                     "max_discount_amount, valid_from, valid_to, usage_limit, used_count, is_active, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, coupon.getCode().trim().toUpperCase());
            stmt.setString(2, coupon.getDescription());
            stmt.setString(3, coupon.getDiscountType().name());
            stmt.setBigDecimal(4, coupon.getDiscountValue());
            stmt.setBigDecimal(5, coupon.getMinBookingAmount());
            stmt.setBigDecimal(6, coupon.getMaxDiscountAmount());
            stmt.setDate(7, Date.valueOf(coupon.getValidFrom()));
            stmt.setDate(8, Date.valueOf(coupon.getValidTo()));
            stmt.setInt(9, coupon.getUsageLimit());
            stmt.setInt(10, coupon.getUsedCount());
            stmt.setBoolean(11, coupon.isActive());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    coupon.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public boolean update(Coupon coupon) throws SQLException {
        String sql = "UPDATE coupons SET code = ?, description = ?, discount_type = ?, discount_value = ?, " +
                     "min_booking_amount = ?, max_discount_amount = ?, valid_from = ?, valid_to = ?, " +
                     "usage_limit = ?, is_active = ? WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, coupon.getCode().trim().toUpperCase());
            stmt.setString(2, coupon.getDescription());
            stmt.setString(3, coupon.getDiscountType().name());
            stmt.setBigDecimal(4, coupon.getDiscountValue());
            stmt.setBigDecimal(5, coupon.getMinBookingAmount());
            stmt.setBigDecimal(6, coupon.getMaxDiscountAmount());
            stmt.setDate(7, Date.valueOf(coupon.getValidFrom()));
            stmt.setDate(8, Date.valueOf(coupon.getValidTo()));
            stmt.setInt(9, coupon.getUsageLimit());
            stmt.setBoolean(10, coupon.isActive());
            stmt.setLong(11, coupon.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM coupons WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    private Coupon mapRow(ResultSet rs) throws SQLException {
        Coupon c = new Coupon();
        c.setId(rs.getLong("id"));
        c.setCode(rs.getString("code"));
        c.setDescription(rs.getString("description"));
        try {
            c.setDiscountType(Coupon.DiscountType.valueOf(rs.getString("discount_type")));
        } catch (Exception e) {
            c.setDiscountType(Coupon.DiscountType.PERCENTAGE);
        }
        c.setDiscountValue(rs.getBigDecimal("discount_value"));
        c.setMinBookingAmount(rs.getBigDecimal("min_booking_amount"));
        c.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));

        Date vf = rs.getDate("valid_from");
        if (vf != null) c.setValidFrom(vf.toLocalDate());
        Date vt = rs.getDate("valid_to");
        if (vt != null) c.setValidTo(vt.toLocalDate());

        c.setUsageLimit(rs.getInt("usage_limit"));
        c.setUsedCount(rs.getInt("used_count"));
        c.setActive(rs.getBoolean("is_active"));

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) c.setCreatedAt(cat.toLocalDateTime());

        return c;
    }
}


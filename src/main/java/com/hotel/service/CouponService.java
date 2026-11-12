package com.hotel.service;

import com.hotel.dao.CouponDAO;
import com.hotel.model.Coupon;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class CouponService {

    private static final Logger logger = LoggerFactory.getLogger(CouponService.class);
    private final CouponDAO couponDAO = new CouponDAO();

    public static class CouponValidationResult {
        private final boolean valid;
        private final String message;
        private final Coupon coupon;
        private final BigDecimal discountAmount;

        public CouponValidationResult(boolean valid, String message, Coupon coupon, BigDecimal discountAmount) {
            this.valid = valid;
            this.message = message;
            this.coupon = coupon;
            this.discountAmount = discountAmount;
        }

        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
        public Coupon getCoupon() { return coupon; }
        public BigDecimal getDiscountAmount() { return discountAmount; }
    }

    public CouponValidationResult validateCoupon(String code, BigDecimal bookingAmount) {
        if (code == null || code.trim().isEmpty()) {
            return new CouponValidationResult(false, "Please enter a coupon code.", null, BigDecimal.ZERO);
        }

        try {
            Coupon coupon = couponDAO.findByCode(code.trim());
            if (coupon == null) {
                return new CouponValidationResult(false, "Invalid coupon code. Please check and try again.", null, BigDecimal.ZERO);
            }

            if (!coupon.isActive()) {
                return new CouponValidationResult(false, "This coupon is currently inactive.", null, BigDecimal.ZERO);
            }

            LocalDate today = LocalDate.now();
            if (coupon.getValidFrom() != null && today.isBefore(coupon.getValidFrom())) {
                return new CouponValidationResult(false, "This coupon is not valid yet.", null, BigDecimal.ZERO);
            }

            if (coupon.getValidTo() != null && today.isAfter(coupon.getValidTo())) {
                return new CouponValidationResult(false, "This coupon has expired.", null, BigDecimal.ZERO);
            }

            if (coupon.getUsageLimit() > 0 && coupon.getUsedCount() >= coupon.getUsageLimit()) {
                return new CouponValidationResult(false, "This promotional offer has reached its maximum usage limit.", null, BigDecimal.ZERO);
            }

            if (coupon.getMinBookingAmount() != null && bookingAmount != null && bookingAmount.compareTo(coupon.getMinBookingAmount()) < 0) {
                return new CouponValidationResult(
                    false,
                    "This coupon requires a minimum booking amount of Rs " + coupon.getMinBookingAmount(),
                    null,
                    BigDecimal.ZERO
                );
            }

            BigDecimal discount = coupon.calculateDiscount(bookingAmount);
            return new CouponValidationResult(true, "Coupon applied successfully! You saved Rs " + discount, coupon, discount);

        } catch (SQLException e) {
            logger.error("Error validating coupon: {}", code, e);
            return new CouponValidationResult(false, "Error verifying coupon. Please try again.", null, BigDecimal.ZERO);
        }
    }

    public void applyCouponUsage(Long couponId) {
        if (couponId == null) return;
        try {
            couponDAO.incrementUsage(couponId);
        } catch (SQLException e) {
            logger.error("Error incrementing usage for coupon ID: {}", couponId, e);
        }
    }

    public List<Coupon> getAllCoupons() throws SQLException {
        return couponDAO.findAll();
    }

    public Long createCoupon(Coupon coupon) throws SQLException {
        return couponDAO.create(coupon);
    }

    public boolean updateCoupon(Coupon coupon) throws SQLException {
        return couponDAO.update(coupon);
    }

    public boolean deleteCoupon(Long id) throws SQLException {
        return couponDAO.delete(id);
    }
}


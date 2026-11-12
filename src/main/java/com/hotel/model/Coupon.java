package com.hotel.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Coupon implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum DiscountType {
        PERCENTAGE("Percentage"),
        FIXED_AMOUNT("Fixed Amount");

        private final String displayName;

        DiscountType(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private String code;
    private String description;
    private DiscountType discountType;
    private BigDecimal discountValue;
    private BigDecimal minBookingAmount;
    private BigDecimal maxDiscountAmount;
    private LocalDate validFrom;
    private LocalDate validTo;
    private int usageLimit;
    private int usedCount;
    private boolean isActive;
    private LocalDateTime createdAt;

    public Coupon() {
        this.discountType = DiscountType.PERCENTAGE;
        this.minBookingAmount = BigDecimal.ZERO;
        this.maxDiscountAmount = new BigDecimal("5000.00");
        this.usageLimit = 1000;
        this.usedCount = 0;
        this.isActive = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public DiscountType getDiscountType() { return discountType; }
    public void setDiscountType(DiscountType discountType) { this.discountType = discountType; }

    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }

    public BigDecimal getMinBookingAmount() { return minBookingAmount; }
    public void setMinBookingAmount(BigDecimal minBookingAmount) { this.minBookingAmount = minBookingAmount; }

    public BigDecimal getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }

    public LocalDate getValidFrom() { return validFrom; }
    public void setValidFrom(LocalDate validFrom) { this.validFrom = validFrom; }

    public LocalDate getValidTo() { return validTo; }
    public void setValidTo(LocalDate validTo) { this.validTo = validTo; }

    public int getUsageLimit() { return usageLimit; }
    public void setUsageLimit(int usageLimit) { this.usageLimit = usageLimit; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isValidForAmount(BigDecimal bookingAmount) {
        if (!isActive) return false;
        LocalDate today = LocalDate.now();
        if (validFrom != null && today.isBefore(validFrom)) return false;
        if (validTo != null && today.isAfter(validTo)) return false;
        if (usageLimit > 0 && usedCount >= usageLimit) return false;
        if (minBookingAmount != null && bookingAmount != null && bookingAmount.compareTo(minBookingAmount) < 0) return false;
        return true;
    }

    public BigDecimal calculateDiscount(BigDecimal baseAmount) {
        if (baseAmount == null || baseAmount.compareTo(BigDecimal.ZERO) <= 0) return BigDecimal.ZERO;
        BigDecimal discount;
        if (discountType == DiscountType.PERCENTAGE) {
            discount = baseAmount.multiply(discountValue).divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);
            if (maxDiscountAmount != null && discount.compareTo(maxDiscountAmount) > 0) {
                discount = maxDiscountAmount;
            }
        } else {
            discount = discountValue;
            if (discount.compareTo(baseAmount) > 0) {
                discount = baseAmount;
            }
        }
        return discount;
    }
}


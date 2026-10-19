package com.hotel.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Booking implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum BookingStatus {
        PENDING("Pending"),
        CONFIRMED("Confirmed"),
        CHECKED_IN("Checked In"),
        CHECKED_OUT("Checked Out"),
        CANCELLED("Cancelled");

        private final String displayName;

        BookingStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private String bookingReference;
    private Long userId;
    private Long roomId;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private int totalNights;
    private int numGuests;
    private String guestName;
    private String guestEmail;
    private String guestPhone;
    private BigDecimal roomPricePerNight;
    private BigDecimal baseAmount;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    private BookingStatus bookingStatus;
    private String specialRequests;
    private String cancellationReason;
    private LocalDateTime cancelledAt;
    private LocalDateTime checkedInAt;
    private LocalDateTime checkedOutAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Joined room/payment fields for convenient display in views
    private String roomNumber;
    private String roomName;
    private Room.RoomType roomType;
    private String roomPrimaryImageUrl;
    private String customerEmail;
    private Invoice.PaymentStatus paymentStatus;

    public Booking() {
        this.bookingStatus = BookingStatus.CONFIRMED;
        this.roomPricePerNight = BigDecimal.ZERO;
        this.baseAmount = BigDecimal.ZERO;
        this.taxAmount = BigDecimal.ZERO;
        this.totalAmount = BigDecimal.ZERO;
        this.numGuests = 1;
        this.totalNights = 1;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }

    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }

    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }

    public int getTotalNights() { return totalNights; }
    public void setTotalNights(int totalNights) { this.totalNights = totalNights; }

    public int getNumGuests() { return numGuests; }
    public void setNumGuests(int numGuests) { this.numGuests = numGuests; }

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }

    public String getGuestPhone() { return guestPhone; }
    public void setGuestPhone(String guestPhone) { this.guestPhone = guestPhone; }

    public BigDecimal getRoomPricePerNight() { return roomPricePerNight; }
    public void setRoomPricePerNight(BigDecimal roomPricePerNight) { this.roomPricePerNight = roomPricePerNight; }

    public BigDecimal getBaseAmount() { return baseAmount; }
    public void setBaseAmount(BigDecimal baseAmount) { this.baseAmount = baseAmount; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BookingStatus getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(BookingStatus bookingStatus) { this.bookingStatus = bookingStatus; }

    public String getSpecialRequests() { return specialRequests; }
    public void setSpecialRequests(String specialRequests) { this.specialRequests = specialRequests; }

    public String getCancellationReason() { return cancellationReason; }
    public void setCancellationReason(String cancellationReason) { this.cancellationReason = cancellationReason; }

    public LocalDateTime getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(LocalDateTime cancelledAt) { this.cancelledAt = cancelledAt; }

    public LocalDateTime getCheckedInAt() { return checkedInAt; }
    public void setCheckedInAt(LocalDateTime checkedInAt) { this.checkedInAt = checkedInAt; }

    public LocalDateTime getCheckedOutAt() { return checkedOutAt; }
    public void setCheckedOutAt(LocalDateTime checkedOutAt) { this.checkedOutAt = checkedOutAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public Room.RoomType getRoomType() { return roomType; }
    public void setRoomType(Room.RoomType roomType) { this.roomType = roomType; }

    public String getRoomPrimaryImageUrl() { return roomPrimaryImageUrl; }
    public void setRoomPrimaryImageUrl(String roomPrimaryImageUrl) { this.roomPrimaryImageUrl = roomPrimaryImageUrl; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public Invoice.PaymentStatus getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(Invoice.PaymentStatus paymentStatus) { this.paymentStatus = paymentStatus; }

    public boolean canBeCancelled() {
        if (bookingStatus == BookingStatus.CANCELLED || bookingStatus == BookingStatus.CHECKED_OUT) {
            return false;
        }
        // Can be cancelled up until check-in date
        return !checkInDate.isBefore(LocalDate.now());
    }

    public boolean canCheckIn() {
        return bookingStatus == BookingStatus.CONFIRMED;
    }

    public boolean canCheckOut() {
        return bookingStatus == BookingStatus.CHECKED_IN;
    }
}

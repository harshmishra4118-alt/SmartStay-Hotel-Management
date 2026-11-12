package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Feedback implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum SentimentLabel {
        POSITIVE("Positive"),
        NEUTRAL("Neutral"),
        NEGATIVE("Negative");

        private final String displayName;

        SentimentLabel(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private Long bookingId;
    private Long userId;
    private Long hotelId;
    private Long roomId;
    private int rating;
    private int cleanlinessRating;
    private int serviceRating;
    private int amenitiesRating;
    private String comments;
    private SentimentLabel sentimentLabel;
    private String ruleKeywordsMatched;
    private boolean isApproved;
    private String adminReply;
    private LocalDateTime createdAt;

    // Joined fields
    private String customerName;
    private String customerEmail;
    private String roomName;
    private String roomNumber;
    private String bookingReference;
    private String hotelName;

    public Feedback() {
        this.rating = 5;
        this.cleanlinessRating = 5;
        this.serviceRating = 5;
        this.amenitiesRating = 5;
        this.sentimentLabel = SentimentLabel.POSITIVE;
        this.isApproved = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getHotelId() { return hotelId; }
    public void setHotelId(Long hotelId) { this.hotelId = hotelId; }

    public String getHotelName() { return hotelName; }
    public void setHotelName(String hotelName) { this.hotelName = hotelName; }

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public int getCleanlinessRating() { return cleanlinessRating; }
    public void setCleanlinessRating(int cleanlinessRating) { this.cleanlinessRating = cleanlinessRating; }

    public int getServiceRating() { return serviceRating; }
    public void setServiceRating(int serviceRating) { this.serviceRating = serviceRating; }

    public int getAmenitiesRating() { return amenitiesRating; }
    public void setAmenitiesRating(int amenitiesRating) { this.amenitiesRating = amenitiesRating; }

    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }

    public SentimentLabel getSentimentLabel() { return sentimentLabel; }
    public void setSentimentLabel(SentimentLabel sentimentLabel) { this.sentimentLabel = sentimentLabel; }
    public SentimentLabel getSentiment() { return sentimentLabel; }

    public String getRuleKeywordsMatched() { return ruleKeywordsMatched; }
    public void setRuleKeywordsMatched(String ruleKeywordsMatched) { this.ruleKeywordsMatched = ruleKeywordsMatched; }

    public boolean isApproved() { return isApproved; }
    public void setApproved(boolean approved) { isApproved = approved; }

    public String getAdminReply() { return adminReply; }
    public void setAdminReply(String adminReply) { this.adminReply = adminReply; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getUserFullName() { return customerName != null ? customerName : "Valued Guest"; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }
}

package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum NotificationType {
        BOOKING("Booking Alert"),
        PAYMENT("Payment Receipt"),
        CHECKIN("Check-In Notice"),
        CHECKOUT("Check-Out Summary"),
        SYSTEM("System Notification");

        private final String displayName;

        NotificationType(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private Long userId;
    private String title;
    private String message;
    private NotificationType notificationType;
    private boolean isRead;
    private String referenceLink;
    private LocalDateTime createdAt;

    public Notification() {
        this.notificationType = NotificationType.SYSTEM;
        this.isRead = false;
    }

    public Notification(Long userId, String title, String message, NotificationType notificationType, String referenceLink) {
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.notificationType = notificationType;
        this.referenceLink = referenceLink;
        this.isRead = false;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public NotificationType getNotificationType() { return notificationType; }
    public void setNotificationType(NotificationType notificationType) { this.notificationType = notificationType; }
    public NotificationType getType() { return notificationType; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public String getReferenceLink() { return referenceLink; }
    public void setReferenceLink(String referenceLink) { this.referenceLink = referenceLink; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}

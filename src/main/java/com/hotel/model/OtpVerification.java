package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class OtpVerification implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum OtpType {
        REGISTRATION("Registration"),
        LOGIN("Login"),
        PASSWORD_RESET("Password Reset");

        private final String displayName;

        OtpType(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private String email;
    private String otpHash;
    private OtpType otpType;
    private int attempts;
    private int resendCount;
    private boolean isUsed;
    private LocalDateTime expiresAt;
    private LocalDateTime lastSentAt;
    private String userMetadata; // JSON containing optional details e.g. fullName
    private LocalDateTime createdAt;

    public OtpVerification() {
        this.attempts = 0;
        this.resendCount = 0;
        this.isUsed = false;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getOtpHash() { return otpHash; }
    public void setOtpHash(String otpHash) { this.otpHash = otpHash; }

    public OtpType getOtpType() { return otpType; }
    public void setOtpType(OtpType otpType) { this.otpType = otpType; }

    public int getAttempts() { return attempts; }
    public void setAttempts(int attempts) { this.attempts = attempts; }

    public int getResendCount() { return resendCount; }
    public void setResendCount(int resendCount) { this.resendCount = resendCount; }

    public boolean isUsed() { return isUsed; }
    public void setUsed(boolean used) { isUsed = used; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public LocalDateTime getLastSentAt() { return lastSentAt; }
    public void setLastSentAt(LocalDateTime lastSentAt) { this.lastSentAt = lastSentAt; }

    public String getUserMetadata() { return userMetadata; }
    public void setUserMetadata(String userMetadata) { this.userMetadata = userMetadata; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }
}


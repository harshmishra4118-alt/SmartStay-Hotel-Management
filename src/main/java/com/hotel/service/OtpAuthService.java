package com.hotel.service;

import com.hotel.dao.OtpVerificationDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.OtpVerification;
import com.hotel.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDateTime;

public class OtpAuthService {

    private static final Logger logger = LoggerFactory.getLogger(OtpAuthService.class);
    private static final String SALT = "SmartStay-Otp-Secure-Salt-2026-v2!";
    private static final int OTP_EXPIRY_MINUTES = 5;
    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int RESEND_COOLDOWN_SECONDS = 60;
    private static final int MAX_RESENDS_ALLOWED = 3;

    private final OtpVerificationDAO otpDAO = new OtpVerificationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom secureRandom = new SecureRandom();

    public static class OtpResult {
        private final boolean success;
        private final String message;
        private final int cooldownSeconds;
        private final User user;

        public OtpResult(boolean success, String message, int cooldownSeconds, User user) {
            this.success = success;
            this.message = message;
            this.cooldownSeconds = cooldownSeconds;
            this.user = user;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public int getCooldownSeconds() { return cooldownSeconds; }
        public User getUser() { return user; }
    }

    /**
     * Generates and transmits a secure 6-digit OTP to the recipient email.
     * Enforces rate limiting, invalidates previous unused OTPs, and stores a cryptographic hash.
     */
    public OtpResult requestOtp(String email, OtpVerification.OtpType type, String userMetadata) {
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            return new OtpResult(false, "Please provide a valid email address.", 0, null);
        }

        email = email.trim().toLowerCase();

        try {
            // For login OTP, verify user exists as CUSTOMER
            if (type == OtpVerification.OtpType.LOGIN) {
                User existingUser = userDAO.findByEmail(email);
                if (existingUser == null) {
                    return new OtpResult(false, "No registered account found with this email. Please register first.", 0, null);
                }
                if (!existingUser.isActive()) {
                    return new OtpResult(false, "Your account is currently suspended. Please contact support.", 0, null);
                }
            } else if (type == OtpVerification.OtpType.REGISTRATION) {
                User existingUser = userDAO.findByEmail(email);
                if (existingUser != null) {
                    return new OtpResult(false, "An account with this email already exists. Please use OTP Login instead.", 0, null);
                }
            }

            // Check recent rate limits
            int recentCount = otpDAO.countRecentRequests(email, 15);
            if (recentCount >= 5) {
                return new OtpResult(false, "Too many OTP requests. Please wait 15 minutes before trying again.", 900, null);
            }

            // Check if there is an active OTP within cooldown period
            OtpVerification activeOtp = otpDAO.findLatestActive(email, type);
            if (activeOtp != null) {
                long secondsSinceLastSent = java.time.Duration.between(activeOtp.getLastSentAt(), LocalDateTime.now()).getSeconds();
                if (secondsSinceLastSent < RESEND_COOLDOWN_SECONDS) {
                    int remainingCooldown = (int) (RESEND_COOLDOWN_SECONDS - secondsSinceLastSent);
                    return new OtpResult(false, "Please wait " + remainingCooldown + " seconds before requesting a new OTP.", remainingCooldown, null);
                }

                if (activeOtp.getResendCount() >= MAX_RESENDS_ALLOWED) {
                    return new OtpResult(false, "Maximum OTP resend attempts reached for this session. Please try again after 5 minutes.", 300, null);
                }
            }

            // Invalidate any active previous OTPs for this email and type
            otpDAO.invalidatePrior(email, type);

            // Generate cryptographically secure 6-digit OTP (100000 - 999999)
            int otpNumber = 100000 + secureRandom.nextInt(900000);
            String otpCode = String.valueOf(otpNumber);

            // Hash the OTP with salt - never store plain text!
            String otpHash = hashOtp(email, otpCode);

            // Save OTP record to database
            OtpVerification newOtp = new OtpVerification();
            newOtp.setEmail(email);
            newOtp.setOtpHash(otpHash);
            newOtp.setOtpType(type);
            newOtp.setExpiresAt(LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES));
            newOtp.setLastSentAt(LocalDateTime.now());
            newOtp.setUserMetadata(userMetadata);

            Long savedId = otpDAO.create(newOtp);
            if (savedId == null) {
                return new OtpResult(false, "Could not initialize OTP verification. Please try again.", 0, null);
            }

            // Transmit OTP email via Gmail SMTP
            boolean sent = emailService.sendOtpEmail(email, otpCode, type.getDisplayName());
            if (!sent) {
                logger.warn("SMTP send returned false for {}, but simulation/log fallback was recorded.", email);
            }

            return new OtpResult(true, "A 6-digit verification code has been sent to " + email + ". It will expire in 5 minutes.", RESEND_COOLDOWN_SECONDS, null);

        } catch (SQLException e) {
            logger.error("Database error during OTP request for {}", email, e);
            return new OtpResult(false, "Server error during OTP transmission. Please try again.", 0, null);
        }
    }

    /**
     * Verifies the submitted OTP against the stored cryptographic hash.
     * Enforces single-use, max attempts, and expiry constraints.
     */
    public OtpResult verifyOtp(String email, String enteredOtp, OtpVerification.OtpType type) {
        if (email == null || enteredOtp == null || enteredOtp.trim().length() != 6) {
            return new OtpResult(false, "Please enter a valid 6-digit verification code.", 0, null);
        }

        email = email.trim().toLowerCase();
        enteredOtp = enteredOtp.trim();

        try {
            OtpVerification activeOtp = otpDAO.findLatestActive(email, type);
            if (activeOtp == null) {
                return new OtpResult(false, "No active OTP found. The code may have expired. Please request a new code.", 0, null);
            }

            // Check if expired
            if (activeOtp.isExpired()) {
                otpDAO.markUsed(activeOtp.getId());
                return new OtpResult(false, "This OTP has expired. Please request a new one.", 0, null);
            }

            // Check attempt limits
            if (activeOtp.getAttempts() >= MAX_FAILED_ATTEMPTS) {
                otpDAO.markUsed(activeOtp.getId()); // Invalidate
                return new OtpResult(false, "Too many failed attempts. This OTP has been invalidated. Please request a new code.", 0, null);
            }

            // Hash the entered OTP and compare
            String expectedHash = activeOtp.getOtpHash();
            String candidateHash = hashOtp(email, enteredOtp);

            if (!expectedHash.equals(candidateHash)) {
                otpDAO.incrementAttempts(activeOtp.getId());
                int attemptsLeft = MAX_FAILED_ATTEMPTS - (activeOtp.getAttempts() + 1);
                return new OtpResult(false, "Incorrect verification code. " + attemptsLeft + " attempt(s) remaining.", 0, null);
            }

            // Mark OTP as used immediately (single-use constraint)
            otpDAO.markUsed(activeOtp.getId());

            // Handle user retrieval or account creation
            User user = userDAO.findByEmail(email);

            if (user == null && type == OtpVerification.OtpType.REGISTRATION) {
                // Auto-provision Customer account
                String fullName = "SmartStay Guest";
                String phone = null;
                if (activeOtp.getUserMetadata() != null) {
                    try {
                        com.google.gson.JsonObject meta = com.google.gson.JsonParser.parseString(activeOtp.getUserMetadata()).getAsJsonObject();
                        if (meta.has("fullName")) fullName = meta.get("fullName").getAsString();
                        if (meta.has("phone")) phone = meta.get("phone").getAsString();
                    } catch (Exception ignored) {}
                }

                user = new User();
                user.setEmail(email);
                user.setFullName(fullName);
                user.setPhone(phone);
                user.setRole(User.Role.CUSTOMER);
                user.setStatus(User.Status.ACTIVE);
                // Set a secure random password hash for the OTP account
                user.setPasswordHash(com.hotel.util.PasswordUtil.hashPassword(java.util.UUID.randomUUID().toString()));

                Long newUserId = userDAO.create(user);
                user.setId(newUserId);
                logger.info("Successfully registered new user via Gmail OTP: {} (ID: {})", email, newUserId);
            }

            if (user != null) {
                userDAO.updateLastLogin(user.getId());
            }

            return new OtpResult(true, "Authentication successful!", 0, user);

        } catch (SQLException e) {
            logger.error("Database error during OTP verification for {}", email, e);
            return new OtpResult(false, "Server error during verification. Please try again.", 0, null);
        }
    }

    private String hashOtp(String email, String otp) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String data = email + ":" + otp + ":" + SALT;
            byte[] hash = digest.digest(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}


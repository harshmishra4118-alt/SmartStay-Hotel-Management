package com.hotel.service;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.CustomerProfileDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.CustomerProfile;
import com.hotel.model.User;
import com.hotel.util.PasswordUtil;
import com.hotel.util.ValidationUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;

public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    private final UserDAO userDAO = new UserDAO();
    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public User register(String email, String password, String fullName, String phone, String clientIp) throws Exception {
        if (!ValidationUtil.isValidEmail(email)) {
            throw new IllegalArgumentException("Please provide a valid email address.");
        }
        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters long.");
        }
        if (!ValidationUtil.isNotEmpty(fullName)) {
            throw new IllegalArgumentException("Full name is required.");
        }

        User existing = userDAO.findByEmail(email);
        if (existing != null) {
            throw new IllegalArgumentException("An account with this email address already exists.");
        }

        String hashedPassword = PasswordUtil.hashPassword(password);
        User user = new User();
        user.setEmail(email.toLowerCase().trim());
        user.setPasswordHash(hashedPassword);
        user.setFullName(fullName.trim());
        user.setPhone(phone != null ? phone.trim() : "");
        user.setRole(User.Role.CUSTOMER);
        user.setStatus(User.Status.ACTIVE);

        Long userId = userDAO.create(user);
        user.setId(userId);

        // Initialize customer profile
        CustomerProfile profile = new CustomerProfile();
        profile.setUserId(userId);
        profileDAO.saveOrUpdate(profile);

        auditLogDAO.log(userId, "USER_REGISTERED", "User", String.valueOf(userId),
                "Customer registered account: " + user.getEmail(), clientIp);

        return user;
    }

    public User login(String email, String plainPassword, String clientIp) throws Exception {
        if (!ValidationUtil.isNotEmpty(email) || !ValidationUtil.isNotEmpty(plainPassword)) {
            throw new IllegalArgumentException("Email and password cannot be empty.");
        }

        User user = userDAO.findByEmail(email);
        if (user == null) {
            auditLogDAO.log(null, "LOGIN_FAILED_NOT_FOUND", "User", null,
                    "Failed login attempt for email: " + email, clientIp);
            throw new IllegalArgumentException("Invalid email or password.");
        }

        if (user.getStatus() != User.Status.ACTIVE) {
            auditLogDAO.log(user.getId(), "LOGIN_BLOCKED_STATUS", "User", String.valueOf(user.getId()),
                    "Account is " + user.getStatus(), clientIp);
            throw new IllegalStateException("Your account is " + user.getStatus().name().toLowerCase() + ". Please contact support.");
        }

        boolean valid = PasswordUtil.verifyPassword(plainPassword, user.getPasswordHash());
        if (!valid) {
            auditLogDAO.log(user.getId(), "LOGIN_FAILED_PASSWORD", "User", String.valueOf(user.getId()),
                    "Invalid password attempt for: " + email, clientIp);
            throw new IllegalArgumentException("Invalid email or password.");
        }

        userDAO.updateLastLogin(user.getId());
        auditLogDAO.log(user.getId(), "LOGIN_SUCCESS", "User", String.valueOf(user.getId()),
                "User logged in successfully as " + user.getRole(), clientIp);

        return user;
    }

    public void changePassword(Long userId, String oldPassword, String newPassword, String clientIp) throws Exception {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException("User not found.");
        }
        if (!PasswordUtil.verifyPassword(oldPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect.");
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new IllegalArgumentException("New password must be at least 6 characters.");
        }

        String newHash = PasswordUtil.hashPassword(newPassword);
        userDAO.updatePassword(userId, newHash);
        auditLogDAO.log(userId, "PASSWORD_CHANGED", "User", String.valueOf(userId),
                "Password updated successfully", clientIp);
    }
}

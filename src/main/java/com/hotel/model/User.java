package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum Role {
        CUSTOMER, STAFF, ADMIN
    }

    public enum Status {
        ACTIVE, INACTIVE, SUSPENDED
    }

    private Long id;
    private String email;
    private String passwordHash;
    private Role role;
    private String fullName;
    private String phone;
    private Status status;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long assignedHotelId;
    private String assignedHotelName;

    public User() {
        this.role = Role.CUSTOMER;
        this.status = Status.ACTIVE;
    }

    public User(Long id, String email, String passwordHash, Role role, String fullName, String phone, Status status) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.fullName = fullName;
        this.phone = phone;
        this.status = status;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public boolean isActive() {
        return status == Status.ACTIVE;
    }

    public boolean isAdmin() {
        return role == Role.ADMIN;
    }

    public Long getAssignedHotelId() { return assignedHotelId; }
    public void setAssignedHotelId(Long assignedHotelId) { this.assignedHotelId = assignedHotelId; }

    public String getAssignedHotelName() { return assignedHotelName; }
    public void setAssignedHotelName(String assignedHotelName) { this.assignedHotelName = assignedHotelName; }

    public boolean isSuperAdmin() {
        return role == Role.ADMIN && assignedHotelId == null;
    }

    public boolean isHotelAdmin() {
        return role == Role.ADMIN && assignedHotelId != null;
    }

    public boolean isStaff() {
        return role == Role.STAFF || role == Role.ADMIN;
    }

    // JavaBean getter aliases for JSP EL compatibility
    public boolean getSuperAdmin() { return isSuperAdmin(); }
    public boolean getHotelAdmin() { return isHotelAdmin(); }
    public boolean getStaff() { return isStaff(); }
    public boolean getAdmin() { return isAdmin(); }
    public boolean getActive() { return isActive(); }
}

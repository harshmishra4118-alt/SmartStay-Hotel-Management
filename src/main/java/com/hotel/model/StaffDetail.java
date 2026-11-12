package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class StaffDetail implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum Department {
        FRONT_DESK, HOUSEKEEPING, MANAGEMENT, MAINTENANCE
    }

    public enum Shift {
        MORNING, EVENING, NIGHT, ROTATING
    }

    private Long id;
    private Long userId;
    private String employeeCode;
    private Department department;
    private LocalDate hireDate;
    private Shift shift;
    private String emergencyPhone;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Joined user & hotel details for easy display
    private String userFullName;
    private String userEmail;
    private String userPhone;
    private Long assignedHotelId;
    private String assignedHotelName;

    public StaffDetail() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public Department getDepartment() { return department; }
    public void setDepartment(Department department) { this.department = department; }

    public LocalDate getHireDate() { return hireDate; }
    public void setHireDate(LocalDate hireDate) { this.hireDate = hireDate; }

    public Shift getShift() { return shift; }
    public void setShift(Shift shift) { this.shift = shift; }

    public String getEmergencyPhone() { return emergencyPhone; }
    public void setEmergencyPhone(String emergencyPhone) { this.emergencyPhone = emergencyPhone; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserPhone() { return userPhone; }
    public void setUserPhone(String userPhone) { this.userPhone = userPhone; }

    public Long getAssignedHotelId() { return assignedHotelId; }
    public void setAssignedHotelId(Long assignedHotelId) { this.assignedHotelId = assignedHotelId; }

    public String getAssignedHotelName() { return assignedHotelName; }
    public void setAssignedHotelName(String assignedHotelName) { this.assignedHotelName = assignedHotelName; }
}

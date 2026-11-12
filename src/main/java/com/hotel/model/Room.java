package com.hotel.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Room implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum RoomType {
        STANDARD("Standard Room"),
        DELUXE("Deluxe Room"),
        EXECUTIVE_SUITE("Executive Suite"),
        PRESIDENTIAL_SUITE("Presidential Suite"),
        FAMILY_STUDIO("Family Studio");

        private final String displayName;

        RoomType(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public enum OperationalStatus {
        ACTIVE("Active"),
        INACTIVE("Inactive"),
        MAINTENANCE("Maintenance");

        private final String displayName;

        OperationalStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public enum HousekeepingStatus {
        CLEAN("Clean"),
        DIRTY("Dirty"),
        INSPECTING("Inspecting"),
        OUT_OF_SERVICE("Out of Service");

        private final String displayName;

        HousekeepingStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private Long hotelId = 1L;
    private String hotelName;
    private String hotelCity;
    private String roomNumber;
    private RoomType roomType;
    private String name;
    private String description;
    private BigDecimal pricePerNight;
    private int capacity;
    private String bedType;
    private int sizeSqft;
    private int floorNumber;
    private OperationalStatus operationalStatus;
    private HousekeepingStatus housekeepingStatus;
    private String primaryImageUrl;
    private String amenities; // comma-separated e.g. "High-speed WiFi, Jacuzzi, Balcony, City View"
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Room() {
        this.roomType = RoomType.DELUXE;
        this.operationalStatus = OperationalStatus.ACTIVE;
        this.housekeepingStatus = HousekeepingStatus.CLEAN;
        this.capacity = 2;
        this.floorNumber = 1;
        this.pricePerNight = BigDecimal.ZERO;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getHotelId() { return hotelId; }
    public void setHotelId(Long hotelId) { this.hotelId = hotelId; }

    public String getHotelName() { return hotelName; }
    public void setHotelName(String hotelName) { this.hotelName = hotelName; }

    public String getHotelCity() { return hotelCity; }
    public void setHotelCity(String hotelCity) { this.hotelCity = hotelCity; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPricePerNight() { return pricePerNight; }
    public void setPricePerNight(BigDecimal pricePerNight) { this.pricePerNight = pricePerNight; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public String getBedType() { return bedType; }
    public void setBedType(String bedType) { this.bedType = bedType; }

    public int getSizeSqft() { return sizeSqft; }
    public void setSizeSqft(int sizeSqft) { this.sizeSqft = sizeSqft; }

    public int getFloorNumber() { return floorNumber; }
    public void setFloorNumber(int floorNumber) { this.floorNumber = floorNumber; }

    public OperationalStatus getOperationalStatus() { return operationalStatus; }
    public void setOperationalStatus(OperationalStatus operationalStatus) { this.operationalStatus = operationalStatus; }

    public HousekeepingStatus getHousekeepingStatus() { return housekeepingStatus; }
    public void setHousekeepingStatus(HousekeepingStatus housekeepingStatus) { this.housekeepingStatus = housekeepingStatus; }

    public String getPrimaryImageUrl() { return primaryImageUrl; }
    public void setPrimaryImageUrl(String primaryImageUrl) { this.primaryImageUrl = primaryImageUrl; }

    public String getAmenities() { return amenities; }
    public void setAmenities(String amenities) { this.amenities = amenities; }

    public List<String> getAmenitiesList() {
        if (amenities == null || amenities.trim().isEmpty()) {
            return new ArrayList<>();
        }
        String[] parts = amenities.split(",");
        List<String> list = new ArrayList<>();
        for (String p : parts) {
            String trimmed = p.trim();
            if (!trimmed.isEmpty()) {
                list.add(trimmed);
            }
        }
        return list;
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public boolean isAvailableForBooking() {
        return operationalStatus == OperationalStatus.ACTIVE && housekeepingStatus != HousekeepingStatus.OUT_OF_SERVICE;
    }
}

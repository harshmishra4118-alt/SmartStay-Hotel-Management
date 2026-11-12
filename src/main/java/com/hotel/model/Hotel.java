package com.hotel.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Hotel implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum Status {
        ACTIVE("Active"),
        INACTIVE("Inactive");

        private final String displayName;

        Status(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private String name;
    private String tagline;
    private String description;
    private String address;
    private String city;
    private String state;
    private String country;
    private String postalCode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private BigDecimal starRating;
    private String phone;
    private String email;
    private String primaryImageUrl;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String checkinTime;
    private String checkoutTime;
    private String cancellationPolicy;
    private Status status;
    private boolean isFeatured;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Transient attributes for location calculations and joined views
    private Double distanceKm;
    private String drivingTimeEstimate;
    private String walkingTimeEstimate;
    private List<HotelImage> images = new ArrayList<>();
    private List<HotelFacility> facilities = new ArrayList<>();
    private List<Room> rooms = new ArrayList<>();
    private int reviewCount = 0;
    private boolean isFavorite = false;

    public Hotel() {
        this.status = Status.ACTIVE;
        this.country = "India";
        this.starRating = new BigDecimal("4.5");
        this.minPrice = new BigDecimal("3500.00");
        this.maxPrice = new BigDecimal("35000.00");
        this.checkinTime = "14:00";
        this.checkoutTime = "11:00";
        this.isFeatured = false;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getTagline() { return tagline; }
    public void setTagline(String tagline) { this.tagline = tagline; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public BigDecimal getStarRating() { return starRating; }
    public void setStarRating(BigDecimal starRating) { this.starRating = starRating; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPrimaryImageUrl() { return primaryImageUrl; }
    public void setPrimaryImageUrl(String primaryImageUrl) { this.primaryImageUrl = primaryImageUrl; }

    public BigDecimal getMinPrice() { return minPrice; }
    public void setMinPrice(BigDecimal minPrice) { this.minPrice = minPrice; }

    public BigDecimal getMaxPrice() { return maxPrice; }
    public void setMaxPrice(BigDecimal maxPrice) { this.maxPrice = maxPrice; }

    public String getCheckinTime() { return checkinTime; }
    public void setCheckinTime(String checkinTime) { this.checkinTime = checkinTime; }

    public String getCheckoutTime() { return checkoutTime; }
    public void setCheckoutTime(String checkoutTime) { this.checkoutTime = checkoutTime; }

    public String getCancellationPolicy() { return cancellationPolicy; }
    public void setCancellationPolicy(String cancellationPolicy) { this.cancellationPolicy = cancellationPolicy; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public boolean isFeatured() { return isFeatured; }
    public void setFeatured(boolean featured) { isFeatured = featured; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Double getDistanceKm() { return distanceKm; }
    public void setDistanceKm(Double distanceKm) { this.distanceKm = distanceKm; }

    public String getDrivingTimeEstimate() { return drivingTimeEstimate; }
    public void setDrivingTimeEstimate(String drivingTimeEstimate) { this.drivingTimeEstimate = drivingTimeEstimate; }

    public String getWalkingTimeEstimate() { return walkingTimeEstimate; }
    public void setWalkingTimeEstimate(String walkingTimeEstimate) { this.walkingTimeEstimate = walkingTimeEstimate; }

    public List<HotelImage> getImages() { return images; }
    public void setImages(List<HotelImage> images) { this.images = images; }

    public List<HotelFacility> getFacilities() { return facilities; }
    public void setFacilities(List<HotelFacility> facilities) { this.facilities = facilities; }

    public List<Room> getRooms() { return rooms; }
    public void setRooms(List<Room> rooms) { this.rooms = rooms; }

    public int getReviewCount() { return reviewCount; }
    public void setReviewCount(int reviewCount) { this.reviewCount = reviewCount; }

    public boolean isFavorite() { return isFavorite; }
    public void setFavorite(boolean favorite) { isFavorite = favorite; }

    // Helpers for JSP Expression Language
    public String getFullLocation() {
        return (address != null ? address + ", " : "") + city + ", " + state + " - " + postalCode;
    }

    public String getFormattedDistance() {
        if (distanceKm == null) return null;
        if (distanceKm < 1.0) {
            return String.format("%.0f m away", distanceKm * 1000);
        }
        return String.format("%.1f km away", distanceKm);
    }

    public int getImageCount() {
        return images != null ? images.size() : 0;
    }

    public int getFacilityCount() {
        return facilities != null ? facilities.size() : 0;
    }

    public int getRoomCount() {
        return rooms != null ? rooms.size() : 0;
    }
}


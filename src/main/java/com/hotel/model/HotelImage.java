package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class HotelImage implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum ImageCategory {
        EXTERIOR("Hotel Exterior"),
        BEDROOM("Luxury Bedroom"),
        DELUXE_ROOM("Deluxe Room"),
        LUXURY_SUITE("Luxury Suite"),
        BATHROOM("Spa Bathroom"),
        SWIMMING_POOL("Swimming Pool"),
        RESTAURANT("Fine Dining & Bar"),
        RECEPTION("Grand Reception"),
        FACILITY("Hotel Facilities"),
        OTHER("Other");

        private final String displayName;

        ImageCategory(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private Long hotelId;
    private String imageUrl;
    private ImageCategory category;
    private String caption;
    private boolean isPrimary;
    private int displayOrder;
    private LocalDateTime createdAt;

    public HotelImage() {
        this.category = ImageCategory.EXTERIOR;
        this.isPrimary = false;
        this.displayOrder = 0;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getHotelId() { return hotelId; }
    public void setHotelId(Long hotelId) { this.hotelId = hotelId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public ImageCategory getCategory() { return category; }
    public void setCategory(ImageCategory category) { this.category = category; }

    public String getCaption() { return caption; }
    public void setCaption(String caption) { this.caption = caption; }

    public boolean isPrimary() { return isPrimary; }
    public void setPrimary(boolean primary) { isPrimary = primary; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}


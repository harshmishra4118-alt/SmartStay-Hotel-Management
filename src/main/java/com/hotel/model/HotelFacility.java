package com.hotel.model;

import java.io.Serializable;

public class HotelFacility implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long hotelId;
    private String facilityName;
    private String facilityIcon;
    private boolean isHighlighted;

    public HotelFacility() {
        this.facilityIcon = "bi-check-circle";
        this.isHighlighted = true;
    }

    public HotelFacility(Long hotelId, String facilityName, String facilityIcon, boolean isHighlighted) {
        this.hotelId = hotelId;
        this.facilityName = facilityName;
        this.facilityIcon = facilityIcon;
        this.isHighlighted = isHighlighted;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getHotelId() { return hotelId; }
    public void setHotelId(Long hotelId) { this.hotelId = hotelId; }

    public String getFacilityName() { return facilityName; }
    public void setFacilityName(String facilityName) { this.facilityName = facilityName; }

    public String getFacilityIcon() { return facilityIcon; }
    public void setFacilityIcon(String facilityIcon) { this.facilityIcon = facilityIcon; }

    public boolean isHighlighted() { return isHighlighted; }
    public void setHighlighted(boolean highlighted) { isHighlighted = highlighted; }
}


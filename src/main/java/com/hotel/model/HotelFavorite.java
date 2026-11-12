package com.hotel.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class HotelFavorite implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long userId;
    private Long hotelId;
    private LocalDateTime createdAt;

    // Joined Hotel for convenience in user wishlist views
    private Hotel hotel;

    public HotelFavorite() {}

    public HotelFavorite(Long userId, Long hotelId) {
        this.userId = userId;
        this.hotelId = hotelId;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getHotelId() { return hotelId; }
    public void setHotelId(Long hotelId) { this.hotelId = hotelId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Hotel getHotel() { return hotel; }
    public void setHotel(Hotel hotel) { this.hotel = hotel; }
}


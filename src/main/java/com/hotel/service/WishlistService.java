package com.hotel.service;

import com.hotel.dao.HotelFavoriteDAO;
import com.hotel.model.Hotel;

import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

public class WishlistService {

    private final HotelFavoriteDAO favoriteDAO = new HotelFavoriteDAO();

    public boolean toggleFavorite(Long userId, Long hotelId) throws SQLException {
        if (userId == null || hotelId == null) return false;
        boolean exists = favoriteDAO.isFavorite(userId, hotelId);
        if (exists) {
            favoriteDAO.removeFavorite(userId, hotelId);
            return false; // Removed
        } else {
            favoriteDAO.addFavorite(userId, hotelId);
            return true; // Added
        }
    }

    public boolean isFavorite(Long userId, Long hotelId) {
        if (userId == null || hotelId == null) return false;
        try {
            return favoriteDAO.isFavorite(userId, hotelId);
        } catch (SQLException e) {
            return false;
        }
    }

    public List<Hotel> getFavoriteHotels(Long userId) {
        if (userId == null) return Collections.emptyList();
        try {
            return favoriteDAO.getFavoritesByUser(userId);
        } catch (SQLException e) {
            return Collections.emptyList();
        }
    }
}


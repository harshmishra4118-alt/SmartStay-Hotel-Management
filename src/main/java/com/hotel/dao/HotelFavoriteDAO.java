package com.hotel.dao;

import com.hotel.model.Hotel;
import com.hotel.model.HotelFavorite;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HotelFavoriteDAO extends BaseDAO {

    public boolean addFavorite(Long userId, Long hotelId) throws SQLException {
        String sql = "INSERT IGNORE INTO hotel_favorites (user_id, hotel_id, created_at) VALUES (?, ?, NOW())";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setLong(2, hotelId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean removeFavorite(Long userId, Long hotelId) throws SQLException {
        String sql = "DELETE FROM hotel_favorites WHERE user_id = ? AND hotel_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setLong(2, hotelId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean isFavorite(Long userId, Long hotelId) throws SQLException {
        String sql = "SELECT 1 FROM hotel_favorites WHERE user_id = ? AND hotel_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setLong(2, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<Hotel> getFavoritesByUser(Long userId) throws SQLException {
        String sql = "SELECT h.*, hf.created_at AS favorite_saved_at " +
                     "FROM hotel_favorites hf " +
                     "JOIN hotels h ON hf.hotel_id = h.id " +
                     "WHERE hf.user_id = ? " +
                     "ORDER BY hf.created_at DESC";

        List<Hotel> list = new ArrayList<>();
        HotelDAO hotelDAO = new HotelDAO();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Hotel h = new Hotel();
                    h.setId(rs.getLong("id"));
                    h.setName(rs.getString("name"));
                    h.setTagline(rs.getString("tagline"));
                    h.setDescription(rs.getString("description"));
                    h.setAddress(rs.getString("address"));
                    h.setCity(rs.getString("city"));
                    h.setState(rs.getString("state"));
                    h.setCountry(rs.getString("country"));
                    h.setPostalCode(rs.getString("postal_code"));
                    h.setLatitude(rs.getBigDecimal("latitude"));
                    h.setLongitude(rs.getBigDecimal("longitude"));
                    h.setStarRating(rs.getBigDecimal("star_rating"));
                    h.setPhone(rs.getString("phone"));
                    h.setEmail(rs.getString("email"));
                    h.setPrimaryImageUrl(rs.getString("primary_image_url"));
                    h.setMinPrice(rs.getBigDecimal("min_price"));
                    h.setMaxPrice(rs.getBigDecimal("max_price"));
                    h.setFavorite(true);
                    h.setFacilities(hotelDAO.getHotelFacilities(h.getId()));
                    list.add(h);
                }
            }
        }
        return list;
    }
}


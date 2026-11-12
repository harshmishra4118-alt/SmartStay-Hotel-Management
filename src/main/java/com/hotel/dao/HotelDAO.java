package com.hotel.dao;

import com.hotel.model.Hotel;
import com.hotel.model.HotelFacility;
import com.hotel.model.HotelImage;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class HotelDAO extends BaseDAO {

    public Long create(Hotel hotel) throws SQLException {
        String sql = "INSERT INTO hotels (name, tagline, description, address, city, state, country, " +
                     "postal_code, latitude, longitude, star_rating, phone, email, primary_image_url, " +
                     "min_price, max_price, checkin_time, checkout_time, cancellation_policy, status, " +
                     "is_featured, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, hotel.getName().trim());
            stmt.setString(2, hotel.getTagline());
            stmt.setString(3, hotel.getDescription());
            stmt.setString(4, hotel.getAddress().trim());
            stmt.setString(5, hotel.getCity().trim());
            stmt.setString(6, hotel.getState().trim());
            stmt.setString(7, hotel.getCountry() != null ? hotel.getCountry() : "India");
            stmt.setString(8, hotel.getPostalCode().trim());
            stmt.setBigDecimal(9, hotel.getLatitude());
            stmt.setBigDecimal(10, hotel.getLongitude());
            stmt.setBigDecimal(11, hotel.getStarRating());
            stmt.setString(12, hotel.getPhone());
            stmt.setString(13, hotel.getEmail().trim().toLowerCase());
            stmt.setString(14, hotel.getPrimaryImageUrl());
            stmt.setBigDecimal(15, hotel.getMinPrice());
            stmt.setBigDecimal(16, hotel.getMaxPrice());
            stmt.setString(17, hotel.getCheckinTime());
            stmt.setString(18, hotel.getCheckoutTime());
            stmt.setString(19, hotel.getCancellationPolicy());
            stmt.setString(20, hotel.getStatus().name());
            stmt.setBoolean(21, hotel.isFeatured());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    hotel.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public boolean update(Hotel hotel) throws SQLException {
        String sql = "UPDATE hotels SET name = ?, tagline = ?, description = ?, address = ?, city = ?, " +
                     "state = ?, country = ?, postal_code = ?, latitude = ?, longitude = ?, star_rating = ?, " +
                     "phone = ?, email = ?, primary_image_url = ?, min_price = ?, max_price = ?, " +
                     "checkin_time = ?, checkout_time = ?, cancellation_policy = ?, status = ?, " +
                     "is_featured = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, hotel.getName().trim());
            stmt.setString(2, hotel.getTagline());
            stmt.setString(3, hotel.getDescription());
            stmt.setString(4, hotel.getAddress().trim());
            stmt.setString(5, hotel.getCity().trim());
            stmt.setString(6, hotel.getState().trim());
            stmt.setString(7, hotel.getCountry());
            stmt.setString(8, hotel.getPostalCode().trim());
            stmt.setBigDecimal(9, hotel.getLatitude());
            stmt.setBigDecimal(10, hotel.getLongitude());
            stmt.setBigDecimal(11, hotel.getStarRating());
            stmt.setString(12, hotel.getPhone());
            stmt.setString(13, hotel.getEmail().trim().toLowerCase());
            stmt.setString(14, hotel.getPrimaryImageUrl());
            stmt.setBigDecimal(15, hotel.getMinPrice());
            stmt.setBigDecimal(16, hotel.getMaxPrice());
            stmt.setString(17, hotel.getCheckinTime());
            stmt.setString(18, hotel.getCheckoutTime());
            stmt.setString(19, hotel.getCancellationPolicy());
            stmt.setString(20, hotel.getStatus().name());
            stmt.setBoolean(21, hotel.isFeatured());
            stmt.setLong(22, hotel.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM hotels WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public Hotel findById(Long id) throws SQLException {
        String sql = "SELECT * FROM hotels WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Hotel hotel = mapRow(rs);
                    hotel.setImages(getHotelImages(conn, hotel.getId()));
                    hotel.setFacilities(getHotelFacilities(conn, hotel.getId()));
                    return hotel;
                }
            }
        }
        return null;
    }

    public List<Hotel> findAllActive() throws SQLException {
        String sql = "SELECT * FROM hotels WHERE status = 'ACTIVE' ORDER BY is_featured DESC, star_rating DESC";
        List<Hotel> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Hotel hotel = mapRow(rs);
                hotel.setFacilities(getHotelFacilities(conn, hotel.getId()));
                list.add(hotel);
            }
        }
        return list;
    }

    public List<Hotel> findAll() throws SQLException {
        String sql = "SELECT * FROM hotels ORDER BY id ASC";
        List<Hotel> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<String> getDistinctCities() throws SQLException {
        String sql = "SELECT DISTINCT city FROM hotels WHERE status = 'ACTIVE' ORDER BY city ASC";
        List<String> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("city"));
            }
        }
        return list;
    }

    /**
     * Searches hotels with full multi-criteria filtering:
     * Destination / city / keyword, price range, star rating, facility filters, and dynamic sorting.
     */
    public List<Hotel> searchHotels(String query, String city, BigDecimal minPrice, BigDecimal maxPrice,
                                    Double minRating, List<String> facilityNames, String sortBy,
                                    Double userLat, Double userLng) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT h.* ");
        if (userLat != null && userLng != null) {
            sql.append(", (6371 * acos(cos(radians(?)) * cos(radians(h.latitude)) * cos(radians(h.longitude) - radians(?)) + sin(radians(?)) * sin(radians(h.latitude)))) AS distance_km ");
        }
        sql.append("FROM hotels h WHERE h.status = 'ACTIVE' ");

        List<Object> params = new ArrayList<>();
        if (userLat != null && userLng != null) {
            params.add(userLat);
            params.add(userLng);
            params.add(userLat);
        }

        if (query != null && !query.trim().isEmpty()) {
            String q = "%" + query.trim().toLowerCase() + "%";
            sql.append("AND (LOWER(h.name) LIKE ? OR LOWER(h.city) LIKE ? OR LOWER(h.address) LIKE ? OR LOWER(h.postal_code) LIKE ?) ");
            params.add(q);
            params.add(q);
            params.add(q);
            params.add(q);
        }

        if (city != null && !city.trim().isEmpty() && !"ALL".equalsIgnoreCase(city.trim())) {
            sql.append("AND LOWER(h.city) = LOWER(?) ");
            params.add(city.trim());
        }

        if (minPrice != null) {
            sql.append("AND h.min_price >= ? ");
            params.add(minPrice);
        }

        if (maxPrice != null) {
            sql.append("AND h.min_price <= ? ");
            params.add(maxPrice);
        }

        if (minRating != null && minRating > 0) {
            sql.append("AND h.star_rating >= ? ");
            params.add(minRating);
        }

        if (facilityNames != null && !facilityNames.isEmpty()) {
            for (String fac : facilityNames) {
                if (fac != null && !fac.trim().isEmpty()) {
                    sql.append("AND EXISTS (SELECT 1 FROM hotel_facilities hf WHERE hf.hotel_id = h.id AND LOWER(hf.facility_name) LIKE ?) ");
                    params.add("%" + fac.trim().toLowerCase() + "%");
                }
            }
        }

        // Sorting
        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY h.min_price ASC");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY h.min_price DESC");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY h.star_rating DESC");
        } else if ("nearest".equalsIgnoreCase(sortBy) && userLat != null && userLng != null) {
            sql.append("ORDER BY distance_km ASC");
        } else {
            // Default recommended
            sql.append("ORDER BY h.is_featured DESC, h.star_rating DESC, h.min_price ASC");
        }

        List<Hotel> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Hotel h = mapRow(rs);
                    if (userLat != null && userLng != null) {
                        try {
                            double dist = rs.getDouble("distance_km");
                            h.setDistanceKm(dist);
                        } catch (SQLException ignored) {}
                    }
                    h.setFacilities(getHotelFacilities(conn, h.getId()));
                    list.add(h);
                }
            }
        }
        return list;
    }

    /**
     * Finds nearby hotels using exact Haversine distance in SQL within maxDistanceKm radius.
     */
    public List<Hotel> findNearby(double userLat, double userLng, double maxDistanceKm, String sortBy) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT h.*, " +
            "(6371 * acos(cos(radians(?)) * cos(radians(h.latitude)) * cos(radians(h.longitude) - radians(?)) + sin(radians(?)) * sin(radians(h.latitude)))) AS distance_km " +
            "FROM hotels h " +
            "WHERE h.status = 'ACTIVE' "
        );

        if (maxDistanceKm > 0) {
            sql.append("HAVING distance_km <= ? ");
        }

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY h.min_price ASC");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY h.star_rating DESC");
        } else {
            sql.append("ORDER BY distance_km ASC");
        }

        List<Hotel> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setDouble(1, userLat);
            stmt.setDouble(2, userLng);
            stmt.setDouble(3, userLat);
            if (maxDistanceKm > 0) {
                stmt.setDouble(4, maxDistanceKm);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Hotel h = mapRow(rs);
                    h.setDistanceKm(rs.getDouble("distance_km"));
                    h.setFacilities(getHotelFacilities(conn, h.getId()));
                    list.add(h);
                }
            }
        }
        return list;
    }

    // --- Image Gallery Management ---

    public List<HotelImage> getHotelImages(Long hotelId) throws SQLException {
        try (Connection conn = getConnection()) {
            return getHotelImages(conn, hotelId);
        }
    }

    private List<HotelImage> getHotelImages(Connection conn, Long hotelId) throws SQLException {
        String sql = "SELECT * FROM hotel_images WHERE hotel_id = ? ORDER BY is_primary DESC, display_order ASC, id ASC";
        List<HotelImage> list = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    HotelImage img = new HotelImage();
                    img.setId(rs.getLong("id"));
                    img.setHotelId(rs.getLong("hotel_id"));
                    img.setImageUrl(rs.getString("image_url"));
                    try {
                        img.setCategory(HotelImage.ImageCategory.valueOf(rs.getString("category")));
                    } catch (Exception e) {
                        img.setCategory(HotelImage.ImageCategory.EXTERIOR);
                    }
                    img.setCaption(rs.getString("caption"));
                    img.setPrimary(rs.getBoolean("is_primary"));
                    img.setDisplayOrder(rs.getInt("display_order"));
                    list.add(img);
                }
            }
        }
        return list;
    }

    public Long addHotelImage(HotelImage img) throws SQLException {
        String sql = "INSERT INTO hotel_images (hotel_id, image_url, category, caption, is_primary, display_order, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, img.getHotelId());
            stmt.setString(2, img.getImageUrl());
            stmt.setString(3, img.getCategory().name());
            stmt.setString(4, img.getCaption());
            stmt.setBoolean(5, img.isPrimary());
            stmt.setInt(6, img.getDisplayOrder());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    img.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public boolean deleteHotelImage(Long imageId) throws SQLException {
        String sql = "DELETE FROM hotel_images WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, imageId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean setPrimaryHotelImage(Long hotelId, Long imageId) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sql1 = "UPDATE hotel_images SET is_primary = FALSE WHERE hotel_id = ?";
                try (PreparedStatement stmt1 = conn.prepareStatement(sql1)) {
                    stmt1.setLong(1, hotelId);
                    stmt1.executeUpdate();
                }

                String sql2 = "UPDATE hotel_images SET is_primary = TRUE WHERE id = ? AND hotel_id = ?";
                try (PreparedStatement stmt2 = conn.prepareStatement(sql2)) {
                    stmt2.setLong(1, imageId);
                    stmt2.setLong(2, hotelId);
                    stmt2.executeUpdate();
                }

                String sql3 = "UPDATE hotels h JOIN hotel_images hi ON h.id = hi.hotel_id " +
                              "SET h.primary_image_url = hi.image_url WHERE hi.id = ? AND h.id = ?";
                try (PreparedStatement stmt3 = conn.prepareStatement(sql3)) {
                    stmt3.setLong(1, imageId);
                    stmt3.setLong(2, hotelId);
                    stmt3.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    // --- Facilities Management ---

    public List<HotelFacility> getHotelFacilities(Long hotelId) throws SQLException {
        try (Connection conn = getConnection()) {
            return getHotelFacilities(conn, hotelId);
        }
    }

    private List<HotelFacility> getHotelFacilities(Connection conn, Long hotelId) throws SQLException {
        String sql = "SELECT * FROM hotel_facilities WHERE hotel_id = ? ORDER BY is_highlighted DESC, id ASC";
        List<HotelFacility> list = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    HotelFacility f = new HotelFacility();
                    f.setId(rs.getLong("id"));
                    f.setHotelId(rs.getLong("hotel_id"));
                    f.setFacilityName(rs.getString("facility_name"));
                    f.setFacilityIcon(rs.getString("facility_icon"));
                    f.setHighlighted(rs.getBoolean("is_highlighted"));
                    list.add(f);
                }
            }
        }
        return list;
    }

    public Long addHotelFacility(HotelFacility facility) throws SQLException {
        String sql = "INSERT INTO hotel_facilities (hotel_id, facility_name, facility_icon, is_highlighted) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, facility.getHotelId());
            stmt.setString(2, facility.getFacilityName());
            stmt.setString(3, facility.getFacilityIcon());
            stmt.setBoolean(4, facility.isHighlighted());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    facility.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public boolean deleteHotelFacility(Long facilityId) throws SQLException {
        String sql = "DELETE FROM hotel_facilities WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, facilityId);
            return stmt.executeUpdate() > 0;
        }
    }

    private Hotel mapRow(ResultSet rs) throws SQLException {
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
        h.setCheckinTime(rs.getString("checkin_time"));
        h.setCheckoutTime(rs.getString("checkout_time"));
        h.setCancellationPolicy(rs.getString("cancellation_policy"));
        try {
            h.setStatus(Hotel.Status.valueOf(rs.getString("status")));
        } catch (Exception e) {
            h.setStatus(Hotel.Status.ACTIVE);
        }
        h.setFeatured(rs.getBoolean("is_featured"));

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) h.setCreatedAt(cat.toLocalDateTime());
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) h.setUpdatedAt(uat.toLocalDateTime());

        return h;
    }
}


package com.hotel.dao;

import com.hotel.model.Room;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO extends BaseDAO {

    public Long create(Room room) throws SQLException {
        String sql = "INSERT INTO rooms (hotel_id, room_number, room_type, name, description, price_per_night, " +
                     "capacity, bed_type, size_sqft, floor_number, operational_status, housekeeping_status, " +
                     "primary_image_url, amenities, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, room.getHotelId() != null ? room.getHotelId() : 1L);
            stmt.setString(2, room.getRoomNumber().trim().toUpperCase());
            stmt.setString(3, room.getRoomType().name());
            stmt.setString(4, room.getName().trim());
            stmt.setString(5, room.getDescription());
            stmt.setBigDecimal(6, room.getPricePerNight());
            stmt.setInt(7, room.getCapacity());
            stmt.setString(8, room.getBedType());
            stmt.setInt(9, room.getSizeSqft());
            stmt.setInt(10, room.getFloorNumber());
            stmt.setString(11, room.getOperationalStatus().name());
            stmt.setString(12, room.getHousekeepingStatus().name());
            stmt.setString(13, room.getPrimaryImageUrl());
            stmt.setString(14, room.getAmenities());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    room.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public boolean update(Room room) throws SQLException {
        String sql = "UPDATE rooms SET hotel_id = ?, room_number = ?, room_type = ?, name = ?, description = ?, " +
                     "price_per_night = ?, capacity = ?, bed_type = ?, size_sqft = ?, floor_number = ?, " +
                     "operational_status = ?, housekeeping_status = ?, primary_image_url = ?, amenities = ?, " +
                     "updated_at = NOW() WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, room.getHotelId() != null ? room.getHotelId() : 1L);
            stmt.setString(2, room.getRoomNumber().trim().toUpperCase());
            stmt.setString(3, room.getRoomType().name());
            stmt.setString(4, room.getName().trim());
            stmt.setString(5, room.getDescription());
            stmt.setBigDecimal(6, room.getPricePerNight());
            stmt.setInt(7, room.getCapacity());
            stmt.setString(8, room.getBedType());
            stmt.setInt(9, room.getSizeSqft());
            stmt.setInt(10, room.getFloorNumber());
            stmt.setString(11, room.getOperationalStatus().name());
            stmt.setString(12, room.getHousekeepingStatus().name());
            stmt.setString(13, room.getPrimaryImageUrl());
            stmt.setString(14, room.getAmenities());
            stmt.setLong(15, room.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    public Room findById(Long id) throws SQLException {
        String sql = "SELECT * FROM rooms WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public Room findByRoomNumber(String roomNumber) throws SQLException {
        String sql = "SELECT * FROM rooms WHERE room_number = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, roomNumber.trim().toUpperCase());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public boolean updateOperationalStatus(Long id, Room.OperationalStatus status) throws SQLException {
        String sql = "UPDATE rooms SET operational_status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean updateHousekeepingStatus(Long id, Room.HousekeepingStatus status) throws SQLException {
        String sql = "UPDATE rooms SET housekeeping_status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Room> listAllRooms(Room.OperationalStatus operationalFilter,
                                   Room.HousekeepingStatus housekeepingFilter,
                                   Room.RoomType typeFilter,
                                   String search) throws SQLException {
        return listAllRooms(null, operationalFilter, housekeepingFilter, typeFilter, search);
    }

    public List<Room> listAllRooms(Long hotelId,
                                   Room.OperationalStatus operationalFilter,
                                   Room.HousekeepingStatus housekeepingFilter,
                                   Room.RoomType typeFilter,
                                   String search) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT r.*, h.name AS hotel_name, h.city AS hotel_city FROM rooms r LEFT JOIN hotels h ON r.hotel_id = h.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (hotelId != null) {
            sql.append("AND r.hotel_id = ? ");
            params.add(hotelId);
        }
        if (operationalFilter != null) {
            sql.append("AND r.operational_status = ? ");
            params.add(operationalFilter.name());
        }
        if (housekeepingFilter != null) {
            sql.append("AND r.housekeeping_status = ? ");
            params.add(housekeepingFilter.name());
        }
        if (typeFilter != null) {
            sql.append("AND r.room_type = ? ");
            params.add(typeFilter.name());
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (r.room_number LIKE ? OR r.name LIKE ? OR r.description LIKE ? OR r.amenities LIKE ? OR h.name LIKE ?) ");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append("ORDER BY r.hotel_id ASC, r.floor_number ASC, r.room_number ASC");

        List<Room> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Search rooms with availability checking against existing overlapping bookings.
     */
    public List<Room> searchAvailableRooms(LocalDate checkIn, LocalDate checkOut,
                                           Integer guests, BigDecimal maxBudget,
                                           Room.RoomType roomType) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT r.* FROM rooms r WHERE r.operational_status = 'ACTIVE' " +
                "AND r.housekeeping_status != 'OUT_OF_SERVICE' "
        );
        List<Object> params = new ArrayList<>();

        if (guests != null && guests > 0) {
            sql.append("AND r.capacity >= ? ");
            params.add(guests);
        }
        if (maxBudget != null && maxBudget.compareTo(BigDecimal.ZERO) > 0) {
            sql.append("AND r.price_per_night <= ? ");
            params.add(maxBudget);
        }
        if (roomType != null) {
            sql.append("AND r.room_type = ? ");
            params.add(roomType.name());
        }

        // If date range is specified, exclude rooms that have overlapping confirmed or checked-in bookings
        if (checkIn != null && checkOut != null) {
            sql.append("AND r.id NOT IN ( " +
                       "  SELECT b.room_id FROM bookings b " +
                       "  WHERE b.booking_status IN ('CONFIRMED', 'CHECKED_IN') " +
                       "  AND b.check_in_date < ? AND b.check_out_date > ? " +
                       ") ");
            params.add(Date.valueOf(checkOut));
            params.add(Date.valueOf(checkIn));
        }

        sql.append("ORDER BY r.price_per_night ASC");

        List<Room> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Room> getFeaturedRooms(int limit) throws SQLException {
        String sql = "SELECT * FROM rooms WHERE operational_status = 'ACTIVE' " +
                     "ORDER BY price_per_night DESC LIMIT ?";
        List<Room> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Room> findByHotelId(Long hotelId) throws SQLException {
        String sql = "SELECT r.*, h.name AS hotel_name, h.city AS hotel_city " +
                     "FROM rooms r " +
                     "LEFT JOIN hotels h ON r.hotel_id = h.id " +
                     "WHERE r.hotel_id = ? ORDER BY r.floor_number ASC, r.room_number ASC";
        List<Room> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Room> findAvailableByHotel(Long hotelId, LocalDate checkIn, LocalDate checkOut,
                                           Integer guests, Room.RoomType roomType) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, h.name AS hotel_name, h.city AS hotel_city " +
            "FROM rooms r " +
            "LEFT JOIN hotels h ON r.hotel_id = h.id " +
            "WHERE r.hotel_id = ? " +
            "  AND r.operational_status = 'ACTIVE' " +
            "  AND r.housekeeping_status != 'OUT_OF_SERVICE' "
        );

        List<Object> params = new ArrayList<>();
        params.add(hotelId);

        if (guests != null && guests > 0) {
            sql.append(" AND r.capacity >= ? ");
            params.add(guests);
        }

        if (roomType != null) {
            sql.append(" AND r.room_type = ? ");
            params.add(roomType.name());
        }

        if (checkIn != null && checkOut != null) {
            sql.append(
                " AND NOT EXISTS ( " +
                "     SELECT 1 FROM bookings b " +
                "     WHERE b.room_id = r.id " +
                "       AND b.booking_status IN ('CONFIRMED', 'CHECKED_IN') " +
                "       AND b.check_in_date < ? " +
                "       AND b.check_out_date > ? " +
                " ) "
            );
            params.add(java.sql.Date.valueOf(checkOut));
            params.add(java.sql.Date.valueOf(checkIn));
        }

        sql.append(" ORDER BY r.price_per_night ASC");

        List<Room> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public int countTotalRooms(Long hotelId) throws SQLException {
        String sql = hotelId != null ? "SELECT COUNT(*) FROM rooms WHERE hotel_id = ?" : "SELECT COUNT(*) FROM rooms";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (hotelId != null) stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countTotalActiveRooms(Long hotelId) throws SQLException {
        String sql = hotelId != null 
            ? "SELECT COUNT(*) FROM rooms WHERE operational_status = 'ACTIVE' AND hotel_id = ?"
            : "SELECT COUNT(*) FROM rooms WHERE operational_status = 'ACTIVE'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (hotelId != null) stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countRoomsByHousekeepingStatus(Long hotelId, Room.HousekeepingStatus status) throws SQLException {
        String sql = hotelId != null
            ? "SELECT COUNT(*) FROM rooms WHERE housekeeping_status = ? AND hotel_id = ?"
            : "SELECT COUNT(*) FROM rooms WHERE housekeeping_status = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            if (hotelId != null) stmt.setLong(2, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countRoomsUnderMaintenance(Long hotelId) throws SQLException {
        String sql = hotelId != null
            ? "SELECT COUNT(*) FROM rooms WHERE operational_status = 'MAINTENANCE' AND hotel_id = ?"
            : "SELECT COUNT(*) FROM rooms WHERE operational_status = 'MAINTENANCE'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (hotelId != null) stmt.setLong(1, hotelId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countTotalActiveRooms() throws SQLException {
        return countTotalActiveRooms(null);
    }

    public int countRoomsByHousekeepingStatus(Room.HousekeepingStatus status) throws SQLException {
        return countRoomsByHousekeepingStatus(null, status);
    }

    public int countRoomsUnderMaintenance() throws SQLException {
        return countRoomsUnderMaintenance(null);
    }

    private Room mapRow(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setId(rs.getLong("id"));
        try {
            r.setHotelId(rs.getLong("hotel_id"));
        } catch (SQLException ignored) {}
        try {
            r.setHotelName(rs.getString("hotel_name"));
        } catch (SQLException ignored) {}
        try {
            r.setHotelCity(rs.getString("hotel_city"));
        } catch (SQLException ignored) {}

        r.setRoomNumber(rs.getString("room_number"));
        r.setRoomType(Room.RoomType.valueOf(rs.getString("room_type")));
        r.setName(rs.getString("name"));
        r.setDescription(rs.getString("description"));
        r.setPricePerNight(rs.getBigDecimal("price_per_night"));
        r.setCapacity(rs.getInt("capacity"));
        r.setBedType(rs.getString("bed_type"));
        r.setSizeSqft(rs.getInt("size_sqft"));
        r.setFloorNumber(rs.getInt("floor_number"));
        r.setOperationalStatus(Room.OperationalStatus.valueOf(rs.getString("operational_status")));
        r.setHousekeepingStatus(Room.HousekeepingStatus.valueOf(rs.getString("housekeeping_status")));
        r.setPrimaryImageUrl(rs.getString("primary_image_url"));
        r.setAmenities(rs.getString("amenities"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) r.setCreatedAt(c.toLocalDateTime());
        Timestamp u = rs.getTimestamp("updated_at");
        if (u != null) r.setUpdatedAt(u.toLocalDateTime());

        return r;
    }
}

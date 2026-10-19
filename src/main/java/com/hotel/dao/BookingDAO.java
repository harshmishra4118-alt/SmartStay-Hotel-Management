package com.hotel.dao;

import com.hotel.model.Booking;
import com.hotel.model.Invoice;
import com.hotel.model.Room;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO extends BaseDAO {

    /**
     * Checks if a room has any overlapping active reservation.
     * Uses SELECT ... FOR UPDATE when a connection is within a transaction to prevent race conditions.
     */
    public boolean isRoomAvailable(Connection conn, Long roomId, LocalDate checkIn, LocalDate checkOut, Long excludeBookingId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM bookings " +
                "WHERE room_id = ? " +
                "AND booking_status IN ('CONFIRMED', 'CHECKED_IN') " +
                "AND check_in_date < ? AND check_out_date > ? "
        );

        if (excludeBookingId != null) {
            sql.append("AND id != ? ");
        }

        // Lock rows if transactional
        if (!conn.getAutoCommit()) {
            sql.append("FOR UPDATE");
        }

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setLong(1, roomId);
            stmt.setDate(2, Date.valueOf(checkOut));
            stmt.setDate(3, Date.valueOf(checkIn));
            if (excludeBookingId != null) {
                stmt.setLong(4, excludeBookingId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        }
        return false;
    }

    public boolean isRoomAvailable(Long roomId, LocalDate checkIn, LocalDate checkOut, Long excludeBookingId) throws SQLException {
        try (Connection conn = getConnection()) {
            return isRoomAvailable(conn, roomId, checkIn, checkOut, excludeBookingId);
        }
    }

    public Long create(Booking booking, Connection conn) throws SQLException {
        String sql = "INSERT INTO bookings " +
                     "(booking_reference, user_id, room_id, check_in_date, check_out_date, total_nights, num_guests, " +
                     "guest_name, guest_email, guest_phone, room_price_per_night, base_amount, tax_amount, total_amount, " +
                     "booking_status, special_requests, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, booking.getBookingReference());
            stmt.setLong(2, booking.getUserId());
            stmt.setLong(3, booking.getRoomId());
            stmt.setDate(4, Date.valueOf(booking.getCheckInDate()));
            stmt.setDate(5, Date.valueOf(booking.getCheckOutDate()));
            stmt.setInt(6, booking.getTotalNights());
            stmt.setInt(7, booking.getNumGuests());
            stmt.setString(8, booking.getGuestName().trim());
            stmt.setString(9, booking.getGuestEmail().trim());
            stmt.setString(10, booking.getGuestPhone().trim());
            stmt.setBigDecimal(11, booking.getRoomPricePerNight());
            stmt.setBigDecimal(12, booking.getBaseAmount());
            stmt.setBigDecimal(13, booking.getTaxAmount());
            stmt.setBigDecimal(14, booking.getTotalAmount());
            stmt.setString(15, booking.getBookingStatus().name());
            stmt.setString(16, booking.getSpecialRequests());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    booking.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public Booking findById(Long id) throws SQLException {
        String sql = getJoinedBookingSql() + "WHERE b.id = ?";
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

    public Booking findByReference(String reference) throws SQLException {
        String sql = getJoinedBookingSql() + "WHERE b.booking_reference = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, reference.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<Booking> listByUser(Long userId) throws SQLException {
        String sql = getJoinedBookingSql() + "WHERE b.user_id = ? ORDER BY b.id DESC";
        List<Booking> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Booking> listAll(Booking.BookingStatus statusFilter, LocalDate dateFilter, String search, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(getJoinedBookingSql());
        sql.append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null) {
            sql.append("AND b.booking_status = ? ");
            params.add(statusFilter.name());
        }
        if (dateFilter != null) {
            sql.append("AND (b.check_in_date = ? OR b.check_out_date = ?) ");
            params.add(Date.valueOf(dateFilter));
            params.add(Date.valueOf(dateFilter));
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (b.booking_reference LIKE ? OR b.guest_name LIKE ? OR b.guest_email LIKE ? OR r.room_number LIKE ?) ");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append("ORDER BY b.id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Booking> list = new ArrayList<>();
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

    public int countAll(Booking.BookingStatus statusFilter, LocalDate dateFilter, String search) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM bookings b " +
                "LEFT JOIN rooms r ON b.room_id = r.id " +
                "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (statusFilter != null) {
            sql.append("AND b.booking_status = ? ");
            params.add(statusFilter.name());
        }
        if (dateFilter != null) {
            sql.append("AND (b.check_in_date = ? OR b.check_out_date = ?) ");
            params.add(Date.valueOf(dateFilter));
            params.add(Date.valueOf(dateFilter));
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (b.booking_reference LIKE ? OR b.guest_name LIKE ? OR b.guest_email LIKE ? OR r.room_number LIKE ?) ");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
            params.add(term);
        }

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public boolean updateStatus(Long id, Booking.BookingStatus status, String cancellationReason, Connection conn) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = ?, cancellation_reason = ?, " +
                     "cancelled_at = ?, updated_at = NOW() WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setString(2, cancellationReason);
            stmt.setTimestamp(3, status == Booking.BookingStatus.CANCELLED ? Timestamp.valueOf(LocalDateTime.now()) : null);
            stmt.setLong(4, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean recordCheckIn(Long id, Connection conn) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = 'CHECKED_IN', checked_in_at = NOW(), updated_at = NOW() WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean recordCheckOut(Long id, Connection conn) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = 'CHECKED_OUT', checked_out_at = NOW(), updated_at = NOW() WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Booking> getTodayArrivals() throws SQLException {
        String sql = getJoinedBookingSql() +
                     "WHERE b.check_in_date = CURDATE() AND b.booking_status = 'CONFIRMED' " +
                     "ORDER BY b.id ASC";
        List<Booking> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<Booking> getTodayDepartures() throws SQLException {
        String sql = getJoinedBookingSql() +
                     "WHERE b.check_out_date = CURDATE() AND b.booking_status = 'CHECKED_IN' " +
                     "ORDER BY b.id ASC";
        List<Booking> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countByStatus(Booking.BookingStatus status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE booking_status = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private String getJoinedBookingSql() {
        return "SELECT b.*, " +
               "r.room_number, r.name AS room_name, r.room_type, r.primary_image_url, " +
               "u.email AS customer_email, " +
               "i.payment_status " +
               "FROM bookings b " +
               "JOIN rooms r ON b.room_id = r.id " +
               "JOIN users u ON b.user_id = u.id " +
               "LEFT JOIN invoices i ON b.id = i.booking_id ";
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setId(rs.getLong("id"));
        b.setBookingReference(rs.getString("booking_reference"));
        b.setUserId(rs.getLong("user_id"));
        b.setRoomId(rs.getLong("room_id"));
        b.setCheckInDate(rs.getDate("check_in_date").toLocalDate());
        b.setCheckOutDate(rs.getDate("check_out_date").toLocalDate());
        b.setTotalNights(rs.getInt("total_nights"));
        b.setNumGuests(rs.getInt("num_guests"));
        b.setGuestName(rs.getString("guest_name"));
        b.setGuestEmail(rs.getString("guest_email"));
        b.setGuestPhone(rs.getString("guest_phone"));
        b.setRoomPricePerNight(rs.getBigDecimal("room_price_per_night"));
        b.setBaseAmount(rs.getBigDecimal("base_amount"));
        b.setTaxAmount(rs.getBigDecimal("tax_amount"));
        b.setTotalAmount(rs.getBigDecimal("total_amount"));
        b.setBookingStatus(Booking.BookingStatus.valueOf(rs.getString("booking_status")));
        b.setSpecialRequests(rs.getString("special_requests"));
        b.setCancellationReason(rs.getString("cancellation_reason"));

        Timestamp cancelledAt = rs.getTimestamp("cancelled_at");
        if (cancelledAt != null) b.setCancelledAt(cancelledAt.toLocalDateTime());
        Timestamp checkInAt = rs.getTimestamp("checked_in_at");
        if (checkInAt != null) b.setCheckedInAt(checkInAt.toLocalDateTime());
        Timestamp checkOutAt = rs.getTimestamp("checked_out_at");
        if (checkOutAt != null) b.setCheckedOutAt(checkOutAt.toLocalDateTime());

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) b.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) b.setUpdatedAt(updatedAt.toLocalDateTime());

        // Joined fields
        b.setRoomNumber(rs.getString("room_number"));
        b.setRoomName(rs.getString("room_name"));
        String rt = rs.getString("room_type");
        if (rt != null) b.setRoomType(Room.RoomType.valueOf(rt));
        b.setRoomPrimaryImageUrl(rs.getString("primary_image_url"));
        b.setCustomerEmail(rs.getString("customer_email"));
        String ps = rs.getString("payment_status");
        if (ps != null) b.setPaymentStatus(Invoice.PaymentStatus.valueOf(ps));

        return b;
    }
}

package com.hotel.dao;

import com.hotel.model.Feedback;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO extends BaseDAO {

    public Long create(Feedback fb) throws SQLException {
        String sql = "INSERT INTO feedback " +
                     "(booking_id, user_id, hotel_id, room_id, rating, cleanliness_rating, service_rating, amenities_rating, " +
                     "comments, sentiment_label, rule_keywords_matched, is_approved, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, fb.getBookingId());
            stmt.setLong(2, fb.getUserId());
            stmt.setObject(3, fb.getHotelId() != null ? fb.getHotelId() : 1L);
            stmt.setLong(4, fb.getRoomId());
            stmt.setInt(5, fb.getRating());
            stmt.setInt(6, fb.getCleanlinessRating());
            stmt.setInt(7, fb.getServiceRating());
            stmt.setInt(8, fb.getAmenitiesRating());
            stmt.setString(9, fb.getComments());
            stmt.setString(10, fb.getSentimentLabel().name());
            stmt.setString(11, fb.getRuleKeywordsMatched());
            stmt.setBoolean(12, fb.isApproved());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    fb.setId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public Feedback findByBookingId(Long bookingId) throws SQLException {
        String sql = getJoinedFeedbackSql() + "WHERE f.booking_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<Feedback> listApprovedForRoom(Long roomId, int limit) throws SQLException {
        String sql = getJoinedFeedbackSql() +
                     "WHERE f.room_id = ? AND f.is_approved = TRUE " +
                     "ORDER BY f.id DESC LIMIT ?";
        List<Feedback> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, roomId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Feedback> listApprovedForHotel(Long hotelId, int limit) throws SQLException {
        String sql = getJoinedFeedbackSql() +
                     "WHERE (f.hotel_id = ? OR r.hotel_id = ?) AND f.is_approved = TRUE " +
                     "ORDER BY f.id DESC LIMIT ?";
        List<Feedback> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, hotelId);
            stmt.setLong(2, hotelId);
            stmt.setInt(3, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Feedback> listAll(Boolean approvedFilter, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(getJoinedFeedbackSql());
        List<Object> params = new ArrayList<>();

        if (approvedFilter != null) {
            sql.append("WHERE f.is_approved = ? ");
            params.add(approvedFilter);
        }

        sql.append("ORDER BY f.id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Feedback> list = new ArrayList<>();
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

    public int countAll(Boolean approvedFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM feedback f ");
        List<Object> params = new ArrayList<>();

        if (approvedFilter != null) {
            sql.append("WHERE f.is_approved = ? ");
            params.add(approvedFilter);
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

    public boolean updateApproval(Long id, boolean approved) throws SQLException {
        String sql = "UPDATE feedback SET is_approved = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, approved);
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean reply(Long id, String adminReply) throws SQLException {
        String sql = "UPDATE feedback SET admin_reply = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, adminReply);
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public double getAverageRatingForRoom(Long roomId) throws SQLException {
        String sql = "SELECT COALESCE(AVG(rating), 0.0) FROM feedback WHERE room_id = ? AND is_approved = TRUE";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, roomId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        }
        return 0.0;
    }

    private String getJoinedFeedbackSql() {
        return "SELECT f.*, u.full_name AS customer_name, u.email AS customer_email, " +
               "r.name AS room_name, r.room_number, b.booking_reference, h.name AS hotel_name " +
               "FROM feedback f " +
               "JOIN users u ON f.user_id = u.id " +
               "JOIN rooms r ON f.room_id = r.id " +
               "JOIN bookings b ON f.booking_id = b.id " +
               "LEFT JOIN hotels h ON (f.hotel_id = h.id OR r.hotel_id = h.id) ";
    }

    private Feedback mapRow(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setId(rs.getLong("id"));
        f.setBookingId(rs.getLong("booking_id"));
        f.setUserId(rs.getLong("user_id"));
        try { f.setHotelId(rs.getLong("hotel_id")); } catch (SQLException ignored) {}
        f.setRoomId(rs.getLong("room_id"));
        f.setRating(rs.getInt("rating"));
        f.setCleanlinessRating(rs.getInt("cleanliness_rating"));
        f.setServiceRating(rs.getInt("service_rating"));
        f.setAmenitiesRating(rs.getInt("amenities_rating"));
        f.setComments(rs.getString("comments"));
        f.setSentimentLabel(Feedback.SentimentLabel.valueOf(rs.getString("sentiment_label")));
        f.setRuleKeywordsMatched(rs.getString("rule_keywords_matched"));
        f.setApproved(rs.getBoolean("is_approved"));
        f.setAdminReply(rs.getString("admin_reply"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) f.setCreatedAt(c.toLocalDateTime());

        f.setCustomerName(rs.getString("customer_name"));
        f.setCustomerEmail(rs.getString("customer_email"));
        f.setRoomName(rs.getString("room_name"));
        f.setRoomNumber(rs.getString("room_number"));
        f.setBookingReference(rs.getString("booking_reference"));
        try { f.setHotelName(rs.getString("hotel_name")); } catch (SQLException ignored) {}

        return f;
    }
}

package com.hotel.dao;

import com.hotel.model.CustomerProfile;

import java.sql.*;

public class CustomerProfileDAO extends BaseDAO {

    public CustomerProfile findByUserId(Long userId) throws SQLException {
        String sql = "SELECT * FROM customer_profiles WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public boolean saveOrUpdate(CustomerProfile profile) throws SQLException {
        String sql = "INSERT INTO customer_profiles " +
                     "(user_id, id_document_type, id_document_number, address, city, state_province, country, postal_code, emergency_contact, preferences_notes, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW()) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "id_document_type = VALUES(id_document_type), " +
                     "id_document_number = VALUES(id_document_number), " +
                     "address = VALUES(address), " +
                     "city = VALUES(city), " +
                     "state_province = VALUES(state_province), " +
                     "country = VALUES(country), " +
                     "postal_code = VALUES(postal_code), " +
                     "emergency_contact = VALUES(emergency_contact), " +
                     "preferences_notes = VALUES(preferences_notes), " +
                     "updated_at = NOW()";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, profile.getUserId());
            stmt.setString(2, profile.getIdDocumentType());
            stmt.setString(3, profile.getIdDocumentNumber());
            stmt.setString(4, profile.getAddress());
            stmt.setString(5, profile.getCity());
            stmt.setString(6, profile.getStateProvince());
            stmt.setString(7, profile.getCountry());
            stmt.setString(8, profile.getPostalCode());
            stmt.setString(9, profile.getEmergencyContact());
            stmt.setString(10, profile.getPreferencesNotes());

            return stmt.executeUpdate() > 0;
        }
    }

    private CustomerProfile mapRow(ResultSet rs) throws SQLException {
        CustomerProfile p = new CustomerProfile();
        p.setId(rs.getLong("id"));
        p.setUserId(rs.getLong("user_id"));
        p.setIdDocumentType(rs.getString("id_document_type"));
        p.setIdDocumentNumber(rs.getString("id_document_number"));
        p.setAddress(rs.getString("address"));
        p.setCity(rs.getString("city"));
        p.setStateProvince(rs.getString("state_province"));
        p.setCountry(rs.getString("country"));
        p.setPostalCode(rs.getString("postal_code"));
        p.setEmergencyContact(rs.getString("emergency_contact"));
        p.setPreferencesNotes(rs.getString("preferences_notes"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) p.setCreatedAt(c.toLocalDateTime());
        Timestamp u = rs.getTimestamp("updated_at");
        if (u != null) p.setUpdatedAt(u.toLocalDateTime());

        return p;
    }
}

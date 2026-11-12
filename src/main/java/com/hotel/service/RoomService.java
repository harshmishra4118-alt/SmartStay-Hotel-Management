package com.hotel.service;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Room;
import com.hotel.util.ValidationUtil;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class RoomService {

    private final RoomDAO roomDAO = new RoomDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public List<Room> getAllRooms(Room.OperationalStatus operationalFilter,
                                  Room.HousekeepingStatus housekeepingFilter,
                                  Room.RoomType typeFilter,
                                  String search) throws SQLException {
        return roomDAO.listAllRooms(null, operationalFilter, housekeepingFilter, typeFilter, search);
    }

    public List<Room> getAllRooms(Long hotelId,
                                  Room.OperationalStatus operationalFilter,
                                  Room.HousekeepingStatus housekeepingFilter,
                                  Room.RoomType typeFilter,
                                  String search) throws SQLException {
        return roomDAO.listAllRooms(hotelId, operationalFilter, housekeepingFilter, typeFilter, search);
    }

    public List<Room> searchAvailableRooms(LocalDate checkIn, LocalDate checkOut,
                                           Integer guests, BigDecimal maxBudget,
                                           Room.RoomType roomType) throws SQLException {
        return roomDAO.searchAvailableRooms(checkIn, checkOut, guests, maxBudget, roomType);
    }

    public Room getRoomById(Long id) throws SQLException {
        return roomDAO.findById(id);
    }

    public Room getRoomByNumber(String roomNumber) throws SQLException {
        return roomDAO.findByRoomNumber(roomNumber);
    }

    public Long createRoom(Room room, Long adminUserId, String clientIp) throws Exception {
        validateRoom(room);

        Room existing = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existing != null) {
            throw new IllegalArgumentException("Room number '" + room.getRoomNumber() + "' already exists.");
        }

        Long id = roomDAO.create(room);
        auditLogDAO.log(adminUserId, "ROOM_CREATED", "Room", String.valueOf(id),
                "Created room #" + room.getRoomNumber() + " (" + room.getRoomType() + ")", clientIp);
        return id;
    }

    public void updateRoom(Room room, Long adminUserId, String clientIp) throws Exception {
        validateRoom(room);

        Room existing = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existing != null && !existing.getId().equals(room.getId())) {
            throw new IllegalArgumentException("Room number '" + room.getRoomNumber() + "' is already used by another room.");
        }

        roomDAO.update(room);
        auditLogDAO.log(adminUserId, "ROOM_UPDATED", "Room", String.valueOf(room.getId()),
                "Updated details for room #" + room.getRoomNumber(), clientIp);
    }

    public void setOperationalStatus(Long roomId, Room.OperationalStatus status, Long staffUserId, String clientIp) throws SQLException {
        roomDAO.updateOperationalStatus(roomId, status);
        auditLogDAO.log(staffUserId, "ROOM_OPERATIONAL_STATUS_CHANGED", "Room", String.valueOf(roomId),
                "Operational status changed to " + status, clientIp);
    }

    public void setHousekeepingStatus(Long roomId, Room.HousekeepingStatus status, Long staffUserId, String clientIp) throws SQLException {
        roomDAO.updateHousekeepingStatus(roomId, status);
        auditLogDAO.log(staffUserId, "ROOM_HOUSEKEEPING_STATUS_CHANGED", "Room", String.valueOf(roomId),
                "Housekeeping status changed to " + status, clientIp);
    }

    public List<Room> getFeaturedRooms(int limit) throws SQLException {
        return roomDAO.getFeaturedRooms(limit);
    }

    private void validateRoom(Room room) {
        if (!ValidationUtil.isValidRoomNumber(room.getRoomNumber())) {
            throw new IllegalArgumentException("Invalid room number format. Alphanumeric and hyphens only.");
        }
        if (!ValidationUtil.isNotEmpty(room.getName())) {
            throw new IllegalArgumentException("Room name is required.");
        }
        if (room.getPricePerNight() == null || room.getPricePerNight().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Price per night must be greater than zero.");
        }
        if (room.getCapacity() <= 0 || room.getCapacity() > 10) {
            throw new IllegalArgumentException("Room capacity must be between 1 and 10 guests.");
        }
    }
}

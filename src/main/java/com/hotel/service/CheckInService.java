package com.hotel.service;

import com.hotel.config.DatabaseConfig;
import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.NotificationDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Notification;
import com.hotel.model.Room;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class CheckInService {

    private static final Logger logger = LoggerFactory.getLogger(CheckInService.class);

    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public void processCheckIn(Long bookingId, Long staffUserId, String clientIp) throws Exception {
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (booking.getBookingStatus() != Booking.BookingStatus.CONFIRMED) {
            throw new IllegalStateException("Only CONFIRMED bookings can be checked in. Current status: " + booking.getBookingStatus());
        }

        Room room = roomDAO.findById(booking.getRoomId());
        if (room == null || room.getOperationalStatus() != Room.OperationalStatus.ACTIVE) {
            throw new IllegalStateException("Room is not in active operational state.");
        }

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                bookingDAO.recordCheckIn(bookingId, conn);

                // Update room housekeeping if needed
                roomDAO.updateHousekeepingStatus(room.getId(), Room.HousekeepingStatus.CLEAN);

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }

        notificationDAO.create(new Notification(
                booking.getUserId(),
                "Welcome to SmartStay! Checked In to Room " + booking.getRoomNumber(),
                "You have been successfully checked in to Room " + booking.getRoomNumber() + ". Enjoy your stay!",
                Notification.NotificationType.CHECKIN,
                "/customer/booking-details?ref=" + booking.getBookingReference()
        ));

        auditLogDAO.log(staffUserId, "GUEST_CHECKED_IN", "Booking", String.valueOf(bookingId),
                "Checked in guest " + booking.getGuestName() + " to Room #" + booking.getRoomNumber(), clientIp);
    }

    public void processCheckOut(Long bookingId, Long staffUserId, String clientIp) throws Exception {
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (booking.getBookingStatus() != Booking.BookingStatus.CHECKED_IN) {
            throw new IllegalStateException("Only CHECKED_IN bookings can be checked out. Current status: " + booking.getBookingStatus());
        }

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                bookingDAO.recordCheckOut(bookingId, conn);

                // Automatically flag room as DIRTY so housekeeping team is notified
                roomDAO.updateHousekeepingStatus(booking.getRoomId(), Room.HousekeepingStatus.DIRTY);

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }

        notificationDAO.create(new Notification(
                booking.getUserId(),
                "Checked Out: Thank you for staying with us!",
                "You have successfully checked out of Room " + booking.getRoomNumber() + ". We would love your feedback!",
                Notification.NotificationType.CHECKOUT,
                "/customer/feedback?bookingRef=" + booking.getBookingReference()
        ));

        auditLogDAO.log(staffUserId, "GUEST_CHECKED_OUT", "Booking", String.valueOf(bookingId),
                "Checked out guest " + booking.getGuestName() + " from Room #" + booking.getRoomNumber() + ". Room marked DIRTY.", clientIp);
    }

    public List<Booking> getTodayArrivals() throws SQLException {
        return bookingDAO.getTodayArrivals();
    }

    public List<Booking> getTodayArrivals(Long hotelId) throws SQLException {
        return bookingDAO.getTodayArrivals(hotelId);
    }

    public List<Booking> getTodayDepartures() throws SQLException {
        return bookingDAO.getTodayDepartures();
    }

    public List<Booking> getTodayDepartures(Long hotelId) throws SQLException {
        return bookingDAO.getTodayDepartures(hotelId);
    }
}

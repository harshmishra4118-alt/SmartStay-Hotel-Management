package com.hotel.service;

import com.hotel.config.DatabaseConfig;
import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.InvoiceDAO;
import com.hotel.dao.NotificationDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Invoice;
import com.hotel.model.Notification;
import com.hotel.model.Room;
import com.hotel.util.DateUtil;
import com.hotel.util.ValidationUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class BookingService {

    private static final Logger logger = LoggerFactory.getLogger(BookingService.class);
    private static final BigDecimal TAX_RATE = new BigDecimal("0.12"); // 12% GST / Luxury tax
    private static final SecureRandom random = new SecureRandom();

    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public static class PriceBreakdown {
        public int nights;
        public BigDecimal pricePerNight;
        public BigDecimal baseAmount;
        public BigDecimal taxAmount;
        public BigDecimal totalAmount;
    }

    public PriceBreakdown calculatePricing(BigDecimal pricePerNight, LocalDate checkIn, LocalDate checkOut) {
        if (pricePerNight == null || checkIn == null || checkOut == null) {
            throw new IllegalArgumentException("Invalid price or dates for calculation.");
        }
        int nights = DateUtil.calculateNights(checkIn, checkOut);
        if (nights <= 0) {
            throw new IllegalArgumentException("Check-out date must be strictly after check-in date.");
        }

        PriceBreakdown pb = new PriceBreakdown();
        pb.nights = nights;
        pb.pricePerNight = pricePerNight;
        pb.baseAmount = pricePerNight.multiply(BigDecimal.valueOf(nights)).setScale(2, RoundingMode.HALF_UP);
        pb.taxAmount = pb.baseAmount.multiply(TAX_RATE).setScale(2, RoundingMode.HALF_UP);
        pb.totalAmount = pb.baseAmount.add(pb.taxAmount).setScale(2, RoundingMode.HALF_UP);
        return pb;
    }

    /**
     * Atomically creates a reservation and matching invoice with transaction isolation.
     */
    public Booking createReservation(Long userId, Long roomId, LocalDate checkIn, LocalDate checkOut,
                                     int numGuests, String guestName, String guestEmail, String guestPhone,
                                     String specialRequests, String clientIp) throws Exception {

        if (!ValidationUtil.isValidDateRange(checkIn, checkOut)) {
            throw new IllegalArgumentException("Invalid reservation dates. Check-in must be today or future date.");
        }
        if (!ValidationUtil.isNotEmpty(guestName)) {
            throw new IllegalArgumentException("Primary guest name is required.");
        }
        if (!ValidationUtil.isValidEmail(guestEmail)) {
            throw new IllegalArgumentException("Valid guest email is required.");
        }
        if (!ValidationUtil.isValidPhone(guestPhone)) {
            throw new IllegalArgumentException("Valid guest phone number is required.");
        }

        Room room = roomDAO.findById(roomId);
        if (room == null || room.getOperationalStatus() != Room.OperationalStatus.ACTIVE) {
            throw new IllegalArgumentException("Selected room is not currently available for reservation.");
        }
        if (numGuests > room.getCapacity()) {
            throw new IllegalArgumentException("Selected room capacity is " + room.getCapacity() + " guests.");
        }

        PriceBreakdown pricing = calculatePricing(room.getPricePerNight(), checkIn, checkOut);

        Booking booking = new Booking();
        booking.setBookingReference(generateBookingReference());
        booking.setUserId(userId);
        booking.setRoomId(roomId);
        booking.setCheckInDate(checkIn);
        booking.setCheckOutDate(checkOut);
        booking.setTotalNights(pricing.nights);
        booking.setNumGuests(numGuests);
        booking.setGuestName(guestName.trim());
        booking.setGuestEmail(guestEmail.trim());
        booking.setGuestPhone(guestPhone.trim());
        booking.setRoomPricePerNight(pricing.pricePerNight);
        booking.setBaseAmount(pricing.baseAmount);
        booking.setTaxAmount(pricing.taxAmount);
        booking.setTotalAmount(pricing.totalAmount);
        booking.setBookingStatus(Booking.BookingStatus.CONFIRMED);
        booking.setSpecialRequests(specialRequests);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false); // Begin database transaction

            // Concurrency check with row lock
            boolean available = bookingDAO.isRoomAvailable(conn, roomId, checkIn, checkOut, null);
            if (!available) {
                conn.rollback();
                throw new IllegalStateException("Selected room was just reserved by another guest for these dates. Please choose another room or change dates.");
            }

            Long bookingId = bookingDAO.create(booking, conn);
            booking.setId(bookingId);

            // Automatically generate matching Invoice
            Invoice invoice = new Invoice();
            invoice.setInvoiceNumber("INV-" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMM")) + "-" + (1000 + random.nextInt(9000)));
            invoice.setBookingId(bookingId);
            invoice.setUserId(userId);
            invoice.setSubtotalAmount(pricing.baseAmount);
            invoice.setTaxRate(new BigDecimal("12.00"));
            invoice.setTaxAmount(pricing.taxAmount);
            invoice.setDiscountAmount(BigDecimal.ZERO);
            invoice.setTotalPayable(pricing.totalAmount);
            invoice.setPaymentStatus(Invoice.PaymentStatus.UNPAID);
            invoice.setNotes("Reservation invoice for " + room.getName() + " (" + pricing.nights + " nights)");

            invoiceDAO.create(invoice, conn);

            conn.commit(); // Transaction succeeded!
            logger.info("Successfully created booking {} and invoice {}", booking.getBookingReference(), invoice.getInvoiceNumber());

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { logger.error("Rollback failed", ex); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { logger.warn("Failed to close connection", ex); }
            }
        }

        // Send confirmation notification
        try {
            notificationDAO.create(new Notification(
                    userId,
                    "Reservation Confirmed: " + booking.getBookingReference(),
                    "Your reservation for " + room.getName() + " from " + DateUtil.formatDisplayDate(checkIn) +
                            " to " + DateUtil.formatDisplayDate(checkOut) + " has been confirmed.",
                    Notification.NotificationType.BOOKING,
                    "/customer/booking-details?ref=" + booking.getBookingReference()
            ));
        } catch (Exception e) {
            logger.warn("Could not save confirmation notification: {}", e.getMessage());
        }

        auditLogDAO.log(userId, "BOOKING_CREATED", "Booking", String.valueOf(booking.getId()),
                "Created booking " + booking.getBookingReference() + " for Room " + room.getRoomNumber(), clientIp);

        return booking;
    }

    public void cancelReservation(Long bookingId, Long requestingUserId, boolean isAdminOrStaff,
                                  String reason, String clientIp) throws Exception {
        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }

        if (!isAdminOrStaff && !booking.getUserId().equals(requestingUserId)) {
            throw new SecurityException("You do not have permission to cancel this booking.");
        }

        if (booking.getBookingStatus() == Booking.BookingStatus.CANCELLED) {
            throw new IllegalStateException("Booking is already cancelled.");
        }
        if (booking.getBookingStatus() == Booking.BookingStatus.CHECKED_OUT) {
            throw new IllegalStateException("Cannot cancel an already completed stay.");
        }
        if (!isAdminOrStaff && !booking.canBeCancelled()) {
            throw new IllegalStateException("Bookings starting today or in the past cannot be cancelled online. Please contact the front desk.");
        }

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                bookingDAO.updateStatus(bookingId, Booking.BookingStatus.CANCELLED, reason, conn);

                // Update invoice to REFUNDED if paid, or keep updated
                Invoice invoice = invoiceDAO.findByBookingId(bookingId);
                if (invoice != null && invoice.getPaymentStatus() == Invoice.PaymentStatus.PAID) {
                    invoiceDAO.updatePaymentStatus(invoice.getId(), Invoice.PaymentStatus.REFUNDED, conn);
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }

        notificationDAO.create(new Notification(
                booking.getUserId(),
                "Reservation Cancelled: " + booking.getBookingReference(),
                "Your reservation " + booking.getBookingReference() + " has been cancelled. " +
                        (reason != null ? "Reason: " + reason : ""),
                Notification.NotificationType.BOOKING,
                "/customer/my-bookings"
        ));

        auditLogDAO.log(requestingUserId, "BOOKING_CANCELLED", "Booking", String.valueOf(bookingId),
                "Cancelled reservation " + booking.getBookingReference() + ". Reason: " + reason, clientIp);
    }

    public Booking getBookingById(Long id) throws SQLException {
        return bookingDAO.findById(id);
    }

    public Booking getBookingByReference(String reference) throws SQLException {
        return bookingDAO.findByReference(reference);
    }

    public List<Booking> getBookingsByUser(Long userId) throws SQLException {
        return bookingDAO.listByUser(userId);
    }

    public List<Booking> listAllBookings(Booking.BookingStatus status, LocalDate date, String search, int offset, int limit) throws SQLException {
        return bookingDAO.listAll(status, date, search, offset, limit);
    }

    public int countAllBookings(Booking.BookingStatus status, LocalDate date, String search) throws SQLException {
        return bookingDAO.countAll(status, date, search);
    }

    private String generateBookingReference() {
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        StringBuilder sb = new StringBuilder("ASTAY-").append(datePart).append("-");
        for (int i = 0; i < 4; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }
}

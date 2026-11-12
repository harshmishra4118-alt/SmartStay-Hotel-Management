package com.hotel.service;

import com.hotel.config.DatabaseConfig;
import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.InvoiceDAO;
import com.hotel.dao.NotificationDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Hotel;
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
    private final EmailService emailService = new EmailService();
    private final RazorpayPaymentService paymentService = new RazorpayPaymentService();

    public static class PriceBreakdown {
        public int nights;
        public BigDecimal pricePerNight;
        public BigDecimal baseAmount;
        public BigDecimal taxAmount;
        public BigDecimal totalAmount;

        public int getNights() { return nights; }
        public void setNights(int nights) { this.nights = nights; }

        public BigDecimal getPricePerNight() { return pricePerNight; }
        public void setPricePerNight(BigDecimal pricePerNight) { this.pricePerNight = pricePerNight; }

        public BigDecimal getBaseAmount() { return baseAmount; }
        public void setBaseAmount(BigDecimal baseAmount) { this.baseAmount = baseAmount; }

        public BigDecimal getTaxAmount() { return taxAmount; }
        public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

        public BigDecimal getTotalAmount() { return totalAmount; }
        public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
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
        return createReservation(userId, roomId, checkIn, checkOut, numGuests, guestName, guestEmail, guestPhone,
                specialRequests, clientIp, BigDecimal.ZERO, null);
    }

    public Booking createReservation(Long userId, Long roomId, LocalDate checkIn, LocalDate checkOut,
                                     int numGuests, String guestName, String guestEmail, String guestPhone,
                                     String specialRequests, String clientIp,
                                     BigDecimal discountAmount, String couponCode) throws Exception {

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

        BigDecimal effectiveDiscount = (discountAmount != null && discountAmount.compareTo(BigDecimal.ZERO) > 0)
                ? discountAmount : BigDecimal.ZERO;
        if (effectiveDiscount.compareTo(pricing.baseAmount) > 0) {
            effectiveDiscount = pricing.baseAmount;
        }

        BigDecimal discountedBase = pricing.baseAmount.subtract(effectiveDiscount);
        BigDecimal effectiveTax = discountedBase.multiply(TAX_RATE).setScale(2, RoundingMode.HALF_UP);
        BigDecimal finalPayable = discountedBase.add(effectiveTax).setScale(2, RoundingMode.HALF_UP);

        Booking booking = new Booking();
        booking.setBookingReference(generateBookingReference());
        booking.setUserId(userId);
        booking.setHotelId(room.getHotelId() != null ? room.getHotelId() : 1L);
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
        booking.setTaxAmount(effectiveTax);
        booking.setTotalAmount(finalPayable);
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
            invoice.setTaxAmount(effectiveTax);
            invoice.setDiscountAmount(effectiveDiscount);
            invoice.setTotalPayable(finalPayable);
            invoice.setPaymentStatus(Invoice.PaymentStatus.UNPAID);
            String note = "Reservation for " + room.getName() + " (" + pricing.nights + " nights)";
            if (couponCode != null && !couponCode.trim().isEmpty()) {
                note += " [Coupon: " + couponCode.trim().toUpperCase() + ", Discount: Rs " + effectiveDiscount + "]";
            }
            invoice.setNotes(note);

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

        // Send confirmation email via Gmail SMTP
        try {
            com.hotel.dao.HotelDAO hotelDAO = new com.hotel.dao.HotelDAO();
            Hotel hotel = hotelDAO.findById(booking.getHotelId());
            emailService.sendBookingConfirmation(booking.getGuestEmail(), booking, hotel, room);
        } catch (Exception e) {
            logger.warn("Could not send confirmation email: {}", e.getMessage());
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
                    try {
                        paymentService.processRefund(bookingId, invoice.getTotalPayable(), reason);
                    } catch (Exception ex) {
                        logger.warn("Could not process online refund record: {}", ex.getMessage());
                    }
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

    public List<Booking> getBookingsByHotel(Long hotelId, String status, String search) throws SQLException {
        if (hotelId == null) {
            return listAllBookings(null, null, search, 0, 100);
        }
        return bookingDAO.findByHotelId(hotelId, status, search);
    }

    public int getHotelTodayArrivals(Long hotelId) throws SQLException {
        return bookingDAO.countTodayArrivals(hotelId);
    }

    public int getHotelTodayDepartures(Long hotelId) throws SQLException {
        return bookingDAO.countTodayDepartures(hotelId);
    }

    public int getHotelActiveGuests(Long hotelId) throws SQLException {
        return bookingDAO.countActiveGuests(hotelId);
    }

    public List<Booking> getBookingsByUser(Long userId) throws SQLException {
        return bookingDAO.listByUser(userId);
    }

    public List<Booking> listAllBookings(Booking.BookingStatus status, LocalDate date, String search, int offset, int limit) throws SQLException {
        return bookingDAO.listAll(null, status, date, search, offset, limit);
    }

    public List<Booking> listAllBookings(Long hotelId, Booking.BookingStatus status, LocalDate date, String search, int offset, int limit) throws SQLException {
        return bookingDAO.listAll(hotelId, status, date, search, offset, limit);
    }

    public int countAllBookings(Booking.BookingStatus status, LocalDate date, String search) throws SQLException {
        return bookingDAO.countAll(null, status, date, search);
    }

    public int countAllBookings(Long hotelId, Booking.BookingStatus status, LocalDate date, String search) throws SQLException {
        return bookingDAO.countAll(hotelId, status, date, search);
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

package com.hotel.service;

import com.hotel.model.Booking;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

public class BookingServiceTest {

    private final BookingService bookingService = new BookingService();

    @Test
    public void testPriceCalculation3Nights() {
        BigDecimal pricePerNight = new BigDecimal("5000.00");
        LocalDate checkIn = LocalDate.now().plusDays(2);
        LocalDate checkOut = checkIn.plusDays(3);

        BookingService.PriceBreakdown pb = bookingService.calculatePricing(pricePerNight, checkIn, checkOut);

        assertEquals(3, pb.nights);
        assertEquals(new BigDecimal("15000.00"), pb.baseAmount);
        assertEquals(new BigDecimal("1800.00"), pb.taxAmount); // 12% of 15000 = 1800
        assertEquals(new BigDecimal("16800.00"), pb.totalAmount);
    }

    @Test
    public void testPriceCalculationInvalidDates() {
        BigDecimal price = new BigDecimal("4000.00");
        LocalDate checkIn = LocalDate.now().plusDays(5);
        LocalDate checkOut = checkIn; // 0 nights

        assertThrows(IllegalArgumentException.class, () -> bookingService.calculatePricing(price, checkIn, checkOut));
    }

    @Test
    public void testBookingStatusTransitions() {
        Booking booking = new Booking();
        booking.setCheckInDate(LocalDate.now().plusDays(2));
        booking.setBookingStatus(Booking.BookingStatus.CONFIRMED);

        // Future confirmed booking can be cancelled
        assertTrue(booking.canBeCancelled());
        assertTrue(booking.canCheckIn());
        assertFalse(booking.canCheckOut());

        // Checked in booking
        booking.setBookingStatus(Booking.BookingStatus.CHECKED_IN);
        assertFalse(booking.canCheckIn());
        assertTrue(booking.canCheckOut());

        // Cancelled booking
        booking.setBookingStatus(Booking.BookingStatus.CANCELLED);
        assertFalse(booking.canBeCancelled());
        assertFalse(booking.canCheckIn());
        assertFalse(booking.canCheckOut());
    }
}

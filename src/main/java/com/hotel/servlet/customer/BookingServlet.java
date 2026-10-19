package com.hotel.servlet.customer;

import com.hotel.model.Booking;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.service.BookingService;
import com.hotel.service.RoomService;
import com.hotel.util.DateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet(name = "BookingServlet", urlPatterns = {"/customer/book"})
public class BookingServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(BookingServlet.class);
    private final RoomService roomService = new RoomService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roomIdStr = req.getParameter("roomId");
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/rooms");
            return;
        }

        try {
            Long roomId = Long.parseLong(roomIdStr.trim());
            Room room = roomService.getRoomById(roomId);
            if (room == null || !room.isAvailableForBooking()) {
                req.setAttribute("errorMessage", "Selected room is currently not available for new reservations.");
                req.getRequestDispatcher("/WEB-INF/views/public/rooms.jsp").forward(req, resp);
                return;
            }

            String checkInStr = req.getParameter("checkIn");
            String checkOutStr = req.getParameter("checkOut");
            String guestsStr = req.getParameter("guests");

            LocalDate checkIn = DateUtil.parseDate(checkInStr);
            LocalDate checkOut = DateUtil.parseDate(checkOutStr);
            if (checkIn == null) checkIn = LocalDate.now();
            if (checkOut == null) checkOut = checkIn.plusDays(1);

            int guests = 1;
            if (guestsStr != null && !guestsStr.trim().isEmpty()) {
                try { guests = Integer.parseInt(guestsStr.trim()); } catch (Exception ignored) {}
            }

            BookingService.PriceBreakdown pricing = bookingService.calculatePricing(room.getPricePerNight(), checkIn, checkOut);

            req.setAttribute("room", room);
            req.setAttribute("checkIn", DateUtil.formatDate(checkIn));
            req.setAttribute("checkOut", DateUtil.formatDate(checkOut));
            req.setAttribute("guests", guests);
            req.setAttribute("pricing", pricing);

            req.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Error loading booking form", e);
            resp.sendRedirect(req.getContextPath() + "/rooms");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String roomIdStr = req.getParameter("roomId");
        String checkInStr = req.getParameter("checkIn");
        String checkOutStr = req.getParameter("checkOut");
        String guestsStr = req.getParameter("guests");
        String guestName = req.getParameter("guestName");
        String guestEmail = req.getParameter("guestEmail");
        String guestPhone = req.getParameter("guestPhone");
        String specialRequests = req.getParameter("specialRequests");

        try {
            Long roomId = Long.parseLong(roomIdStr.trim());
            LocalDate checkIn = DateUtil.parseDate(checkInStr);
            LocalDate checkOut = DateUtil.parseDate(checkOutStr);
            int numGuests = Integer.parseInt(guestsStr.trim());

            Booking booking = bookingService.createReservation(
                    currentUser.getId(),
                    roomId,
                    checkIn,
                    checkOut,
                    numGuests,
                    guestName,
                    guestEmail,
                    guestPhone,
                    specialRequests,
                    req.getRemoteAddr()
            );

            logger.info("Booking created successfully: {}", booking.getBookingReference());
            resp.sendRedirect(req.getContextPath() + "/customer/booking-details?ref=" + booking.getBookingReference() + "&confirmed=true");

        } catch (IllegalArgumentException | IllegalStateException e) {
            req.setAttribute("errorMessage", e.getMessage());
            try {
                Long roomId = Long.parseLong(roomIdStr.trim());
                req.setAttribute("room", roomService.getRoomById(roomId));
            } catch (Exception ignored) {}
            req.setAttribute("checkIn", checkInStr);
            req.setAttribute("checkOut", checkOutStr);
            req.setAttribute("guests", guestsStr);
            req.setAttribute("guestName", guestName);
            req.setAttribute("guestEmail", guestEmail);
            req.setAttribute("guestPhone", guestPhone);
            req.setAttribute("specialRequests", specialRequests);
            req.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(req, resp);
        } catch (Exception e) {
            logger.error("Booking reservation failure", e);
            req.setAttribute("errorMessage", "An error occurred while confirming your reservation. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(req, resp);
        }
    }
}

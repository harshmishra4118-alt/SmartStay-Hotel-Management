package com.hotel.servlet.publicsite;

import com.hotel.model.Feedback;
import com.hotel.model.Hotel;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.service.FeedbackService;
import com.hotel.service.HotelService;
import com.hotel.service.LocationService;
import com.hotel.service.WishlistService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "HotelDetailServlet", urlPatterns = {"/hotel"})
public class HotelDetailServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HotelDetailServlet.class);
    private final HotelService hotelService = new HotelService();
    private final FeedbackService feedbackService = new FeedbackService();
    private final LocationService locationService = new LocationService();
    private final WishlistService wishlistService = new WishlistService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/hotels");
            return;
        }

        try {
            Long hotelId = Long.parseLong(idStr.trim());
            Hotel hotel = hotelService.getHotelById(hotelId);
            if (hotel == null) {
                req.setAttribute("errorMessage", "The requested luxury hotel could not be found.");
                req.getRequestDispatcher("/WEB-INF/views/common/404.jsp").forward(req, resp);
                return;
            }

            // Dates & guest search filters
            String checkInStr = req.getParameter("checkIn");
            String checkOutStr = req.getParameter("checkOut");
            String guestsStr = req.getParameter("guests");
            String typeStr = req.getParameter("roomType");

            LocalDate checkIn = null;
            LocalDate checkOut = null;
            Integer guests = null;
            Room.RoomType roomType = null;

            if (checkInStr != null && !checkInStr.trim().isEmpty()) {
                try { checkIn = LocalDate.parse(checkInStr.trim()); } catch (DateTimeParseException ignored) {}
            }
            if (checkOutStr != null && !checkOutStr.trim().isEmpty()) {
                try { checkOut = LocalDate.parse(checkOutStr.trim()); } catch (DateTimeParseException ignored) {}
            }
            if (guestsStr != null && !guestsStr.trim().isEmpty()) {
                try { guests = Integer.parseInt(guestsStr.trim()); } catch (NumberFormatException ignored) {}
            }
            if (typeStr != null && !typeStr.trim().isEmpty()) {
                try { roomType = Room.RoomType.valueOf(typeStr.trim().toUpperCase()); } catch (IllegalArgumentException ignored) {}
            }

            List<Room> rooms;
            if (checkIn != null && checkOut != null && checkOut.isAfter(checkIn)) {
                rooms = hotelService.getAvailableRoomsForHotel(hotelId, checkIn, checkOut, guests, roomType);
                req.setAttribute("availabilityChecked", true);
            } else {
                rooms = hotel.getRooms();
                req.setAttribute("availabilityChecked", false);
            }

            // GPS Location calculations
            String latStr = req.getParameter("lat");
            String lngStr = req.getParameter("lng");
            if (latStr != null && lngStr != null) {
                try {
                    double userLat = Double.parseDouble(latStr.trim());
                    double userLng = Double.parseDouble(lngStr.trim());
                    double dist = locationService.calculateDistance(
                            userLat, userLng,
                            hotel.getLatitude().doubleValue(),
                            hotel.getLongitude().doubleValue()
                    );
                    hotel.setDistanceKm(dist);
                    hotel.setDrivingTimeEstimate(locationService.formatDrivingTime(dist));
                    hotel.setWalkingTimeEstimate(locationService.formatWalkingTime(dist));
                    req.setAttribute("directionsUrl", locationService.generateDirectionsUrl(
                            userLat, userLng, hotel.getLatitude(), hotel.getLongitude()
                    ));
                    req.setAttribute("userLat", userLat);
                    req.setAttribute("userLng", userLng);
                } catch (NumberFormatException ignored) {}
            }

            // Check wishlist favorite status
            HttpSession session = req.getSession(false);
            if (session != null) {
                User user = (User) session.getAttribute("currentUser");
                if (user != null) {
                    boolean isFav = wishlistService.isFavorite(user.getId(), hotelId);
                    hotel.setFavorite(isFav);
                }
            }

            // Reviews for this hotel
            List<Feedback> reviews = feedbackService.getApprovedReviewsForHotel(hotelId, 10);

            req.setAttribute("hotel", hotel);
            req.setAttribute("rooms", rooms);
            req.setAttribute("reviews", reviews);
            req.setAttribute("checkIn", checkIn);
            req.setAttribute("checkOut", checkOut);
            req.setAttribute("guests", guests);
            req.setAttribute("roomType", roomType);

            req.getRequestDispatcher("/WEB-INF/views/public/hotel-detail.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/hotels");
        } catch (SQLException e) {
            logger.error("Error retrieving hotel details", e);
            req.setAttribute("errorMessage", "An error occurred while loading hotel information.");
            req.getRequestDispatcher("/WEB-INF/views/common/500.jsp").forward(req, resp);
        }
    }
}


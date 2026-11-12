package com.hotel.servlet.publicsite;

import com.hotel.model.Hotel;
import com.hotel.service.HotelService;
import com.hotel.service.LocationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "HotelsServlet", urlPatterns = {"/hotels"})
public class HotelsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HotelsServlet.class);
    private final HotelService hotelService = new HotelService();
    private final LocationService locationService = new LocationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String query = req.getParameter("q");
            String city = req.getParameter("city");
            String minPriceStr = req.getParameter("minPrice");
            String maxPriceStr = req.getParameter("maxPrice");
            String minRatingStr = req.getParameter("minRating");
            String sortBy = req.getParameter("sortBy");
            String[] facilitiesArr = req.getParameterValues("facilities");
            String latStr = req.getParameter("lat");
            String lngStr = req.getParameter("lng");

            BigDecimal minPrice = null;
            if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                try { minPrice = new BigDecimal(minPriceStr.trim()); } catch (NumberFormatException ignored) {}
            }

            BigDecimal maxPrice = null;
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                try { maxPrice = new BigDecimal(maxPriceStr.trim()); } catch (NumberFormatException ignored) {}
            }

            Double minRating = null;
            if (minRatingStr != null && !minRatingStr.trim().isEmpty()) {
                try { minRating = Double.parseDouble(minRatingStr.trim()); } catch (NumberFormatException ignored) {}
            }

            Double userLat = null;
            Double userLng = null;
            if (latStr != null && lngStr != null && !latStr.trim().isEmpty() && !lngStr.trim().isEmpty()) {
                try {
                    userLat = Double.parseDouble(latStr.trim());
                    userLng = Double.parseDouble(lngStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            List<String> facilities = (facilitiesArr != null && facilitiesArr.length > 0)
                    ? Arrays.asList(facilitiesArr) : null;

            List<Hotel> hotels = hotelService.searchHotels(query, city, minPrice, maxPrice, minRating, facilities, sortBy, userLat, userLng);
            List<String> availableCities = hotelService.getAvailableCities();

            req.setAttribute("hotels", hotels);
            req.setAttribute("cities", availableCities);
            req.setAttribute("selectedCity", city);
            req.setAttribute("searchQuery", query);
            req.setAttribute("minPrice", minPrice);
            req.setAttribute("maxPrice", maxPrice);
            req.setAttribute("minRating", minRating);
            req.setAttribute("sortBy", sortBy != null ? sortBy : "RECOMMENDED");
            req.setAttribute("selectedFacilities", facilities);
            req.setAttribute("userLat", userLat);
            req.setAttribute("userLng", userLng);

            req.getRequestDispatcher("/WEB-INF/views/public/hotels.jsp").forward(req, resp);

        } catch (SQLException e) {
            logger.error("Database error retrieving hotels catalog", e);
            req.setAttribute("errorMessage", "Unable to load hotels catalog. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/common/500.jsp").forward(req, resp);
        }
    }
}


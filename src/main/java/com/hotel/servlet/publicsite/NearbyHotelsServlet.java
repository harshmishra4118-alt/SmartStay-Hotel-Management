package com.hotel.servlet.publicsite;

import com.google.gson.Gson;
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
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "NearbyHotelsServlet", urlPatterns = {"/hotels/nearby", "/api/hotels/nearby"})
public class NearbyHotelsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(NearbyHotelsServlet.class);
    private final HotelService hotelService = new HotelService();
    private final LocationService locationService = new LocationService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String latStr = req.getParameter("lat");
        String lngStr = req.getParameter("lng");
        String radiusStr = req.getParameter("radius");
        String sortBy = req.getParameter("sortBy");
        String format = req.getParameter("format");

        if (latStr == null || lngStr == null || latStr.trim().isEmpty() || lngStr.trim().isEmpty()) {
            if ("json".equalsIgnoreCase(format) || req.getRequestURI().contains("/api/")) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"error\": \"Latitude and Longitude parameters are required.\"}");
                return;
            }
            // For page view, redirect to page that prompts for geolocation
            req.getRequestDispatcher("/WEB-INF/views/public/nearby-hotels.jsp").forward(req, resp);
            return;
        }

        try {
            double userLat = Double.parseDouble(latStr.trim());
            double userLng = Double.parseDouble(lngStr.trim());
            double radiusKm = 0.0; // 0 = find all and sort by proximity
            if (radiusStr != null && !radiusStr.trim().isEmpty()) {
                try {
                    radiusKm = Double.parseDouble(radiusStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            List<Hotel> nearbyHotels = hotelService.getNearbyHotels(userLat, userLng, radiusKm, sortBy);

            if ("json".equalsIgnoreCase(format) || req.getRequestURI().contains("/api/")) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                List<Map<String, Object>> result = new ArrayList<>();
                for (Hotel h : nearbyHotels) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", h.getId());
                    map.put("name", h.getName());
                    map.put("city", h.getCity());
                    map.put("state", h.getState());
                    map.put("address", h.getAddress());
                    map.put("starRating", h.getStarRating());
                    map.put("minPrice", h.getMinPrice());
                    map.put("primaryImageUrl", h.getPrimaryImageUrl());
                    map.put("latitude", h.getLatitude());
                    map.put("longitude", h.getLongitude());
                    map.put("distanceKm", h.getDistanceKm() != null ? Math.round(h.getDistanceKm() * 10.0) / 10.0 : null);
                    map.put("drivingTime", h.getDrivingTimeEstimate());
                    map.put("walkingTime", h.getWalkingTimeEstimate());
                    map.put("directionsUrl", locationService.generateDirectionsUrl(userLat, userLng, h.getLatitude(), h.getLongitude()));
                    result.add(map);
                }
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            req.setAttribute("hotels", nearbyHotels);
            req.setAttribute("userLat", userLat);
            req.setAttribute("userLng", userLng);
            req.setAttribute("radiusKm", radiusKm);
            req.setAttribute("sortBy", sortBy);
            req.getRequestDispatcher("/WEB-INF/views/public/nearby-hotels.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid numeric coordinates.");
        } catch (SQLException e) {
            logger.error("Error discovering nearby hotels", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error retrieving nearby hotels.");
        }
    }
}


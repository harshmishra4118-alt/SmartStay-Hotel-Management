package com.hotel.servlet.publicsite;

import com.hotel.model.Hotel;
import com.hotel.service.HotelService;
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
import java.util.List;

@WebServlet(name = "HotelCompareServlet", urlPatterns = {"/compare"})
public class HotelCompareServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HotelCompareServlet.class);
    private final HotelService hotelService = new HotelService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idsParam = req.getParameter("ids");
        String latStr = req.getParameter("lat");
        String lngStr = req.getParameter("lng");

        Double userLat = null;
        Double userLng = null;
        if (latStr != null && lngStr != null) {
            try {
                userLat = Double.parseDouble(latStr.trim());
                userLng = Double.parseDouble(lngStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<Long> hotelIds = new ArrayList<>();
        if (idsParam != null && !idsParam.trim().isEmpty()) {
            String[] parts = idsParam.split(",");
            for (String p : parts) {
                try {
                    hotelIds.add(Long.parseLong(p.trim()));
                } catch (NumberFormatException ignored) {}
            }
        }

        try {
            List<Hotel> allHotels = hotelService.getAllActiveHotels();
            List<Hotel> compareHotels = new ArrayList<>();

            if (!hotelIds.isEmpty()) {
                compareHotels = hotelService.compareHotels(hotelIds, userLat, userLng);
            } else if (allHotels.size() >= 2) {
                // Default comparison between the first two luxury properties
                List<Long> defaultIds = List.of(allHotels.get(0).getId(), allHotels.get(1).getId());
                compareHotels = hotelService.compareHotels(defaultIds, userLat, userLng);
            }

            req.setAttribute("allHotels", allHotels);
            req.setAttribute("compareHotels", compareHotels);
            req.setAttribute("userLat", userLat);
            req.setAttribute("userLng", userLng);

            req.getRequestDispatcher("/WEB-INF/views/public/compare.jsp").forward(req, resp);

        } catch (SQLException e) {
            logger.error("Error generating hotel comparison", e);
            req.setAttribute("errorMessage", "Unable to load hotel comparison.");
            req.getRequestDispatcher("/WEB-INF/views/common/500.jsp").forward(req, resp);
        }
    }
}


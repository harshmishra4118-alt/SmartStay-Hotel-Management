package com.hotel.servlet.publicsite;

import com.hotel.model.Room;
import com.hotel.service.SmartRecommenderService;
import com.hotel.util.DateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "RecommendationServlet", urlPatterns = {"/rooms/recommend"})
public class RecommendationServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(RecommendationServlet.class);
    private final SmartRecommenderService recommenderService = new SmartRecommenderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String guestsStr = req.getParameter("guests");
        String budgetStr = req.getParameter("maxBudget");
        String typeStr = req.getParameter("roomType");
        String[] amenitiesArr = req.getParameterValues("amenities");
        String checkInStr = req.getParameter("checkIn");
        String checkOutStr = req.getParameter("checkOut");

        int guests = 2;
        if (guestsStr != null && !guestsStr.trim().isEmpty()) {
            try { guests = Integer.parseInt(guestsStr.trim()); } catch (Exception ignored) {}
        }

        BigDecimal maxBudget = null;
        if (budgetStr != null && !budgetStr.trim().isEmpty()) {
            try { maxBudget = new BigDecimal(budgetStr.trim()); } catch (Exception ignored) {}
        }

        Room.RoomType roomType = null;
        if (typeStr != null && !typeStr.trim().isEmpty()) {
            try { roomType = Room.RoomType.valueOf(typeStr.trim()); } catch (Exception ignored) {}
        }

        List<String> amenities = (amenitiesArr != null) ? Arrays.asList(amenitiesArr) : new ArrayList<>();
        LocalDate checkIn = DateUtil.parseDate(checkInStr);
        LocalDate checkOut = DateUtil.parseDate(checkOutStr);

        try {
            List<SmartRecommenderService.ScoredRecommendation> recs =
                    recommenderService.getRecommendations(guests, maxBudget, amenities, roomType, checkIn, checkOut, 6);

            req.setAttribute("recommendations", recs);
            req.setAttribute("guests", guests);
            req.setAttribute("maxBudget", budgetStr);
            req.setAttribute("selectedType", typeStr);
            req.setAttribute("selectedAmenities", amenities);
            req.setAttribute("checkIn", checkInStr);
            req.setAttribute("checkOut", checkOutStr);
            req.setAttribute("allRoomTypes", Room.RoomType.values());

        } catch (Exception e) {
            logger.error("Failed to calculate recommendations", e);
            req.setAttribute("errorMessage", "Error generating room recommendations.");
        }

        req.getRequestDispatcher("/WEB-INF/views/public/recommendations.jsp").forward(req, resp);
    }
}

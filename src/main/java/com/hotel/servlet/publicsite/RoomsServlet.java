package com.hotel.servlet.publicsite;

import com.hotel.model.Room;
import com.hotel.service.RoomService;
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
import java.util.List;

@WebServlet(name = "RoomsServlet", urlPatterns = {"/rooms"})
public class RoomsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(RoomsServlet.class);
    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String checkInStr = req.getParameter("checkIn");
        String checkOutStr = req.getParameter("checkOut");
        String guestsStr = req.getParameter("guests");
        String budgetStr = req.getParameter("maxBudget");
        String typeStr = req.getParameter("roomType");

        LocalDate checkIn = DateUtil.parseDate(checkInStr);
        LocalDate checkOut = DateUtil.parseDate(checkOutStr);

        Integer guests = null;
        if (guestsStr != null && !guestsStr.trim().isEmpty()) {
            try { guests = Integer.parseInt(guestsStr.trim()); } catch (NumberFormatException ignored) {}
        }

        BigDecimal maxBudget = null;
        if (budgetStr != null && !budgetStr.trim().isEmpty()) {
            try { maxBudget = new BigDecimal(budgetStr.trim()); } catch (Exception ignored) {}
        }

        Room.RoomType roomType = null;
        if (typeStr != null && !typeStr.trim().isEmpty()) {
            try { roomType = Room.RoomType.valueOf(typeStr.trim()); } catch (Exception ignored) {}
        }

        try {
            List<Room> rooms = roomService.searchAvailableRooms(checkIn, checkOut, guests, maxBudget, roomType);
            req.setAttribute("rooms", rooms);
            req.setAttribute("checkIn", checkInStr);
            req.setAttribute("checkOut", checkOutStr);
            req.setAttribute("guests", guests);
            req.setAttribute("maxBudget", budgetStr);
            req.setAttribute("selectedType", typeStr);
            req.setAttribute("allRoomTypes", Room.RoomType.values());
        } catch (Exception e) {
            logger.error("Failed to load rooms", e);
            req.setAttribute("errorMessage", "Unable to load rooms at this time. Please try again.");
        }

        req.getRequestDispatcher("/WEB-INF/views/public/rooms.jsp").forward(req, resp);
    }
}

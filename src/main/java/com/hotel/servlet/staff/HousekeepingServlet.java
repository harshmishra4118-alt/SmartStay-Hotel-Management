package com.hotel.servlet.staff;

import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.service.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HousekeepingServlet", urlPatterns = {"/staff/housekeeping"})
public class HousekeepingServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HousekeepingServlet.class);
    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String statusFilterStr = req.getParameter("status");
        Room.HousekeepingStatus filter = null;
        if (statusFilterStr != null && !statusFilterStr.trim().isEmpty()) {
            try { filter = Room.HousekeepingStatus.valueOf(statusFilterStr.trim()); } catch (Exception ignored) {}
        }

        try {
            List<Room> rooms = roomService.getAllRooms(null, filter, null, null);
            req.setAttribute("rooms", rooms);
            req.setAttribute("selectedStatus", statusFilterStr);
            req.setAttribute("allStatuses", Room.HousekeepingStatus.values());

            req.getRequestDispatcher("/WEB-INF/views/staff/housekeeping.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load housekeeping rooms", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading housekeeping schedule.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentStaff = (User) session.getAttribute("currentUser");

        String roomIdStr = req.getParameter("roomId");
        String newStatusStr = req.getParameter("status");

        try {
            Long roomId = Long.parseLong(roomIdStr.trim());
            Room.HousekeepingStatus newStatus = Room.HousekeepingStatus.valueOf(newStatusStr.trim());

            roomService.setHousekeepingStatus(roomId, newStatus, currentStaff.getId(), req.getRemoteAddr());

            resp.sendRedirect(req.getContextPath() + "/staff/housekeeping?updated=true");

        } catch (Exception e) {
            logger.error("Error updating housekeeping status", e);
            resp.sendRedirect(req.getContextPath() + "/staff/housekeeping?error=true");
        }
    }
}

package com.hotel.servlet.admin;

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
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "AdminRoomsServlet", urlPatterns = {"/admin/rooms", "/admin/rooms/add", "/admin/rooms/edit", "/admin/rooms/status"})
public class AdminRoomsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminRoomsServlet.class);
    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        try {
            if ("/admin/rooms/add".equals(servletPath)) {
                req.setAttribute("allRoomTypes", Room.RoomType.values());
                req.setAttribute("allOperationalStatuses", Room.OperationalStatus.values());
                req.setAttribute("allHousekeepingStatuses", Room.HousekeepingStatus.values());
                req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
                return;
            }

            if ("/admin/rooms/edit".equals(servletPath)) {
                String idStr = req.getParameter("id");
                Room room = roomService.getRoomById(Long.parseLong(idStr));
                req.setAttribute("room", room);
                req.setAttribute("allRoomTypes", Room.RoomType.values());
                req.setAttribute("allOperationalStatuses", Room.OperationalStatus.values());
                req.setAttribute("allHousekeepingStatuses", Room.HousekeepingStatus.values());
                req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
                return;
            }

            // List rooms
            String opFilter = req.getParameter("operational");
            String hkFilter = req.getParameter("housekeeping");
            String typeFilter = req.getParameter("type");
            String search = req.getParameter("search");

            Room.OperationalStatus opStatus = null;
            if (opFilter != null && !opFilter.trim().isEmpty()) {
                try { opStatus = Room.OperationalStatus.valueOf(opFilter.trim()); } catch (Exception ignored) {}
            }

            Room.HousekeepingStatus hkStatus = null;
            if (hkFilter != null && !hkFilter.trim().isEmpty()) {
                try { hkStatus = Room.HousekeepingStatus.valueOf(hkFilter.trim()); } catch (Exception ignored) {}
            }

            Room.RoomType rType = null;
            if (typeFilter != null && !typeFilter.trim().isEmpty()) {
                try { rType = Room.RoomType.valueOf(typeFilter.trim()); } catch (Exception ignored) {}
            }

            List<Room> rooms = roomService.getAllRooms(opStatus, hkStatus, rType, search);
            req.setAttribute("rooms", rooms);
            req.setAttribute("allRoomTypes", Room.RoomType.values());
            req.setAttribute("allOperationalStatuses", Room.OperationalStatus.values());
            req.setAttribute("allHousekeepingStatuses", Room.HousekeepingStatus.values());

            req.getRequestDispatcher("/WEB-INF/views/admin/rooms.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Error in AdminRoomsServlet GET", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading rooms.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("currentUser");

        String servletPath = req.getServletPath();

        try {
            if ("/admin/rooms/status".equals(servletPath)) {
                Long roomId = Long.parseLong(req.getParameter("roomId"));
                Room.OperationalStatus status = Room.OperationalStatus.valueOf(req.getParameter("status"));
                roomService.setOperationalStatus(roomId, status, currentAdmin.getId(), req.getRemoteAddr());
                resp.sendRedirect(req.getContextPath() + "/admin/rooms?statusUpdated=true");
                return;
            }

            String idStr = req.getParameter("id");
            String roomNumber = req.getParameter("roomNumber");
            String roomType = req.getParameter("roomType");
            String name = req.getParameter("name");
            String description = req.getParameter("description");
            String priceStr = req.getParameter("pricePerNight");
            String capacityStr = req.getParameter("capacity");
            String bedType = req.getParameter("bedType");
            String sizeStr = req.getParameter("sizeSqft");
            String floorStr = req.getParameter("floorNumber");
            String operational = req.getParameter("operationalStatus");
            String housekeeping = req.getParameter("housekeepingStatus");
            String primaryImage = req.getParameter("primaryImageUrl");
            String amenities = req.getParameter("amenities");

            Room room = new Room();
            if (idStr != null && !idStr.trim().isEmpty()) {
                room.setId(Long.parseLong(idStr.trim()));
            }
            room.setRoomNumber(roomNumber);
            room.setRoomType(Room.RoomType.valueOf(roomType));
            room.setName(name);
            room.setDescription(description);
            room.setPricePerNight(new BigDecimal(priceStr.trim()));
            room.setCapacity(Integer.parseInt(capacityStr.trim()));
            room.setBedType(bedType != null ? bedType : "King Bed");
            room.setSizeSqft(sizeStr != null && !sizeStr.trim().isEmpty() ? Integer.parseInt(sizeStr.trim()) : 400);
            room.setFloorNumber(floorStr != null && !floorStr.trim().isEmpty() ? Integer.parseInt(floorStr.trim()) : 1);
            room.setOperationalStatus(Room.OperationalStatus.valueOf(operational));
            room.setHousekeepingStatus(Room.HousekeepingStatus.valueOf(housekeeping));
            room.setPrimaryImageUrl(primaryImage != null && !primaryImage.trim().isEmpty() ? primaryImage.trim() : "https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80");
            room.setAmenities(amenities);

            if (room.getId() == null) {
                roomService.createRoom(room, currentAdmin.getId(), req.getRemoteAddr());
                resp.sendRedirect(req.getContextPath() + "/admin/rooms?created=true");
            } else {
                roomService.updateRoom(room, currentAdmin.getId(), req.getRemoteAddr());
                resp.sendRedirect(req.getContextPath() + "/admin/rooms?updated=true");
            }

        } catch (IllegalArgumentException e) {
            req.setAttribute("errorMessage", e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            logger.error("Failed to save room", e);
            req.setAttribute("errorMessage", "Error saving room details: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

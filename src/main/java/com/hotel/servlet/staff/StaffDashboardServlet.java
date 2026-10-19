package com.hotel.servlet.staff;

import com.hotel.dao.BookingDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Room;
import com.hotel.service.CheckInService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffDashboardServlet", urlPatterns = {"/staff/dashboard"})
public class StaffDashboardServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(StaffDashboardServlet.class);
    private final CheckInService checkInService = new CheckInService();
    private final RoomDAO roomDAO = new RoomDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Booking> todayArrivals = checkInService.getTodayArrivals();
            List<Booking> todayDepartures = checkInService.getTodayDepartures();
            int dirtyRooms = roomDAO.countRoomsByHousekeepingStatus(Room.HousekeepingStatus.DIRTY);
            int cleanRooms = roomDAO.countRoomsByHousekeepingStatus(Room.HousekeepingStatus.CLEAN);
            int activeRooms = roomDAO.countTotalActiveRooms();

            req.setAttribute("todayArrivals", todayArrivals);
            req.setAttribute("todayDepartures", todayDepartures);
            req.setAttribute("dirtyRooms", dirtyRooms);
            req.setAttribute("cleanRooms", cleanRooms);
            req.setAttribute("activeRooms", activeRooms);

            req.getRequestDispatcher("/WEB-INF/views/staff/dashboard.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load staff dashboard", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading staff operations.");
        }
    }
}

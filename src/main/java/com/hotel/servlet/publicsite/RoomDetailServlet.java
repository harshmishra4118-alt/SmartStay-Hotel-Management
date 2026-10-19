package com.hotel.servlet.publicsite;

import com.hotel.model.Room;
import com.hotel.service.FeedbackService;
import com.hotel.service.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet(name = "RoomDetailServlet", urlPatterns = {"/room-details"})
public class RoomDetailServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(RoomDetailServlet.class);
    private final RoomService roomService = new RoomService();
    private final FeedbackService feedbackService = new FeedbackService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/rooms");
            return;
        }

        try {
            Long roomId = Long.parseLong(idStr.trim());
            Room room = roomService.getRoomById(roomId);
            if (room == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Room not found.");
                return;
            }

            req.setAttribute("room", room);
            req.setAttribute("reviews", feedbackService.getApprovedReviewsForRoom(roomId, 10));
            req.setAttribute("similarRooms", roomService.getFeaturedRooms(3));

            req.getRequestDispatcher("/WEB-INF/views/public/room-details.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/rooms");
        } catch (Exception e) {
            logger.error("Error retrieving room details", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading room details.");
        }
    }
}

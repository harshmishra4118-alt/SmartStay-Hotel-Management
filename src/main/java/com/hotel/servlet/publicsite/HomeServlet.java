package com.hotel.servlet.publicsite;

import com.hotel.model.Hotel;
import com.hotel.model.Room;
import com.hotel.service.FeedbackService;
import com.hotel.service.HotelService;
import com.hotel.service.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HomeServlet.class);
    private final RoomService roomService = new RoomService();
    private final FeedbackService feedbackService = new FeedbackService();
    private final HotelService hotelService = new HotelService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Hotel> featuredHotels = hotelService.getAllActiveHotels();
            List<String> cities = hotelService.getAvailableCities();
            List<Room> featuredRooms = roomService.getFeaturedRooms(4);

            req.setAttribute("featuredHotels", featuredHotels);
            req.setAttribute("cities", cities);
            req.setAttribute("featuredRooms", featuredRooms);
            req.setAttribute("feedbacks", feedbackService.listAllFeedback(true, 0, 3));
        } catch (Exception e) {
            logger.error("Error loading home page content", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(req, resp);
    }
}

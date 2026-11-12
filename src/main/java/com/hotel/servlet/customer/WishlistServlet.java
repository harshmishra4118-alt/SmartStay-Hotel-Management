package com.hotel.servlet.customer;

import com.google.gson.Gson;
import com.hotel.model.Hotel;
import com.hotel.model.User;
import com.hotel.service.WishlistService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "WishlistServlet", urlPatterns = {"/customer/wishlist", "/api/wishlist/toggle"})
public class WishlistServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(WishlistServlet.class);
    private final WishlistService wishlistService = new WishlistService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + req.getRequestURI());
            return;
        }

        if (req.getServletPath().equals("/api/wishlist/toggle")) {
            handleToggle(req, resp, user);
            return;
        }

        List<Hotel> favorites = wishlistService.getFavoriteHotels(user.getId());
        req.setAttribute("favoriteHotels", favorites);
        req.getRequestDispatcher("/WEB-INF/views/customer/wishlist.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"success\":false,\"message\":\"Please log in to save favorites.\"}");
            return;
        }

        handleToggle(req, resp, user);
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String hotelIdStr = req.getParameter("hotelId");
        if (hotelIdStr == null || hotelIdStr.trim().isEmpty()) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST, false, "hotelId parameter is required", false);
            return;
        }

        try {
            Long hotelId = Long.parseLong(hotelIdStr.trim());
            boolean isNowFavorite = wishlistService.toggleFavorite(user.getId(), hotelId);
            String message = isNowFavorite ? "Saved to your luxury wishlist." : "Removed from your luxury wishlist.";
            sendJson(resp, HttpServletResponse.SC_OK, true, message, isNowFavorite);
        } catch (NumberFormatException e) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid hotelId", false);
        } catch (SQLException e) {
            logger.error("Error toggling favorite for user: {}", user.getId(), e);
            sendJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Error updating favorites", false);
        }
    }

    private void sendJson(HttpServletResponse resp, int status, boolean success, String message, boolean isFavorite) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Map<String, Object> map = new HashMap<>();
        map.put("success", success);
        map.put("message", message);
        map.put("isFavorite", isFavorite);
        resp.getWriter().write(gson.toJson(map));
    }
}


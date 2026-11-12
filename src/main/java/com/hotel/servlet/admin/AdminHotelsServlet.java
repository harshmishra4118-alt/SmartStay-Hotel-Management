package com.hotel.servlet.admin;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.HotelDAO;
import com.hotel.model.Hotel;
import com.hotel.model.User;
import com.hotel.service.HotelService;
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
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "AdminHotelsServlet", urlPatterns = {"/admin/hotels", "/admin/hotel-form"})
public class AdminHotelsServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminHotelsServlet.class);
    private final HotelService hotelService = new HotelService();
    private final HotelDAO hotelDAO = new HotelDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrator access required.");
            return;
        }

        String path = req.getServletPath();

        try {
            if ("/admin/hotel-form".equals(path)) {
                String idStr = req.getParameter("id");
                Hotel hotel = new Hotel();
                if (idStr != null && !idStr.trim().isEmpty()) {
                    Long hotelId = Long.parseLong(idStr.trim());
                    // If hotel admin, enforce they only edit their own assigned hotel
                    if (currentUser.isHotelAdmin() && !currentUser.getAssignedHotelId().equals(hotelId)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to hotel profile.");
                        return;
                    }
                    hotel = hotelService.getHotelById(hotelId);
                    if (hotel == null) {
                        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Hotel not found.");
                        return;
                    }
                } else if (currentUser.isHotelAdmin()) {
                    // Hotel admins cannot create new hotels, only Super Admins can
                    resp.sendRedirect(req.getContextPath() + "/admin/hotel-form?id=" + currentUser.getAssignedHotelId());
                    return;
                }

                req.setAttribute("hotel", hotel);
                req.getRequestDispatcher("/WEB-INF/views/admin/hotel-form.jsp").forward(req, resp);
                return;
            }

            // List hotels
            List<Hotel> hotels;
            if (currentUser.isHotelAdmin()) {
                Hotel assigned = hotelService.getHotelById(currentUser.getAssignedHotelId());
                hotels = (assigned != null) ? List.of(assigned) : List.of();
            } else {
                hotels = hotelService.getAllHotels();
            }

            req.setAttribute("hotels", hotels);
            req.getRequestDispatcher("/WEB-INF/views/admin/hotels.jsp").forward(req, resp);

        } catch (SQLException e) {
            logger.error("Error handling admin hotels request", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error handling hotel administration.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrator access required.");
            return;
        }

        String action = req.getParameter("action");
        if ("toggle-status".equalsIgnoreCase(action)) {
            handleToggleStatus(req, resp, currentUser);
            return;
        }

        // Save / Update Hotel
        String idStr = req.getParameter("id");
        String name = req.getParameter("name");
        String tagline = req.getParameter("tagline");
        String description = req.getParameter("description");
        String address = req.getParameter("address");
        String city = req.getParameter("city");
        String state = req.getParameter("state");
        String postalCode = req.getParameter("postalCode");
        String latStr = req.getParameter("latitude");
        String lngStr = req.getParameter("longitude");
        String starRatingStr = req.getParameter("starRating");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String primaryImageUrl = req.getParameter("primaryImageUrl");
        String minPriceStr = req.getParameter("minPrice");
        String maxPriceStr = req.getParameter("maxPrice");
        String checkinTime = req.getParameter("checkinTime");
        String checkoutTime = req.getParameter("checkoutTime");
        String cancellationPolicy = req.getParameter("cancellationPolicy");
        String statusStr = req.getParameter("status");
        boolean isFeatured = "true".equalsIgnoreCase(req.getParameter("isFeatured")) || "on".equalsIgnoreCase(req.getParameter("isFeatured"));

        try {
            Hotel hotel = new Hotel();
            boolean isEdit = (idStr != null && !idStr.trim().isEmpty() && !"0".equals(idStr.trim()));
            if (isEdit) {
                Long id = Long.parseLong(idStr.trim());
                if (currentUser.isHotelAdmin() && !currentUser.getAssignedHotelId().equals(id)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Permission denied to edit other properties.");
                    return;
                }
                hotel.setId(id);
            } else if (currentUser.isHotelAdmin()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only platform super administrators can register new hotel properties.");
                return;
            }

            hotel.setName(name != null ? name.trim() : "");
            hotel.setTagline(tagline);
            hotel.setDescription(description != null ? description.trim() : "");
            hotel.setAddress(address != null ? address.trim() : "");
            hotel.setCity(city != null ? city.trim() : "");
            hotel.setState(state != null ? state.trim() : "");
            hotel.setCountry("India");
            hotel.setPostalCode(postalCode != null ? postalCode.trim() : "");
            hotel.setLatitude(new BigDecimal(latStr != null && !latStr.trim().isEmpty() ? latStr.trim() : "19.0760"));
            hotel.setLongitude(new BigDecimal(lngStr != null && !lngStr.trim().isEmpty() ? lngStr.trim() : "72.8777"));
            hotel.setStarRating(new BigDecimal(starRatingStr != null && !starRatingStr.trim().isEmpty() ? starRatingStr.trim() : "4.5"));
            hotel.setPhone(phone != null ? phone.trim() : "");
            hotel.setEmail(email != null ? email.trim() : "");
            hotel.setPrimaryImageUrl(primaryImageUrl != null ? primaryImageUrl.trim() : "");
            hotel.setMinPrice(new BigDecimal(minPriceStr != null && !minPriceStr.trim().isEmpty() ? minPriceStr.trim() : "3500.00"));
            hotel.setMaxPrice(new BigDecimal(maxPriceStr != null && !maxPriceStr.trim().isEmpty() ? maxPriceStr.trim() : "35000.00"));
            hotel.setCheckinTime(checkinTime != null ? checkinTime.trim() : "14:00");
            hotel.setCheckoutTime(checkoutTime != null ? checkoutTime.trim() : "11:00");
            hotel.setCancellationPolicy(cancellationPolicy);
            hotel.setStatus(statusStr != null ? Hotel.Status.valueOf(statusStr.toUpperCase()) : Hotel.Status.ACTIVE);
            hotel.setFeatured(isFeatured);

            if (isEdit) {
                hotelDAO.update(hotel);
                auditLogDAO.log(currentUser.getId(), "HOTEL_UPDATED", "Hotel", String.valueOf(hotel.getId()),
                        "Updated hotel property details: " + hotel.getName(), req.getRemoteAddr());
            } else {
                Long newId = hotelDAO.create(hotel);
                hotel.setId(newId);
                auditLogDAO.log(currentUser.getId(), "HOTEL_REGISTERED", "Hotel", String.valueOf(newId),
                        "Registered new luxury hotel property: " + hotel.getName(), req.getRemoteAddr());
            }

            session.setAttribute("flashSuccess", "Hotel property '" + hotel.getName() + "' saved successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/hotels");

        } catch (Exception e) {
            logger.error("Error saving hotel property", e);
            req.setAttribute("errorMessage", "Error saving hotel: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/hotel-form.jsp").forward(req, resp);
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || currentUser.isHotelAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/admin/hotels");
            return;
        }

        try {
            Long hotelId = Long.parseLong(idStr.trim());
            Hotel h = hotelDAO.findById(hotelId);
            if (h != null) {
                Hotel.Status newStatus = (h.getStatus() == Hotel.Status.ACTIVE) ? Hotel.Status.INACTIVE : Hotel.Status.ACTIVE;
                h.setStatus(newStatus);
                hotelDAO.update(h);
                auditLogDAO.log(currentUser.getId(), "HOTEL_STATUS_TOGGLED", "Hotel", String.valueOf(hotelId),
                        "Changed hotel status to: " + newStatus, req.getRemoteAddr());
            }
        } catch (SQLException e) {
            logger.error("Error toggling hotel status", e);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/hotels");
    }
}


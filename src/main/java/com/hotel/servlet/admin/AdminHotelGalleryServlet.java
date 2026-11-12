package com.hotel.servlet.admin;

import com.hotel.model.Hotel;
import com.hotel.model.HotelImage;
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
import java.util.List;

@WebServlet(name = "AdminHotelGalleryServlet", urlPatterns = {"/admin/hotel-gallery"})
public class AdminHotelGalleryServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminHotelGalleryServlet.class);
    private final HotelService hotelService = new HotelService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !currentUser.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Long hotelId = null;
            if (currentUser.isHotelAdmin()) {
                hotelId = currentUser.getAssignedHotelId();
            } else {
                String hotelParam = req.getParameter("hotelId");
                if (hotelParam != null && !hotelParam.trim().isEmpty()) {
                    try {
                        hotelId = Long.parseLong(hotelParam.trim());
                    } catch (Exception ignored) {}
                }
                if (hotelId == null) {
                    List<Hotel> all = hotelService.getAllHotels();
                    if (!all.isEmpty()) {
                        hotelId = all.get(0).getId();
                    }
                }
            }

            if (hotelId == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/hotels");
                return;
            }

            Hotel hotel = hotelService.getHotelById(hotelId);
            List<HotelImage> images = hotelService.getHotelImages(hotelId);
            List<Hotel> allHotels = hotelService.getAllHotels();

            req.setAttribute("hotel", hotel);
            req.setAttribute("images", images);
            req.setAttribute("allHotels", allHotels);
            req.setAttribute("selectedHotelId", hotelId);
            req.setAttribute("allCategories", HotelImage.ImageCategory.values());
            req.setAttribute("isOwnerScope", currentUser.isHotelAdmin());

            req.getRequestDispatcher("/WEB-INF/views/admin/hotel-gallery.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Error loading hotel gallery", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading hotel image gallery.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !currentUser.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String hotelIdStr = req.getParameter("hotelId");

        try {
            Long hotelId = null;
            if (currentUser.isHotelAdmin()) {
                hotelId = currentUser.getAssignedHotelId();
            } else if (hotelIdStr != null && !hotelIdStr.trim().isEmpty()) {
                hotelId = Long.parseLong(hotelIdStr.trim());
            }

            if (hotelId == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/hotels");
                return;
            }

            if ("add".equals(action)) {
                String imageUrl = req.getParameter("imageUrl");
                String categoryStr = req.getParameter("category");
                String caption = req.getParameter("caption");
                boolean isPrimary = "true".equalsIgnoreCase(req.getParameter("isPrimary"));
                String orderStr = req.getParameter("displayOrder");

                if (imageUrl == null || imageUrl.trim().isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/hotel-gallery?hotelId=" + hotelId + "&error=missing_url");
                    return;
                }

                HotelImage img = new HotelImage();
                img.setHotelId(hotelId);
                img.setImageUrl(imageUrl.trim());
                try {
                    img.setCategory(HotelImage.ImageCategory.valueOf(categoryStr));
                } catch (Exception e) {
                    img.setCategory(HotelImage.ImageCategory.EXTERIOR);
                }
                img.setCaption(caption != null ? caption.trim() : "");
                img.setPrimary(isPrimary);
                int order = 0;
                try {
                    if (orderStr != null && !orderStr.trim().isEmpty()) {
                        order = Integer.parseInt(orderStr.trim());
                    }
                } catch (Exception ignored) {}
                img.setDisplayOrder(order);

                Long imgId = hotelService.addHotelImage(img);
                if (isPrimary && imgId != null) {
                    hotelService.setPrimaryHotelImage(hotelId, imgId);
                }

                resp.sendRedirect(req.getContextPath() + "/admin/hotel-gallery?hotelId=" + hotelId + "&success=added");
                return;

            } else if ("delete".equals(action)) {
                String imageIdStr = req.getParameter("imageId");
                if (imageIdStr != null && !imageIdStr.trim().isEmpty()) {
                    Long imageId = Long.parseLong(imageIdStr.trim());
                    hotelService.deleteHotelImage(imageId);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/hotel-gallery?hotelId=" + hotelId + "&success=deleted");
                return;

            } else if ("set-primary".equals(action)) {
                String imageIdStr = req.getParameter("imageId");
                if (imageIdStr != null && !imageIdStr.trim().isEmpty()) {
                    Long imageId = Long.parseLong(imageIdStr.trim());
                    hotelService.setPrimaryHotelImage(hotelId, imageId);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/hotel-gallery?hotelId=" + hotelId + "&success=primary_updated");
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/admin/hotel-gallery?hotelId=" + hotelId);

        } catch (Exception e) {
            logger.error("Error updating hotel gallery", e);
            resp.sendRedirect(req.getContextPath() + "/admin/hotel-gallery?hotelId=" + hotelIdStr + "&error=" + e.getMessage());
        }
    }
}


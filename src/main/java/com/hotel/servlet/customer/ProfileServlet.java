package com.hotel.servlet.customer;

import com.hotel.dao.CustomerProfileDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.CustomerProfile;
import com.hotel.model.User;
import com.hotel.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet(name = "CustomerProfileServlet", urlPatterns = {"/customer/profile"})
public class ProfileServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(ProfileServlet.class);
    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            User refreshedUser = userDAO.findById(currentUser.getId());
            CustomerProfile profile = profileDAO.findByUserId(currentUser.getId());
            if (profile == null) {
                profile = new CustomerProfile();
                profile.setUserId(currentUser.getId());
            }

            req.setAttribute("user", refreshedUser);
            req.setAttribute("profile", profile);
            req.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load customer profile", e);
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String action = req.getParameter("action");

        try {
            if ("changePassword".equals(action)) {
                String oldPass = req.getParameter("oldPassword");
                String newPass = req.getParameter("newPassword");
                authService.changePassword(currentUser.getId(), oldPass, newPass, req.getRemoteAddr());
                req.setAttribute("successMessage", "Password updated successfully.");
            } else {
                // Update profile info
                String fullName = req.getParameter("fullName");
                String phone = req.getParameter("phone");
                String docType = req.getParameter("idDocumentType");
                String docNumber = req.getParameter("idDocumentNumber");
                String address = req.getParameter("address");
                String city = req.getParameter("city");
                String country = req.getParameter("country");
                String emergency = req.getParameter("emergencyContact");
                String preferences = req.getParameter("preferencesNotes");

                userDAO.updateProfile(currentUser.getId(), fullName, phone);

                CustomerProfile profile = profileDAO.findByUserId(currentUser.getId());
                if (profile == null) {
                    profile = new CustomerProfile();
                    profile.setUserId(currentUser.getId());
                }
                profile.setIdDocumentType(docType);
                profile.setIdDocumentNumber(docNumber);
                profile.setAddress(address);
                profile.setCity(city);
                profile.setCountry(country);
                profile.setEmergencyContact(emergency);
                profile.setPreferencesNotes(preferences);

                profileDAO.saveOrUpdate(profile);

                // Update session object
                currentUser.setFullName(fullName);
                currentUser.setPhone(phone);
                session.setAttribute("currentUser", currentUser);

                req.setAttribute("successMessage", "Profile details saved successfully.");
            }
        } catch (Exception e) {
            logger.error("Failed to update profile", e);
            req.setAttribute("errorMessage", e.getMessage());
        }

        doGet(req, resp);
    }
}

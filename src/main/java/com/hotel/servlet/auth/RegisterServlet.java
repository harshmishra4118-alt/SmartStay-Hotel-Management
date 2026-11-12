package com.hotel.servlet.auth;

import com.hotel.model.User;
import com.hotel.service.AuthService;
import com.hotel.util.CsrfUtil;
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

@WebServlet(name = "RegisterServlet", urlPatterns = { "/register" })
public class RegisterServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(RegisterServlet.class);
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (password == null || !password.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Passwords do not match.");
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.setAttribute("phone", phone);
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        try {
            User user = authService.register(email, password, fullName, phone, req.getRemoteAddr());

            // Auto-login upon successful registration
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null)
                oldSession.invalidate();
            HttpSession newSession = req.getSession(true);
            newSession.setAttribute("currentUser", user);
            CsrfUtil.getOrCreateToken(newSession);

            logger.info("New customer registered and authenticated: {}", user.getEmail());
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings?registered=true");

        } catch (IllegalArgumentException e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.setAttribute("phone", phone);
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        } catch (SQLException e) {
            logger.error("Database error during registration for email: {}", email, e);
            String dbMsg = "Database error: " + (e.getMessage() != null ? e.getMessage()
                    : "Unable to complete registration due to database connectivity issue.");
            req.setAttribute("errorMessage", dbMsg);
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.setAttribute("phone", phone);
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        } catch (Exception e) {
            logger.error("Registration error for email: {}", email, e);
            String detail = (e.getMessage() != null && !e.getMessage().isBlank()) ? e.getMessage()
                    : "Please check your information and try again.";
            req.setAttribute("errorMessage", "Registration failed: " + detail);
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.setAttribute("phone", phone);
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}

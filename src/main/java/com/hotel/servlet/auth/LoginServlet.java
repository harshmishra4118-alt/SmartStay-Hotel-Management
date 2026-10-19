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

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(LoginServlet.class);
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            redirectUserByRole(user, req, resp, null);
            return;
        }

        String redirect = req.getParameter("redirect");
        req.setAttribute("redirect", redirect);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String redirect = req.getParameter("redirect");

        try {
            User user = authService.login(email, password, req.getRemoteAddr());

            // Session fixation protection: invalidate old session and generate a clean new session ID
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession newSession = req.getSession(true);
            newSession.setAttribute("currentUser", user);

            // Re-generate fresh CSRF token for the authenticated session
            CsrfUtil.getOrCreateToken(newSession);

            logger.info("User {} logged in successfully with role {}", user.getEmail(), user.getRole());
            redirectUserByRole(user, req, resp, redirect);

        } catch (IllegalArgumentException | IllegalStateException e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.setAttribute("email", email);
            req.setAttribute("redirect", redirect);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        } catch (Exception e) {
            logger.error("Unexpected login failure", e);
            req.setAttribute("errorMessage", "An error occurred during sign in. Please try again.");
            req.setAttribute("email", email);
            req.setAttribute("redirect", redirect);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }

    private void redirectUserByRole(User user, HttpServletRequest req, HttpServletResponse resp, String redirect) throws IOException {
        if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("login") && !redirect.contains("logout")) {
            resp.sendRedirect(redirect);
            return;
        }

        if (user.getRole() == User.Role.ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else if (user.getRole() == User.Role.STAFF) {
            resp.sendRedirect(req.getContextPath() + "/staff/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }
}

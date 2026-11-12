package com.hotel.servlet.auth;

import com.google.gson.Gson;
import com.hotel.dao.UserDAO;
import com.hotel.model.OtpVerification;
import com.hotel.model.User;
import com.hotel.service.OtpAuthService;
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
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "OtpAuthServlet", urlPatterns = {"/otp-login", "/otp-register", "/api/otp/send", "/api/otp/verify"})
public class OtpAuthServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(OtpAuthServlet.class);
    private final OtpAuthService otpService = new OtpAuthService();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);

        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        if ("/otp-register".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/auth/otp-register.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/auth/otp-login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        boolean isApi = path.startsWith("/api/otp/");

        if ("/api/otp/send".equals(path) || (req.getParameter("action") != null && "send".equalsIgnoreCase(req.getParameter("action")))) {
            handleSendOtp(req, resp, isApi);
        } else if ("/api/otp/verify".equals(path) || (req.getParameter("action") != null && "verify".equalsIgnoreCase(req.getParameter("action")))) {
            handleVerifyOtp(req, resp, isApi);
        } else {
            if (isApi) {
                sendJson(resp, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid request action", null);
            } else {
                resp.sendRedirect(req.getContextPath() + "/otp-login");
            }
        }
    }

    private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp, boolean isApi) throws IOException, ServletException {
        String email = req.getParameter("email");
        String typeStr = req.getParameter("type");
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");

        OtpVerification.OtpType type = OtpVerification.OtpType.LOGIN;
        if ("REGISTRATION".equalsIgnoreCase(typeStr) || req.getServletPath().contains("register")) {
            type = OtpVerification.OtpType.REGISTRATION;
        }

        Map<String, String> metaMap = new HashMap<>();
        if (fullName != null) metaMap.put("fullName", fullName.trim());
        if (phone != null) metaMap.put("phone", phone.trim());
        String metaJson = metaMap.isEmpty() ? null : gson.toJson(metaMap);

        OtpAuthService.OtpResult result = otpService.requestOtp(email, type, metaJson);

        if (isApi) {
            Map<String, Object> data = new HashMap<>();
            data.put("cooldownSeconds", result.getCooldownSeconds());
            sendJson(resp, result.isSuccess() ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST,
                    result.isSuccess(), result.getMessage(), data);
        } else {
            req.setAttribute("email", email);
            req.setAttribute("fullName", fullName);
            req.setAttribute("phone", phone);
            req.setAttribute("otpSent", result.isSuccess());
            req.setAttribute("otpType", type.name());
            req.setAttribute("cooldownSeconds", result.getCooldownSeconds());

            if (result.isSuccess()) {
                req.setAttribute("successMessage", result.getMessage());
            } else {
                req.setAttribute("errorMessage", result.getMessage());
            }

            String jsp = (type == OtpVerification.OtpType.REGISTRATION)
                    ? "/WEB-INF/views/auth/otp-register.jsp"
                    : "/WEB-INF/views/auth/otp-login.jsp";
            req.getRequestDispatcher(jsp).forward(req, resp);
        }
    }

    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp, boolean isApi) throws IOException, ServletException {
        String email = req.getParameter("email");
        String code = req.getParameter("code");
        String typeStr = req.getParameter("type");

        OtpVerification.OtpType type = OtpVerification.OtpType.LOGIN;
        if ("REGISTRATION".equalsIgnoreCase(typeStr) || req.getServletPath().contains("register")) {
            type = OtpVerification.OtpType.REGISTRATION;
        }

        OtpAuthService.OtpResult result = otpService.verifyOtp(email, code, type);

        if (!result.isSuccess()) {
            if (isApi) {
                sendJson(resp, HttpServletResponse.SC_UNAUTHORIZED, false, result.getMessage(), null);
            } else {
                req.setAttribute("email", email);
                req.setAttribute("otpSent", true);
                req.setAttribute("otpType", type.name());
                req.setAttribute("errorMessage", result.getMessage());
                String jsp = (type == OtpVerification.OtpType.REGISTRATION)
                        ? "/WEB-INF/views/auth/otp-register.jsp"
                        : "/WEB-INF/views/auth/otp-login.jsp";
                req.getRequestDispatcher(jsp).forward(req, resp);
            }
            return;
        }

        // OTP verified successfully - authenticate user session
        User user = result.getUser();
        if (user == null && type == OtpVerification.OtpType.LOGIN) {
            try {
                user = userDAO.findByEmail(email);
            } catch (SQLException e) {
                logger.error("Error fetching user after OTP verification", e);
            }
        }

        if (user == null) {
            if (isApi) {
                sendJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "User account not found.", null);
            } else {
                req.setAttribute("errorMessage", "User account could not be found.");
                req.getRequestDispatcher("/WEB-INF/views/auth/otp-login.jsp").forward(req, resp);
            }
            return;
        }

        // Establish session with session fixation renewal
        HttpSession oldSession = req.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession newSession = req.getSession(true);
        newSession.setAttribute("currentUser", user);
        CsrfUtil.getOrCreateToken(newSession);

        logger.info("User {} successfully authenticated via OTP", user.getEmail());

        if (isApi) {
            Map<String, Object> data = new HashMap<>();
            data.put("userId", user.getId());
            data.put("email", user.getEmail());
            data.put("role", user.getRole().name());
            String redirectUrl = req.getContextPath() + (user.getRole() == User.Role.ADMIN ? "/admin/dashboard" : "/customer/my-bookings");
            data.put("redirectUrl", redirectUrl);
            sendJson(resp, HttpServletResponse.SC_OK, true, "Authentication successful! Redirecting...", data);
        } else {
            if (user.getRole() == User.Role.ADMIN) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else if (user.getRole() == User.Role.STAFF) {
                resp.sendRedirect(req.getContextPath() + "/staff/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
            }
        }
    }

    private void sendJson(HttpServletResponse resp, int status, boolean success, String message, Object data) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Map<String, Object> map = new HashMap<>();
        map.put("success", success);
        map.put("message", message);
        if (data != null) map.put("data", data);
        resp.getWriter().write(gson.toJson(map));
    }
}


package com.hotel.filter;

import com.hotel.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 * Enforces Role-Based Access Control (RBAC) across customer, staff, and admin routes.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/customer/*", "/staff/*", "/admin/*"})
public class AuthFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(AuthFilter.class);

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Check if user is logged in
        if (currentUser == null) {
            logger.info("Unauthenticated attempt to access protected resource: {}. Redirecting to login.", path);
            String redirectUrl = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUrl += "?" + req.getQueryString();
            }
            res.sendRedirect(req.getContextPath() + "/login?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Enforce role-based access
        if (path.startsWith("/admin/")) {
            if (currentUser.getRole() != User.Role.ADMIN) {
                logger.warn("Unauthorized attempt by user {} ({}) to access admin path: {}",
                        currentUser.getId(), currentUser.getRole(), path);
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrator privileges required.");
                return;
            }
        } else if (path.startsWith("/staff/")) {
            if (currentUser.getRole() != User.Role.STAFF && currentUser.getRole() != User.Role.ADMIN) {
                logger.warn("Unauthorized attempt by user {} ({}) to access staff path: {}",
                        currentUser.getId(), currentUser.getRole(), path);
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Staff or Administrator privileges required.");
                return;
            }
        }

        // Passed role check
        chain.doFilter(request, response);
    }
}

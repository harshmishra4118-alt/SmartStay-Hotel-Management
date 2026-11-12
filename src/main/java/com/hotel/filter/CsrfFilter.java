package com.hotel.filter;

import com.hotel.util.CsrfUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 * Filter to enforce Cross-Site Request Forgery (CSRF) protection on state-modifying requests.
 */
@WebFilter(filterName = "CsrfFilter", urlPatterns = {"/*"})
public class CsrfFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(CsrfFilter.class);

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Skip static resources
        if (path.startsWith("/assets/") || path.endsWith(".css") || path.endsWith(".js") ||
            path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".jpeg") ||
            path.endsWith(".svg") || path.endsWith(".ico")) {
            chain.doFilter(request, response);
            return;
        }

        // Ensure session exists and CSRF token is present
        HttpSession session = req.getSession(true);
        String token = CsrfUtil.getOrCreateToken(session);
        req.setAttribute("csrfToken", token);

        String method = req.getMethod();
        boolean isStateChanging = "POST".equalsIgnoreCase(method) ||
                                  "PUT".equalsIgnoreCase(method) ||
                                  "DELETE".equalsIgnoreCase(method);

        // Exempt AJAX API endpoints and external payment webhooks/verification
        boolean isExemptApi = path.startsWith("/api/") || path.equals("/payment/razorpay-verify");

        if (isStateChanging && !isExemptApi) {
            if (!CsrfUtil.isValidToken(req)) {
                logger.warn("CSRF token validation failed for path: {} from IP: {}", path, req.getRemoteAddr());
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Security verification failed (Invalid or missing CSRF token). Please refresh the page and try again.");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}

package com.hotel.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility for Cross-Site Request Forgery (CSRF) token generation and verification.
 */
public class CsrfUtil {

    public static final String CSRF_PARAM_NAME = "csrfToken";
    public static final String CSRF_SESSION_ATTR = "csrfToken";
    public static final String CSRF_HEADER_NAME = "X-CSRF-TOKEN";

    private static final SecureRandom random = new SecureRandom();

    public static String generateToken() {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static String getOrCreateToken(HttpSession session) {
        if (session == null) return "";
        synchronized (session) {
            String token = (String) session.getAttribute(CSRF_SESSION_ATTR);
            if (token == null || token.trim().isEmpty()) {
                token = generateToken();
                session.setAttribute(CSRF_SESSION_ATTR, token);
            }
            return token;
        }
    }

    public static boolean isValidToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        String sessionToken = (String) session.getAttribute(CSRF_SESSION_ATTR);
        if (sessionToken == null || sessionToken.trim().isEmpty()) {
            return false;
        }

        // Check request parameter first, then header
        String submittedToken = request.getParameter(CSRF_PARAM_NAME);
        if (submittedToken == null || submittedToken.trim().isEmpty()) {
            submittedToken = request.getHeader(CSRF_HEADER_NAME);
        }

        if (submittedToken == null) {
            return false;
        }

        // Constant time comparison to prevent timing attacks
        return java.security.MessageDigest.isEqual(
                sessionToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                submittedToken.trim().getBytes(java.nio.charset.StandardCharsets.UTF_8)
        );
    }
}

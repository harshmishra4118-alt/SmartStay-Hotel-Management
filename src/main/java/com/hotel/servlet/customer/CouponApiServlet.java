package com.hotel.servlet.customer;

import com.google.gson.Gson;
import com.hotel.service.CouponService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "CouponApiServlet", urlPatterns = {"/api/coupon/validate"})
public class CouponApiServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(CouponApiServlet.class);
    private final CouponService couponService = new CouponService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String amountStr = req.getParameter("amount");

        BigDecimal amount = BigDecimal.ZERO;
        if (amountStr != null && !amountStr.trim().isEmpty()) {
            try {
                amount = new BigDecimal(amountStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        CouponService.CouponValidationResult result = couponService.validateCoupon(code, amount);

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Map<String, Object> map = new HashMap<>();
        map.put("valid", result.isValid());
        map.put("message", result.getMessage());
        map.put("discountAmount", result.getDiscountAmount());
        if (result.getCoupon() != null) {
            map.put("code", result.getCoupon().getCode());
            map.put("discountType", result.getCoupon().getDiscountType().name());
            map.put("discountValue", result.getCoupon().getDiscountValue());
        }

        resp.getWriter().write(gson.toJson(map));
    }
}


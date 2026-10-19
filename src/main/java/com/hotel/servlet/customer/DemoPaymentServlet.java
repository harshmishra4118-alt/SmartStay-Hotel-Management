package com.hotel.servlet.customer;

import com.hotel.model.Invoice;
import com.hotel.model.Payment;
import com.hotel.model.User;
import com.hotel.service.BillingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet(name = "DemoPaymentServlet", urlPatterns = {"/customer/payment"})
public class DemoPaymentServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(DemoPaymentServlet.class);
    private final BillingService billingService = new BillingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String invoiceIdStr = req.getParameter("invoiceId");
        if (invoiceIdStr == null || invoiceIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            Long invoiceId = Long.parseLong(invoiceIdStr.trim());
            Invoice invoice = billingService.getInvoiceById(invoiceId);

            if (invoice == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Invoice not found.");
                return;
            }

            if (!currentUser.isStaff() && !invoice.getUserId().equals(currentUser.getId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to invoice.");
                return;
            }

            if (invoice.getPaymentStatus() == Invoice.PaymentStatus.PAID) {
                resp.sendRedirect(req.getContextPath() + "/customer/invoice?id=" + invoice.getId() + "&alreadyPaid=true");
                return;
            }

            req.setAttribute("invoice", invoice);
            req.setAttribute("paymentMethods", Payment.PaymentMethod.values());

            req.getRequestDispatcher("/WEB-INF/views/customer/payment-demo.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load demo payment page", e);
            resp.sendRedirect(req.getContextPath() + "/customer/my-bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String invoiceIdStr = req.getParameter("invoiceId");
        String methodStr = req.getParameter("paymentMethod");
        String notes = req.getParameter("notes");

        try {
            Long invoiceId = Long.parseLong(invoiceIdStr.trim());
            Invoice invoice = billingService.getInvoiceById(invoiceId);

            if (invoice == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Invoice not found.");
                return;
            }

            Payment.PaymentMethod method = Payment.PaymentMethod.CREDIT_CARD_DEMO;
            if (methodStr != null && !methodStr.trim().isEmpty()) {
                method = Payment.PaymentMethod.valueOf(methodStr.trim());
            }

            Payment payment = billingService.processDemoPayment(
                    invoiceId,
                    currentUser.getId(),
                    invoice.getTotalPayable(),
                    method,
                    notes != null ? notes : "Demo simulation checkout payment",
                    req.getRemoteAddr()
            );

            resp.sendRedirect(req.getContextPath() + "/customer/invoice?id=" + invoiceId + "&paymentSuccess=true");

        } catch (Exception e) {
            logger.error("Payment processing error", e);
            req.setAttribute("errorMessage", "Demo payment could not be processed: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

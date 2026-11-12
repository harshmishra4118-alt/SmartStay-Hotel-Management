package com.hotel.servlet.customer;

import com.hotel.model.Booking;
import com.hotel.model.Invoice;
import com.hotel.model.Payment;
import com.hotel.model.User;
import com.hotel.service.BillingService;
import com.hotel.service.BookingService;
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

@WebServlet(name = "InvoiceServlet", urlPatterns = {"/customer/invoice"})
public class InvoiceServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(InvoiceServlet.class);
    private final BillingService billingService = new BillingService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        String bookingIdStr = req.getParameter("bookingId");

        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            Invoice invoice = null;
            if (idStr != null && !idStr.trim().isEmpty()) {
                invoice = billingService.getInvoiceById(Long.parseLong(idStr.trim()));
            } else if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
                invoice = billingService.getInvoiceByBookingId(Long.parseLong(bookingIdStr.trim()));
            }

            if (invoice == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Invoice not found.");
                return;
            }

            if ("pdf".equalsIgnoreCase(req.getParameter("format")) || "true".equalsIgnoreCase(req.getParameter("download"))) {
                resp.sendRedirect(req.getContextPath() + "/customer/invoice/pdf?invoiceId=" + invoice.getId());
                return;
            }

            // Security: verify customer ownership or staff
            if (!currentUser.isStaff() && !invoice.getUserId().equals(currentUser.getId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to invoice.");
                return;
            }

            Booking booking = bookingService.getBookingById(invoice.getBookingId());
            List<Payment> payments = billingService.getPaymentsForInvoice(invoice.getId());

            req.setAttribute("invoice", invoice);
            req.setAttribute("booking", booking);
            req.setAttribute("payments", payments);

            req.getRequestDispatcher("/WEB-INF/views/customer/invoice.jsp").forward(req, resp);

        } catch (Exception e) {
            logger.error("Failed to load invoice", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading invoice details.");
        }
    }
}

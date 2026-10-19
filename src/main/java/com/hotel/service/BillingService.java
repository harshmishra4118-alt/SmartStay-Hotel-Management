package com.hotel.service;

import com.hotel.config.DatabaseConfig;
import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.InvoiceDAO;
import com.hotel.dao.NotificationDAO;
import com.hotel.dao.PaymentDAO;
import com.hotel.model.Booking;
import com.hotel.model.Invoice;
import com.hotel.model.Notification;
import com.hotel.model.Payment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class BillingService {

    private static final Logger logger = LoggerFactory.getLogger(BillingService.class);
    private static final SecureRandom random = new SecureRandom();

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public Invoice getInvoiceByBookingId(Long bookingId) throws SQLException {
        return invoiceDAO.findByBookingId(bookingId);
    }

    public Invoice getInvoiceById(Long invoiceId) throws SQLException {
        return invoiceDAO.findById(invoiceId);
    }

    public Invoice getInvoiceByNumber(String invoiceNumber) throws SQLException {
        return invoiceDAO.findByInvoiceNumber(invoiceNumber);
    }

    public List<Payment> getPaymentsForInvoice(Long invoiceId) throws SQLException {
        return paymentDAO.findByInvoiceId(invoiceId);
    }

    public List<Payment> getPaymentsForBooking(Long bookingId) throws SQLException {
        return paymentDAO.findByBookingId(bookingId);
    }

    /**
     * Executes safe demo payment simulation.
     * Transactionally creates payment record, marks invoice as PAID, and triggers confirmation.
     */
    public Payment processDemoPayment(Long invoiceId, Long userId, BigDecimal amount,
                                      Payment.PaymentMethod method, String transactionNotes,
                                      String clientIp) throws Exception {

        Invoice invoice = invoiceDAO.findById(invoiceId);
        if (invoice == null) {
            throw new IllegalArgumentException("Invoice not found.");
        }
        if (invoice.getPaymentStatus() == Invoice.PaymentStatus.PAID) {
            throw new IllegalStateException("Invoice is already fully paid.");
        }
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Payment amount must be greater than zero.");
        }

        String paymentRef = "PAY-DEMO-" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) +
                            "-" + (10000 + random.nextInt(90000));

        Payment payment = new Payment();
        payment.setPaymentReference(paymentRef);
        payment.setInvoiceId(invoiceId);
        payment.setBookingId(invoice.getBookingId());
        payment.setAmount(amount);
        payment.setPaymentMethod(method);
        payment.setPaymentStatus(Payment.RecordStatus.SUCCESS);
        payment.setTransactionNotes(transactionNotes != null ? transactionNotes : "Demo simulation transaction - No real money charged.");
        payment.setDemo(true);

        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                paymentDAO.create(payment, conn);
                invoiceDAO.updatePaymentStatus(invoiceId, Invoice.PaymentStatus.PAID, conn);

                conn.commit();
                logger.info("Processed demo payment {} for invoice {}", paymentRef, invoice.getInvoiceNumber());
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }

        notificationDAO.create(new Notification(
                userId,
                "Demo Payment Successful: " + paymentRef,
                "Demo payment of ₹" + amount + " for invoice " + invoice.getInvoiceNumber() +
                        " was recorded successfully.",
                Notification.NotificationType.PAYMENT,
                "/customer/invoice?id=" + invoiceId
        ));

        auditLogDAO.log(userId, "DEMO_PAYMENT_PROCESSED", "Payment", paymentRef,
                "Processed demo payment of ₹" + amount + " via " + method, clientIp);

        return payment;
    }

    public List<Invoice> listInvoices(Invoice.PaymentStatus status, int offset, int limit) throws SQLException {
        return invoiceDAO.listInvoices(status, offset, limit);
    }
}

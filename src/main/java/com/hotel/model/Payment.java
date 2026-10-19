package com.hotel.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Payment implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum PaymentMethod {
        CREDIT_CARD_DEMO("Demo Credit Card"),
        DEBIT_CARD_DEMO("Demo Debit Card"),
        UPI_DEMO("Demo UPI / QR"),
        CASH("Cash at Front Desk"),
        BANK_TRANSFER_DEMO("Demo Net Banking");

        private final String displayName;

        PaymentMethod(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public enum RecordStatus {
        SUCCESS("Successful"),
        PENDING("Pending"),
        FAILED("Failed");

        private final String displayName;

        RecordStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    private Long id;
    private String paymentReference;
    private Long invoiceId;
    private Long bookingId;
    private BigDecimal amount;
    private PaymentMethod paymentMethod;
    private RecordStatus paymentStatus;
    private String transactionNotes;
    private boolean isDemo;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;

    // Joined fields
    private String invoiceNumber;
    private String bookingReference;

    public Payment() {
        this.paymentMethod = PaymentMethod.CREDIT_CARD_DEMO;
        this.paymentStatus = RecordStatus.SUCCESS;
        this.isDemo = true;
        this.amount = BigDecimal.ZERO;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }

    public Long getInvoiceId() { return invoiceId; }
    public void setInvoiceId(Long invoiceId) { this.invoiceId = invoiceId; }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    public RecordStatus getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(RecordStatus paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getTransactionNotes() { return transactionNotes; }
    public void setTransactionNotes(String transactionNotes) { this.transactionNotes = transactionNotes; }

    public boolean isDemo() { return isDemo; }
    public void setDemo(boolean demo) { isDemo = demo; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }
}

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Razorpay Payment Gateway - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <!-- Checkout Header -->
                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                    <div class="bg-navy p-4 text-white d-flex align-items-center justify-content-between">
                        <div>
                            <span class="badge bg-gold text-dark px-2 py-1 mb-1 fw-bold">Online Payment Gateway</span>
                            <h3 class="font-serif text-white mb-0">Complete Your Reservation</h3>
                        </div>
                        <i class="bi bi-credit-card-2-front text-gold display-6"></i>
                    </div>

                    <div class="card-body p-4">
                        <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                        <!-- Hotel & Room Summary Card -->
                        <div class="p-3 bg-light rounded-3 mb-4 border">
                            <div class="d-flex align-items-center gap-3">
                                <c:if test="${not empty hotel.primaryImageUrl}">
                                    <img src="${hotel.primaryImageUrl}" alt="${hotel.name}" class="rounded-3" style="width: 100px; height: 80px; object-fit: cover;" />
                                </c:if>
                                <div>
                                    <h5 class="font-serif text-navy mb-1">${hotel.name}</h5>
                                    <p class="text-muted small mb-0"><i class="bi bi-geo-alt text-danger me-1"></i>${hotel.city}, ${hotel.state}</p>
                                    <small class="text-secondary fw-semibold">
                                        ${room.name} (#${room.roomNumber}) • ${booking.totalNights} Night(s)
                                    </small>
                                </div>
                            </div>
                        </div>

                        <!-- Itemized Pricing Breakdown -->
                        <h5 class="font-serif text-navy mb-3">Itemized Billing Summary</h5>
                        <div class="vstack gap-2 border-bottom pb-3 mb-3 small">
                            <div class="d-flex justify-content-between">
                                <span class="text-muted">Stay Duration:</span>
                                <strong>${booking.checkInDate} to ${booking.checkOutDate} (${booking.totalNights} nights)</strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-muted">Room Charges:</span>
                                <span>Rs <fmt:formatNumber value="${invoice.subtotalAmount}" maxFractionDigits="2" /></span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-muted">GST & State Luxury Tax (12%):</span>
                                <span>Rs <fmt:formatNumber value="${invoice.taxAmount}" maxFractionDigits="2" /></span>
                            </div>
                            <c:if test="${invoice.discountAmount > 0}">
                                <div class="d-flex justify-content-between text-success">
                                    <span><i class="bi bi-tag-fill me-1"></i>Coupon Discount:</span>
                                    <span>-Rs <fmt:formatNumber value="${invoice.discountAmount}" maxFractionDigits="2" /></span>
                                </div>
                            </c:if>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <small class="text-muted d-block">Total Payable Amount</small>
                                <span class="badge bg-success-subtle text-success border border-success">All taxes included</span>
                            </div>
                            <h2 class="font-serif text-navy fw-bold mb-0">Rs <fmt:formatNumber value="${invoice.totalPayable}" maxFractionDigits="2" /></h2>
                        </div>

                        <!-- Razorpay Live Checkout Trigger Button -->
                        <div class="text-center">
                            <button id="btnPayRazorpay" class="btn btn-navy btn-lg w-100 py-3 fw-bold shadow mb-3">
                                <i class="bi bi-lock-fill text-gold me-2"></i>Pay via Razorpay (Cards / UPI / NetBanking)
                            </button>
                            <small class="text-muted d-block">
                                <i class="bi bi-shield-check text-success me-1"></i>Secured with 256-bit SSL encryption & HMAC-SHA256 signature verification.
                            </small>
                        </div>

                        <!-- Hidden Verification Form for Razorpay Callback -->
                        <form id="razorpayVerifyForm" action="${pageContext.request.contextPath}/payment/razorpay-verify" method="POST" class="d-none">
                            <input type="hidden" name="booking_id" value="${booking.id}" />
                            <input type="hidden" name="razorpay_order_id" id="rzp_order_id" value="${transaction.gatewayOrderId}" />
                            <input type="hidden" name="razorpay_payment_id" id="rzp_payment_id" />
                            <input type="hidden" name="razorpay_signature" id="rzp_signature" />
                        </form>

                        <!-- Developer / Demo Simulation Box -->
                        <div class="border-top pt-3 mt-4 text-center">
                            <small class="text-muted d-block mb-2">Testing / Sandbox Environment:</small>
                            <button type="button" id="btnSimulateSuccess" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-play-circle me-1 text-primary"></i>Simulate Razorpay Payment Success
                            </button>
                        </div>
                    </div>
                </div>

                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/customer/my-bookings" class="text-muted small text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i>Return to My Bookings
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Razorpay Standard Checkout Script -->
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const btnPay = document.getElementById('btnPayRazorpay');
    const verifyForm = document.getElementById('razorpayVerifyForm');
    const btnSimulate = document.getElementById('btnSimulateSuccess');

    // Razorpay Checkout Configuration
    const options = {
        "key": "${razorpayKeyId}",
        "amount": "${amountInPaise}",
        "currency": "INR",
        "name": "SmartStay Luxury Hotels",
        "description": "Reservation #${booking.bookingReference}",
        "image": "${pageContext.request.contextPath}/assets/img/logo.png",
        "order_id": "${transaction.gatewayOrderId}",
        "handler": function (response) {
            document.getElementById('rzp_order_id').value = response.razorpay_order_id;
            document.getElementById('rzp_payment_id').value = response.razorpay_payment_id;
            document.getElementById('rzp_signature').value = response.razorpay_signature;
            verifyForm.submit();
        },
        "prefill": {
            "name": "${booking.guestName}",
            "email": "${booking.guestEmail}",
            "contact": "${booking.guestPhone}"
        },
        "theme": {
            "color": "#0a192f"
        }
    };

    if (btnPay) {
        btnPay.addEventListener('click', function(e) {
            e.preventDefault();
            if (typeof Razorpay !== 'undefined') {
                const rzp = new Razorpay(options);
                rzp.open();
            } else {
                // If offline or script blocked, provide graceful sandbox simulation prompt
                if (confirm('Razorpay checkout script not reachable in this offline sandbox. Would you like to simulate successful payment authorization?')) {
                    simulatePayment();
                }
            }
        });
    }

    if (btnSimulate) {
        btnSimulate.addEventListener('click', simulatePayment);
    }

    function simulatePayment() {
        const fakePaymentId = 'pay_' + Math.random().toString(36).substring(2, 14);
        document.getElementById('rzp_order_id').value = "${transaction.gatewayOrderId}";
        document.getElementById('rzp_payment_id').value = fakePaymentId;
        document.getElementById('rzp_signature').value = "test_sig_" + fakePaymentId;
        verifyForm.submit();
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Payment Verification Failed - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100">
    <div class="container py-4">
        <div class="card border-0 shadow-sm rounded-4 p-5 max-w-700 mx-auto bg-white text-center">
            <div class="mb-4">
                <span class="badge bg-danger-subtle text-danger p-3 rounded-circle fs-1 shadow-sm">
                    <i class="bi bi-x-circle-fill"></i>
                </span>
            </div>

            <h2 class="font-serif fw-bold text-navy mb-2">Payment Verification Failed</h2>
            <p class="text-muted mb-4 lead">
                We could not cryptographically verify the transaction with our payment gateway. Your reservation has not been charged.
            </p>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger text-start small mb-4">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                </div>
            </c:if>

            <div class="p-3 bg-light rounded-3 mb-4 text-start small border">
                <p class="mb-1 text-muted"><strong>Troubleshooting Steps:</strong></p>
                <ul class="mb-0 text-secondary ps-3">
                    <li>Ensure your card or UPI account has sufficient balance and international/online transactions enabled.</li>
                    <li>Avoid refreshing the browser while the payment window is processing.</li>
                    <li>You can retry the transaction or select an alternative payment method.</li>
                </ul>
            </div>

            <div class="d-flex flex-wrap justify-content-center gap-3">
                <c:if test="${not empty bookingId}">
                    <a href="${pageContext.request.contextPath}/payment/razorpay?bookingId=${bookingId}" class="btn btn-navy px-4 py-2 fw-semibold">
                        <i class="bi bi-arrow-clockwise me-1 text-gold"></i>Retry Razorpay Payment
                    </a>
                </c:if>
                <a href="${pageContext.request.contextPath}/customer/my-bookings" class="btn btn-outline-secondary px-4 py-2">
                    <i class="bi bi-calendar2-range me-1"></i>View My Reservations
                </a>
                <a href="${pageContext.request.contextPath}/contact" class="btn btn-light px-3 py-2 text-muted">
                    <i class="bi bi-headset me-1"></i>Contact Concierge
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


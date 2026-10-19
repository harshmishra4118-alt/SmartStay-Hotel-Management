<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Demo Payment Simulation - AuraStay Luxury Suites"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-4 text-white">
    <div class="container">
        <h1 class="font-serif display-6 mb-1">Demo Payment Simulator</h1>
        <p class="text-light opacity-75 small mb-0">Academic demonstration portal — simulated transaction settlement.</p>
    </div>
</div>

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <!-- Demo Simulation Disclaimer Banner -->
    <div class="alert alert-warning border-warning d-flex align-items-center gap-3 p-3 mb-4 rounded-3 shadow-sm">
        <i class="bi bi-shield-exclamation fs-2 text-warning"></i>
        <div>
            <h6 class="alert-heading fw-bold mb-1">Simulation Environment Only</h6>
            <p class="mb-0 small">
                This is a mock payment sandbox for college portfolio demonstration. 
                <strong>No real bank account, UPI ID, or credit card will be charged.</strong> 
                Transactions are recorded safely in the local database with an explicit <code>is_demo = true</code> audit tag.
            </p>
        </div>
    </div>

    <div class="row g-4 justify-content-center">
        <!-- Invoice Summary Column -->
        <div class="col-lg-5">
            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                <div class="card-header bg-navy text-white py-3">
                    <h5 class="font-serif mb-0"><i class="bi bi-receipt me-2 text-gold"></i>Invoice Summary</h5>
                </div>
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-3">
                        <span class="text-secondary small">Invoice Number</span>
                        <span class="font-monospace fw-bold text-navy">${invoice.invoiceNumber}</span>
                    </div>
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-3">
                        <span class="text-secondary small">Total Invoice Value</span>
                        <span class="fw-semibold">₹<fmt:formatNumber value="${invoice.totalPayable}" pattern="#,##0.00"/></span>
                    </div>
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-3">
                        <span class="text-secondary small">Amount Already Paid</span>
                        <span class="text-success fw-semibold">₹<fmt:formatNumber value="${invoice.paidAmount}" pattern="#,##0.00"/></span>
                    </div>
                    <div class="d-flex justify-content-between pt-2 mb-4 bg-light p-3 rounded">
                        <span class="fw-bold text-navy">Settlement Amount Due:</span>
                        <span class="fw-bold text-gold fs-4">₹<fmt:formatNumber value="${invoice.balanceDue > 0 ? invoice.balanceDue : invoice.totalPayable}" pattern="#,##0.00"/></span>
                    </div>

                    <div class="p-3 bg-light rounded small text-secondary">
                        <p class="mb-1"><i class="bi bi-lock-fill text-success me-1"></i>256-bit TLS simulated checkout</p>
                        <p class="mb-0"><i class="bi bi-check2-circle text-gold me-1"></i>Instant reservation voucher update</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Payment Input Simulator Column -->
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="font-serif text-navy mb-0"><i class="bi bi-credit-card-2-front me-2 text-gold"></i>Select Demo Payment Method</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/customer/payment" method="POST" id="demoPaymentForm">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="invoiceId" value="${invoice.id}">

                        <!-- Method selection -->
                        <div class="mb-4">
                            <label class="form-label fw-bold text-navy small text-uppercase">Payment Channel</label>
                            <div class="row g-2">
                                <c:forEach var="method" items="${paymentMethods}">
                                    <div class="col-sm-6">
                                        <div class="form-check p-3 border rounded-3 bg-light hover-shadow">
                                            <input class="form-check-input" type="radio" name="paymentMethod" id="pm_${method.name()}" value="${method.name()}" ${method.name() == 'CREDIT_CARD_DEMO' ? 'checked' : ''} onchange="togglePaymentInputs(this.value)">
                                            <label class="form-check-label fw-semibold text-navy w-100" for="pm_${method.name()}">
                                                <i class="bi ${method.name().contains('CARD') ? 'bi-credit-card' : (method.name().contains('UPI') ? 'bi-qr-code' : (method.name().contains('NET') ? 'bi-bank' : 'bi-cash'))} text-gold me-2"></i>
                                                ${method.displayName}
                                            </label>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- Card Mock Form Fields (Default) -->
                        <div id="cardFields" class="p-3 border rounded bg-light mb-4">
                            <h6 class="small text-uppercase fw-bold text-navy mb-3"><i class="bi bi-credit-card me-1 text-gold"></i>Simulated Card Input</h6>
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Cardholder Name</label>
                                <input type="text" class="form-control form-control-sm" value="VALUED GUEST (DEMO)" readonly>
                            </div>
                            <div class="row g-2 mb-3">
                                <div class="col-8">
                                    <label class="form-label small text-secondary">Card Number (Mock)</label>
                                    <input type="text" class="form-control form-control-sm font-monospace" value="4532 •••• •••• 8899" readonly>
                                </div>
                                <div class="col-2">
                                    <label class="form-label small text-secondary">Expiry</label>
                                    <input type="text" class="form-control form-control-sm text-center" value="12/28" readonly>
                                </div>
                                <div class="col-2">
                                    <label class="form-label small text-secondary">CVV</label>
                                    <input type="password" class="form-control form-control-sm text-center" value="•••" readonly>
                                </div>
                            </div>
                            <small class="text-muted"><i class="bi bi-info-circle me-1"></i>Pre-populated mock test credentials for instant evaluation.</small>
                        </div>

                        <!-- UPI Mock Fields -->
                        <div id="upiFields" class="p-3 border rounded bg-light mb-4 d-none">
                            <h6 class="small text-uppercase fw-bold text-navy mb-3"><i class="bi bi-qr-code me-1 text-gold"></i>Simulated UPI VPA</h6>
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Virtual Payment Address (VPA)</label>
                                <div class="input-group input-group-sm">
                                    <input type="text" class="form-control font-monospace" value="aurastay.guest@okhdfcbank" readonly>
                                    <span class="input-group-text bg-success text-white"><i class="bi bi-check-circle"></i> Verified</span>
                                </div>
                            </div>
                            <div class="text-center p-3 bg-white border rounded">
                                <i class="bi bi-qr-code text-navy" style="font-size: 5rem;"></i>
                                <small class="d-block text-muted mt-1">Scan & Pay Mock QR Code (Simulated)</small>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Payment Notes (Optional)</label>
                            <input type="text" name="notes" class="form-control form-control-sm" placeholder="e.g. Advance deposit via Demo Simulator">
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-gold btn-lg fw-bold shadow-sm py-3">
                                <i class="bi bi-check-circle-fill me-2"></i>Authorize Demo Payment of ₹<fmt:formatNumber value="${invoice.balanceDue > 0 ? invoice.balanceDue : invoice.totalPayable}" pattern="#,##0.00"/>
                            </button>
                            <a href="${pageContext.request.contextPath}/customer/invoice?id=${invoice.id}" class="btn btn-outline-secondary btn-sm">
                                Cancel & Return to Invoice
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function togglePaymentInputs(method) {
    const cardFields = document.getElementById('cardFields');
    const upiFields = document.getElementById('upiFields');
    if (method === 'UPI_DEMO') {
        cardFields.classList.add('d-none');
        upiFields.classList.remove('d-none');
    } else {
        cardFields.classList.remove('d-none');
        upiFields.classList.add('d-none');
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

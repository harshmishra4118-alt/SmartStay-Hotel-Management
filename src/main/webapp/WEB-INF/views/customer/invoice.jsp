<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Tax Invoice #${invoice.invoiceNumber} - SmartStay Hotel"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-4 text-white no-print">
    <div class="container d-flex flex-wrap justify-content-between align-items-center">
        <div>
            <h1 class="font-serif display-6 mb-1">Tax Invoice & Billing</h1>
            <p class="text-light opacity-75 small mb-0">Official receipt and payment ledger for reservation ${booking.bookingReference}.</p>
        </div>
        <div class="mt-3 mt-md-0 d-flex gap-2">
            <button onclick="window.print()" class="btn btn-outline-light btn-sm">
                <i class="bi bi-printer me-1"></i> Print Invoice
            </button>
            <c:if test="${invoice.paymentStatus.name() != 'PAID' && booking.bookingStatus.name() != 'CANCELLED'}">
                <a href="${pageContext.request.contextPath}/customer/payment?invoiceId=${invoice.id}" class="btn btn-gold btn-sm">
                    <i class="bi bi-credit-card-2-front me-1"></i> Pay Balance Online (Demo)
                </a>
            </c:if>
        </div>
    </div>
</div>

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <c:if test="${param.paymentSuccess == 'true'}">
        <div class="alert alert-success alert-dismissible fade show small mb-4 no-print" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i> <strong>Payment Successful!</strong> Demo transaction was approved and recorded in your ledger.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.alreadyPaid == 'true'}">
        <div class="alert alert-info alert-dismissible fade show small mb-4 no-print" role="alert">
            <i class="bi bi-info-circle-fill me-2"></i> This invoice has already been paid in full.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Invoice Card Container -->
    <div class="card shadow-sm border-0 print-card mx-auto" style="max-width: 900px;">
        <div class="card-body p-4 p-md-5">
            <!-- Header Section -->
            <div class="row align-items-center border-bottom pb-4 mb-4">
                <div class="col-sm-7">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-gem text-gold fs-3"></i>
                        <span class="font-serif fs-3 fw-bold text-navy">SmartStay</span>
                    </div>
                    <p class="text-secondary small mb-1">SmartStay Hotel Private Limited</p>
                    <p class="text-secondary small mb-1">742 Marine Drive, Promenade District, Mumbai 400020</p>
                    <p class="text-secondary small mb-0">GSTIN: <span class="fw-semibold">27AAACA1234F1Z8</span> | CIN: U55101MH2023PTC998877</p>
                </div>
                <div class="col-sm-5 text-sm-end mt-3 mt-sm-0">
                    <span class="badge bg-navy text-gold px-3 py-2 fs-6 mb-2">ORIGINAL TAX INVOICE</span>
                    <h5 class="fw-bold text-navy mb-1">${invoice.invoiceNumber}</h5>
                    <p class="text-muted small mb-1">Issued: <fmt:parseDate value="${invoice.issueDate}" pattern="yyyy-MM-dd" var="parsedIssue" type="date"/><fmt:formatDate value="${parsedIssue}" pattern="dd MMM yyyy"/></p>
                    <c:choose>
                        <c:when test="${invoice.paymentStatus.name() == 'PAID'}">
                            <span class="badge badge-paid fs-6"><i class="bi bi-check-circle me-1"></i>PAID IN FULL</span>
                        </c:when>
                        <c:when test="${invoice.paymentStatus.name() == 'PARTIAL'}">
                            <span class="badge badge-pending fs-6"><i class="bi bi-pie-chart me-1"></i>PARTIAL PAYMENT</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-unpaid fs-6"><i class="bi bi-exclamation-circle me-1"></i>PAYMENT DUE</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Billed To & Reservation Info -->
            <div class="row mb-4">
                <div class="col-sm-6 mb-3 mb-sm-0">
                    <h6 class="text-navy text-uppercase fw-bold small mb-2">Billed To (Guest Details)</h6>
                    <p class="fw-bold mb-1">${booking.guestName}</p>
                    <p class="text-secondary small mb-1"><i class="bi bi-envelope me-1"></i>${booking.guestEmail}</p>
                    <p class="text-secondary small mb-0"><i class="bi bi-telephone me-1"></i>${booking.guestPhone}</p>
                </div>
                <div class="col-sm-6 text-sm-end">
                    <h6 class="text-navy text-uppercase fw-bold small mb-2">Reservation Reference</h6>
                    <p class="fw-bold mb-1 font-monospace text-navy">${booking.bookingReference}</p>
                    <p class="text-secondary small mb-1">Check-In: <strong>${booking.checkInDate}</strong> (from 14:00)</p>
                    <p class="text-secondary small mb-0">Check-Out: <strong>${booking.checkOutDate}</strong> (by 11:00)</p>
                </div>
            </div>

            <!-- Itemized Table -->
            <div class="table-responsive mb-4">
                <table class="table table-bordered align-middle">
                    <thead class="table-light">
                        <tr>
                            <th class="text-center" style="width: 50px;">#</th>
                            <th>Description</th>
                            <th class="text-center" style="width: 100px;">Rate / Night</th>
                            <th class="text-center" style="width: 80px;">Nights</th>
                            <th class="text-end" style="width: 130px;">Amount (INR)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="text-center">1</td>
                            <td>
                                <strong>${booking.roomName}</strong> (${booking.roomType.displayName})<br>
                                <small class="text-muted">Luxury accommodation with complimentary high-speed Wi-Fi, swimming pool access & gourmet breakfast</small>
                            </td>
                            <td class="text-center">₹<fmt:formatNumber value="${booking.roomPricePerNight}" pattern="#,##0.00"/></td>
                            <td class="text-center">${booking.totalNights}</td>
                            <td class="text-end">₹<fmt:formatNumber value="${invoice.roomCharges}" pattern="#,##0.00"/></td>
                        </tr>
                        <c:if test="${invoice.serviceCharges > 0}">
                            <tr>
                                <td class="text-center">2</td>
                                <td>Additional Hospitality & Concierge Services</td>
                                <td class="text-center">-</td>
                                <td class="text-center">-</td>
                                <td class="text-end">₹<fmt:formatNumber value="${invoice.serviceCharges}" pattern="#,##0.00"/></td>
                            </tr>
                        </c:if>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="4" class="text-end text-secondary">Subtotal (Net Amount):</td>
                            <td class="text-end fw-semibold">₹<fmt:formatNumber value="${invoice.subtotal}" pattern="#,##0.00"/></td>
                        </tr>
                        <tr>
                            <td colspan="4" class="text-end text-secondary">Goods & Services Tax (GST 12%):</td>
                            <td class="text-end fw-semibold">₹<fmt:formatNumber value="${invoice.taxAmount}" pattern="#,##0.00"/></td>
                        </tr>
                        <c:if test="${invoice.discountAmount > 0}">
                            <tr>
                                <td colspan="4" class="text-end text-success">Promotional Privilege Discount:</td>
                                <td class="text-end text-success">-₹<fmt:formatNumber value="${invoice.discountAmount}" pattern="#,##0.00"/></td>
                            </tr>
                        </c:if>
                        <tr class="table-light">
                            <td colspan="4" class="text-end fw-bold text-navy fs-5">Total Payable:</td>
                            <td class="text-end fw-bold text-gold fs-5">₹<fmt:formatNumber value="${invoice.totalPayable}" pattern="#,##0.00"/></td>
                        </tr>
                        <tr>
                            <td colspan="4" class="text-end text-success fw-semibold">Total Paid to Date:</td>
                            <td class="text-end text-success fw-semibold">₹<fmt:formatNumber value="${invoice.paidAmount}" pattern="#,##0.00"/></td>
                        </tr>
                        <tr class="${invoice.balanceDue > 0 ? 'table-warning' : 'table-light'}">
                            <td colspan="4" class="text-end fw-bold text-navy">Balance Due:</td>
                            <td class="text-end fw-bold ${invoice.balanceDue > 0 ? 'text-danger' : 'text-success'}">
                                ₹<fmt:formatNumber value="${invoice.balanceDue}" pattern="#,##0.00"/>
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <!-- Payment Ledger History -->
            <div class="mb-4">
                <h6 class="text-navy text-uppercase fw-bold small mb-2">Recorded Transactions & Receipts</h6>
                <c:choose>
                    <c:when test="${not empty payments}">
                        <div class="table-responsive">
                            <table class="table table-sm table-bordered align-middle">
                                <thead class="table-light small">
                                    <tr>
                                        <th>Date & Time</th>
                                        <th>Receipt Ref</th>
                                        <th>Payment Channel</th>
                                        <th>Status</th>
                                        <th class="text-end">Amount</th>
                                    </tr>
                                </thead>
                                <tbody class="small">
                                    <c:forEach var="p" items="${payments}">
                                        <tr>
                                            <td>${p.createdAt}</td>
                                            <td class="font-monospace fw-semibold text-navy">${p.paymentReference}</td>
                                            <td>
                                                <i class="bi bi-credit-card me-1 text-gold"></i>
                                                ${p.paymentMethod.displayName}
                                                <c:if test="${p.demo}">
                                                    <span class="badge bg-secondary ms-1" style="font-size: 0.65rem;">DEMO</span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="badge ${p.status.name() == 'SUCCESS' ? 'badge-paid' : 'badge-unpaid'}">
                                                    ${p.status.displayName}
                                                </span>
                                            </td>
                                            <td class="text-end fw-bold">₹<fmt:formatNumber value="${p.amount}" pattern="#,##0.00"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted small fst-italic">No payments recorded yet for this invoice.</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Disclaimers & Signatures -->
            <div class="border-top pt-4 mt-4">
                <div class="row align-items-end">
                    <div class="col-sm-8">
                        <small class="text-muted d-block mb-1"><strong>Terms & Conditions:</strong></small>
                        <small class="text-muted d-block">1. This computer-generated document constitutes an official Tax Invoice under Indian GST regulations.</small>
                        <small class="text-muted d-block">2. All demo payment records are for simulation and college evaluation demonstration purposes.</small>
                        <small class="text-muted d-block">3. For billing inquiries, contact billing@SmartStay.com or frontdesk +91 22 2200 8899.</small>
                    </div>
                    <div class="col-sm-4 text-sm-end mt-4 mt-sm-0">
                        <div class="border-bottom border-dark pb-2 mb-1" style="width: 160px; margin-left: auto;">
                            <span class="font-serif fst-italic text-navy fw-bold">SmartStay Desk</span>
                        </div>
                        <small class="text-muted d-block">Authorized Signatory</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

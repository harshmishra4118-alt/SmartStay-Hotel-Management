<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Reservation Voucher - ${booking.bookingReference}"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <!-- Top Action Buttons (Hidden when printing) -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 no-print">
        <a href="${pageContext.request.contextPath}/customer/my-bookings" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left me-1"></i>Back to My Bookings
        </a>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-navy btn-sm" onclick="window.print()">
                <i class="bi bi-printer me-1"></i>Print Voucher
            </button>
            <c:if test="${not empty invoice}">
                <a href="${pageContext.request.contextPath}/customer/invoice?id=${invoice.id}" class="btn btn-outline-navy btn-sm">
                    <i class="bi bi-receipt me-1"></i>View Tax Invoice
                </a>
            </c:if>
            <c:if test="${booking.canBeCancelled()}">
                <button type="button" class="btn btn-outline-danger btn-sm" data-bs-toggle="modal" data-bs-target="#cancelModal">
                    <i class="bi bi-x-circle me-1"></i>Cancel Reservation
                </button>
            </c:if>
        </div>
    </div>

    <!-- Official Voucher Printable Card -->
    <div class="bg-white p-4 p-md-5 rounded-3 shadow border print-full-width">
        <!-- Voucher Header -->
        <div class="d-flex justify-content-between align-items-start border-bottom pb-4 mb-4">
            <div>
                <h3 class="font-serif text-navy mb-1"><i class="bi bi-gem text-gold me-2"></i>AuraStay Suites & Resort</h3>
                <p class="text-muted small mb-0">7 Royal Palms Boulevard, Marina Bay &bull; +91 (022) 8900 1200</p>
                <small class="text-secondary">Official Guest Reservation Voucher</small>
            </div>
            <div class="text-end">
                <span class="badge bg-navy text-gold px-3 py-2 fs-6 d-inline-block mb-1">
                    ${booking.bookingReference}
                </span>
                <div class="d-block">
                    <c:choose>
                        <c:param name="status" value="${booking.bookingStatus.name()}"/>
                        <c:when test="${booking.bookingStatus.name() == 'CONFIRMED'}"><span class="badge badge-confirmed">Confirmed</span></c:when>
                        <c:when test="${booking.bookingStatus.name() == 'CHECKED_IN'}"><span class="badge badge-checkedin">Checked In</span></c:when>
                        <c:when test="${booking.bookingStatus.name() == 'CHECKED_OUT'}"><span class="badge badge-checkedout">Checked Out</span></c:when>
                        <c:when test="${booking.bookingStatus.name() == 'CANCELLED'}"><span class="badge badge-cancelled">Cancelled</span></c:when>
                        <c:otherwise><span class="badge badge-pending">Pending</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Voucher Body Grid -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="p-3 bg-light rounded border h-100">
                    <h6 class="font-serif text-navy text-uppercase small fw-bold border-bottom pb-2 mb-2">Guest Particulars</h6>
                    <p class="small mb-1"><strong>Primary Guest:</strong> ${booking.guestName}</p>
                    <p class="small mb-1"><strong>Email:</strong> ${booking.guestEmail}</p>
                    <p class="small mb-1"><strong>Telephone:</strong> ${booking.guestPhone}</p>
                    <p class="small mb-0"><strong>Guests:</strong> ${booking.numGuests} registered</p>
                </div>
            </div>

            <div class="col-md-6">
                <div class="p-3 bg-light rounded border h-100">
                    <h6 class="font-serif text-navy text-uppercase small fw-bold border-bottom pb-2 mb-2">Stay Schedule</h6>
                    <p class="small mb-1"><strong>Check-In:</strong> ${booking.checkInDate} <small class="text-muted">(from 2:00 PM)</small></p>
                    <p class="small mb-1"><strong>Check-Out:</strong> ${booking.checkOutDate} <small class="text-muted">(until 11:00 AM)</small></p>
                    <p class="small mb-1"><strong>Total Duration:</strong> ${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''}</p>
                    <p class="small mb-0"><strong>Room Number:</strong> Room #${booking.roomNumber} (${booking.roomName})</p>
                </div>
            </div>
        </div>

        <!-- Pricing & Billing Summary -->
        <div class="table-responsive mb-4">
            <table class="table table-bordered align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Description</th>
                        <th class="text-center">Rate</th>
                        <th class="text-center">Nights</th>
                        <th class="text-end">Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <strong>${booking.roomName}</strong> (${booking.roomType.displayName})<br>
                            <small class="text-muted">Includes complimentary high-speed Wi-Fi & gourmet breakfast buffet</small>
                        </td>
                        <td class="text-center">₹<fmt:formatNumber value="${booking.roomPricePerNight}" pattern="#,##0.00"/></td>
                        <td class="text-center">${booking.totalNights}</td>
                        <td class="text-end">₹<fmt:formatNumber value="${booking.baseAmount}" pattern="#,##0.00"/></td>
                    </tr>
                    <tr>
                        <td colspan="3" class="text-end text-muted small">Taxes & GST (12%):</td>
                        <td class="text-end">₹<fmt:formatNumber value="${booking.taxAmount}" pattern="#,##0.00"/></td>
                    </tr>
                    <tr class="table-light fs-5 fw-bold text-navy">
                        <td colspan="3" class="text-end">Total Reservation Value:</td>
                        <td class="text-end text-gold">₹<fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0.00"/></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <c:if test="${not empty booking.specialRequests}">
            <div class="p-3 bg-light rounded border mb-4">
                <small class="fw-bold text-navy text-uppercase d-block mb-1">Special Requests Recorded:</small>
                <small class="text-secondary">${booking.specialRequests}</small>
            </div>
        </c:if>

        <!-- Payment Settlement Status -->
        <div class="p-3 bg-light rounded border d-flex flex-wrap justify-content-between align-items-center mb-4">
            <div>
                <small class="text-muted text-uppercase fw-bold d-block">Payment Settlement</small>
                <c:choose>
                    <c:when test="${invoice.paymentStatus.name() == 'PAID'}">
                        <span class="badge badge-paid fs-6"><i class="bi bi-check-circle-fill me-1"></i>Settled / Paid in Full</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-unpaid fs-6"><i class="bi bi-clock-history me-1"></i>Unpaid (Due at Check-in or Online)</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <c:if test="${invoice.paymentStatus.name() != 'PAID' && booking.bookingStatus.name() != 'CANCELLED'}">
                <a href="${pageContext.request.contextPath}/customer/payment?invoiceId=${invoice.id}" class="btn btn-gold btn-sm no-print mt-2 mt-sm-0">
                    <i class="bi bi-credit-card-2-front me-1"></i>Settle via Demo Payment Simulator
                </a>
            </c:if>
        </div>

        <div class="text-muted small border-top pt-3">
            <p class="mb-1"><i class="bi bi-info-circle me-1"></i>Please present this voucher along with official government photo ID at the front desk upon check-in.</p>
            <p class="mb-0">&copy; AuraStay Luxury Suites. Generated automatically on ${booking.createdAt}.</p>
        </div>
    </div>
</div>

<!-- Cancel Reservation Modal -->
<div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title font-serif" id="cancelModalLabel">Cancel Reservation</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/customer/cancel-booking" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}">
                <input type="hidden" name="bookingId" value="${booking.id}">

                <div class="modal-body">
                    <p class="text-secondary small">
                        Are you sure you wish to cancel reservation <strong>${booking.bookingReference}</strong>? 
                        Any advance demo payment will be marked as refunded.
                    </p>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary">Reason for Cancellation (Optional)</label>
                        <input type="text" name="reason" class="form-control form-control-sm" placeholder="e.g. Change of flight schedule">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Keep Reservation</button>
                    <button type="submit" class="btn btn-danger btn-sm">Confirm Cancellation</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

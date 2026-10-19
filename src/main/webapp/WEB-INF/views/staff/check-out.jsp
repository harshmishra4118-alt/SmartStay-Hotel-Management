<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Guest Express Check-Out - AuraStay Front Desk"/>
</jsp:include>

<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Staff Sidebar -->
        <div class="col-lg-2 col-md-3">
            <jsp:include page="/WEB-INF/views/common/staff-sidebar.jsp" />
        </div>

        <!-- Main Content Area -->
        <div class="col-lg-10 col-md-9 bg-light min-vh-100 p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <div>
                    <h2 class="font-serif text-navy mb-1">Guest Express Check-Out</h2>
                    <p class="text-secondary small mb-0">Settle guest folio, retrieve room keys, finalize departure, and trigger housekeeping cleaning.</p>
                </div>
                <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Return to Terminal
                </a>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <!-- Booking Reference Search Bar -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-4">
                <form action="${pageContext.request.contextPath}/staff/check-out" method="GET" class="row g-3 align-items-center">
                    <div class="col-md-9">
                        <label class="form-label small fw-bold text-navy text-uppercase">Enter Booking Reference</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" name="ref" class="form-control font-monospace" placeholder="e.g. AURA-20261019-XXXX" value="${param.ref}" required>
                        </div>
                    </div>
                    <div class="col-md-3 pt-md-4">
                        <button type="submit" class="btn btn-navy w-100 fw-bold">
                            Find Reservation
                        </button>
                    </div>
                </form>
            </div>

            <!-- Booking Details Card if found -->
            <c:choose>
                <c:when test="${not empty booking}">
                    <div class="card border-0 shadow-sm rounded-3 bg-white p-4 p-md-5">
                        <div class="d-flex flex-wrap justify-content-between align-items-center border-bottom pb-3 mb-4">
                            <div>
                                <span class="badge bg-navy text-gold px-3 py-2 mb-2">RESERVATION FOUND</span>
                                <h4 class="font-serif text-navy mb-0">${booking.bookingReference}</h4>
                            </div>
                            <div class="text-end">
                                <span class="badge ${booking.bookingStatus.name() == 'CHECKED_IN' ? 'badge-confirmed' : 'badge-unpaid'} fs-6">
                                    ${booking.bookingStatus.displayName}
                                </span>
                            </div>
                        </div>

                        <div class="row g-4 mb-4">
                            <div class="col-md-6">
                                <h6 class="text-navy text-uppercase fw-bold small mb-3">Guest Information</h6>
                                <p class="mb-1 fw-bold fs-5">${booking.guestName}</p>
                                <p class="text-secondary small mb-1"><i class="bi bi-envelope me-1"></i>${booking.guestEmail}</p>
                                <p class="text-secondary small mb-0"><i class="bi bi-telephone me-1"></i>${booking.guestPhone}</p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-navy text-uppercase fw-bold small mb-3">Occupied Suite Details</h6>
                                <p class="mb-1 fw-bold fs-5">${booking.roomName} (Room #${booking.roomNumber})</p>
                                <p class="text-secondary small mb-1">Stay Duration: <strong>${booking.checkInDate} to ${booking.checkOutDate} (${booking.totalNights} nights)</strong></p>
                                <p class="text-secondary small mb-0">Total Folio Amount: <strong>₹<fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0.00"/></strong></p>
                            </div>
                        </div>

                        <!-- Check-Out Execution Form -->
                        <c:choose>
                            <c:when test="${booking.bookingStatus.name() == 'CHECKED_IN'}">
                                <form action="${pageContext.request.contextPath}/staff/check-out" method="POST" class="border-top pt-4">
                                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                                    <input type="hidden" name="bookingId" value="${booking.id}">

                                    <h6 class="text-navy text-uppercase fw-bold small mb-3">Departure Handover & Inventory Checklist</h6>
                                    <div class="bg-light p-3 rounded mb-4">
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" id="checkKeyReturn" required>
                                            <label class="form-check-label small fw-semibold text-navy" for="checkKeyReturn">
                                                Retrieved physical RFID access key cards for Room #${booking.roomNumber}
                                            </label>
                                        </div>
                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="checkbox" id="checkMinibar" required>
                                            <label class="form-check-label small fw-semibold text-navy" for="checkMinibar">
                                                Room minibar and amenities consumption reviewed with guest
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="checkFolio" required>
                                            <label class="form-check-label small fw-semibold text-navy" for="checkFolio">
                                                Final Tax Invoice generated and sent to guest email: ${booking.guestEmail}
                                            </label>
                                        </div>
                                    </div>

                                    <div class="alert alert-secondary small d-flex align-items-center gap-2 mb-4">
                                        <i class="bi bi-info-circle fs-5 text-primary"></i>
                                        <span>Confirming check-out will mark Room #${booking.roomNumber} as <strong>DIRTY</strong> on the Housekeeping Board for immediate sanitization.</span>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-outline-secondary btn-sm">Cancel</a>
                                        <button type="submit" class="btn btn-gold px-4 py-2 fw-bold">
                                            <i class="bi bi-box-arrow-right me-1"></i> Finalize Guest Check-Out
                                        </button>
                                    </div>
                                </form>
                            </c:when>
                            <c:when test="${booking.bookingStatus.name() == 'CHECKED_OUT'}">
                                <div class="alert alert-info border-0 rounded-3 mb-0">
                                    <i class="bi bi-info-circle-fill me-2"></i> This reservation has already completed check-out and departure.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-warning border-0 rounded-3 mb-0">
                                    <i class="bi bi-exclamation-triangle-fill me-2"></i> This reservation cannot be checked out because its status is <strong>${booking.bookingStatus.displayName}</strong> (Guest has not checked in).
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:when test="${not empty param.ref}">
                    <div class="card border-0 shadow-sm rounded-3 bg-white p-5 text-center">
                        <i class="bi bi-search text-muted" style="font-size: 3rem;"></i>
                        <h5 class="font-serif text-navy mt-3">No Reservation Found</h5>
                        <p class="text-secondary small mb-0">No booking was found matching reference "<strong>${param.ref}</strong>".</p>
                    </div>
                </c:when>
            </c:choose>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

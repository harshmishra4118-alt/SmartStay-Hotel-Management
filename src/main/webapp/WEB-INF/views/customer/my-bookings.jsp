<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="My Reservations - SmartStay Hotel"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-4 text-white">
    <div class="container">
        <h1 class="font-serif display-6 mb-1">My Bookings & Stays</h1>
        <p class="text-light opacity-75 small mb-0">View booking vouchers, invoices, and stay history.</p>
    </div>
</div>

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <c:if test="${param.registered == 'true'}">
        <div class="alert alert-success alert-dismissible fade show p-4 mb-4 rounded-3 shadow-sm border-success" role="alert">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div>
                    <h5 class="alert-heading font-serif text-success mb-1">
                        <i class="bi bi-check-circle-fill me-2"></i>Welcome to SmartStay, <c:out value="${sessionScope.currentUser.fullName}"/>!
                    </h5>
                    <p class="mb-0 small text-muted">
                        Your complimentary guest account has been successfully created. Begin your journey by discovering our handpicked luxury suites across India.
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-gold btn-sm px-4 fw-semibold text-navy">
                    <i class="bi bi-search me-1"></i>Browse Available Rooms
                </a>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.cancelled == 'true'}">
        <div class="alert alert-warning alert-dismissible fade show small mb-4" role="alert">
            <i class="bi bi-info-circle-fill me-2"></i> Your reservation has been successfully cancelled.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.reviewSuccess == 'true'}">
        <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i> Thank you! Your review has been submitted and verified.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty bookings}">
            <div class="bg-white rounded-3 shadow-sm border overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Reference</th>
                                <th>Suite</th>
                                <th>Stay Dates</th>
                                <th>Guests</th>
                                <th>Total (₹)</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${bookings}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/customer/booking-details?ref=${b.bookingReference}" class="fw-bold text-navy text-decoration-none">
                                            ${b.bookingReference}
                                        </a>
                                        <small class="d-block text-muted">${b.createdAt}</small>
                                    </td>
                                    <td>
                                        <strong>${b.roomName}</strong>
                                        <small class="d-block text-muted">Room #${b.roomNumber} &bull; ${b.roomType.displayName}</small>
                                    </td>
                                    <td>
                                        <span class="small">${b.checkInDate} to ${b.checkOutDate}</span>
                                        <small class="d-block text-muted">${b.totalNights} night${b.totalNights > 1 ? 's' : ''}</small>
                                    </td>
                                    <td>${b.numGuests}</td>
                                    <td>
                                        <strong class="text-navy">₹<fmt:formatNumber value="${b.totalAmount}" pattern="#,##0.00"/></strong>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.bookingStatus.name() == 'CONFIRMED'}"><span class="badge badge-confirmed">Confirmed</span></c:when>
                                            <c:when test="${b.bookingStatus.name() == 'CHECKED_IN'}"><span class="badge badge-checkedin">Checked In</span></c:when>
                                            <c:when test="${b.bookingStatus.name() == 'CHECKED_OUT'}"><span class="badge badge-checkedout">Checked Out</span></c:when>
                                            <c:when test="${b.bookingStatus.name() == 'CANCELLED'}"><span class="badge badge-cancelled">Cancelled</span></c:when>
                                            <c:otherwise><span class="badge badge-pending">Pending</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.paymentStatus.name() == 'PAID'}">
                                                <span class="badge badge-paid">Paid</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-unpaid">Unpaid</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/customer/booking-details?ref=${b.bookingReference}" class="btn btn-outline-navy" title="View Voucher">
                                                <i class="bi bi-file-earmark-text"></i>
                                            </a>
                                            <c:if test="${b.bookingStatus.name() == 'CHECKED_OUT'}">
                                                <a href="${pageContext.request.contextPath}/customer/feedback?bookingRef=${b.bookingReference}" class="btn btn-outline-warning text-dark" title="Review Stay">
                                                    <i class="bi bi-star"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5 bg-white rounded-3 shadow-sm border">
                <i class="bi bi-calendar-x text-muted fs-1 mb-3 d-block"></i>
                <h4 class="font-serif text-navy">No Reservations on Record</h4>
                <p class="text-muted mx-auto mb-4" style="max-width: 480px;">
                    You do not currently have any active or past reservations with SmartStay.
                </p>
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-gold btn-sm px-4">
                    <i class="bi bi-search me-1"></i>Find Your Perfect Suite
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="My Notifications - AuraStay Luxury Suites"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-4 text-white">
    <div class="container d-flex flex-wrap justify-content-between align-items-center">
        <div>
            <h1 class="font-serif display-6 mb-1">In-App Notifications</h1>
            <p class="text-light opacity-75 small mb-0">Booking updates, payment acknowledgments, and guest concierge notices.</p>
        </div>
        <c:if test="${not empty notifications}">
            <div class="mt-3 mt-md-0">
                <a href="${pageContext.request.contextPath}/customer/notifications?markAll=true" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-check2-all me-1"></i> Mark All as Read
                </a>
            </div>
        </c:if>
    </div>
</div>

<div class="container my-5" style="max-width: 850px;">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <c:choose>
        <c:when test="${not empty notifications}">
            <div class="list-group shadow-sm border-0 rounded-3 overflow-hidden">
                <c:forEach var="n" items="${notifications}">
                    <div class="list-group-item list-group-item-action p-4 border-bottom ${!n.read ? 'bg-light border-start border-4 border-warning' : ''}">
                        <div class="d-flex w-100 justify-content-between align-items-center mb-1">
                            <div class="d-flex align-items-center gap-2">
                                <c:choose>
                                    <c:when test="${n.type.name() == 'BOOKING'}">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle"><i class="bi bi-check-circle me-1"></i>Booking Alert</span>
                                    </c:when>
                                    <c:when test="${n.type.name() == 'PAYMENT'}">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle"><i class="bi bi-credit-card me-1"></i>Payment Received</span>
                                    </c:when>
                                    <c:when test="${n.type.name() == 'CHECKIN'}">
                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle"><i class="bi bi-calendar-event me-1"></i>Check-In Notice</span>
                                    </c:when>
                                    <c:when test="${n.type.name() == 'CHECKOUT'}">
                                        <span class="badge bg-info-subtle text-info border border-info-subtle"><i class="bi bi-box-arrow-right me-1"></i>Check-Out Notice</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary-subtle text-secondary border"><i class="bi bi-bell me-1"></i>${n.type.displayName}</span>
                                    </c:otherwise>
                                </c:choose>
                                <h6 class="mb-0 fw-bold text-navy ${!n.read ? 'fw-bolder' : ''}">${n.title}</h6>
                            </div>
                            <small class="text-muted">${n.createdAt}</small>
                        </div>
                        <p class="mb-2 text-secondary small">${n.message}</p>
                        <div class="d-flex justify-content-end">
                            <c:if test="${!n.read}">
                                <a href="${pageContext.request.contextPath}/customer/notifications?markRead=${n.id}" class="text-decoration-none small text-gold fw-semibold">
                                    <i class="bi bi-check2 me-1"></i>Mark as Read
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5 bg-white rounded-3 shadow-sm border p-4">
                <i class="bi bi-bell-slash text-muted" style="font-size: 3.5rem;"></i>
                <h5 class="font-serif text-navy mt-3">No Notifications</h5>
                <p class="text-secondary small mb-3">You're completely up to date. Stay and reservation alerts will appear here.</p>
                <a href="${pageContext.request.contextPath}/customer/my-bookings" class="btn btn-navy btn-sm">
                    View My Reservations
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

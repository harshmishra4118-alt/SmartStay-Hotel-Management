<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Luxury Rooms & Suites - AuraStay"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<!-- Header Banner -->
<div class="bg-navy py-5 text-white">
    <div class="container text-center">
        <span class="text-gold text-uppercase small fw-bold tracking-wider">Accommodations</span>
        <h1 class="font-serif display-5 mt-1">Rooms & Suites Inventory</h1>
        <p class="text-light opacity-75 mx-auto mb-0" style="max-width: 600px;">
            Designed for uncompromising comfort, sublime acoustic privacy, and panoramic views.
        </p>
    </div>
</div>

<div class="container my-5">
    <!-- Filter Bar Card -->
    <div class="bg-white p-4 rounded-3 shadow-sm border mb-5">
        <form action="${pageContext.request.contextPath}/rooms" method="GET" class="row g-3 align-items-end">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Check-In</label>
                <input type="date" name="checkIn" class="form-control form-control-sm" value="${checkIn}">
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Check-Out</label>
                <input type="date" name="checkOut" class="form-control form-control-sm" value="${checkOut}">
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Guests</label>
                <select name="guests" class="form-select form-select-sm">
                    <option value="">Any Capacity</option>
                    <c:forEach begin="1" end="6" var="g">
                        <option value="${g}" ${guests == g ? 'selected' : ''}>${g} Guest${g > 1 ? 's' : ''}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Max Budget (₹)</label>
                <input type="number" name="maxBudget" class="form-control form-control-sm" placeholder="e.g. 10000" value="${maxBudget}">
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Suite Type</label>
                <select name="roomType" class="form-select form-select-sm">
                    <option value="">All Types</option>
                    <c:forEach var="t" items="${allRoomTypes}">
                        <option value="${t.name()}" ${selectedType == t.name() ? 'selected' : ''}>${t.displayName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6 d-flex gap-2">
                <button type="submit" class="btn btn-gold btn-sm flex-grow-1">
                    <i class="bi bi-filter me-1"></i>Filter
                </button>
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline-secondary btn-sm" title="Clear Filters">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </a>
            </div>
        </form>
    </div>

    <!-- Alert Banners -->
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <!-- Room Cards Grid -->
    <c:choose>
        <c:when test="${not empty rooms}">
            <div class="row g-4">
                <c:forEach var="room" items="${rooms}">
                    <div class="col-lg-4 col-md-6">
                        <div class="room-card">
                            <div class="room-card-img-wrapper">
                                <img src="${room.primaryImageUrl}" alt="${room.name}" loading="lazy">
                                <span class="room-badge-type">${room.roomType.displayName}</span>
                                <span class="room-badge-price">
                                    ₹<fmt:formatNumber value="${room.pricePerNight}" pattern="#,##0"/> <small>/night</small>
                                </span>
                            </div>
                            <div class="room-card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h4 class="room-card-title mb-0">${room.name}</h4>
                                    <span class="badge bg-light text-secondary border small">#${room.roomNumber}</span>
                                </div>
                                <p class="text-muted small mb-3">
                                    ${room.description}
                                </p>
                                <div class="d-flex align-items-center gap-3 text-muted small mb-3">
                                    <span><i class="bi bi-people-fill text-gold me-1"></i>${room.capacity} Guests</span>
                                    <span><i class="bi bi-aspect-ratio text-gold me-1"></i>${room.sizeSqft} sq ft</span>
                                    <span><i class="bi bi-door-closed text-gold me-1"></i>Floor ${room.floorNumber}</span>
                                </div>
                                <div class="mb-4">
                                    <c:forEach var="amenity" items="${room.amenitiesList}">
                                        <span class="room-amenity-pill"><i class="bi bi-check2 text-gold"></i>${amenity}</span>
                                    </c:forEach>
                                </div>
                                <div class="mt-auto d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/room-details?id=${room.id}" class="btn btn-outline-navy flex-grow-1">
                                        View Details
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/book?roomId=${room.id}&checkIn=${checkIn}&checkOut=${checkOut}&guests=${guests}" class="btn btn-gold flex-grow-1">
                                        Reserve Room
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5 bg-white rounded-3 shadow-sm border my-4">
                <i class="bi bi-door-closed text-muted fs-1 mb-3 d-block"></i>
                <h4 class="font-serif text-navy">No Suites Matched Your Criteria</h4>
                <p class="text-muted mx-auto mb-4" style="max-width: 500px;">
                    Try adjusting your budget, selecting different dates, or browsing all room types.
                </p>
                <div class="d-flex justify-content-center gap-2">
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-navy btn-sm">Reset All Filters</a>
                    <a href="${pageContext.request.contextPath}/rooms/recommend" class="btn btn-gold btn-sm">Try Smart Matcher</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

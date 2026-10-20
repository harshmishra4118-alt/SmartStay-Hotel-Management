<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Smart Suite Recommendations - SmartStay"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-5 text-white">
    <div class="container text-center">
        <span class="badge bg-gold text-dark mb-2 px-3 py-1 fw-bold text-uppercase">
            <i class="bi bi-cpu me-1"></i> Rule-Based Engine
        </span>
        <h1 class="font-serif display-5 mt-1">Smart Room Matcher</h1>
        <p class="text-light opacity-75 mx-auto mb-0" style="max-width: 600px;">
            Personalized suite recommendations scored deterministically using guest capacity, budget tolerance, and requested amenities.
        </p>
    </div>
</div>

<div class="container my-5">
    <!-- Search / Criteria Form -->
    <div class="bg-white p-4 rounded-3 shadow-sm border mb-5">
        <form action="${pageContext.request.contextPath}/rooms/recommend" method="GET">
            <div class="row g-3 mb-3">
                <div class="col-md-3 col-sm-6">
                    <label class="form-label small fw-bold text-uppercase text-secondary">Guests</label>
                    <select name="guests" class="form-select">
                        <c:forEach begin="1" end="6" var="g">
                            <option value="${g}" ${guests == g ? 'selected' : ''}>${g} Guest${g > 1 ? 's' : ''}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3 col-sm-6">
                    <label class="form-label small fw-bold text-uppercase text-secondary">Budget per Night (₹)</label>
                    <input type="number" name="maxBudget" class="form-control" placeholder="e.g. 15000" value="${maxBudget}">
                </div>
                <div class="col-md-3 col-sm-6">
                    <label class="form-label small fw-bold text-uppercase text-secondary">Check-In</label>
                    <input type="date" name="checkIn" class="form-control" value="${checkIn}">
                </div>
                <div class="col-md-3 col-sm-6">
                    <label class="form-label small fw-bold text-uppercase text-secondary">Check-Out</label>
                    <input type="date" name="checkOut" class="form-control" value="${checkOut}">
                </div>
            </div>

            <!-- Desired Amenities Checkboxes -->
            <div class="mb-3">
                <label class="form-label small fw-bold text-uppercase text-secondary d-block mb-2">
                    Priority Amenities (Score Boosters)
                </label>
                <div class="d-flex flex-wrap gap-3">
                    <c:forEach var="am" items="${['WiFi', 'Jacuzzi', 'Balcony', 'City View', 'Garden View', 'Espresso', 'Mini Bar', 'Kitchenette']}">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="amenities" value="${am}" id="chk_${am}"
                                   ${selectedAmenities.contains(am) ? 'checked' : ''}>
                            <label class="form-check-label small" for="chk_${am}">${am}</label>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                <small class="text-muted">
                    <i class="bi bi-info-circle me-1"></i>Scored by capacity fit (30%), budget proximity (30%), and amenity matches (25%).
                </small>
                <button type="submit" class="btn btn-gold px-4">
                    <i class="bi bi-stars me-1"></i>Calculate Matches
                </button>
            </div>
        </form>
    </div>

    <!-- Recommendations Result Grid -->
    <div class="mb-4">
        <h3 class="font-serif text-navy mb-1">Recommended Suites</h3>
        <p class="text-muted small">Sorted by best deterministic suitability score.</p>
    </div>

    <c:choose>
        <c:when test="${not empty recommendations}">
            <div class="row g-4">
                <c:forEach var="rec" items="${recommendations}">
                    <div class="col-lg-4 col-md-6">
                        <div class="room-card position-relative">
                            <div class="position-absolute top-0 end-0 m-3 z-3">
                                <span class="badge bg-gold text-dark shadow px-3 py-2 fw-bold" style="font-size: 0.85rem;">
                                    <i class="bi bi-stars me-1"></i>${rec.matchPercent}% Match
                                </span>
                            </div>
                            <div class="room-card-img-wrapper">
                                <img src="${rec.room.primaryImageUrl}" alt="${rec.room.name}" loading="lazy">
                                <span class="room-badge-type">${rec.room.roomType.displayName}</span>
                                <span class="room-badge-price">
                                    ₹<fmt:formatNumber value="${rec.room.pricePerNight}" pattern="#,##0"/> <small>/night</small>
                                </span>
                            </div>
                            <div class="room-card-body">
                                <h4 class="room-card-title">${rec.room.name}</h4>
                                <div class="p-2 bg-light rounded small text-secondary mb-3 border-start border-3 border-warning">
                                    <strong class="text-navy">Recommendation Match:</strong> ${rec.rationale}
                                </div>
                                <div class="d-flex align-items-center gap-3 text-muted small mb-3">
                                    <span><i class="bi bi-people-fill text-gold me-1"></i>${rec.room.capacity} Guests</span>
                                    <span><i class="bi bi-aspect-ratio text-gold me-1"></i>${rec.room.sizeSqft} sq ft</span>
                                    <span><i class="bi bi-moon-stars text-gold me-1"></i>${rec.room.bedType}</span>
                                </div>
                                <div class="mt-auto d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/room-details?id=${rec.room.id}" class="btn btn-outline-navy flex-grow-1">
                                        Details
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/book?roomId=${rec.room.id}&checkIn=${checkIn}&checkOut=${checkOut}&guests=${guests}" class="btn btn-gold flex-grow-1">
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
            <div class="text-center py-5 bg-white rounded-3 shadow-sm border">
                <i class="bi bi-search text-muted fs-1 mb-3 d-block"></i>
                <h4 class="font-serif text-navy">No Matches Available</h4>
                <p class="text-muted mx-auto mb-4" style="max-width: 500px;">
                    None of our suites fit the selected guest count or budget criteria. Try widening your budget or selecting fewer guests.
                </p>
                <a href="${pageContext.request.contextPath}/rooms/recommend" class="btn btn-navy btn-sm">Reset Criteria</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

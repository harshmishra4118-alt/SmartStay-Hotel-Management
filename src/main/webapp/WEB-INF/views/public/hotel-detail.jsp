<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="${hotel.name} - SmartStay Luxury" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<!-- Leaflet CSS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />

<main class="bg-light pb-5">
    <!-- Hero Banner with Primary Image -->
    <section class="position-relative text-white" style="background: linear-gradient(rgba(10, 25, 47, 0.75), rgba(10, 25, 47, 0.85)), url('${hotel.primaryImageUrl}') center/cover no-repeat; padding: 100px 0 60px;">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="badge bg-gold text-dark px-3 py-1 fw-bold">
                            <i class="bi bi-star-fill me-1"></i>${hotel.starRating} Five-Star Luxury
                        </span>
                        <span class="badge bg-white text-navy px-3 py-1 fw-bold">
                            <i class="bi bi-geo-alt-fill text-gold me-1"></i>${hotel.city}, ${hotel.state}
                        </span>
                    </div>
                    <h1 class="display-4 font-serif fw-bold text-white mb-2">${hotel.name}</h1>
                    <p class="lead text-light fst-italic mb-3">${hotel.tagline}</p>
                    <p class="text-white-50 small mb-0">
                        <i class="bi bi-pin-map me-1 text-gold"></i>${hotel.address}, ${hotel.postalCode}, ${hotel.country}
                        <span class="mx-2">•</span>
                        <i class="bi bi-telephone me-1 text-gold"></i>${hotel.phone}
                        <span class="mx-2">•</span>
                        <i class="bi bi-envelope me-1 text-gold"></i>${hotel.email}
                    </p>
                </div>
                <div class="col-lg-4 text-lg-end mt-4 mt-lg-0">
                    <div class="bg-white p-4 rounded-4 text-dark shadow-lg d-inline-block text-start w-100" style="max-width: 340px;">
                        <small class="text-muted d-block">Starting from</small>
                        <div class="d-flex align-items-baseline gap-1 mb-2">
                            <h2 class="font-serif text-navy fw-bold mb-0">Rs <fmt:formatNumber value="${hotel.minPrice}" maxFractionDigits="0" /></h2>
                            <small class="text-muted">/ night</small>
                        </div>
                        <a href="#availableRooms" class="btn btn-gold w-100 fw-bold py-2 shadow-sm mb-2">
                            <i class="bi bi-calendar-check me-1"></i>View Available Rooms
                        </a>
                        <c:if test="${not empty directionsUrl}">
                            <a href="${directionsUrl}" target="_blank" class="btn btn-outline-navy btn-sm w-100">
                                <i class="bi bi-map me-1 text-primary"></i>Get Map Directions
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- GPS Distance Banner (if detected) -->
    <c:if test="${not empty hotel.distanceKm}">
        <div class="bg-navy py-2 text-white border-top border-gold">
            <div class="container d-flex align-items-center justify-content-between small">
                <span>
                    <i class="bi bi-compass text-gold me-2"></i>
                    Distance from your current location: <strong><fmt:formatNumber value="${hotel.distanceKm}" maxFractionDigits="1" /> km</strong>
                </span>
                <span>
                    <i class="bi bi-car-front text-gold me-1"></i>${hotel.drivingTimeEstimate}
                    <span class="mx-2">•</span>
                    <i class="bi bi-person-walking text-gold me-1"></i>${hotel.walkingTimeEstimate}
                </span>
            </div>
        </div>
    </c:if>

    <div class="container mt-5">
        <div class="row g-4">
            <!-- Left Column: Gallery, Overview, Facilities, Reviews -->
            <div class="col-lg-8">
                <!-- Categorized Photo Gallery Tabs -->
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden mb-5">
                    <div class="card-header bg-white p-4 border-bottom-0 pb-0">
                        <div class="d-flex align-items-center justify-content-between">
                            <h3 class="font-serif text-navy mb-0">
                                <i class="bi bi-images text-gold me-2"></i>Hotel Image Gallery
                            </h3>
                            <span class="badge bg-light text-muted border">${hotel.images.size()} Photos</span>
                        </div>
                        <!-- Gallery Category Nav Tabs -->
                        <ul class="nav nav-tabs mt-3 border-bottom-0" id="galleryTabs" role="tablist">
                            <li class="nav-item">
                                <button class="nav-link active fw-semibold text-navy" data-bs-toggle="tab" data-bs-target="#tab-all">All Photos</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link fw-semibold text-navy" data-bs-toggle="tab" data-bs-target="#tab-exterior">Exterior & Grounds</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link fw-semibold text-navy" data-bs-toggle="tab" data-bs-target="#tab-suites">Suites & Rooms</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link fw-semibold text-navy" data-bs-toggle="tab" data-bs-target="#tab-pool">Pool & Spa</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link fw-semibold text-navy" data-bs-toggle="tab" data-bs-target="#tab-dining">Dining</button>
                            </li>
                        </ul>
                    </div>
                    <div class="card-body p-4 pt-3">
                        <div class="tab-content" id="galleryTabContent">
                            <!-- All Photos Grid -->
                            <div class="tab-pane fade show active" id="tab-all">
                                <div class="row g-3">
                                    <c:forEach var="img" items="${hotel.images}" varStatus="status">
                                        <div class="${status.index == 0 ? 'col-12' : 'col-md-6 col-lg-4'}">
                                            <div class="position-relative rounded-3 overflow-hidden shadow-sm" style="height: ${status.index == 0 ? '380px' : '200px'};">
                                                <img src="${img.imageUrl}" alt="${img.caption}" class="w-100 h-100" style="object-fit: cover;" />
                                                <div class="position-absolute bottom-0 start-0 end-0 bg-dark bg-opacity-75 p-2 text-white small">
                                                    <span class="badge bg-gold text-dark me-1" style="font-size: 0.65rem;">${img.category}</span>
                                                    ${img.caption}
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                            <!-- Exterior Tab -->
                            <div class="tab-pane fade" id="tab-exterior">
                                <div class="row g-3">
                                    <c:forEach var="img" items="${hotel.images}">
                                        <c:if test="${img.category == 'EXTERIOR' || img.category == 'RECEPTION'}">
                                            <div class="col-md-6">
                                                <div class="rounded-3 overflow-hidden shadow-sm" style="height: 240px;">
                                                    <img src="${img.imageUrl}" alt="${img.caption}" class="w-100 h-100" style="object-fit: cover;" />
                                                </div>
                                                <small class="text-muted d-block mt-1">${img.caption}</small>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                            <!-- Suites Tab -->
                            <div class="tab-pane fade" id="tab-suites">
                                <div class="row g-3">
                                    <c:forEach var="img" items="${hotel.images}">
                                        <c:if test="${img.category == 'LUXURY_SUITE' || img.category == 'BEDROOM' || img.category == 'DELUXE_ROOM' || img.category == 'BATHROOM'}">
                                            <div class="col-md-6">
                                                <div class="rounded-3 overflow-hidden shadow-sm" style="height: 240px;">
                                                    <img src="${img.imageUrl}" alt="${img.caption}" class="w-100 h-100" style="object-fit: cover;" />
                                                </div>
                                                <small class="text-muted d-block mt-1">${img.caption}</small>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                            <!-- Pool Tab -->
                            <div class="tab-pane fade" id="tab-pool">
                                <div class="row g-3">
                                    <c:forEach var="img" items="${hotel.images}">
                                        <c:if test="${img.category == 'SWIMMING_POOL' || img.category == 'FACILITY'}">
                                            <div class="col-md-6">
                                                <div class="rounded-3 overflow-hidden shadow-sm" style="height: 240px;">
                                                    <img src="${img.imageUrl}" alt="${img.caption}" class="w-100 h-100" style="object-fit: cover;" />
                                                </div>
                                                <small class="text-muted d-block mt-1">${img.caption}</small>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                            <!-- Dining Tab -->
                            <div class="tab-pane fade" id="tab-dining">
                                <div class="row g-3">
                                    <c:forEach var="img" items="${hotel.images}">
                                        <c:if test="${img.category == 'RESTAURANT'}">
                                            <div class="col-md-6">
                                                <div class="rounded-3 overflow-hidden shadow-sm" style="height: 240px;">
                                                    <img src="${img.imageUrl}" alt="${img.caption}" class="w-100 h-100" style="object-fit: cover;" />
                                                </div>
                                                <small class="text-muted d-block mt-1">${img.caption}</small>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Description & Highlights -->
                <div class="card shadow-sm border-0 rounded-4 p-4 mb-5">
                    <h3 class="font-serif text-navy mb-3">About This Property</h3>
                    <p class="text-muted leading-relaxed">${hotel.description}</p>
                    
                    <h4 class="font-serif text-navy mt-4 mb-3">Signature Facilities & Services</h4>
                    <div class="row g-3">
                        <c:forEach var="fac" items="${hotel.facilities}">
                            <div class="col-md-4 col-sm-6">
                                <div class="d-flex align-items-center gap-2 p-2 bg-light rounded-3">
                                    <i class="bi ${fac.facilityIcon} text-gold fs-5"></i>
                                    <span class="small fw-semibold text-dark">${fac.facilityName}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <h4 class="font-serif text-navy mt-4 mb-3">Policies & House Rules</h4>
                    <div class="row g-3 small">
                        <div class="col-md-6">
                            <div class="border rounded-3 p-3">
                                <strong><i class="bi bi-clock me-1 text-gold"></i>Check-In:</strong> ${hotel.checkinTime} onwards<br />
                                <strong><i class="bi bi-clock-history me-1 text-gold"></i>Check-Out:</strong> Until ${hotel.checkoutTime}
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="border rounded-3 p-3">
                                <strong><i class="bi bi-shield-check me-1 text-gold"></i>Cancellation Policy:</strong><br />
                                ${hotel.cancellationPolicy}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Available Rooms Section -->
                <div class="card shadow-sm border-0 rounded-4 p-4 mb-5" id="availableRooms">
                    <div class="d-flex align-items-center justify-content-between mb-4">
                        <div>
                            <h3 class="font-serif text-navy mb-0">Rooms & Suites</h3>
                            <p class="text-muted small mb-0">Select your dates to verify live room availability.</p>
                        </div>
                    </div>

                    <!-- Date & Guests Filter Form -->
                    <form action="${pageContext.request.contextPath}/hotel" method="GET" class="bg-light p-3 rounded-3 mb-4">
                        <input type="hidden" name="id" value="${hotel.id}" />
                        <div class="row g-2 align-items-end">
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Check-In</label>
                                <input type="date" name="checkIn" class="form-control form-control-sm" value="${checkIn}" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Check-Out</label>
                                <input type="date" name="checkOut" class="form-control form-control-sm" value="${checkOut}" />
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small fw-bold">Guests</label>
                                <select name="guests" class="form-select form-select-sm">
                                    <option value="1" ${guests == 1 ? 'selected' : ''}>1 Guest</option>
                                    <option value="2" ${guests == 2 || empty guests ? 'selected' : ''}>2 Guests</option>
                                    <option value="3" ${guests == 3 ? 'selected' : ''}>3 Guests</option>
                                    <option value="4" ${guests == 4 ? 'selected' : ''}>4 Guests</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-navy btn-sm w-100">Check Dates</button>
                            </div>
                        </div>
                    </form>

                    <!-- Room Cards -->
                    <div class="vstack gap-3">
                        <c:forEach var="room" items="${rooms}">
                            <div class="card border rounded-3 overflow-hidden">
                                <div class="row g-0 align-items-center">
                                    <div class="col-md-4">
                                        <img src="${room.primaryImageUrl}" alt="${room.name}" class="w-100 h-100" style="min-height: 180px; object-fit: cover;" />
                                    </div>
                                    <div class="col-md-5 p-3">
                                        <div class="d-flex align-items-center gap-2 mb-1">
                                            <span class="badge bg-navy" style="font-size: 0.7rem;">Room #${room.roomNumber}</span>
                                            <span class="badge bg-light text-dark border" style="font-size: 0.7rem;">${room.bedType}</span>
                                        </div>
                                        <h5 class="font-serif text-navy mb-1">${room.name}</h5>
                                        <p class="text-muted small mb-2" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                            ${room.description}
                                        </p>
                                        <small class="text-secondary">
                                            <i class="bi bi-people me-1"></i>Up to ${room.capacity} Guests
                                            <span class="mx-1">•</span>
                                            <i class="bi bi-aspect-ratio me-1"></i>${room.sizeSqft} sq ft
                                        </small>
                                    </div>
                                    <div class="col-md-3 p-3 text-md-end border-start bg-light h-100 d-flex flex-column justify-content-center">
                                        <small class="text-muted">Rate per night</small>
                                        <h4 class="font-serif text-navy fw-bold mb-2">Rs <fmt:formatNumber value="${room.pricePerNight}" maxFractionDigits="0" /></h4>
                                        <a href="${pageContext.request.contextPath}/customer/book?roomId=${room.id}&checkIn=${checkIn}&checkOut=${checkOut}&guests=${guests}" class="btn btn-gold btn-sm fw-bold">
                                            Book This Room
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Customer Reviews & Sentiment Section -->
                <div class="card shadow-sm border-0 rounded-4 p-4">
                    <div class="d-flex align-items-center justify-content-between mb-4">
                        <h3 class="font-serif text-navy mb-0">Guest Reviews & Ratings</h3>
                        <span class="badge bg-gold text-dark px-3 py-2 fw-bold">
                            <i class="bi bi-star-fill me-1"></i>${hotel.starRating} / 5.0
                        </span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty reviews}">
                            <div class="vstack gap-3">
                                <c:forEach var="rev" items="${reviews}">
                                    <div class="p-3 border rounded-3 bg-white">
                                        <div class="d-flex align-items-center justify-content-between mb-2">
                                            <div>
                                                <strong>${rev.customerName}</strong>
                                                <small class="text-muted d-block" style="font-size: 0.75rem;">Verified Guest • Stay in ${rev.roomName}</small>
                                            </div>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="badge ${rev.sentimentLabel == 'POSITIVE' ? 'bg-success' : 'bg-secondary'}">
                                                    ${rev.sentimentLabel}
                                                </span>
                                                <span class="text-gold fw-bold">
                                                    <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                                                </span>
                                            </div>
                                        </div>
                                        <p class="text-muted small mb-2 fst-italic">"${rev.comments}"</p>
                                        <c:if test="${not empty rev.adminReply}">
                                            <div class="alert alert-light border small py-2 px-3 mt-2 mb-0">
                                                <strong class="text-navy"><i class="bi bi-reply-fill text-gold me-1"></i>Management Response:</strong>
                                                <p class="mb-0 text-muted">${rev.adminReply}</p>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted">No reviews yet for this property. Be the first to review your stay!</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Right Column: Interactive Map, Coordinates, Quick Actions -->
            <div class="col-lg-4">
                <div class="card shadow-sm border-0 rounded-4 p-4 sticky-top" style="top: 90px;">
                    <h4 class="font-serif text-navy mb-3">
                        <i class="bi bi-compass text-gold me-2"></i>Location & Directions
                    </h4>
                    
                    <p class="small text-muted mb-2">
                        <strong>Address:</strong><br />
                        ${hotel.address}, ${hotel.city}, ${hotel.state} ${hotel.postalCode}
                    </p>

                    <div class="p-3 bg-light rounded-3 small mb-3 border">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted">GPS Latitude:</span>
                            <span class="font-monospace fw-bold">${hotel.latitude}</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">GPS Longitude:</span>
                            <span class="font-monospace fw-bold">${hotel.longitude}</span>
                        </div>
                    </div>

                    <!-- Interactive OpenStreetMap Tile -->
                    <div id="hotelDetailMap" class="rounded-3 overflow-hidden mb-3 border shadow-sm" style="height: 200px; width: 100%; z-index: 1;"></div>

                    <!-- Direct Google Maps link -->
                    <a href="https://www.google.com/maps/search/?api=1&query=${hotel.latitude},${hotel.longitude}" target="_blank" class="btn btn-outline-navy w-100 mb-3 py-2">
                        <i class="bi bi-geo-alt me-1 text-danger"></i>Open in Google Maps
                    </a>

                    <hr />

                    <h5 class="font-serif text-navy mb-3">Ecosystem Actions</h5>
                    <div class="vstack gap-2">
                        <a href="${pageContext.request.contextPath}/compare?ids=${hotel.id}" class="btn btn-outline-secondary w-100 btn-sm">
                            <i class="bi bi-arrow-left-right me-1"></i>Compare with Other Properties
                        </a>
                        <a href="${pageContext.request.contextPath}/hotels/nearby" class="btn btn-outline-secondary w-100 btn-sm">
                            <i class="bi bi-crosshair me-1"></i>Find Nearby Hotels
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const mapEl = document.getElementById('hotelDetailMap');
    if (mapEl && typeof L !== 'undefined') {
        const hotelLat = ${hotel.latitude};
        const hotelLng = ${hotel.longitude};
        const hotelMap = L.map('hotelDetailMap').setView([hotelLat, hotelLng], 14);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(hotelMap);
        const marker = L.marker([hotelLat, hotelLng]).addTo(hotelMap);
        marker.bindPopup('<strong style="color:#0a192f;">${hotel.name}</strong><br><span style="font-size:12px;color:#666;">${hotel.address}, ${hotel.city}</span>').openPopup();
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


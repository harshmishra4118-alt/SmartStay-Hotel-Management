<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Luxury Hotel Destinations across India" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100">
    <div class="container">
        <!-- Hero Header -->
        <div class="text-center mb-5">
            <span class="badge bg-gold text-dark px-3 py-2 rounded-pill text-uppercase tracking-wider fw-bold">
                <i class="bi bi-geo-alt-fill me-1"></i>Curated Luxury Network
            </span>
            <h1 class="font-serif display-5 fw-bold text-navy mt-3">Discover India's Finest Luxury Escapes</h1>
            <p class="text-muted lead max-w-700 mx-auto">
                From Arabian bayfront palaces and royal Rajasthani courtyards to snow-capped alpine chalets and sun-kissed coastal villas.
            </p>
        </div>

        <!-- Filter & Search Toolbar -->
        <div class="card shadow-sm border-0 mb-4 rounded-3">
            <div class="card-body p-4">
                <form action="${pageContext.request.contextPath}/hotels" method="GET" id="hotelFilterForm">
                    <input type="hidden" name="lat" id="userLatInput" value="${userLat}" />
                    <input type="hidden" name="lng" id="userLngInput" value="${userLng}" />

                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-navy">Destination City</label>
                            <select name="city" class="form-select">
                                <option value="">All Destinations (India)</option>
                                <c:forEach var="c" items="${cities}">
                                    <option value="${c}" ${selectedCity == c ? 'selected' : ''}>${c}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-navy">Search by Name / Keyword</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" name="q" class="form-control" placeholder="Palace, Beach, Spa..." value="<c:out value='${searchQuery}' />" />
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-navy">Sort By</label>
                            <select name="sortBy" class="form-select">
                                <option value="RECOMMENDED" ${sortBy == 'RECOMMENDED' ? 'selected' : ''}>Featured / Top</option>
                                <option value="RATING" ${sortBy == 'RATING' ? 'selected' : ''}>Highest Rating</option>
                                <option value="PRICE_ASC" ${sortBy == 'PRICE_ASC' ? 'selected' : ''}>Price: Low to High</option>
                                <option value="PRICE_DESC" ${sortBy == 'PRICE_DESC' ? 'selected' : ''}>Price: High to Low</option>
                                <option value="DISTANCE" ${sortBy == 'DISTANCE' ? 'selected' : ''}>Distance (Nearest)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-navy w-100 py-2">
                                <i class="bi bi-funnel me-1"></i>Filter
                            </button>
                        </div>
                        <div class="col-md-2">
                            <button type="button" class="btn btn-outline-gold w-100 py-2 text-dark fw-semibold" id="btnDetectLocation">
                                <i class="bi bi-crosshair me-1 text-gold"></i>Near Me
                            </button>
                        </div>
                    </div>

                    <c:if test="${not empty userLat}">
                        <div class="mt-3 pt-2 border-top d-flex align-items-center justify-content-between">
                            <small class="text-success fw-semibold">
                                <i class="bi bi-geo-fill me-1"></i>Location detected: GPS (${userLat}, ${userLng}). Distances calculated accurately.
                            </small>
                            <a href="${pageContext.request.contextPath}/hotels" class="small text-muted text-decoration-none">Reset GPS</a>
                        </div>
                    </c:if>
                </form>
            </div>
        </div>

        <!-- Hotels Grid -->
        <div class="row g-4">
            <c:choose>
                <c:when test="${not empty hotels}">
                    <c:forEach var="hotel" items="${hotels}">
                        <div class="col-lg-4 col-md-6">
                            <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden hotel-card">
                                <div class="position-relative">
                                    <img src="${hotel.primaryImageUrl}" alt="${hotel.name}" class="card-img-top" style="height: 240px; object-fit: cover;" />
                                    <div class="position-absolute top-0 start-0 m-3">
                                        <span class="badge bg-navy text-white px-2 py-1 shadow-sm">
                                            <i class="bi bi-star-fill text-gold me-1"></i>${hotel.starRating}
                                        </span>
                                        <span class="badge bg-gold text-dark px-2 py-1 shadow-sm ms-1 fw-bold">
                                            ${hotel.city}
                                        </span>
                                    </div>
                                    <div class="position-absolute top-0 end-0 m-3">
                                        <button class="btn btn-light btn-sm rounded-circle shadow-sm btn-wishlist-toggle" data-hotel-id="${hotel.id}" title="Save to Wishlist">
                                            <i class="bi ${hotel.favorite ? 'bi-heart-fill text-danger' : 'bi-heart text-muted'}"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="card-body p-4 d-flex flex-column">
                                    <h4 class="card-title font-serif text-navy mb-1">${hotel.name}</h4>
                                    <p class="text-muted small mb-2 fst-italic">${hotel.tagline}</p>
                                    
                                    <p class="text-secondary small mb-3">
                                        <i class="bi bi-geo-alt-fill text-gold me-1"></i>${hotel.address}, ${hotel.city}
                                    </p>

                                    <c:if test="${not empty hotel.distanceKm}">
                                        <div class="alert alert-info py-1 px-2 small mb-3 d-flex align-items-center justify-content-between">
                                            <span><i class="bi bi-compass me-1"></i><fmt:formatNumber value="${hotel.distanceKm}" maxFractionDigits="1" /> km away</span>
                                            <span class="badge bg-white text-dark">${hotel.drivingTimeEstimate}</span>
                                        </div>
                                    </c:if>

                                    <p class="card-text text-muted small flex-grow-1" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">
                                        ${hotel.description}
                                    </p>

                                    <div class="pt-3 border-top mt-auto d-flex align-items-center justify-content-between">
                                        <div>
                                            <small class="text-muted d-block" style="font-size: 0.75rem;">Prices From</small>
                                            <strong class="text-navy fs-5">Rs <fmt:formatNumber value="${hotel.minPrice}" maxFractionDigits="0" /></strong>
                                            <small class="text-muted">/ night</small>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <a href="${pageContext.request.contextPath}/compare?ids=${hotel.id}" class="btn btn-sm btn-outline-secondary" title="Compare this hotel">
                                                <i class="bi bi-arrow-left-right"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/hotel?id=${hotel.id}" class="btn btn-sm btn-gold px-3 fw-semibold">
                                                Explore & Book
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="col-12 text-center py-5">
                        <i class="bi bi-buildings text-muted display-1"></i>
                        <h3 class="text-navy font-serif mt-3">No matching hotels found</h3>
                        <p class="text-muted">Try relaxing your search terms or clearing city filters.</p>
                        <a href="${pageContext.request.contextPath}/hotels" class="btn btn-navy px-4">View All Hotels</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const btnNearMe = document.getElementById('btnDetectLocation');
    if (btnNearMe) {
        btnNearMe.addEventListener('click', function() {
            if (navigator.geolocation) {
                btnNearMe.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Locating...';
                navigator.geolocation.getCurrentPosition(function(pos) {
                    document.getElementById('userLatInput').value = pos.coords.latitude;
                    document.getElementById('userLngInput').value = pos.coords.longitude;
                    document.getElementById('hotelFilterForm').submit();
                }, function(err) {
                    alert('Could not determine your GPS location. Please ensure location services are enabled.');
                    btnNearMe.innerHTML = '<i class="bi bi-crosshair me-1 text-gold"></i>Near Me';
                });
            } else {
                alert('Geolocation is not supported by your browser.');
            }
        });
    }

    // Wishlist Toggle
    document.querySelectorAll('.btn-wishlist-toggle').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const hotelId = this.getAttribute('data-hotel-id');
            const icon = this.querySelector('i');
            fetch('${pageContext.request.contextPath}/api/wishlist/toggle', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'hotelId=' + hotelId
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    if (data.isFavorite) {
                        icon.className = 'bi bi-heart-fill text-danger';
                    } else {
                        icon.className = 'bi bi-heart text-muted';
                    }
                } else if (data.message && data.message.includes('log in')) {
                    window.location.href = '${pageContext.request.contextPath}/login?redirect=' + encodeURIComponent(window.location.pathname + window.location.search);
                }
            })
            .catch(err => console.error(err));
        });
    });
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


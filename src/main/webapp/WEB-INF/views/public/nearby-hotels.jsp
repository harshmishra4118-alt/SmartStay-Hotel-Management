<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Nearby Hotels & Proximity Finder - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<!-- Leaflet CSS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />

<main class="py-5 bg-light min-vh-100">
    <div class="container">
        <!-- Header -->
        <div class="text-center mb-5">
            <span class="badge bg-gold text-dark px-3 py-2 rounded-pill text-uppercase tracking-wider fw-bold">
                <i class="bi bi-compass-fill me-1"></i>Geolocation Proximity Engine
            </span>
            <h1 class="font-serif display-5 fw-bold text-navy mt-3">Find Luxury Hotels Near You</h1>
            <p class="text-muted lead max-w-700 mx-auto">
                Discover five-star SmartStay destinations based on your exact real-time GPS location or search by city and PIN code.
            </p>
        </div>

        <!-- Detection & Location Search Card -->
        <div class="card shadow-sm border-0 rounded-4 p-4 mb-4 max-w-900 mx-auto bg-white">
            <div class="row g-4 align-items-center">
                <!-- GPS Detection -->
                <div class="col-lg-6 text-center border-end-lg pe-lg-4">
                    <button id="btnAutoDetect" class="btn btn-navy btn-lg w-100 py-3 shadow rounded-pill">
                        <i class="bi bi-crosshair me-2 text-gold"></i>Detect My GPS Location
                    </button>
                    <p id="geoStatus" class="small text-muted mt-2 mb-0">One-click browser GPS permission</p>
                </div>

                <!-- Manual City / PIN Code Fallback -->
                <div class="col-lg-6 ps-lg-4">
                    <label class="form-label small fw-bold text-muted mb-2">Or Search by City / PIN Code:</label>
                    <form id="manualLocForm" class="d-flex gap-2 mb-2">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="bi bi-geo-alt text-gold"></i></span>
                            <input type="text" id="manualLocationInput" class="form-control border-start-0" placeholder="e.g. Jaipur, Mumbai, 560066, 175131" />
                        </div>
                        <button type="submit" class="btn btn-gold text-navy fw-bold px-3">Search</button>
                    </form>
                    <div class="d-flex flex-wrap gap-1 align-items-center">
                        <small class="text-muted me-1">Popular:</small>
                        <a href="javascript:void(0)" onclick="searchCity('Mumbai')" class="badge bg-light text-navy border text-decoration-none">Mumbai</a>
                        <a href="javascript:void(0)" onclick="searchCity('Jaipur')" class="badge bg-light text-navy border text-decoration-none">Jaipur</a>
                        <a href="javascript:void(0)" onclick="searchCity('Bengaluru')" class="badge bg-light text-navy border text-decoration-none">Bengaluru</a>
                        <a href="javascript:void(0)" onclick="searchCity('Manali')" class="badge bg-light text-navy border text-decoration-none">Manali</a>
                        <a href="javascript:void(0)" onclick="searchCity('Goa')" class="badge bg-light text-navy border text-decoration-none">Goa</a>
                        <a href="javascript:void(0)" onclick="searchCity('Delhi')" class="badge bg-light text-navy border text-decoration-none">Delhi</a>
                    </div>
                </div>
            </div>

            <c:if test="${not empty userLat}">
                <div class="border-top pt-3 mt-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
                    <span class="small fw-semibold text-success">
                        <i class="bi bi-check-circle-fill me-1"></i>Active Coordinates: ${userLat}, ${userLng}
                    </span>

                    <form action="${pageContext.request.contextPath}/hotels/nearby" method="GET" class="d-flex align-items-center gap-2">
                        <input type="hidden" name="lat" value="${userLat}" />
                        <input type="hidden" name="lng" value="${userLng}" />
                        <label class="form-label small mb-0 fw-semibold text-muted">Radius:</label>
                        <select name="radius" class="form-select form-select-sm shadow-sm" onchange="this.form.submit()">
                            <option value="50" ${radiusKm == 50 ? 'selected' : ''}>Within 50 km</option>
                            <option value="150" ${radiusKm == 150 ? 'selected' : ''}>Within 150 km</option>
                            <option value="500" ${radiusKm == 500 ? 'selected' : ''}>Within 500 km</option>
                            <option value="0" ${radiusKm == 0 ? 'selected' : ''}>Nationwide (Closest First)</option>
                        </select>
                    </form>
                </div>
            </c:if>
        </div>

        <!-- Interactive OpenStreetMap Container -->
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden mb-5 bg-white">
            <div class="card-header bg-navy text-white d-flex justify-content-between align-items-center py-3 px-4">
                <span class="fw-bold font-serif">
                    <i class="bi bi-map text-gold me-2"></i>Interactive Proximity Map (OpenStreetMap)
                </span>
                <small class="text-white-50">Powered by Leaflet</small>
            </div>
            <div id="nearbyMap" style="height: 420px; width: 100%; z-index: 1;"></div>
        </div>

        <!-- Nearby Results Grid -->
        <c:if test="${not empty hotels}">
            <h3 class="font-serif text-navy mb-4">
                <i class="bi bi-building-check text-gold me-2"></i>Closest Properties (${hotels.size()})
            </h3>
            <div class="row g-4">
                <c:forEach var="h" items="${hotels}">
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden h-100 bg-white">
                            <div class="row g-0 h-100">
                                <div class="col-md-5 position-relative">
                                    <img src="${h.primaryImageUrl}" alt="${h.name}" class="w-100 h-100 object-fit-cover" style="min-height: 220px;" 
                                         onerror="this.src='https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80'" />
                                    <div class="position-absolute top-0 start-0 m-2">
                                        <span class="badge bg-gold text-dark fw-bold shadow-sm">
                                            <i class="bi bi-compass me-1"></i><fmt:formatNumber value="${h.distanceKm}" maxFractionDigits="1" /> km away
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-7 p-4 d-flex flex-column justify-content-between">
                                    <div>
                                        <div class="d-flex align-items-center justify-content-between mb-2">
                                            <span class="badge bg-navy text-white">
                                                <i class="bi bi-star-fill text-gold me-1"></i>${h.starRating} &#9733;
                                            </span>
                                            <small class="text-muted">${h.city}</small>
                                        </div>

                                        <h5 class="font-serif text-navy mb-1 fw-bold">${h.name}</h5>
                                        <p class="text-secondary small mb-2">
                                            <i class="bi bi-geo-alt me-1 text-danger"></i>${h.address}, ${h.city}
                                        </p>
                                        <p class="text-muted small mb-2">
                                            <i class="bi bi-car-front text-gold me-1"></i>${h.drivingTimeEstimate}
                                            <span class="mx-1">•</span>
                                            <i class="bi bi-person-walking text-gold me-1"></i>${h.walkingTimeEstimate}
                                        </p>
                                    </div>

                                    <div class="pt-3 border-top d-flex align-items-center justify-content-between mt-2">
                                        <div>
                                            <small class="text-muted d-block" style="font-size: 0.7rem;">From</small>
                                            <strong class="text-navy fs-6">Rs <fmt:formatNumber value="${h.minPrice}" maxFractionDigits="0" /></strong>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <a href="https://www.google.com/maps/dir/?api=1&origin=${userLat},${userLng}&destination=${h.latitude},${h.longitude}" target="_blank" class="btn btn-outline-secondary btn-sm" title="Turn-by-turn Directions">
                                                <i class="bi bi-arrow-up-right"></i> Directions
                                            </a>
                                            <a href="${pageContext.request.contextPath}/hotel?id=${h.id}&lat=${userLat}&lng=${userLng}" class="btn btn-gold btn-sm fw-semibold">
                                                View & Book
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>
    </div>
</main>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

<script>
// City coordinates mapping for instant manual destination search
const KNOWN_DESTINATIONS = {
    'mumbai': { lat: 18.9220, lng: 72.8347 },
    '400020': { lat: 18.9220, lng: 72.8347 },
    'jaipur': { lat: 26.9124, lng: 75.7873 },
    '302002': { lat: 26.9124, lng: 75.7873 },
    'bengaluru': { lat: 12.9716, lng: 77.5946 },
    'bangalore': { lat: 12.9716, lng: 77.5946 },
    '560066': { lat: 12.9716, lng: 77.5946 },
    'manali': { lat: 32.2432, lng: 77.1892 },
    '175131': { lat: 32.2432, lng: 77.1892 },
    'goa': { lat: 15.5494, lng: 73.7535 },
    '403516': { lat: 15.5494, lng: 73.7535 },
    'delhi': { lat: 28.6139, lng: 77.2090 },
    'new delhi': { lat: 28.6139, lng: 77.2090 },
    '110001': { lat: 28.6139, lng: 77.2090 }
};

function searchCity(name) {
    const key = name.toLowerCase().trim();
    if (KNOWN_DESTINATIONS[key]) {
        const dest = KNOWN_DESTINATIONS[key];
        window.location.href = '${pageContext.request.contextPath}/hotels/nearby?lat=' + dest.lat + '&lng=' + dest.lng;
    }
}

document.addEventListener('DOMContentLoaded', function() {
    // 1. Manual Form Search
    const manualForm = document.getElementById('manualLocForm');
    const manualInput = document.getElementById('manualLocationInput');
    if (manualForm && manualInput) {
        manualForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const val = manualInput.value.toLowerCase().trim();
            if (KNOWN_DESTINATIONS[val]) {
                const dest = KNOWN_DESTINATIONS[val];
                window.location.href = '${pageContext.request.contextPath}/hotels/nearby?lat=' + dest.lat + '&lng=' + dest.lng;
            } else {
                alert('Destination "' + manualInput.value + '" not recognized. Try Mumbai, Jaipur, Bengaluru, Manali, Goa, or Delhi.');
            }
        });
    }

    // 2. GPS Browser Location Detection
    const btn = document.getElementById('btnAutoDetect');
    const statusText = document.getElementById('geoStatus');

    if (btn) {
        btn.addEventListener('click', function() {
            if (navigator.geolocation) {
                btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Acquiring GPS Signal...';
                statusText.innerText = 'Requesting device coordinates...';
                
                navigator.geolocation.getCurrentPosition(function(pos) {
                    const lat = pos.coords.latitude;
                    const lng = pos.coords.longitude;
                    statusText.innerText = 'GPS locked! Loading nearest hotels...';
                    window.location.href = '${pageContext.request.contextPath}/hotels/nearby?lat=' + lat + '&lng=' + lng;
                }, function(err) {
                    btn.innerHTML = '<i class="bi bi-crosshair me-2 text-gold"></i>Detect My GPS Location';
                    statusText.innerText = 'Geolocation access denied or timed out. Use the City / PIN code search above.';
                    alert('Could not access your location. You can search directly by City or PIN code.');
                }, { timeout: 10000, enableHighAccuracy: true });
            } else {
                alert('Geolocation is not supported by your browser.');
            }
        });
    }

    // 3. Initialize Leaflet Map
    const defaultLat = ${not empty userLat ? userLat : 20.5937};
    const defaultLng = ${not empty userLng ? userLng : 78.9629};
    const defaultZoom = ${not empty userLat ? 8 : 5};

    const map = L.map('nearbyMap').setView([defaultLat, defaultLng], defaultZoom);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const bounds = [];

    // User Location Pin (if available)
    <c:if test="${not empty userLat}">
        const userMarker = L.circleMarker([${userLat}, ${userLng}], {
            radius: 10,
            fillColor: '#0a192f',
            color: '#c5a059',
            weight: 3,
            opacity: 1,
            fillOpacity: 0.9
        }).addTo(map);
        userMarker.bindPopup('<strong style="color:#0a192f;">Your Current Location</strong>').openPopup();
        bounds.push([${userLat}, ${userLng}]);
    </c:if>

    // Hotel Pins
    <c:forEach var="h" items="${hotels}">
        const marker_${h.id} = L.marker([${h.latitude}, ${h.longitude}]).addTo(map);
        bounds.push([${h.latitude}, ${h.longitude}]);
        
        const popupContent_${h.id} = `
            <div style="min-width: 200px;">
                <h6 style="margin: 0 0 4px 0; color: #0a192f; font-weight: bold;">${h.name}</h6>
                <p style="margin: 0 0 6px 0; font-size: 12px; color: #666;">
                    ${h.city} &bull; <strong style="color: #c5a059;">Rs <fmt:formatNumber value="${h.minPrice}" maxFractionDigits="0" /></strong>/night
                </p>
                <c:if test="${not empty h.distanceKm}">
                    <p style="margin: 0 0 8px 0; font-size: 11px; color: #28a745; font-weight: 600;">
                        <i class="bi bi-compass"></i> <fmt:formatNumber value="${h.distanceKm}" maxFractionDigits="1" /> km away
                    </p>
                </c:if>
                <a href="${pageContext.request.contextPath}/hotel?id=${h.id}" style="display: inline-block; padding: 4px 10px; background: #0a192f; color: #c5a059; border-radius: 4px; font-size: 12px; text-decoration: none; font-weight: 600;">View Hotel</a>
            </div>
        `;
        marker_${h.id}.bindPopup(popupContent_${h.id});
    </c:forEach>

    if (bounds.length > 1) {
        map.fitBounds(bounds, { padding: [40, 40] });
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="SmartStay Hotel | Official Site"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<!-- Hero Section -->
<section class="hero-luxury">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="badge bg-gold text-dark mb-3 px-3 py-2 fw-semibold text-uppercase tracking-wider">
                    <i class="bi bi-star-fill me-1"></i> The Five-Star Standard
                </span>
                <h1 class="display-3 font-serif fw-bold text-white mb-3">
                    Where Timeless Elegance Meets <span class="text-gold">Smart Luxury</span>
                </h1>
                <p class="hero-subtitle">
                    Immerse yourself in bespoke accommodations, panoramic horizons, and intuitive 
                    hospitality designed for discerning travelers.
                </p>
                <div class="d-flex flex-wrap gap-3">
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-gold btn-lg">
                        <i class="bi bi-door-open me-2"></i>Explore Suites
                    </a>
                    <a href="${pageContext.request.contextPath}/rooms/recommend" class="btn btn-outline-light btn-lg">
                        <i class="bi bi-stars text-gold me-2"></i>Smart Room Matcher
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Floating Booking Search Bar -->
<div class="container">
    <div class="booking-search-card">
        <form action="${pageContext.request.contextPath}/hotels" method="GET" class="row g-3 align-items-end">
            <div class="col-md-3 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">
                    <i class="bi bi-geo-alt-fill text-gold me-1"></i>Destination City
                </label>
                <select name="city" class="form-select">
                    <option value="">All Luxury Destinations</option>
                    <c:forEach var="c" items="${cities}">
                        <option value="${c}">${c}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-3 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">
                    <i class="bi bi-calendar-check text-gold me-1"></i>Check-In
                </label>
                <input type="date" name="checkIn" class="form-control">
            </div>
            <div class="col-md-2 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">
                    <i class="bi bi-calendar-x text-gold me-1"></i>Check-Out
                </label>
                <input type="date" name="checkOut" class="form-control">
            </div>
            <div class="col-md-2 col-sm-6">
                <label class="form-label small fw-bold text-uppercase text-secondary mb-1">
                    <i class="bi bi-person-fill text-gold me-1"></i>Guests
                </label>
                <select name="guests" class="form-select">
                    <option value="1">1 Guest</option>
                    <option value="2" selected>2 Guests</option>
                    <option value="3">3 Guests</option>
                    <option value="4">4 Guests</option>
                </select>
            </div>
            <div class="col-md-2 col-sm-12">
                <button type="submit" class="btn btn-gold w-100 py-2">
                    <i class="bi bi-search me-1"></i>Find Hotels
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Featured Luxury Hotels Across India -->
<section class="py-5 my-4">
    <div class="container">
        <div class="d-flex flex-wrap justify-content-between align-items-end mb-4">
            <div>
                <span class="text-gold text-uppercase fw-bold small tracking-wider">Multi-Hotel Ecosystem</span>
                <h2 class="font-serif text-navy display-6 mt-1 mb-0">Our Curated Luxury Escapes</h2>
            </div>
            <div class="mt-2 mt-sm-0">
                <a href="${pageContext.request.contextPath}/hotels" class="btn btn-outline-navy btn-sm me-2">
                    View All ${featuredHotels.size()} Properties
                </a>
                <a href="${pageContext.request.contextPath}/hotels/nearby" class="btn btn-navy btn-sm">
                    <i class="bi bi-crosshair text-gold me-1"></i>Hotels Near Me
                </a>
            </div>
        </div>

        <div class="row g-4">
            <c:forEach var="h" items="${featuredHotels}" begin="0" end="2">
                <div class="col-lg-4 col-md-6">
                    <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden hotel-card">
                        <div class="position-relative">
                            <img src="${h.primaryImageUrl}" alt="${h.name}" class="card-img-top" style="height: 230px; object-fit: cover;" />
                            <div class="position-absolute top-0 start-0 m-3">
                                <span class="badge bg-gold text-dark fw-bold">
                                    <i class="bi bi-star-fill me-1"></i>${h.starRating}
                                </span>
                                <span class="badge bg-navy text-white ms-1">${h.city}</span>
                            </div>
                        </div>
                        <div class="card-body p-4 d-flex flex-column">
                            <h5 class="font-serif text-navy mb-1">${h.name}</h5>
                            <p class="text-muted small mb-2 fst-italic">${h.tagline}</p>
                            <p class="text-secondary small mb-3">
                                <i class="bi bi-geo-alt-fill text-gold me-1"></i>${h.address}
                            </p>
                            <div class="pt-3 border-top mt-auto d-flex align-items-center justify-content-between">
                                <div>
                                    <small class="text-muted d-block" style="font-size: 0.7rem;">From</small>
                                    <strong class="text-navy fs-5">Rs <fmt:formatNumber value="${h.minPrice}" maxFractionDigits="0" /></strong>
                                    <small class="text-muted">/ night</small>
                                </div>
                                <a href="${pageContext.request.contextPath}/hotel?id=${h.id}" class="btn btn-gold btn-sm px-3 fw-semibold">
                                    Explore & Book
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Curated Experiences & Features -->
<section class="py-5 my-5">
    <div class="container">
        <div class="text-center mx-auto mb-5" style="max-width: 650px;">
            <span class="text-gold text-uppercase fw-bold small tracking-wider">Unmatched Excellence</span>
            <h2 class="font-serif text-navy display-6 mt-1">Curated Hotel Amenities</h2>
            <p class="text-muted">Every aspect of your stay is thoughtfully crafted to indulge the senses and elevate comfort.</p>
        </div>

        <div class="row g-4">
            <div class="col-lg-3 col-md-6">
                <div class="p-4 bg-white rounded-3 shadow-sm border text-center h-100">
                    <div class="kpi-icon bg-gold text-dark mx-auto mb-3">
                        <i class="bi bi-water"></i>
                    </div>
                    <h5 class="font-serif text-navy">Heated Infinity Pool</h5>
                    <p class="small text-muted mb-0">Rooftop panoramic infinity pool with temperature control and private poolside cabanas.</p>
                </div>
            </div>
            <div class="col-lg-3 col-md-6">
                <div class="p-4 bg-white rounded-3 shadow-sm border text-center h-100">
                    <div class="kpi-icon bg-navy text-gold mx-auto mb-3">
                        <i class="bi bi-cup-hot-fill"></i>
                    </div>
                    <h5 class="font-serif text-navy">Artisanal Dining</h5>
                    <p class="small text-muted mb-0">Michelin-guided master chefs presenting farm-to-table breakfast buffets and signature dinners.</p>
                </div>
            </div>
            <div class="col-lg-3 col-md-6">
                <div class="p-4 bg-white rounded-3 shadow-sm border text-center h-100">
                    <div class="kpi-icon bg-gold text-dark mx-auto mb-3">
                        <i class="bi bi-robot"></i>
                    </div>
                    <h5 class="font-serif text-navy">Smart Concierge</h5>
                    <p class="small text-muted mb-0">24/7 intelligent instant assistant for inquiries, room recommendations, and custom amenities.</p>
                </div>
            </div>
            <div class="col-lg-3 col-md-6">
                <div class="p-4 bg-white rounded-3 shadow-sm border text-center h-100">
                    <div class="kpi-icon bg-navy text-gold mx-auto mb-3">
                        <i class="bi bi-car-front-fill"></i>
                    </div>
                    <h5 class="font-serif text-navy">Valet & Transfers</h5>
                    <p class="small text-muted mb-0">Complimentary covered valet parking with EV charging and luxury Mercedes airport transfers.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Featured Rooms Section -->
<section class="py-5 bg-ivory border-top border-bottom">
    <div class="container">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-end mb-4">
            <div>
                <span class="text-gold text-uppercase fw-bold small tracking-wider">Handcrafted Sanctuaries</span>
                <h2 class="font-serif text-navy display-6 mt-1">Featured Rooms & Suites</h2>
            </div>
            <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline-navy mt-3 mt-md-0">
                View All Suites <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>

        <div class="row g-4">
            <c:forEach var="room" items="${featuredRooms}">
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
                            <h4 class="room-card-title">${room.name}</h4>
                            <p class="text-muted small mb-3 text-truncate-2">
                                ${room.description}
                            </p>
                            <div class="d-flex align-items-center gap-3 text-muted small mb-3">
                                <span><i class="bi bi-people-fill text-gold me-1"></i>Up to ${room.capacity} Guests</span>
                                <span><i class="bi bi-aspect-ratio text-gold me-1"></i>${room.sizeSqft} sq ft</span>
                                <span><i class="bi bi-layer-forward text-gold me-1"></i>Floor ${room.floorNumber}</span>
                            </div>
                            <div class="mb-4">
                                <c:forEach var="amenity" items="${room.amenitiesList}" end="2">
                                    <span class="room-amenity-pill"><i class="bi bi-check2 text-gold"></i>${amenity}</span>
                                </c:forEach>
                            </div>
                            <div class="mt-auto d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/room-details?id=${room.id}" class="btn btn-outline-navy flex-grow-1">
                                    Details
                                </a>
                                <a href="${pageContext.request.contextPath}/customer/book?roomId=${room.id}" class="btn btn-gold flex-grow-1">
                                    Reserve
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Verified Guest Reviews -->
<c:if test="${not empty feedbacks}">
<section class="py-5 my-4">
    <div class="container">
        <div class="text-center mx-auto mb-5" style="max-width: 650px;">
            <span class="text-gold text-uppercase fw-bold small tracking-wider">Guest Testimonials</span>
            <h2 class="font-serif text-navy display-6 mt-1">Refined Hospitality, Confirmed</h2>
            <p class="text-muted">Real impressions from verified guests who have stayed at SmartStay Hotel.</p>
        </div>

        <div class="row g-4">
            <c:forEach var="fb" items="${feedbacks}">
                <div class="col-lg-4 col-md-6">
                    <div class="p-4 bg-white rounded-3 shadow-sm border h-100 d-flex flex-column">
                        <div class="d-flex align-items-center gap-1 text-gold mb-3">
                            <c:forEach begin="1" end="${fb.rating}"><i class="bi bi-star-fill"></i></c:forEach>
                            <c:forEach begin="${fb.rating + 1}" end="5"><i class="bi bi-star"></i></c:forEach>
                            <span class="badge bg-light text-success ms-2 border small">Verified Stay</span>
                        </div>
                        <p class="font-serif fst-italic text-secondary mb-3 flex-grow-1">
                            "${fb.comments}"
                        </p>
                        <div class="border-top pt-3 mt-auto">
                            <h6 class="mb-0 text-navy fw-bold">${fb.customerName}</h6>
                            <small class="text-muted">${fb.roomName} &bull; ${fb.bookingReference}</small>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

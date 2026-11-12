<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="My Luxury Wishlist - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100">
    <div class="container">
        <!-- Header -->
        <div class="d-flex align-items-center justify-content-between mb-4">
            <div>
                <h2 class="font-serif text-navy fw-bold mb-1">
                    <i class="bi bi-heart-fill text-danger me-2"></i>My Saved Luxury Hotels
                </h2>
                <p class="text-muted mb-0">Your personally curated collection of five-star destinations across India.</p>
            </div>
            <a href="${pageContext.request.contextPath}/hotels" class="btn btn-outline-navy btn-sm">
                <i class="bi bi-compass me-1"></i>Explore More Hotels
            </a>
        </div>

        <c:choose>
            <c:when test="${not empty favoriteHotels}">
                <div class="row g-4" id="wishlistGrid">
                    <c:forEach var="hotel" items="${favoriteHotels}">
                        <div class="col-lg-4 col-md-6 hotel-item-${hotel.id}">
                            <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden">
                                <div class="position-relative">
                                    <img src="${hotel.primaryImageUrl}" alt="${hotel.name}" class="card-img-top" style="height: 220px; object-fit: cover;" />
                                    <div class="position-absolute top-0 start-0 m-3">
                                        <span class="badge bg-gold text-dark fw-bold">
                                            <i class="bi bi-star-fill me-1"></i>${hotel.starRating}
                                        </span>
                                        <span class="badge bg-navy text-white ms-1">${hotel.city}</span>
                                    </div>
                                    <div class="position-absolute top-0 end-0 m-3">
                                        <button class="btn btn-light btn-sm rounded-circle shadow-sm btn-remove-fav" data-id="${hotel.id}" title="Remove from Wishlist">
                                            <i class="bi bi-trash text-danger"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="card-body p-4 d-flex flex-column">
                                    <h5 class="card-title font-serif text-navy mb-1">${hotel.name}</h5>
                                    <p class="text-muted small mb-2 fst-italic">${hotel.tagline}</p>
                                    <p class="text-secondary small mb-3">
                                        <i class="bi bi-geo-alt-fill text-gold me-1"></i>${hotel.address}, ${hotel.city}
                                    </p>

                                    <div class="pt-3 border-top mt-auto d-flex align-items-center justify-content-between">
                                        <div>
                                            <small class="text-muted d-block">From</small>
                                            <strong class="text-navy fs-5">Rs <fmt:formatNumber value="${hotel.minPrice}" maxFractionDigits="0" /></strong>
                                            <small class="text-muted">/ night</small>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/hotel?id=${hotel.id}" class="btn btn-gold btn-sm px-3 fw-semibold">
                                            View & Book
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card border-0 shadow-sm rounded-4 text-center py-5">
                    <i class="bi bi-heart text-muted display-1"></i>
                    <h3 class="font-serif text-navy mt-3">Your wishlist is currently empty</h3>
                    <p class="text-muted">Browse our collection of luxury destinations and click the heart icon on any property to save it here.</p>
                    <div>
                        <a href="${pageContext.request.contextPath}/hotels" class="btn btn-navy px-4">Browse Luxury Hotels</a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.btn-remove-fav').forEach(btn => {
        btn.addEventListener('click', function() {
            const hotelId = this.getAttribute('data-id');
            const item = document.querySelector('.hotel-item-' + hotelId);
            
            fetch('${pageContext.request.contextPath}/api/wishlist/toggle', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'hotelId=' + hotelId
            })
            .then(res => res.json())
            .then(data => {
                if (data.success && item) {
                    item.remove();
                }
            });
        });
    });
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


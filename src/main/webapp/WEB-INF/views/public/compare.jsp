<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Compare Luxury Hotels - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100">
    <div class="container">
        <!-- Header -->
        <div class="text-center mb-5">
            <span class="badge bg-gold text-dark px-3 py-2 rounded-pill text-uppercase tracking-wider fw-bold">
                <i class="bi bi-arrow-left-right me-1"></i>Side-by-Side Evaluation
            </span>
            <h1 class="font-serif display-5 fw-bold text-navy mt-3">Compare SmartStay Luxury Properties</h1>
            <p class="text-muted lead max-w-700 mx-auto">
                Compare amenities, ratings, price tiers, and location logistics to choose the perfect luxury retreat.
            </p>
        </div>

        <!-- Add Hotel Selector -->
        <div class="card shadow-sm border-0 rounded-4 p-3 mb-4 max-w-800 mx-auto">
            <div class="row g-2 align-items-center">
                <div class="col-md-3">
                    <span class="small fw-bold text-navy"><i class="bi bi-plus-circle text-gold me-1"></i>Add Property:</span>
                </div>
                <div class="col-md-6">
                    <select id="selectHotelToAdd" class="form-select form-select-sm">
                        <option value="">Choose another hotel to compare...</option>
                        <c:forEach var="h" items="${allHotels}">
                            <option value="${h.id}">${h.name} (${h.city})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="button" class="btn btn-navy btn-sm w-100" id="btnAddHotel">
                        Add to Matrix
                    </button>
                </div>
            </div>
        </div>

        <!-- Comparison Table -->
        <c:choose>
            <c:when test="${not empty compareHotels}">
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                    <div class="table-responsive">
                        <table class="table table-bordered mb-0 align-middle">
                            <!-- Header Row with Photos -->
                            <thead class="bg-navy text-white text-center">
                                <tr>
                                    <th style="width: 20%;" class="p-3 text-start">Property Feature</th>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <th style="width: ${80 / compareHotels.size()}%;" class="p-3">
                                            <div class="position-relative mb-2">
                                                <img src="${hotel.primaryImageUrl}" alt="${hotel.name}" class="rounded-3 w-100" style="height: 160px; object-fit: cover;" />
                                                <button class="btn btn-danger btn-sm position-absolute top-0 end-0 m-1 rounded-circle p-1 btn-remove-compare" data-id="${hotel.id}" title="Remove from comparison">
                                                    <i class="bi bi-x"></i>
                                                </button>
                                            </div>
                                            <h5 class="font-serif text-white mb-1">${hotel.name}</h5>
                                            <span class="badge bg-gold text-dark">${hotel.city}</span>
                                        </th>
                                    </c:forEach>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Star Rating -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-star-fill text-gold me-2"></i>Star Rating</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="text-center">
                                            <span class="fs-5 text-gold fw-bold">★ ${hotel.starRating}</span>
                                            <small class="text-muted d-block">Five-Star Luxury</small>
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Starting Rate -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-tag text-gold me-2"></i>Starting Price</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="text-center">
                                            <strong class="text-navy fs-5">Rs <fmt:formatNumber value="${hotel.minPrice}" maxFractionDigits="0" /></strong>
                                            <small class="text-muted d-block">per night</small>
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Price Range -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-cash-stack text-gold me-2"></i>Price Range</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="text-center small">
                                            Rs <fmt:formatNumber value="${hotel.minPrice}" maxFractionDigits="0" /> - 
                                            Rs <fmt:formatNumber value="${hotel.maxPrice}" maxFractionDigits="0" />
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Location & Address -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-geo-alt text-gold me-2"></i>Address & Destination</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="text-center small">
                                            ${hotel.address},<br />
                                            <strong>${hotel.city}, ${hotel.state}</strong>
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Distance from User -->
                                <c:if test="${not empty userLat}">
                                    <tr>
                                        <td class="fw-bold text-navy bg-light"><i class="bi bi-compass text-gold me-2"></i>Distance from You</td>
                                        <c:forEach var="hotel" items="${compareHotels}">
                                            <td class="text-center">
                                                <span class="badge bg-gold text-dark px-2 py-1">
                                                    <fmt:formatNumber value="${hotel.distanceKm}" maxFractionDigits="1" /> km away
                                                </span>
                                                <small class="d-block text-muted mt-1">${hotel.drivingTimeEstimate}</small>
                                            </td>
                                        </c:forEach>
                                    </tr>
                                </c:if>

                                <!-- Check-In / Check-Out -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-clock text-gold me-2"></i>Timings</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="text-center small">
                                            Check-In: <strong>${hotel.checkinTime}</strong><br />
                                            Check-Out: <strong>${hotel.checkoutTime}</strong>
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Signature Facilities -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-award text-gold me-2"></i>Key Amenities</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="p-3">
                                            <ul class="list-unstyled mb-0 small vstack gap-1">
                                                <c:forEach var="fac" items="${hotel.facilities}">
                                                    <li><i class="bi ${fac.facilityIcon} text-gold me-1"></i>${fac.facilityName}</li>
                                                </c:forEach>
                                            </ul>
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Cancellation Policy -->
                                <tr>
                                    <td class="fw-bold text-navy bg-light"><i class="bi bi-shield-check text-gold me-2"></i>Cancellation</td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="text-center small text-muted">
                                            ${hotel.cancellationPolicy}
                                        </td>
                                    </c:forEach>
                                </tr>

                                <!-- Action Buttons -->
                                <tr>
                                    <td class="bg-light"></td>
                                    <c:forEach var="hotel" items="${compareHotels}">
                                        <td class="p-3 text-center">
                                            <a href="${pageContext.request.contextPath}/hotel?id=${hotel.id}" class="btn btn-gold btn-sm w-100 fw-bold py-2 shadow-sm">
                                                Explore & Book
                                            </a>
                                        </td>
                                    </c:forEach>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:choose>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="bi bi-arrow-left-right text-muted display-2"></i>
                    <h3 class="text-navy font-serif mt-3">Select properties to compare</h3>
                    <p class="text-muted">Choose hotels from the dropdown above to view an itemized comparison matrix.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const btnAdd = document.getElementById('btnAddHotel');
    const select = document.getElementById('selectHotelToAdd');

    // Get current IDs from URL
    const urlParams = new URLSearchParams(window.location.search);
    let currentIds = (urlParams.get('ids') || '').split(',').filter(Boolean);

    if (btnAdd && select) {
        btnAdd.addEventListener('click', function() {
            const val = select.value;
            if (!val) return;
            if (currentIds.includes(val)) {
                alert('This property is already in the comparison table.');
                return;
            }
            if (currentIds.length >= 3) {
                alert('You can compare a maximum of 3 hotels side by side.');
                return;
            }
            currentIds.push(val);
            urlParams.set('ids', currentIds.join(','));
            window.location.search = urlParams.toString();
        });
    }

    // Remove buttons
    document.querySelectorAll('.btn-remove-compare').forEach(btn => {
        btn.addEventListener('click', function() {
            const idToRemove = this.getAttribute('data-id');
            currentIds = currentIds.filter(id => id !== idToRemove);
            if (currentIds.length > 0) {
                urlParams.set('ids', currentIds.join(','));
            } else {
                urlParams.delete('ids');
            }
            window.location.search = urlParams.toString();
        });
    });
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


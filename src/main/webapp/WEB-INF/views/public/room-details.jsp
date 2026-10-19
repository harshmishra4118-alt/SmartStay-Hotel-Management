<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="${room.name} - AuraStay Luxury Suites"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container my-5">
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none text-gold">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/rooms" class="text-decoration-none text-gold">Rooms & Suites</a></li>
            <li class="breadcrumb-item active" aria-current="page">${room.name}</li>
        </ol>
    </nav>

    <div class="row g-5">
        <!-- Left: Image & Room Details -->
        <div class="col-lg-8">
            <div class="position-relative rounded-3 overflow-hidden shadow mb-4" style="max-height: 480px;">
                <img src="${room.primaryImageUrl}" alt="${room.name}" class="w-100 h-100 object-fit-cover" style="min-height: 400px;">
                <span class="room-badge-type">${room.roomType.displayName}</span>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h1 class="font-serif text-navy display-6 mb-0">${room.name}</h1>
                <span class="badge bg-navy text-gold px-3 py-2 fs-6">Room #${room.roomNumber}</span>
            </div>

            <div class="row g-3 py-3 border-top border-bottom my-4 text-center">
                <div class="col-3 border-end">
                    <small class="text-muted d-block text-uppercase fw-semibold">Max Guests</small>
                    <span class="fs-5 fw-bold text-navy"><i class="bi bi-people-fill text-gold me-1"></i>${room.capacity}</span>
                </div>
                <div class="col-3 border-end">
                    <small class="text-muted d-block text-uppercase fw-semibold">Room Size</small>
                    <span class="fs-5 fw-bold text-navy"><i class="bi bi-aspect-ratio text-gold me-1"></i>${room.sizeSqft} sq ft</span>
                </div>
                <div class="col-3 border-end">
                    <small class="text-muted d-block text-uppercase fw-semibold">Bedding</small>
                    <span class="fs-5 fw-bold text-navy"><i class="bi bi-moon-stars text-gold me-1"></i>${room.bedType}</span>
                </div>
                <div class="col-3">
                    <small class="text-muted d-block text-uppercase fw-semibold">Floor Level</small>
                    <span class="fs-5 fw-bold text-navy"><i class="bi bi-layer-forward text-gold me-1"></i>Floor ${room.floorNumber}</span>
                </div>
            </div>

            <div class="mb-5">
                <h4 class="font-serif text-navy mb-3">Suite Overview</h4>
                <p class="text-secondary leading-relaxed fs-6">
                    ${room.description}
                </p>
            </div>

            <div class="mb-5">
                <h4 class="font-serif text-navy mb-3">Exclusive Amenities</h4>
                <div class="row g-2">
                    <c:forEach var="amenity" items="${room.amenitiesList}">
                        <div class="col-sm-6">
                            <div class="p-2 bg-light rounded d-flex align-items-center gap-2 border">
                                <i class="bi bi-check-circle-fill text-gold"></i>
                                <span class="small fw-medium">${amenity}</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <!-- Verified Guest Reviews for this Suite -->
            <div class="mt-5 pt-4 border-top">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="font-serif text-navy mb-0">Verified Guest Reviews</h4>
                    <span class="badge bg-gold text-dark px-3 py-2 fw-semibold">
                        <i class="bi bi-star-fill me-1"></i>5-Star Experience
                    </span>
                </div>

                <c:choose>
                    <c:when test="${not empty reviews}">
                        <div class="d-flex flex-column gap-3">
                            <c:forEach var="rev" items="${reviews}">
                                <div class="p-4 bg-white rounded-3 shadow-sm border">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <h6 class="mb-0 text-navy fw-bold">${rev.customerName}</h6>
                                        <div class="text-gold small">
                                            <c:forEach begin="1" end="${rev.rating}"><i class="bi bi-star-fill"></i></c:forEach>
                                        </div>
                                    </div>
                                    <p class="small text-secondary mb-2 fst-italic">"${rev.comments}"</p>
                                    <c:if test="${not empty rev.adminReply}">
                                        <div class="p-3 bg-light rounded mt-2 border-start border-3 border-warning">
                                            <small class="fw-bold text-navy d-block mb-1">Management Response:</small>
                                            <small class="text-muted">${rev.adminReply}</small>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted small">No guest reviews submitted yet for this suite. Be the first to share your experience!</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Right: Reservation Sidebar Card -->
        <div class="col-lg-4">
            <div class="bg-white p-4 rounded-3 shadow border sticky-top" style="top: 100px;">
                <div class="border-bottom pb-3 mb-3">
                    <span class="text-muted small text-uppercase fw-semibold">Nightly Rate</span>
                    <div class="d-flex align-items-baseline gap-1 mt-1">
                        <h2 class="font-serif text-navy fw-bold mb-0">
                            ₹<fmt:formatNumber value="${room.pricePerNight}" pattern="#,##0"/>
                        </h2>
                        <small class="text-muted">/ night + 12% GST</small>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/customer/book" method="GET" class="d-flex flex-column gap-3">
                    <input type="hidden" name="roomId" value="${room.id}">

                    <div>
                        <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Check-In</label>
                        <input type="date" name="checkIn" class="form-control" required>
                    </div>

                    <div>
                        <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Check-Out</label>
                        <input type="date" name="checkOut" class="form-control" required>
                    </div>

                    <div>
                        <label class="form-label small fw-bold text-uppercase text-secondary mb-1">Guests</label>
                        <select name="guests" class="form-select">
                            <c:forEach begin="1" end="${room.capacity}" var="g">
                                <option value="${g}" ${g == 1 ? 'selected' : ''}>${g} Guest${g > 1 ? 's' : ''}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-gold w-100 py-2 fs-6 mt-2">
                        <i class="bi bi-calendar2-check me-2"></i>Reserve This Suite
                    </button>
                </form>

                <div class="mt-4 pt-3 border-top small text-muted">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-shield-check text-success fs-5"></i>
                        <span>Best Rate Guaranteed online</span>
                    </div>
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-cup-hot text-gold fs-5"></i>
                        <span>Complimentary Gourmet Breakfast</span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-arrow-repeat text-primary fs-5"></i>
                        <span>Free cancellation up to check-in</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

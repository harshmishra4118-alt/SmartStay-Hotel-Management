<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Guest Stay Review - SmartStay Hotel"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-4 text-white">
    <div class="container">
        <h1 class="font-serif display-6 mb-1">Share Your Experience</h1>
        <p class="text-light opacity-75 small mb-0">Your honest feedback empowers us to elevate the art of hospitality.</p>
    </div>
</div>

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="font-serif text-navy mb-0">Stay Review: ${booking.roomName}</h5>
                        <small class="text-muted">Reservation Ref: <span class="font-monospace fw-semibold text-navy">${booking.bookingReference}</span></small>
                    </div>
                    <span class="badge bg-gold text-dark px-3 py-2">Verified Guest</span>
                </div>

                <div class="card-body p-4 p-md-5">
                    <form action="${pageContext.request.contextPath}/customer/feedback" method="POST">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="bookingId" value="${booking.id}">

                        <!-- Overall Star Rating -->
                        <div class="mb-4 text-center p-3 bg-light rounded">
                            <label class="form-label fw-bold text-navy text-uppercase small d-block mb-2">Overall Experience Rating</label>
                            <div class="d-inline-flex gap-3 fs-3" id="starContainer">
                                <c:forEach var="star" begin="1" end="5">
                                    <div class="form-check form-check-inline m-0">
                                        <input class="btn-check" type="radio" name="rating" id="rating${star}" value="${star}" ${star == 5 ? 'checked' : ''} required>
                                        <label class="btn btn-outline-warning border-0 px-2 fs-3 text-gold" for="rating${star}">
                                            <i class="bi bi-star-fill"></i>
                                            <span class="d-block small text-muted" style="font-size: 0.75rem;">${star} ${star == 1 ? 'Star' : 'Stars'}</span>
                                        </label>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- Detailed Category Ratings -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-4">
                                <div class="p-3 border rounded bg-light text-center">
                                    <label class="form-label fw-bold text-navy small mb-1">
                                        <i class="bi bi-stars text-gold me-1"></i> Cleanliness
                                    </label>
                                    <select name="cleanliness" class="form-select form-select-sm" required>
                                        <option value="5" selected>5 - Exceptional</option>
                                        <option value="4">4 - Very Good</option>
                                        <option value="3">3 - Satisfactory</option>
                                        <option value="2">2 - Needs Attention</option>
                                        <option value="1">1 - Unsatisfactory</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="p-3 border rounded bg-light text-center">
                                    <label class="form-label fw-bold text-navy small mb-1">
                                        <i class="bi bi-person-heart text-gold me-1"></i> Staff Service
                                    </label>
                                    <select name="service" class="form-select form-select-sm" required>
                                        <option value="5" selected>5 - Impeccable</option>
                                        <option value="4">4 - Courteous</option>
                                        <option value="3">3 - Standard</option>
                                        <option value="2">2 - Inattentive</option>
                                        <option value="1">1 - Poor</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="p-3 border rounded bg-light text-center">
                                    <label class="form-label fw-bold text-navy small mb-1">
                                        <i class="bi bi-cup-hot text-gold me-1"></i> Amenities & Comfort
                                    </label>
                                    <select name="amenities" class="form-select form-select-sm" required>
                                        <option value="5" selected>5 - World Class</option>
                                        <option value="4">4 - High Quality</option>
                                        <option value="3">3 - Adequate</option>
                                        <option value="2">2 - Limited</option>
                                        <option value="1">1 - Lacking</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Comments -->
                        <div class="mb-4">
                            <label class="form-label fw-bold text-navy small text-uppercase">Your Review & Suggestions</label>
                            <textarea name="comments" class="form-control" rows="5" placeholder="Tell us about the highlights of your stay, room comfort, dining experience, or how our team could have made your visit even more memorable..." required></textarea>
                            <div class="form-text small">Our rule-based sentiment classifier analyses reviews to continuously refine guest service standards.</div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center">
                            <a href="${pageContext.request.contextPath}/customer/my-bookings" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-arrow-left me-1"></i> Back to Reservations
                            </a>
                            <button type="submit" class="btn btn-gold px-4 py-2 fw-bold">
                                <i class="bi bi-send-fill me-1"></i> Submit Guest Review
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

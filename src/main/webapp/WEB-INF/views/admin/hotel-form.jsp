<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="${empty hotel.id ? 'Register Hotel' : 'Edit Hotel Property'} - Admin Portal" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 px-0">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
        </div>

        <!-- Main Content -->
        <main class="col-md-9 col-lg-10 ms-sm-auto px-md-4 py-4 bg-light min-vh-100">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="font-serif text-navy fw-bold mb-1">
                        <i class="bi bi-building text-gold me-2"></i>${empty hotel.id ? 'Register New Luxury Property' : 'Edit Hotel Property'}
                    </h2>
                    <p class="text-muted small mb-0">Configure destination details, geolocation coordinates, and amenities.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/hotels" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i>Back to Properties
                </a>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <div class="card shadow-sm border-0 rounded-4 p-4 max-w-900">
                <form action="${pageContext.request.contextPath}/admin/hotels" method="POST">
                    <input type="hidden" name="id" value="${hotel.id != null ? hotel.id : 0}" />

                    <!-- Basic Info -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">1. General Identity</h5>
                    <div class="row g-3 mb-4">
                        <div class="col-md-8">
                            <label class="form-label small fw-bold">Hotel Property Name</label>
                            <input type="text" name="name" class="form-control" value="${hotel.name}" placeholder="e.g. SmartStay Grand Palace & Spa" required />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold">Star Rating</label>
                            <input type="number" step="0.1" min="1.0" max="5.0" name="starRating" class="form-control" value="${hotel.starRating != null ? hotel.starRating : '4.5'}" required />
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-bold">Tagline</label>
                            <input type="text" name="tagline" class="form-control" value="${hotel.tagline}" placeholder="e.g. Where Timeless Elegance Meets Bayfront Luxury" />
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-bold">Description</label>
                            <textarea name="description" class="form-control" rows="4" required>${hotel.description}</textarea>
                        </div>
                    </div>

                    <!-- Location & GPS -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">2. Destination & Geolocation</h5>
                    <div class="row g-3 mb-4">
                        <div class="col-md-8">
                            <label class="form-label small fw-bold">Street Address</label>
                            <input type="text" name="address" class="form-control" value="${hotel.address}" required />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold">City</label>
                            <input type="text" name="city" class="form-control" value="${hotel.city}" placeholder="e.g. Mumbai, Jaipur, Bengaluru" required />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold">State / Province</label>
                            <input type="text" name="state" class="form-control" value="${hotel.state}" required />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold">Postal Code</label>
                            <input type="text" name="postalCode" class="form-control" value="${hotel.postalCode}" required />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small fw-bold">GPS Latitude</label>
                            <input type="text" name="latitude" class="form-control font-monospace" value="${hotel.latitude != null ? hotel.latitude : '18.92200000'}" required />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small fw-bold">GPS Longitude</label>
                            <input type="text" name="longitude" class="form-control font-monospace" value="${hotel.longitude != null ? hotel.longitude : '72.83470000'}" required />
                        </div>
                    </div>

                    <!-- Contact & Media -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">3. Contact & Media</h5>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Official Telephone</label>
                            <input type="text" name="phone" class="form-control" value="${hotel.phone}" placeholder="+91 (022) 8900 1200" required />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Official Inquiries Email</label>
                            <input type="email" name="email" class="form-control" value="${hotel.email}" placeholder="property@smartstay.com" required />
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-bold">Primary Showcase Image URL</label>
                            <input type="url" name="primaryImageUrl" class="form-control" value="${hotel.primaryImageUrl}" placeholder="https://images.unsplash.com/..." required />
                        </div>
                    </div>

                    <!-- Pricing & Timings -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">4. Operations & Pricing</h5>
                    <div class="row g-3 mb-4">
                        <div class="col-md-3">
                            <label class="form-label small fw-bold">Min Nightly Rate (INR)</label>
                            <input type="number" step="100" name="minPrice" class="form-control" value="${hotel.minPrice != null ? hotel.minPrice : '3500.00'}" required />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold">Max Nightly Rate (INR)</label>
                            <input type="number" step="100" name="maxPrice" class="form-control" value="${hotel.maxPrice != null ? hotel.maxPrice : '35000.00'}" required />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold">Check-In Time</label>
                            <input type="text" name="checkinTime" class="form-control" value="${hotel.checkinTime != null ? hotel.checkinTime : '14:00'}" required />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold">Check-Out Time</label>
                            <input type="text" name="checkoutTime" class="form-control" value="${hotel.checkoutTime != null ? hotel.checkoutTime : '11:00'}" required />
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-bold">Cancellation Policy</label>
                            <textarea name="cancellationPolicy" class="form-control" rows="2">${hotel.cancellationPolicy}</textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Operational Status</label>
                            <select name="status" class="form-select">
                                <option value="ACTIVE" ${hotel.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                <option value="INACTIVE" ${hotel.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                            </select>
                        </div>
                        <div class="col-md-6 d-flex align-items-center pt-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="isFeatured" id="chkFeatured" ${hotel.featured ? 'checked' : ''} />
                                <label class="form-check-label fw-semibold" for="chkFeatured">
                                    Feature on Public Homepage
                                </label>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-navy btn-lg py-3 px-5 fw-bold shadow-sm">
                        <i class="bi bi-save me-2 text-gold"></i>Save Property Information
                    </button>
                </form>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="${empty room ? 'Add New Suite' : 'Edit Suite'} - SmartStay Admin"/>
</jsp:include>

<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Admin Sidebar -->
        <div class="col-lg-2 col-md-3">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
        </div>

        <!-- Main Content Area -->
        <div class="col-lg-10 col-md-9 bg-light min-vh-100 p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <div>
                    <h2 class="font-serif text-navy mb-1">${empty room ? 'Create New Luxury Suite' : 'Modify Suite Configuration'}</h2>
                    <p class="text-secondary small mb-0">Define room amenities, pricing tiers, layout dimensions, and imagery.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Back to Inventory
                </a>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <div class="card border-0 shadow-sm rounded-3 bg-white p-4 p-md-5" style="max-width: 900px;">
                <form action="${pageContext.request.contextPath}/admin/rooms" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <c:if test="${not empty room}">
                        <input type="hidden" name="id" value="${room.id}">
                    </c:if>

                    <h6 class="text-navy text-uppercase fw-bold small mb-3 border-bottom pb-2">Core Suite Identity</h6>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Room Number</label>
                            <input type="text" name="roomNumber" class="form-control font-monospace" placeholder="e.g. 101, 204, PH-01" value="${room.roomNumber}" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Suite Category</label>
                            <select name="roomType" class="form-select" required>
                                <c:forEach var="t" items="${allRoomTypes}">
                                    <option value="${t.name()}" ${room.roomType == t ? 'selected' : ''}>${t.displayName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Floor Level</label>
                            <input type="number" name="floorNumber" class="form-control" min="1" max="50" value="${room.floorNumber != null ? room.floorNumber : 1}" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary text-uppercase">Suite Title / Display Name</label>
                        <input type="text" name="name" class="form-control" placeholder="e.g. Presidential Oceanfront Panorama Suite" value="${room.name}" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary text-uppercase">Architectural Description & Narrative</label>
                        <textarea name="description" class="form-control" rows="3" placeholder="Describe the panoramic vistas, interior marble finishes, and bespoke luxury appointments..." required>${room.description}</textarea>
                    </div>

                    <h6 class="text-navy text-uppercase fw-bold small mt-4 mb-3 border-bottom pb-2">Pricing & Capacities</h6>
                    <div class="row g-3 mb-3">
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Nightly Tariff (₹)</label>
                            <div class="input-group">
                                <span class="input-group-text">₹</span>
                                <input type="number" step="0.01" name="pricePerNight" class="form-control" placeholder="7500.00" value="${room.pricePerNight}" required>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Max Guests</label>
                            <input type="number" name="capacity" class="form-control" min="1" max="10" value="${room.capacity != null ? room.capacity : 2}" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Bed Configuration</label>
                            <input type="text" name="bedType" class="form-control" placeholder="King Bed / 2 Queen Beds" value="${room.bedType != null ? room.bedType : 'King Bed'}" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Size (Sq. Ft.)</label>
                            <input type="number" name="sizeSqft" class="form-control" placeholder="450" value="${room.sizeSqft != null ? room.sizeSqft : 450}" required>
                        </div>
                    </div>

                    <h6 class="text-navy text-uppercase fw-bold small mt-4 mb-3 border-bottom pb-2">Status & Presentation</h6>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Operational Status</label>
                            <select name="operationalStatus" class="form-select" required>
                                <c:forEach var="op" items="${allOperationalStatuses}">
                                    <option value="${op.name()}" ${room.operationalStatus == op ? 'selected' : ''}>${op.displayName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Housekeeping Readiness</label>
                            <select name="housekeepingStatus" class="form-select" required>
                                <c:forEach var="hk" items="${allHousekeepingStatuses}">
                                    <option value="${hk.name()}" ${room.housekeepingStatus == hk ? 'selected' : ''}>${hk.displayName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-secondary text-uppercase">Primary Cover Image URL</label>
                        <input type="url" name="primaryImageUrl" class="form-control" placeholder="https://images.unsplash.com/photo-..." value="${room.primaryImageUrl}" required>
                        <div class="form-text small">High-resolution Unsplash or CDN web image URL showcasing the suite interior.</div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary text-uppercase">Luxury Amenities (Comma Separated)</label>
                        <input type="text" name="amenities" class="form-control" placeholder="High-Speed Wi-Fi, Jacuzzi, Balcony, Butler Service, 4K Smart TV, Nespresso" value="${room.amenities}">
                        <div class="form-text small">Tags parsed by rule-based room recommendation engine.</div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 border-top pt-4">
                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary btn-sm">Cancel</a>
                        <button type="submit" class="btn btn-gold px-4 py-2 fw-bold">
                            <i class="bi bi-save me-1"></i> ${empty room ? 'Create Room in Inventory' : 'Save Suite Updates'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

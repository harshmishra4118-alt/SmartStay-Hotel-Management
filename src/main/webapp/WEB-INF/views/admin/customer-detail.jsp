<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Guest Profile: ${customerUser.fullName} - AuraStay Admin"/>
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
                    <h2 class="font-serif text-navy mb-1">Customer Profile & Travel Dossier</h2>
                    <p class="text-secondary small mb-0">Confidential verified guest records, travel identification, and preferences history.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Back to Customer Directory
                </a>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <div class="card border-0 shadow-sm rounded-3 bg-white p-4 p-md-5" style="max-width: 850px;">
                <div class="d-flex flex-wrap justify-content-between align-items-center border-bottom pb-4 mb-4">
                    <div class="d-flex align-items-center gap-3">
                        <div class="bg-navy text-gold rounded-circle d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; font-size: 1.5rem;">
                            <i class="bi bi-person-fill"></i>
                        </div>
                        <div>
                            <h4 class="font-serif text-navy mb-0">${customerUser.fullName}</h4>
                            <small class="text-secondary">Registered Guest &bull; Member since ${customerUser.createdAt}</small>
                        </div>
                    </div>
                    <div>
                        <span class="badge ${customerUser.status.name() == 'ACTIVE' ? 'bg-success' : 'bg-danger'} fs-6 px-3 py-2">
                            ${customerUser.status.name()}
                        </span>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <h6 class="text-navy text-uppercase fw-bold small mb-3">Contact Information</h6>
                        <p class="mb-2"><small class="text-muted text-uppercase fw-bold d-block">Email Address</small><strong>${customerUser.email}</strong></p>
                        <p class="mb-2"><small class="text-muted text-uppercase fw-bold d-block">Phone Number</small><strong>${customerUser.phone != null ? customerUser.phone : 'Not provided'}</strong></p>
                        <p class="mb-0"><small class="text-muted text-uppercase fw-bold d-block">Emergency Contact</small><strong>${customerProfile.emergencyContact != null ? customerProfile.emergencyContact : 'None specified'}</strong></p>
                    </div>

                    <div class="col-md-6">
                        <h6 class="text-navy text-uppercase fw-bold small mb-3">Travel Identification Details</h6>
                        <p class="mb-2"><small class="text-muted text-uppercase fw-bold d-block">Document Type</small><strong>${customerProfile.idDocumentType != null ? customerProfile.idDocumentType : 'Not verified'}</strong></p>
                        <p class="mb-2"><small class="text-muted text-uppercase fw-bold d-block">Document Number</small><strong class="font-monospace">${customerProfile.idDocumentNumber != null ? customerProfile.idDocumentNumber : 'N/A'}</strong></p>
                        <p class="mb-0"><small class="text-muted text-uppercase fw-bold d-block">Nationality / Country</small><strong>${customerProfile.country != null ? customerProfile.country : 'India'}</strong></p>
                    </div>
                </div>

                <div class="border-top pt-4 mb-4">
                    <h6 class="text-navy text-uppercase fw-bold small mb-2">Residential Address</h6>
                    <p class="text-secondary mb-0">
                        ${customerProfile.address != null ? customerProfile.address : 'No street address saved.'}
                        <c:if test="${not empty customerProfile.city}">, ${customerProfile.city}</c:if>
                        <c:if test="${not empty customerProfile.country}">, ${customerProfile.country}</c:if>
                    </p>
                </div>

                <div class="border-top pt-4 mb-4">
                    <h6 class="text-navy text-uppercase fw-bold small mb-2">Recorded Hospitality Preferences</h6>
                    <div class="p-3 bg-light rounded text-secondary small">
                        ${not empty customerProfile.preferencesNotes ? customerProfile.preferencesNotes : 'No special dietary or accommodation preferences logged by guest.'}
                    </div>
                </div>

                <!-- Administrative Account Status Form -->
                <div class="border-top pt-4">
                    <form action="${pageContext.request.contextPath}/admin/customers" method="POST" class="d-flex align-items-center gap-3">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="customerId" value="${customerUser.id}">
                        <label class="form-label small fw-bold text-navy text-uppercase mb-0">Modify Account Status:</label>
                        <select name="status" class="form-select form-select-sm" style="width: 150px;">
                            <option value="ACTIVE" ${customerUser.status.name() == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                            <option value="SUSPENDED" ${customerUser.status.name() == 'SUSPENDED' ? 'selected' : ''}>SUSPENDED</option>
                            <option value="DELETED" ${customerUser.status.name() == 'DELETED' ? 'selected' : ''}>DELETED</option>
                        </select>
                        <button type="submit" class="btn btn-navy btn-sm fw-bold">Update Account</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="My Profile & Preferences - AuraStay Luxury Suites"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-4 text-white">
    <div class="container">
        <h1 class="font-serif display-6 mb-1">Guest Profile & Security</h1>
        <p class="text-light opacity-75 small mb-0">Manage your contact details, travel identification, and stay preferences.</p>
    </div>
</div>

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i> ${successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show small mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Left: Profile Details Form -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="font-serif text-navy mb-0"><i class="bi bi-person-circle me-2 text-gold"></i>Personal & Identification Details</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/customer/profile" method="POST">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">Full Name</label>
                                <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">Registered Email</label>
                                <input type="email" class="form-control bg-light" value="${user.email}" readonly disabled>
                                <div class="form-text small">Account email identifier cannot be altered.</div>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">Phone / Mobile</label>
                                <input type="tel" name="phone" class="form-control" value="${user.phone}" placeholder="+91 98765 43210" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">Emergency Contact</label>
                                <input type="text" name="emergencyContact" class="form-control" value="${profile.emergencyContact}" placeholder="Name & contact number">
                            </div>
                        </div>

                        <h6 class="text-navy fw-bold text-uppercase small border-top pt-3 mt-4 mb-3">Travel Identification (For Express Check-In)</h6>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">ID Document Type</label>
                                <select name="idDocumentType" class="form-select">
                                    <option value="" ${empty profile.idDocumentType ? 'selected' : ''}>-- Select Document Type --</option>
                                    <option value="Passport" ${profile.idDocumentType == 'Passport' ? 'selected' : ''}>Passport</option>
                                    <option value="Aadhaar" ${profile.idDocumentType == 'Aadhaar' ? 'selected' : ''}>Aadhaar Card</option>
                                    <option value="Driving License" ${profile.idDocumentType == 'Driving License' ? 'selected' : ''}>Driving License</option>
                                    <option value="Voter ID" ${profile.idDocumentType == 'Voter ID' ? 'selected' : ''}>Voter ID Card</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">ID Document Number</label>
                                <input type="text" name="idDocumentNumber" class="form-control font-monospace" value="${profile.idDocumentNumber}" placeholder="e.g. Z1234567 or 1234 5678 9012">
                            </div>
                        </div>

                        <h6 class="text-navy fw-bold text-uppercase small border-top pt-3 mt-4 mb-3">Address & Location</h6>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Residential Address</label>
                            <input type="text" name="address" class="form-control" value="${profile.address}" placeholder="Street, Apartment or Suite number">
                        </div>
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">City</label>
                                <input type="text" name="city" class="form-control" value="${profile.city}" placeholder="e.g. Mumbai">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-secondary text-uppercase">Country</label>
                                <input type="text" name="country" class="form-control" value="${profile.country != null ? profile.country : 'India'}" placeholder="e.g. India">
                            </div>
                        </div>

                        <h6 class="text-navy fw-bold text-uppercase small border-top pt-3 mt-4 mb-3">Hospitality Preferences</h6>
                        <div class="mb-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Personal Preferences & Notes</label>
                            <textarea name="preferencesNotes" class="form-control" rows="3" placeholder="e.g. High floor preference, extra feather pillows, hypoallergenic linen, vegan breakfast...">${profile.preferencesNotes}</textarea>
                        </div>

                        <div class="text-end">
                            <button type="submit" class="btn btn-gold px-4 py-2 fw-bold">
                                <i class="bi bi-save me-1"></i> Save Profile Details
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Right: Security & Change Password -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-3 mb-4">
                <div class="card-header bg-white py-3 border-bottom">
                    <h5 class="font-serif text-navy mb-0"><i class="bi bi-shield-lock me-2 text-gold"></i>Change Password</h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/customer/profile" method="POST">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="action" value="changePassword">

                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Current Password</label>
                            <input type="password" name="oldPassword" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">New Password</label>
                            <input type="password" name="newPassword" class="form-control" minlength="8" required>
                            <div class="form-text small">Minimum 8 characters with letters and numbers.</div>
                        </div>

                        <div class="d-grid mt-4">
                            <button type="submit" class="btn btn-outline-navy fw-bold py-2">
                                <i class="bi bi-key-fill me-1"></i> Update Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Account Summary Card -->
            <div class="card border-0 shadow-sm rounded-3 bg-light">
                <div class="card-body p-4">
                    <h6 class="font-serif text-navy fw-bold mb-3"><i class="bi bi-award text-gold me-2"></i>AuraStay Privilege Status</h6>
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="badge bg-navy text-gold px-3 py-2">VALUED GUEST</span>
                        <span class="badge bg-success">ACTIVE</span>
                    </div>
                    <small class="text-secondary d-block mb-3">
                        Enjoy priority check-in, flexible cancellation options, and personalized hospitality services.
                    </small>
                    <a href="${pageContext.request.contextPath}/customer/notifications" class="btn btn-sm btn-outline-secondary w-100">
                        <i class="bi bi-bell me-1"></i> View System Notifications
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

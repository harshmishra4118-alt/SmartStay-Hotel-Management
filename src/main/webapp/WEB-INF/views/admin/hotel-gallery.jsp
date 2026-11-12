<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Hotel Gallery Management - Admin Portal" />
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
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
                <div>
                    <h2 class="font-serif text-navy fw-bold mb-1">
                        <i class="bi bi-images text-gold me-2"></i>Hotel Photography & Gallery
                    </h2>
                    <p class="text-muted small mb-0">Manage categorized high-resolution photography, suites, and cover imagery.</p>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <c:if test="${not isOwnerScope}">
                        <form method="get" action="${pageContext.request.contextPath}/admin/hotel-gallery" class="d-flex align-items-center gap-2">
                            <label class="form-label small mb-0 fw-semibold text-muted text-nowrap">Property:</label>
                            <select name="hotelId" class="form-select form-select-sm shadow-sm" onchange="this.form.submit()">
                                <c:forEach var="h" items="${allHotels}">
                                    <option value="${h.id}" ${h.id == selectedHotelId ? 'selected' : ''}>${h.name} (${h.city})</option>
                                </c:forEach>
                            </select>
                        </form>
                    </c:if>

                    <button type="button" class="btn btn-gold text-navy fw-bold btn-sm shadow-sm" data-bs-toggle="modal" data-bs-target="#addImageModal">
                        <i class="bi bi-cloud-arrow-up me-1"></i>Upload / Add Photo
                    </button>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.success == 'added'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle me-2"></i>Photograph added to hotel gallery successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.success == 'deleted'}">
                <div class="alert alert-info alert-dismissible fade show" role="alert">
                    <i class="bi bi-trash me-2"></i>Photograph removed from gallery.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.success == 'primary_updated'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-star-fill text-gold me-2"></i>Cover image updated successfully for ${hotel.name}!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Hotel Info Header Card -->
            <div class="card border-0 shadow-sm rounded-4 mb-4 bg-white overflow-hidden">
                <div class="card-body p-4 d-flex flex-wrap align-items-center justify-content-between gap-3">
                    <div class="d-flex align-items-center gap-3">
                        <img src="${hotel.primaryImageUrl}" alt="${hotel.name}" 
                             class="rounded-3 shadow-sm object-fit-cover" style="width: 80px; height: 60px;"
                             onerror="this.src='https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80'">
                        <div>
                            <h4 class="fw-bold text-navy mb-1">${hotel.name}</h4>
                            <p class="text-muted small mb-0">
                                <i class="bi bi-geo-alt-fill text-gold me-1"></i>${hotel.city}, ${hotel.state} &bull; 
                                <span class="badge bg-gold-subtle text-navy border border-gold-subtle">${hotel.starRating} &#9733;</span> &bull; 
                                <span class="fw-semibold">${images.size()} Photographs in Gallery</span>
                            </p>
                        </div>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/hotel?id=${hotel.id}" target="_blank" class="btn btn-outline-navy btn-sm">
                            <i class="bi bi-box-arrow-up-right me-1"></i>View Public Gallery
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/hotel-form?id=${hotel.id}" class="btn btn-outline-secondary btn-sm">
                            <i class="bi bi-pencil me-1"></i>Edit Hotel Info
                        </a>
                    </div>
                </div>
            </div>

            <!-- Photos Grid -->
            <div class="row g-4">
                <c:choose>
                    <c:when test="${empty images}">
                        <div class="col-12">
                            <div class="card border-0 shadow-sm rounded-4 p-5 text-center bg-white">
                                <i class="bi bi-images display-3 text-muted mb-3 opacity-50"></i>
                                <h4 class="fw-bold text-navy">No Photographs Uploaded Yet</h4>
                                <p class="text-muted">Start curating this property's gallery by adding high-resolution photography.</p>
                                <div>
                                    <button class="btn btn-gold text-navy fw-bold" data-bs-toggle="modal" data-bs-target="#addImageModal">
                                        <i class="bi bi-cloud-arrow-up me-1"></i>Add First Photograph
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="img" items="${images}">
                            <div class="col-md-6 col-lg-4 col-xl-3">
                                <div class="card border-0 shadow-sm rounded-4 h-100 overflow-hidden bg-white position-relative">
                                    <div class="position-relative" style="height: 190px;">
                                        <img src="${img.imageUrl}" alt="${img.caption}" 
                                             class="w-100 h-100 object-fit-cover"
                                             onerror="this.src='https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80'">
                                        <div class="position-absolute top-0 start-0 m-2">
                                            <span class="badge bg-navy shadow-sm">${img.category.displayName}</span>
                                        </div>
                                        <c:if test="${img.primary}">
                                            <div class="position-absolute top-0 end-0 m-2">
                                                <span class="badge bg-gold text-navy fw-bold shadow-sm">
                                                    <i class="bi bi-star-fill me-1"></i>Cover Photo
                                                </span>
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="card-body p-3 d-flex flex-column justify-content-between">
                                        <p class="small text-muted mb-3" style="min-height: 38px;">
                                            ${not empty img.caption ? img.caption : 'No caption provided.'}
                                        </p>
                                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                            <c:if test="${!img.primary}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/hotel-gallery">
                                                    <input type="hidden" name="action" value="set-primary">
                                                    <input type="hidden" name="hotelId" value="${hotel.id}">
                                                    <input type="hidden" name="imageId" value="${img.id}">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <button type="submit" class="btn btn-sm btn-outline-warning text-dark py-1 px-2" title="Set as primary cover photo">
                                                        <i class="bi bi-star me-1"></i>Set Cover
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${img.primary}">
                                                <span class="text-success small fw-semibold">
                                                    <i class="bi bi-check-circle-fill me-1"></i>Primary
                                                </span>
                                            </c:if>

                                            <form method="post" action="${pageContext.request.contextPath}/admin/hotel-gallery" onsubmit="return confirm('Are you sure you want to delete this photograph?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="hotelId" value="${hotel.id}">
                                                <input type="hidden" name="imageId" value="${img.id}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger py-1 px-2" title="Delete photograph">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
</div>

<!-- Modal: Add New Photograph -->
<div class="modal fade" id="addImageModal" tabindex="-1" aria-labelledby="addImageModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow rounded-4">
            <form method="post" action="${pageContext.request.contextPath}/admin/hotel-gallery">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="hotelId" value="${hotel.id}">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-navy" id="addImageModalLabel">
                        <i class="bi bi-camera text-gold me-2"></i>Add Photograph to Gallery
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-muted">Image URL <span class="text-danger">*</span></label>
                        <input type="url" name="imageUrl" class="form-control" placeholder="https://images.unsplash.com/..." required>
                        <div class="form-text small">Provide a direct high-resolution web image URL (JPG, PNG, WebP).</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-muted">Category <span class="text-danger">*</span></label>
                        <select name="category" class="form-select" required>
                            <c:forEach var="cat" items="${allCategories}">
                                <option value="${cat.name()}">${cat.displayName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-muted">Caption / Description</label>
                        <input type="text" name="caption" class="form-control" placeholder="e.g. Olympic horizon infinity pool with Arabian sea sunset">
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label small fw-semibold text-muted">Display Order</label>
                            <input type="number" name="displayOrder" class="form-control" value="0" min="0">
                        </div>
                        <div class="col-6 d-flex align-items-end pb-2">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="isPrimary" value="true" id="checkPrimary">
                                <label class="form-check-label small fw-semibold" for="checkPrimary">
                                    Set as Primary Cover
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-navy text-gold fw-bold px-4">
                        <i class="bi bi-cloud-arrow-up me-1"></i>Save Photograph
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


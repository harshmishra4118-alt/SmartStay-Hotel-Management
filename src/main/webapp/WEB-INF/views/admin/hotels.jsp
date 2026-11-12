<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Hotel Properties Management - Admin Portal" />
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
                        <i class="bi bi-buildings text-gold me-2"></i>Hotel Properties Network
                    </h2>
                    <p class="text-muted small mb-0">Ecosystem-wide multi-hotel portfolio across India destinations.</p>
                </div>
                <c:if test="${sessionScope.currentUser.superAdmin}">
                    <a href="${pageContext.request.contextPath}/admin/hotel-form" class="btn btn-navy shadow-sm">
                        <i class="bi bi-plus-circle me-1 text-gold"></i>Register New Property
                    </a>
                </c:if>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-uppercase small text-muted">
                            <tr>
                                <th class="ps-4">Property</th>
                                <th>Destination</th>
                                <th>Star Rating</th>
                                <th>Price Range</th>
                                <th>Coordinates (GPS)</th>
                                <th>Status</th>
                                <th class="text-end pe-4">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="h" items="${hotels}">
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="${h.primaryImageUrl}" alt="${h.name}" class="rounded-3 shadow-sm" style="width: 70px; height: 50px; object-fit: cover;" />
                                            <div>
                                                <h6 class="font-serif text-navy mb-0">${h.name}</h6>
                                                <small class="text-muted">${h.tagline}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-gold text-dark">${h.city}</span>
                                        <small class="text-muted d-block">${h.state}</small>
                                    </td>
                                    <td>
                                        <strong class="text-gold">★ ${h.starRating}</strong>
                                    </td>
                                    <td>
                                        <span class="small fw-semibold text-navy">
                                            Rs <fmt:formatNumber value="${h.minPrice}" maxFractionDigits="0" /> - 
                                            Rs <fmt:formatNumber value="${h.maxPrice}" maxFractionDigits="0" />
                                        </span>
                                    </td>
                                    <td class="small font-monospace">
                                        ${h.latitude},<br />${h.longitude}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${h.status == 'ACTIVE'}">
                                                <span class="badge bg-success-subtle text-success border border-success">Active</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger-subtle text-danger border border-danger">Inactive</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end pe-4">
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/hotel?id=${h.id}" target="_blank" class="btn btn-outline-secondary" title="View Public Page">
                                                <i class="bi bi-box-arrow-up-right"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/hotel-form?id=${h.id}" class="btn btn-outline-primary" title="Edit Hotel Information">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <c:if test="${sessionScope.currentUser.superAdmin}">
                                                <form action="${pageContext.request.contextPath}/admin/hotels" method="POST" class="d-inline" onsubmit="return confirm('Change status for ${h.name}?');">
                                                    <input type="hidden" name="action" value="toggle-status" />
                                                    <input type="hidden" name="id" value="${h.id}" />
                                                    <button type="submit" class="btn btn-outline-${h.status == 'ACTIVE' ? 'warning' : 'success'}" title="${h.status == 'ACTIVE' ? 'Deactivate' : 'Activate'}">
                                                        <i class="bi bi-power"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


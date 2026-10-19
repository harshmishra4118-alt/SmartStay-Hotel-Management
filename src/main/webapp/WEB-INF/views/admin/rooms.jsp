<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Room Inventory Management - AuraStay Admin"/>
</jsp:include>

<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Admin Sidebar -->
        <div class="col-lg-2 col-md-3">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
        </div>

        <!-- Main Content Area -->
        <div class="col-lg-10 col-md-9 bg-light min-vh-100 p-4">
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <div>
                    <h2 class="font-serif text-navy mb-1">Room Inventory & Suites</h2>
                    <p class="text-secondary small mb-0">Configure room categories, nightly rates, operational availability, and housekeeping readiness.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/rooms/add" class="btn btn-gold btn-sm fw-bold">
                        <i class="bi bi-plus-lg me-1"></i> Add New Suite
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.created == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> New suite successfully added to inventory.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.updated == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Suite details updated successfully.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.statusUpdated == 'true'}">
                <div class="alert alert-info alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-info-circle-fill me-2"></i> Room operational status updated.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Filters -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <form action="${pageContext.request.contextPath}/admin/rooms" method="GET" class="row g-2 align-items-center">
                    <div class="col-md-4">
                        <input type="text" name="search" class="form-control form-control-sm" placeholder="Search suite name, room number..." value="${param.search}">
                    </div>
                    <div class="col-md-3">
                        <select name="type" class="form-select form-select-sm">
                            <option value="">-- All Suite Types --</option>
                            <c:forEach var="t" items="${allRoomTypes}">
                                <option value="${t.name()}" ${param.type == t.name() ? 'selected' : ''}>${t.displayName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select name="operational" class="form-select form-select-sm">
                            <option value="">-- Operational Status --</option>
                            <c:forEach var="op" items="${allOperationalStatuses}">
                                <option value="${op.name()}" ${param.operational == op.name() ? 'selected' : ''}>${op.displayName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-1">
                        <button type="submit" class="btn btn-navy btn-sm w-100 fw-bold">Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Rooms Inventory Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light small">
                            <tr>
                                <th style="width: 80px;">Room #</th>
                                <th style="width: 100px;">Preview</th>
                                <th>Suite Details</th>
                                <th>Category & Specs</th>
                                <th>Rate / Night</th>
                                <th>Operational</th>
                                <th>Housekeeping</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="small">
                            <c:forEach var="r" items="${rooms}">
                                <tr>
                                    <td>
                                        <span class="fs-6 fw-bold text-navy font-monospace">${r.roomNumber}</span>
                                    </td>
                                    <td>
                                        <img src="${r.primaryImageUrl}" alt="${r.name}" class="rounded object-fit-cover shadow-sm" style="width: 70px; height: 48px;">
                                    </td>
                                    <td>
                                        <strong class="text-navy d-block">${r.name}</strong>
                                        <small class="text-muted">Floor ${r.floorNumber} &bull; ${r.sizeSqft} sq.ft.</small>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-navy border">${r.roomType.displayName}</span>
                                        <small class="d-block text-secondary">${r.bedType} &bull; Max ${r.capacity} Guests</small>
                                    </td>
                                    <td>
                                        <span class="fw-bold text-navy">₹<fmt:formatNumber value="${r.pricePerNight}" pattern="#,##0"/></span>
                                    </td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/rooms/status" method="POST" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                                            <input type="hidden" name="roomId" value="${r.id}">
                                            <select name="status" class="form-select form-select-sm py-0 px-2" style="width: 125px; font-size: 0.75rem;" onchange="this.form.submit()">
                                                <c:forEach var="op" items="${allOperationalStatuses}">
                                                    <option value="${op.name()}" ${r.operationalStatus == op ? 'selected' : ''}>${op.displayName}</option>
                                                </c:forEach>
                                            </select>
                                        </form>
                                    </td>
                                    <td>
                                        <span class="badge ${r.housekeepingStatus.name() == 'CLEAN' ? 'bg-success-subtle text-success' : (r.housekeepingStatus.name() == 'DIRTY' ? 'bg-danger-subtle text-danger' : 'bg-warning-subtle text-warning')} border">
                                            ${r.housekeepingStatus.displayName}
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <a href="${pageContext.request.contextPath}/admin/rooms/edit?id=${r.id}" class="btn btn-outline-navy btn-sm py-1 px-2" style="font-size: 0.75rem;">
                                            <i class="bi bi-pencil me-1"></i>Edit
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

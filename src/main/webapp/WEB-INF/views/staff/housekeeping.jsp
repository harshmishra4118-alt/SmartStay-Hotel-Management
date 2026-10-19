<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Housekeeping Operations Board - AuraStay Staff"/>
</jsp:include>

<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Staff Sidebar -->
        <div class="col-lg-2 col-md-3">
            <jsp:include page="/WEB-INF/views/common/staff-sidebar.jsp" />
        </div>

        <!-- Main Content Area -->
        <div class="col-lg-10 col-md-9 bg-light min-vh-100 p-4">
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <div>
                    <h2 class="font-serif text-navy mb-1">Housekeeping Operations Board</h2>
                    <p class="text-secondary small mb-0">Track room cleaning, sanitization cycles, inspection readiness, and turn-down status.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Dashboard
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.updated == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Room housekeeping status updated successfully.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Filter Status Bar -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <form action="${pageContext.request.contextPath}/staff/housekeeping" method="GET" class="d-flex flex-wrap gap-2 align-items-center">
                    <span class="text-secondary small fw-bold text-uppercase me-2">Filter by Status:</span>
                    <a href="${pageContext.request.contextPath}/staff/housekeeping" class="btn btn-sm ${empty selectedStatus ? 'btn-navy' : 'btn-outline-secondary'}">
                        All Rooms
                    </a>
                    <c:forEach var="hk" items="${allStatuses}">
                        <a href="${pageContext.request.contextPath}/staff/housekeeping?status=${hk.name()}" class="btn btn-sm ${selectedStatus == hk.name() ? 'btn-navy' : 'btn-outline-secondary'}">
                            ${hk.displayName}
                        </a>
                    </c:forEach>
                </form>
            </div>

            <!-- Rooms Housekeeping Cards / Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th style="width: 100px;">Room #</th>
                                <th>Suite Details</th>
                                <th>Floor</th>
                                <th>Operational</th>
                                <th>Housekeeping Status</th>
                                <th class="text-end" style="width: 250px;">Update Cleanliness</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${rooms}">
                                <tr>
                                    <td>
                                        <span class="fs-5 fw-bold text-navy font-monospace">${r.roomNumber}</span>
                                    </td>
                                    <td>
                                        <strong class="text-navy">${r.name}</strong><br>
                                        <small class="text-muted">${r.roomType.displayName} &bull; ${r.bedType}</small>
                                    </td>
                                    <td>Floor ${r.floorNumber}</td>
                                    <td>
                                        <span class="badge ${r.operationalStatus.name() == 'AVAILABLE' ? 'bg-success' : (r.operationalStatus.name() == 'OCCUPIED' ? 'bg-primary' : 'bg-warning text-dark')}">
                                            ${r.operationalStatus.displayName}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.housekeepingStatus.name() == 'CLEAN'}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle fs-6 px-3 py-2">
                                                    <i class="bi bi-check2-circle me-1"></i>Clean & Ready
                                                </span>
                                            </c:when>
                                            <c:when test="${r.housekeepingStatus.name() == 'DIRTY'}">
                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle fs-6 px-3 py-2">
                                                    <i class="bi bi-exclamation-circle me-1"></i>Needs Cleaning
                                                </span>
                                            </c:when>
                                            <c:when test="${r.housekeepingStatus.name() == 'INSPECTING'}">
                                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle fs-6 px-3 py-2">
                                                    <i class="bi bi-search me-1"></i>Under Inspection
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary-subtle text-secondary border fs-6 px-3 py-2">
                                                    <i class="bi bi-tools me-1"></i>Out of Service
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <form action="${pageContext.request.contextPath}/staff/housekeeping" method="POST" class="d-inline-flex gap-1 justify-content-end">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                                            <input type="hidden" name="roomId" value="${r.id}">
                                            <select name="status" class="form-select form-select-sm" style="width: 140px;">
                                                <c:forEach var="opt" items="${allStatuses}">
                                                    <option value="${opt.name()}" ${r.housekeepingStatus == opt ? 'selected' : ''}>
                                                        ${opt.displayName}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <button type="submit" class="btn btn-navy btn-sm" title="Save Status">
                                                <i class="bi bi-check-lg"></i>
                                            </button>
                                        </form>
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

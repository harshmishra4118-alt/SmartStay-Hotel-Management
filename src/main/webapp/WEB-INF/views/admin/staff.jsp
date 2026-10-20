<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Staff & Shift Management - SmartStay Admin"/>
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
                    <h2 class="font-serif text-navy mb-1">Staff Roster & Shift Schedules</h2>
                    <p class="text-secondary small mb-0">Manage hotel personnel credentials, department allocations, and operational shifts.</p>
                </div>
                <button type="button" class="btn btn-gold btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#newStaffModal">
                    <i class="bi bi-person-plus-fill me-1"></i> Register New Staff
                </button>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.created == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> New staff employee account registered and assigned.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Staff Roster Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th>Employee Code</th>
                                <th>Full Name</th>
                                <th>Email Address</th>
                                <th>Contact Phone</th>
                                <th>Department</th>
                                <th>Shift Schedule</th>
                                <th>Hire Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${staffList}">
                                <tr>
                                    <td>
                                        <span class="badge bg-navy text-gold font-monospace px-2 py-1">${s.employeeCode}</span>
                                    </td>
                                    <td>
                                        <strong class="text-navy">${s.userFullName}</strong>
                                    </td>
                                    <td>${s.userEmail}</td>
                                    <td>${s.userPhone != null ? s.userPhone : '<span class="text-muted">N/A</span>'}</td>
                                    <td>
                                        <span class="badge bg-light text-navy border">${s.department.name()}</span>
                                    </td>
                                    <td>
                                        <span class="badge ${s.shift.name() == 'MORNING' ? 'bg-warning-subtle text-dark' : (s.shift.name() == 'EVENING' ? 'bg-info-subtle text-info' : 'bg-dark-subtle text-dark')}">
                                            ${s.shift.name()}
                                        </span>
                                    </td>
                                    <td>${s.hireDate}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- New Staff Modal -->
<div class="modal fade" id="newStaffModal" tabindex="-1" aria-labelledby="newStaffModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-navy text-white">
                <h5 class="modal-title font-serif" id="newStaffModalLabel"><i class="bi bi-person-badge text-gold me-2"></i>Register New Staff Member</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/staff" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}">
                <input type="hidden" name="action" value="create">

                <div class="modal-body p-4">
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Full Name</label>
                            <input type="text" name="fullName" class="form-control" placeholder="e.g. Vikram Sharma" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Work Email</label>
                            <input type="email" name="email" class="form-control" placeholder="vikram.sharma@SmartStay.com" required>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Contact Mobile</label>
                            <input type="tel" name="phone" class="form-control" placeholder="+91 98765 00000" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Initial Password</label>
                            <input type="password" name="password" class="form-control" minlength="8" required>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Employee Code</label>
                            <input type="text" name="employeeCode" class="form-control font-monospace" placeholder="EMP-104" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Department</label>
                            <select name="department" class="form-select" required>
                                <c:forEach var="d" items="${departments}">
                                    <option value="${d.name()}">${d.name()}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Shift Assignment</label>
                            <select name="shift" class="form-select" required>
                                <c:forEach var="sh" items="${shifts}">
                                    <option value="${sh.name()}">${sh.name()}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-gold px-4 py-2 fw-bold">Create Account</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

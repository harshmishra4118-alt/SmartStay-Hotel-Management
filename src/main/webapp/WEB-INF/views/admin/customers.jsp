<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Guest & Customer Directory - SmartStay Admin"/>
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
                    <h2 class="font-serif text-navy mb-1">Customer & Guest Directory</h2>
                    <p class="text-secondary small mb-0">Browse registered guests, review travel documents, and manage account statuses.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.updated == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Customer account status successfully updated.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Search & Filter Bar -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <form action="${pageContext.request.contextPath}/admin/customers" method="GET" class="row g-2 align-items-center">
                    <div class="col-md-6">
                        <input type="text" name="search" class="form-control form-control-sm" placeholder="Search by full name, email or phone number" value="${search}">
                    </div>
                    <div class="col-md-4">
                        <select name="status" class="form-select form-select-sm">
                            <option value="">-- All Customer Account Statuses --</option>
                            <c:forEach var="st" items="${allStatuses}">
                                <option value="${st.name()}" ${selectedStatus == st.name() ? 'selected' : ''}>${st.name()}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-1">
                        <button type="submit" class="btn btn-navy btn-sm w-100 fw-bold">Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Customers Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th># ID</th>
                                <th>Guest Full Name</th>
                                <th>Email Address</th>
                                <th>Phone Number</th>
                                <th>Registration Date</th>
                                <th>Account Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty customers}">
                                    <c:forEach var="c" items="${customers}">
                                        <tr>
                                            <td class="font-monospace text-muted">#${c.id}</td>
                                            <td>
                                                <strong class="text-navy">${c.fullName}</strong>
                                            </td>
                                            <td>${c.email}</td>
                                            <td>${c.phone != null ? c.phone : '<span class="text-muted fst-italic">Not provided</span>'}</td>
                                            <td>${c.createdAt}</td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/customers" method="POST" class="d-inline">
                                                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                                                    <input type="hidden" name="customerId" value="${c.id}">
                                                    <select name="status" class="form-select form-select-sm py-0 px-2" style="width: 120px; font-size: 0.75rem;" onchange="this.form.submit()">
                                                        <c:forEach var="st" items="${allStatuses}">
                                                            <option value="${st.name()}" ${c.status == st ? 'selected' : ''}>${st.name()}</option>
                                                        </c:forEach>
                                                    </select>
                                                </form>
                                            </td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/admin/customers?viewId=${c.id}" class="btn btn-outline-navy btn-sm py-1 px-2" style="font-size: 0.75rem;">
                                                    <i class="bi bi-eye me-1"></i>View Profile
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="text-center py-5 text-muted fst-italic">
                                            No customers found matching the search query.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
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

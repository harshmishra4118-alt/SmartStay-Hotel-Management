<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Reservations Master Ledger - SmartStay Staff"/>
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
                    <h2 class="font-serif text-navy mb-1">Front Desk Reservations</h2>
                    <p class="text-secondary small mb-0">Search guest records, track arrival schedules, and process front desk transactions.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/staff/check-in" class="btn btn-gold btn-sm fw-bold">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Check-In
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/check-out" class="btn btn-navy btn-sm fw-bold">
                        <i class="bi bi-box-arrow-right me-1"></i> Check-Out
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <!-- Filter & Search Bar -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <form action="${pageContext.request.contextPath}/staff/bookings" method="GET" class="row g-2 align-items-center">
                    <div class="col-md-4">
                        <input type="text" name="search" class="form-control form-control-sm" placeholder="Search reference, guest name or phone" value="${search}">
                    </div>
                    <div class="col-md-3">
                        <select name="status" class="form-select form-select-sm">
                            <option value="">-- All Booking Statuses --</option>
                            <c:forEach var="st" items="${allStatuses}">
                                <option value="${st.name()}" ${selectedStatus == st.name() ? 'selected' : ''}>${st.displayName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <input type="date" name="date" class="form-control form-control-sm" value="${selectedDate}">
                    </div>
                    <div class="col-md-2 d-flex gap-1">
                        <button type="submit" class="btn btn-navy btn-sm w-100 fw-bold">Filter</button>
                        <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary btn-sm" title="Reset Filters"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Bookings Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light small">
                            <tr>
                                <th>Booking Ref</th>
                                <th>Guest Details</th>
                                <th>Room Assigned</th>
                                <th>Check-In &bull; Check-Out</th>
                                <th>Total (₹)</th>
                                <th>Status</th>
                                <th class="text-end">Front Desk Actions</th>
                            </tr>
                        </thead>
                        <tbody class="small">
                            <c:choose>
                                <c:when test="${not empty bookings}">
                                    <c:forEach var="b" items="${bookings}">
                                        <tr>
                                            <td>
                                                <span class="font-monospace fw-bold text-navy">${b.bookingReference}</span>
                                                <small class="d-block text-muted">${b.createdAt}</small>
                                            </td>
                                            <td>
                                                <strong>${b.guestName}</strong>
                                                <small class="d-block text-secondary">${b.guestPhone}</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-navy border">Room #${b.roomNumber}</span>
                                                <small class="d-block text-muted text-truncate" style="max-width: 150px;">${b.roomName}</small>
                                            </td>
                                            <td>
                                                <span>${b.checkInDate} &rarr; ${b.checkOutDate}</span>
                                                <small class="d-block text-muted">(${b.totalNights} nights, ${b.numAdults + b.numChildren} guests)</small>
                                            </td>
                                            <td class="fw-bold">₹<fmt:formatNumber value="${b.totalAmount}" pattern="#,##0.00"/></td>
                                            <td>
                                                <span class="badge ${b.bookingStatus.name() == 'CONFIRMED' ? 'badge-confirmed' : (b.bookingStatus.name() == 'CHECKED_IN' ? 'badge-paid' : (b.bookingStatus.name() == 'CHECKED_OUT' ? 'bg-secondary' : 'badge-unpaid'))}">
                                                    ${b.bookingStatus.displayName}
                                                </span>
                                            </td>
                                            <td class="text-end">
                                                <c:if test="${b.bookingStatus.name() == 'CONFIRMED'}">
                                                    <a href="${pageContext.request.contextPath}/staff/check-in?ref=${b.bookingReference}" class="btn btn-gold btn-sm py-1 px-2 fw-bold" style="font-size: 0.75rem;">
                                                        Check-In
                                                    </a>
                                                </c:if>
                                                <c:if test="${b.bookingStatus.name() == 'CHECKED_IN'}">
                                                    <a href="${pageContext.request.contextPath}/staff/check-out?ref=${b.bookingReference}" class="btn btn-outline-navy btn-sm py-1 px-2 fw-bold" style="font-size: 0.75rem;">
                                                        Check-Out
                                                    </a>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/customer/invoice?bookingId=${b.id}" target="_blank" class="btn btn-outline-secondary btn-sm py-1 px-2" style="font-size: 0.75rem;" title="View Tax Invoice">
                                                    <i class="bi bi-receipt"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="text-center py-5 text-muted fst-italic">
                                            No reservations found matching the specified search criteria.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="card-footer bg-white border-top d-flex justify-content-between align-items-center py-2 px-3 small">
                        <span class="text-muted">Showing page ${currentPage} of ${totalPages} (${totalCount} total)</span>
                        <ul class="pagination pagination-sm mb-0">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/staff/bookings?page=${currentPage - 1}&status=${selectedStatus}&date=${selectedDate}&search=${search}">Previous</a>
                            </li>
                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/staff/bookings?page=${p}&status=${selectedStatus}&date=${selectedDate}&search=${search}">${p}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/staff/bookings?page=${currentPage + 1}&status=${selectedStatus}&date=${selectedDate}&search=${search}">Next</a>
                            </li>
                        </ul>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

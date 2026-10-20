<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="All Reservations & Bookings - SmartStay Admin"/>
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
                    <h2 class="font-serif text-navy mb-1">Master Reservations Ledger</h2>
                    <p class="text-secondary small mb-0">Oversee hotel bookings, handle administrative cancellations, and review guest folios.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/reports/export-csv" class="btn btn-outline-navy btn-sm">
                        <i class="bi bi-download me-1"></i> Export Master CSV
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.cancelled == 'true'}">
                <div class="alert alert-warning alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Reservation has been cancelled by administrator.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Search & Filters -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <form action="${pageContext.request.contextPath}/admin/bookings" method="GET" class="row g-2 align-items-center">
                    <div class="col-md-4">
                        <input type="text" name="search" class="form-control form-control-sm" placeholder="Search reference, guest name or phone" value="${search}">
                    </div>
                    <div class="col-md-3">
                        <select name="status" class="form-select form-select-sm">
                            <option value="">-- All Reservation Statuses --</option>
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
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-outline-secondary btn-sm" title="Clear Filters"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Master Bookings Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th>Booking Ref</th>
                                <th>Guest Details</th>
                                <th>Room Reserved</th>
                                <th>Stay Dates</th>
                                <th>Guests</th>
                                <th>Folio Total</th>
                                <th>Status</th>
                                <th class="text-end">Admin Controls</th>
                            </tr>
                        </thead>
                        <tbody>
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
                                                <small class="d-block text-secondary">${b.guestEmail} &bull; ${b.guestPhone}</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-navy border">Room #${b.roomNumber}</span>
                                                <small class="d-block text-muted text-truncate" style="max-width: 140px;">${b.roomName}</small>
                                            </td>
                                            <td>
                                                <span>${b.checkInDate} &rarr; ${b.checkOutDate}</span>
                                                <small class="d-block text-muted">(${b.totalNights} nights)</small>
                                            </td>
                                            <td>${b.numAdults} Ad, ${b.numChildren} Ch</td>
                                            <td class="fw-bold text-navy">₹<fmt:formatNumber value="${b.totalAmount}" pattern="#,##0.00"/></td>
                                            <td>
                                                <span class="badge ${b.bookingStatus.name() == 'CONFIRMED' ? 'badge-confirmed' : (b.bookingStatus.name() == 'CHECKED_IN' ? 'badge-paid' : (b.bookingStatus.name() == 'CHECKED_OUT' ? 'bg-secondary' : 'badge-unpaid'))}">
                                                    ${b.bookingStatus.displayName}
                                                </span>
                                            </td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/customer/invoice?bookingId=${b.id}" target="_blank" class="btn btn-outline-secondary btn-sm py-1 px-2" style="font-size: 0.75rem;" title="View Invoice">
                                                    <i class="bi bi-receipt"></i>
                                                </a>
                                                <c:if test="${b.bookingStatus.name() == 'CONFIRMED' || b.bookingStatus.name() == 'CHECKED_IN'}">
                                                    <button type="button" class="btn btn-outline-danger btn-sm py-1 px-2" style="font-size: 0.75rem;" data-bs-toggle="modal" data-bs-target="#cancelModal_${b.id}">
                                                        Cancel
                                                    </button>

                                                    <!-- Cancellation Modal -->
                                                    <div class="modal fade" id="cancelModal_${b.id}" tabindex="-1" aria-hidden="true">
                                                        <div class="modal-dialog modal-dialog-centered">
                                                            <div class="modal-content">
                                                                <div class="modal-header bg-danger text-white">
                                                                    <h6 class="modal-title font-serif">Administrative Cancellation</h6>
                                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <form action="${pageContext.request.contextPath}/admin/bookings" method="POST">
                                                                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                                                                    <input type="hidden" name="action" value="cancel">
                                                                    <input type="hidden" name="bookingId" value="${b.id}">

                                                                    <div class="modal-body text-start">
                                                                        <p class="small text-secondary">
                                                                            Are you sure you wish to cancel reservation <strong>${b.bookingReference}</strong> for guest <strong>${b.guestName}</strong>?
                                                                        </p>
                                                                        <div class="mb-3">
                                                                            <label class="form-label small fw-bold text-secondary">Administrative Justification</label>
                                                                            <input type="text" name="reason" class="form-control form-control-sm" placeholder="e.g. Guest requested emergency cancellation / Overbooking reconciliation" required>
                                                                        </div>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Dismiss</button>
                                                                        <button type="submit" class="btn btn-danger btn-sm fw-bold">Confirm Cancellation</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="8" class="text-center py-5 text-muted fst-italic">
                                            No reservations found in the master registry.
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
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/bookings?page=${currentPage - 1}&status=${selectedStatus}&date=${selectedDate}&search=${search}">Previous</a>
                            </li>
                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/bookings?page=${p}&status=${selectedStatus}&date=${selectedDate}&search=${search}">${p}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/bookings?page=${currentPage + 1}&status=${selectedStatus}&date=${selectedDate}&search=${search}">Next</a>
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

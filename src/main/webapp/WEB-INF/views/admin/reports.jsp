<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Financial Reports & Occupancy Analytics - SmartStay Admin"/>
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
                    <h2 class="font-serif text-navy mb-1">Financial & Occupancy Analytics</h2>
                    <p class="text-secondary small mb-0">Generate auditable financial ledgers, track monthly revenue distribution, and export formula-safe CSV reports.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/reports/export-csv" class="btn btn-gold btn-sm fw-bold">
                        <i class="bi bi-file-earmark-spreadsheet-fill me-1"></i> Download Bookings CSV
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <!-- KPI Row -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Gross Revenue Realized</small>
                        <h3 class="fw-bold text-navy mb-0 mt-1">₹<fmt:formatNumber value="${metrics.totalRevenue}" pattern="#,##0.00"/></h3>
                        <small class="text-success"><i class="bi bi-check-circle me-1"></i>Reconciled in database</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Occupancy Velocity</small>
                        <h3 class="fw-bold text-navy mb-0 mt-1">${metrics.occupancyRate}%</h3>
                        <small class="text-muted">${metrics.occupiedRoomsToday} of ${metrics.activeRooms} suites occupied</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Total Folios Recorded</small>
                        <h3 class="fw-bold text-navy mb-0 mt-1">${metrics.totalBookings}</h3>
                        <small class="text-secondary">${metrics.cancelledBookings} cancelled</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Active Stays in House</small>
                        <h3 class="fw-bold text-gold mb-0 mt-1">${metrics.checkedInBookings}</h3>
                        <small class="text-primary">${metrics.confirmedBookings} arriving</small>
                    </div>
                </div>
            </div>

            <!-- Monthly Revenue Breakdown Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white p-4 mb-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="font-serif text-navy mb-0"><i class="bi bi-calendar3 me-2 text-gold"></i>Monthly Revenue Distribution</h5>
                    <span class="badge bg-light text-navy border">INR (₹)</span>
                </div>
                <div class="table-responsive">
                    <table class="table table-bordered align-middle text-center mb-0">
                        <thead class="table-light small">
                            <tr>
                                <c:forEach var="entry" items="${monthlyRevenue}">
                                    <th>${entry.key}</th>
                                </c:forEach>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <c:forEach var="entry" items="${monthlyRevenue}">
                                    <td class="fw-bold text-navy py-3">
                                        ₹<fmt:formatNumber value="${entry.value}" pattern="#,##0"/>
                                    </td>
                                </c:forEach>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- CSV Export Documentation & Safety Note -->
            <div class="alert alert-secondary border-0 d-flex align-items-center gap-3 p-3 mb-4 rounded-3">
                <i class="bi bi-shield-check fs-2 text-success"></i>
                <div class="small">
                    <strong>Spreadsheet Formula Injection Defense Active:</strong> 
                    Our CSV export engine automatically sanitizes all guest text fields, prepending single quotes to protect Microsoft Excel and LibreOffice Calc users against CSV formula injection attacks (CWE-1236).
                </div>
            </div>

            <!-- Recent Ledger Sample -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <h6 class="font-serif text-navy fw-bold mb-0">
                        <i class="bi bi-table text-gold me-2"></i>Financial Ledger Sample (${bookings.size()} records)
                    </h6>
                    <a href="${pageContext.request.contextPath}/admin/reports/export-csv" class="btn btn-navy btn-sm py-1 px-2" style="font-size: 0.75rem;">
                        <i class="bi bi-download me-1"></i> Download Complete Dataset
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th>Booking Ref</th>
                                <th>Guest</th>
                                <th>Suite</th>
                                <th>Check-In &bull; Out</th>
                                <th>Nights</th>
                                <th>Room Charge</th>
                                <th>Taxes (12%)</th>
                                <th>Total Value</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${bookings}">
                                <tr>
                                    <td class="font-monospace fw-bold text-navy">${b.bookingReference}</td>
                                    <td>${b.guestName}</td>
                                    <td>Room #${b.roomNumber}</td>
                                    <td>${b.checkInDate} &rarr; ${b.checkOutDate}</td>
                                    <td>${b.totalNights}</td>
                                    <td>₹<fmt:formatNumber value="${b.baseAmount}" pattern="#,##0.00"/></td>
                                    <td>₹<fmt:formatNumber value="${b.taxAmount}" pattern="#,##0.00"/></td>
                                    <td class="fw-bold text-navy">₹<fmt:formatNumber value="${b.totalAmount}" pattern="#,##0.00"/></td>
                                    <td>
                                        <span class="badge ${b.bookingStatus.name() == 'CONFIRMED' ? 'badge-confirmed' : (b.bookingStatus.name() == 'CHECKED_IN' ? 'badge-paid' : 'badge-unpaid')}">
                                            ${b.bookingStatus.displayName}
                                        </span>
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

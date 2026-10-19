<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Executive Dashboard - AuraStay Luxury Suites"/>
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
                    <h2 class="font-serif text-navy mb-1">Executive Dashboard</h2>
                    <p class="text-secondary small mb-0">High-level financial performance, real-time occupancy, and operational governance.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-navy btn-sm">
                        <i class="bi bi-bar-chart-line me-1"></i> Full Analytics & Reports
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/reports/export-csv" class="btn btn-gold btn-sm fw-bold">
                        <i class="bi bi-download me-1"></i> Export CSV
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <!-- Metric Cards (6 KPI Grid) -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white h-100">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.7rem;">Total Revenue</small>
                        <h4 class="fw-bold text-navy mb-0 mt-1">₹<fmt:formatNumber value="${metrics.totalRevenue}" pattern="#,##0"/></h4>
                        <small class="text-success" style="font-size: 0.75rem;"><i class="bi bi-graph-up me-1"></i>All-time ledger</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white h-100">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.7rem;">Today's Revenue</small>
                        <h4 class="fw-bold text-gold mb-0 mt-1">₹<fmt:formatNumber value="${metrics.todayRevenue}" pattern="#,##0"/></h4>
                        <small class="text-muted" style="font-size: 0.75rem;"><i class="bi bi-calendar-check me-1"></i>Current business day</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white h-100">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.7rem;">Occupancy Rate</small>
                        <h4 class="fw-bold text-navy mb-0 mt-1">${metrics.occupancyRate}%</h4>
                        <div class="progress mt-2" style="height: 6px;">
                            <div class="progress-bar bg-gold" role="progressbar" style="width: ${metrics.occupancyRate}%;"></div>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white h-100">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.7rem;">Active Inventory</small>
                        <h4 class="fw-bold text-navy mb-0 mt-1">${metrics.activeRooms} / ${metrics.totalRooms}</h4>
                        <small class="text-secondary" style="font-size: 0.75rem;">${metrics.occupiedRoomsToday} suites occupied</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white h-100">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.7rem;">Total Bookings</small>
                        <h4 class="fw-bold text-navy mb-0 mt-1">${metrics.totalBookings}</h4>
                        <small class="text-primary" style="font-size: 0.75rem;">${metrics.confirmedBookings} confirmed</small>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white h-100">
                        <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.7rem;">Today's Arrivals</small>
                        <h4 class="fw-bold text-navy mb-0 mt-1">${metrics.todayArrivalsCount}</h4>
                        <small class="text-info" style="font-size: 0.75rem;">${metrics.todayDeparturesCount} departures due</small>
                    </div>
                </div>
            </div>

            <!-- Monthly Revenue Visualization & System Quick Actions -->
            <div class="row g-4 mb-4">
                <div class="col-xl-8">
                    <div class="card border-0 shadow-sm rounded-3 bg-white p-4 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h6 class="font-serif text-navy fw-bold mb-0">
                                <i class="bi bi-calendar-month text-gold me-2"></i>Monthly Revenue Performance (Current Year)
                            </h6>
                            <span class="badge bg-light text-navy border">Real-Time DB Aggregation</span>
                        </div>

                        <div class="row g-2 text-center">
                            <c:forEach var="entry" items="${monthlyRevenue}">
                                <div class="col-4 col-sm-3 col-md-2 mb-3">
                                    <div class="p-2 border rounded bg-light">
                                        <small class="text-secondary text-uppercase fw-bold d-block" style="font-size: 0.7rem;">${entry.key}</small>
                                        <span class="fw-bold text-navy small d-block mt-1">₹<fmt:formatNumber value="${entry.value}" pattern="#,##0"/></span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <div class="col-xl-4">
                    <div class="card border-0 shadow-sm rounded-3 bg-white p-4 h-100">
                        <h6 class="font-serif text-navy fw-bold mb-3">
                            <i class="bi bi-lightning-charge text-gold me-2"></i>Management Quick Actions
                        </h6>
                        <div class="d-grid gap-2">
                            <a href="${pageContext.request.contextPath}/admin/rooms/add" class="btn btn-outline-navy btn-sm text-start py-2">
                                <i class="bi bi-plus-circle text-gold me-2"></i> Add New Luxury Suite
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-outline-navy btn-sm text-start py-2">
                                <i class="bi bi-calendar-check text-gold me-2"></i> Manage Guest Reservations
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-outline-navy btn-sm text-start py-2">
                                <i class="bi bi-people text-gold me-2"></i> View Customer Profiles
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-outline-navy btn-sm text-start py-2">
                                <i class="bi bi-person-badge text-gold me-2"></i> Manage Staff & Shifts
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/feedback" class="btn btn-outline-navy btn-sm text-start py-2">
                                <i class="bi bi-star-half text-gold me-2"></i> Moderate Guest Feedback
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Bookings & Audit Trail -->
            <div class="row g-4">
                <!-- Recent Bookings -->
                <div class="col-xl-7">
                    <div class="card border-0 shadow-sm rounded-3 bg-white h-100">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h6 class="font-serif text-navy fw-bold mb-0">
                                <i class="bi bi-clock-history text-gold me-2"></i>Recent Guest Reservations
                            </h6>
                            <a href="${pageContext.request.contextPath}/admin/bookings" class="small text-gold text-decoration-none fw-semibold">View All</a>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0 small">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Ref &bull; Guest</th>
                                            <th>Suite</th>
                                            <th>Stay Dates</th>
                                            <th>Amount</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="b" items="${recentBookings}">
                                            <tr>
                                                <td>
                                                    <span class="font-monospace fw-bold text-navy d-block">${b.bookingReference}</span>
                                                    <span class="text-secondary">${b.guestName}</span>
                                                </td>
                                                <td>${b.roomName}</td>
                                                <td>${b.checkInDate}</td>
                                                <td class="fw-bold">₹<fmt:formatNumber value="${b.totalAmount}" pattern="#,##0"/></td>
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

                <!-- Recent Audit Trail -->
                <div class="col-xl-5">
                    <div class="card border-0 shadow-sm rounded-3 bg-white h-100">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h6 class="font-serif text-navy fw-bold mb-0">
                                <i class="bi bi-shield-check text-gold me-2"></i>System Security Audit Trail
                            </h6>
                            <a href="${pageContext.request.contextPath}/admin/audit-logs" class="small text-gold text-decoration-none fw-semibold">Full Logs</a>
                        </div>
                        <div class="card-body p-0">
                            <div class="list-group list-group-flush small">
                                <c:forEach var="log" items="${recentLogs}">
                                    <div class="list-group-item py-2 px-3">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="badge bg-navy text-gold" style="font-size: 0.65rem;">${log.action}</span>
                                            <small class="text-muted" style="font-size: 0.7rem;">${log.createdAt}</small>
                                        </div>
                                        <p class="mb-0 text-secondary mt-1 text-truncate" style="font-size: 0.8rem;">
                                            ${log.details}
                                        </p>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

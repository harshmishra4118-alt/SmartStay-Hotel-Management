<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Front Desk Operations Dashboard - AuraStay Luxury Suites"/>
</jsp:include>

<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Staff Sidebar -->
        <div class="col-lg-2 col-md-3">
            <jsp:include page="/WEB-INF/views/common/staff-sidebar.jsp" />
        </div>

        <!-- Main Content Area -->
        <div class="col-lg-10 col-md-9 bg-light min-vh-100 p-4">
            <!-- Header bar -->
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <div>
                    <h2 class="font-serif text-navy mb-1">Front Desk Terminal</h2>
                    <p class="text-secondary small mb-0">Daily arrivals, departures, room readiness, and guest check-in desk.</p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-navy text-gold px-3 py-2"><i class="bi bi-clock me-1"></i>Shift Active</span>
                    <a href="${pageContext.request.contextPath}/staff/check-in" class="btn btn-gold btn-sm fw-bold">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Express Check-In
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.checkInSuccess == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> <strong>Check-In Completed!</strong> Guest room key issued and booking marked as CHECKED_IN.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.checkOutSuccess == 'true'}">
                <div class="alert alert-info alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> <strong>Check-Out Completed!</strong> Stay marked as CHECKED_OUT and room assigned to Housekeeping as DIRTY.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Operational KPI Cards -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Today's Arrivals</small>
                                <h3 class="fw-bold text-navy mb-0 mt-1">${todayArrivals != null ? todayArrivals.size() : 0}</h3>
                            </div>
                            <div class="p-3 bg-primary-subtle text-primary rounded-circle">
                                <i class="bi bi-box-arrow-in-right fs-4"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Today's Departures</small>
                                <h3 class="fw-bold text-navy mb-0 mt-1">${todayDepartures != null ? todayDepartures.size() : 0}</h3>
                            </div>
                            <div class="p-3 bg-info-subtle text-info rounded-circle">
                                <i class="bi bi-box-arrow-right fs-4"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Clean & Ready</small>
                                <h3 class="fw-bold text-success mb-0 mt-1">${cleanRooms}</h3>
                            </div>
                            <div class="p-3 bg-success-subtle text-success rounded-circle">
                                <i class="bi bi-check2-circle fs-4"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-3 p-3 bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <small class="text-secondary text-uppercase fw-bold" style="font-size: 0.75rem;">Awaiting Housekeeping</small>
                                <h3 class="fw-bold text-danger mb-0 mt-1">${dirtyRooms}</h3>
                            </div>
                            <div class="p-3 bg-danger-subtle text-danger rounded-circle">
                                <i class="bi bi-stars fs-4"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Reservation Lookup Bar -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <form action="${pageContext.request.contextPath}/staff/bookings" method="GET" class="row g-2 align-items-center">
                    <div class="col-md-9">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Find reservation by Booking Reference (e.g. AURA-20261019-...) or Guest Name">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-navy w-100 fw-bold">
                            Search Front Desk
                        </button>
                    </div>
                </form>
            </div>

            <!-- Operational Queues: Arrivals & Departures Tables -->
            <div class="row g-4">
                <!-- Today's Arrivals Queue -->
                <div class="col-xl-6">
                    <div class="card border-0 shadow-sm rounded-3 bg-white h-100">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h6 class="font-serif text-navy fw-bold mb-0">
                                <i class="bi bi-box-arrow-in-right text-gold me-2"></i>Expected Arrivals Today
                            </h6>
                            <span class="badge bg-light text-navy border">${todayArrivals != null ? todayArrivals.size() : 0} Stays</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0 small">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Reference / Guest</th>
                                            <th>Room</th>
                                            <th>Nights</th>
                                            <th class="text-end">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty todayArrivals}">
                                                <c:forEach var="arr" items="${todayArrivals}">
                                                    <tr>
                                                        <td>
                                                            <span class="font-monospace fw-bold text-navy d-block">${arr.bookingReference}</span>
                                                            <span class="text-secondary">${arr.guestName}</span>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-light text-dark border">${arr.roomNumber}</span>
                                                            <small class="d-block text-muted text-truncate" style="max-width: 130px;">${arr.roomName}</small>
                                                        </td>
                                                        <td>${arr.totalNights} night(s)</td>
                                                        <td class="text-end">
                                                            <a href="${pageContext.request.contextPath}/staff/check-in?ref=${arr.bookingReference}" class="btn btn-gold btn-sm py-1 px-2 fw-bold" style="font-size: 0.75rem;">
                                                                Check-In
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="4" class="text-center py-4 text-muted fst-italic">
                                                        No expected arrivals scheduled for today.
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

                <!-- Today's Departures Queue -->
                <div class="col-xl-6">
                    <div class="card border-0 shadow-sm rounded-3 bg-white h-100">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h6 class="font-serif text-navy fw-bold mb-0">
                                <i class="bi bi-box-arrow-right text-info me-2"></i>Departures Due Today
                            </h6>
                            <span class="badge bg-light text-navy border">${todayDepartures != null ? todayDepartures.size() : 0} Stays</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0 small">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Reference / Guest</th>
                                            <th>Room</th>
                                            <th>Nights</th>
                                            <th class="text-end">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty todayDepartures}">
                                                <c:forEach var="dep" items="${todayDepartures}">
                                                    <tr>
                                                        <td>
                                                            <span class="font-monospace fw-bold text-navy d-block">${dep.bookingReference}</span>
                                                            <span class="text-secondary">${dep.guestName}</span>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-light text-dark border">${dep.roomNumber}</span>
                                                            <small class="d-block text-muted text-truncate" style="max-width: 130px;">${dep.roomName}</small>
                                                        </td>
                                                        <td>${dep.totalNights} night(s)</td>
                                                        <td class="text-end">
                                                            <a href="${pageContext.request.contextPath}/staff/check-out?ref=${dep.bookingReference}" class="btn btn-outline-navy btn-sm py-1 px-2 fw-bold" style="font-size: 0.75rem;">
                                                                Check-Out
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="4" class="text-center py-4 text-muted fst-italic">
                                                        No departures due today.
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
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

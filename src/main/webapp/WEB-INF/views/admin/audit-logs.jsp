<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="System Security Audit Trail - SmartStay Admin"/>
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
                    <h2 class="font-serif text-navy mb-1">Security & Administrative Audit Trail</h2>
                    <p class="text-secondary small mb-0">Immutable compliance logging of administrative actions, status updates, check-ins, and financial events.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <!-- Audit Trail Table -->
            <div class="card border-0 shadow-sm rounded-3 bg-white overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th style="width: 170px;">Timestamp</th>
                                <th>Actor (User)</th>
                                <th>Action Event</th>
                                <th>Target Entity</th>
                                <th>Event Details</th>
                                <th>Source IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty auditLogs}">
                                    <c:forEach var="log" items="${auditLogs}">
                                        <tr>
                                            <td class="font-monospace text-muted" style="font-size: 0.75rem;">
                                                ${log.createdAt}
                                            </td>
                                            <td>
                                                <strong class="text-navy">${not empty log.userFullName ? log.userFullName : 'System / Self'}</strong>
                                                <c:if test="${log.userId != null}">
                                                    <small class="d-block text-muted">ID: #${log.userId}</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="badge bg-navy text-gold font-monospace" style="font-size: 0.7rem;">
                                                    ${log.action}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-navy border">
                                                    ${log.entityType} ${not empty log.entityId ? '#' : ''}${log.entityId}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="text-secondary">${log.details}</span>
                                            </td>
                                            <td>
                                                <span class="font-monospace text-muted" style="font-size: 0.75rem;">${log.ipAddress}</span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted fst-italic">
                                            No audit trail records captured yet.
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

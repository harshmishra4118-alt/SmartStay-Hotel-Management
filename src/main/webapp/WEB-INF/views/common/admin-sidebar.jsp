<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="sidebar-navy">
    <div class="d-flex align-items-center gap-2 px-3 py-2 mb-4 border-bottom border-secondary">
        <i class="bi bi-shield-lock text-gold fs-4"></i>
        <div>
            <h6 class="mb-0 text-white font-serif">Executive Portal</h6>
            <small class="text-white-50" style="font-size: 0.7rem;">Admin Management</small>
        </div>
    </div>

    <div class="sidebar-heading">Analytics & Overview</div>
    <ul class="nav flex-column mb-3">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/admin/dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2"></i> Dashboard
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath.startsWith('/admin/reports') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/reports">
                <i class="bi bi-bar-chart-line"></i> Reports & CSV
            </a>
        </li>
    </ul>

    <div class="sidebar-heading">Hotel Operations</div>
    <ul class="nav flex-column mb-3">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath.startsWith('/admin/rooms') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/rooms">
                <i class="bi bi-door-open"></i> Room Inventory
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/admin/bookings' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/bookings">
                <i class="bi bi-calendar2-range"></i> Reservations
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath.startsWith('/admin/customers') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/customers">
                <i class="bi bi-people"></i> Guests & Profiles
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath.startsWith('/admin/staff') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/staff">
                <i class="bi bi-person-badge"></i> Staff & Shifts
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath.startsWith('/admin/feedback') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/feedback">
                <i class="bi bi-star-half"></i> Guest Feedback
            </a>
        </li>
    </ul>

    <div class="sidebar-heading">Governance & Security</div>
    <ul class="nav flex-column mb-4">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/admin/audit-logs' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/audit-logs">
                <i class="bi bi-journal-text"></i> Audit Trail
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/home" target="_blank">
                <i class="bi bi-box-arrow-up-right"></i> View Hotel Site
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-power"></i> Sign Out
            </a>
        </li>
    </ul>
</div>

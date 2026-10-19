<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="sidebar-navy">
    <div class="d-flex align-items-center gap-2 px-3 py-2 mb-4 border-bottom border-secondary">
        <i class="bi bi-building-gear text-gold fs-4"></i>
        <div>
            <h6 class="mb-0 text-white font-serif">Front Desk</h6>
            <small class="text-white-50" style="font-size: 0.7rem;">Staff Terminal</small>
        </div>
    </div>

    <div class="sidebar-heading">Daily Desk Operations</div>
    <ul class="nav flex-column mb-3">
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/staff/dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/dashboard">
                <i class="bi bi-grid"></i> Overview & Queue
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/staff/check-in' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/check-in">
                <i class="bi bi-box-arrow-in-right"></i> Guest Check-In
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/staff/check-out' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/check-out">
                <i class="bi bi-box-arrow-right"></i> Guest Check-Out
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/staff/housekeeping' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/housekeeping">
                <i class="bi bi-stars"></i> Housekeeping Board
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${pageContext.request.servletPath == '/staff/bookings' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/bookings">
                <i class="bi bi-search"></i> Find Reservation
            </a>
        </li>
    </ul>

    <div class="sidebar-heading">Quick Actions</div>
    <ul class="nav flex-column mb-4">
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/home" target="_blank">
                <i class="bi bi-box-arrow-up-right"></i> Hotel Public Portal
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-power"></i> Sign Out
            </a>
        </li>
    </ul>
</div>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar navbar-expand-lg navbar-dark navbar-luxury">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
            <i class="bi bi-gem text-gold"></i>
            <span>AuraStay</span> Suites
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/rooms">Rooms & Suites</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/rooms/recommend">
                        <i class="bi bi-stars text-gold me-1"></i>Smart Match
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/about">About Us</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/contact">Contact</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/faq">FAQ</a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-2">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <!-- Notifications link -->
                        <a href="${pageContext.request.contextPath}/customer/notifications" class="btn btn-sm btn-outline-secondary text-white position-relative border-0" title="Notifications">
                            <i class="bi bi-bell fs-5"></i>
                        </a>

                        <!-- User Profile Dropdown -->
                        <div class="dropdown">
                            <button class="btn btn-outline-light dropdown-toggle d-flex align-items-center gap-2 py-1 px-3" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-person-circle text-gold"></i>
                                <span class="d-none d-md-inline" style="max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                    ${sessionScope.currentUser.fullName}
                                </span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                                <li class="px-3 py-1">
                                    <small class="text-muted d-block">Signed in as</small>
                                    <strong class="d-block text-truncate" style="max-width: 180px;">${sessionScope.currentUser.email}</strong>
                                    <span class="badge bg-gold text-dark mt-1" style="font-size: 0.7rem;">${sessionScope.currentUser.role}</span>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/my-bookings"><i class="bi bi-calendar2-check me-2 text-primary"></i>My Bookings</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile"><i class="bi bi-person-badge me-2 text-secondary"></i>Profile & Security</a></li>
                                
                                <c:if test="${sessionScope.currentUser.staff || sessionScope.currentUser.admin}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li><h6 class="dropdown-header text-uppercase" style="font-size: 0.7rem;">Operations</h6></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/staff/dashboard"><i class="bi bi-building-gear me-2 text-info"></i>Staff Desk</a></li>
                                </c:if>

                                <c:if test="${sessionScope.currentUser.admin}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2 me-2 text-danger"></i>Admin Portal</a></li>
                                </c:if>

                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm px-3">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Sign In
                        </a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-gold btn-sm px-3">
                            Register
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>

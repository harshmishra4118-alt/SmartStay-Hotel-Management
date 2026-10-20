<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Create Account - SmartStay Hotel"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container my-5 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">
            <div class="bg-white p-4 p-md-5 rounded-3 shadow border">
                <div class="text-center mb-4">
                    <i class="bi bi-person-plus text-gold display-6 mb-2 d-inline-block"></i>
                    <h3 class="font-serif text-navy mb-1">Join SmartStay</h3>
                    <p class="text-muted small">Create your complimentary guest account for effortless booking</p>
                </div>

                <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                <form action="${pageContext.request.contextPath}/register" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-secondary">Full Name</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light text-muted"><i class="bi bi-person"></i></span>
                            <input type="text" name="fullName" class="form-control" required placeholder="e.g. Johnathan Doe" value="<c:out value="${fullName}"/>">
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                                <input type="email" name="email" class="form-control" required placeholder="guest@example.com" value="<c:out value="${email}"/>">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Phone Number</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-telephone"></i></span>
                                <input type="tel" name="phone" class="form-control" required placeholder="+91 98765 43210" value="<c:out value="${phone}"/>">
                            </div>
                        </div>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Password (Min 6 Chars)</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" class="form-control" required placeholder="Create password">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Confirm Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-lock-fill"></i></span>
                                <input type="password" name="confirmPassword" class="form-control" required placeholder="Repeat password">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-gold w-100 py-2 fw-semibold mb-3">
                        <i class="bi bi-check2-circle me-2"></i>Create Guest Account
                    </button>
                </form>

                <div class="text-center small text-muted border-top pt-3">
                    Already a registered member? 
                    <a href="${pageContext.request.contextPath}/login" class="text-navy fw-bold text-decoration-none">Sign In Here</a>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

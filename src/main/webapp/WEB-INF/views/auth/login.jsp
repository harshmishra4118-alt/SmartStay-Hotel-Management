<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Sign In - AuraStay Luxury Suites"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container my-5 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-5 col-md-7">
            <div class="bg-white p-4 p-md-5 rounded-3 shadow border">
                <div class="text-center mb-4">
                    <i class="bi bi-gem text-gold display-6 mb-2 d-inline-block"></i>
                    <h3 class="font-serif text-navy mb-1">Welcome Back</h3>
                    <p class="text-muted small">Sign in to your AuraStay guest or staff account</p>
                </div>

                <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                <c:if test="${param.loggedOut == 'true'}">
                    <div class="alert alert-info alert-dismissible fade show small" role="alert">
                        <i class="bi bi-info-circle me-1"></i> You have been securely signed out.
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <input type="hidden" name="redirect" value="<c:out value="${redirect}"/>">

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-secondary">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                            <input type="email" name="email" id="loginEmail" class="form-control" required 
                                   placeholder="e.g. guest@example.com" value="<c:out value="${email}"/>">
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label class="form-label small fw-bold text-uppercase text-secondary mb-0">Password</label>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                            <input type="password" name="password" id="loginPassword" class="form-control" required placeholder="Enter your password">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-navy w-100 py-2 fw-semibold mb-3">
                        <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
                    </button>
                </form>

                <div class="text-center small text-muted border-top pt-3">
                    Don't have an account yet? 
                    <a href="${pageContext.request.contextPath}/register" class="text-gold fw-bold text-decoration-none">Create Guest Account</a>
                </div>

                <!-- Academic Demo Accounts Quick Helper -->
                <div class="mt-4 p-3 bg-light rounded border text-start">
                    <span class="badge bg-navy text-gold mb-2 text-uppercase" style="font-size: 0.65rem;">Demo Credentials</span>
                    <div class="d-flex flex-column gap-1 small text-muted" style="font-size: 0.75rem;">
                        <div>
                            <strong>Admin:</strong> 
                            <a href="javascript:void(0)" onclick="fillCreds('admin@aurastay.com', 'Admin@123')" class="text-primary text-decoration-none">admin@aurastay.com</a> / <code>Admin@123</code>
                        </div>
                        <div>
                            <strong>Staff:</strong> 
                            <a href="javascript:void(0)" onclick="fillCreds('frontdesk@aurastay.com', 'Staff@123')" class="text-primary text-decoration-none">frontdesk@aurastay.com</a> / <code>Staff@123</code>
                        </div>
                        <div>
                            <strong>Customer:</strong> 
                            <a href="javascript:void(0)" onclick="fillCreds('john.doe@example.com', 'Customer@123')" class="text-primary text-decoration-none">john.doe@example.com</a> / <code>Customer@123</code>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function fillCreds(email, pass) {
        document.getElementById('loginEmail').value = email;
        document.getElementById('loginPassword').value = pass;
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <jsp:include page="/WEB-INF/views/common/header.jsp">
            <jsp:param name="pageTitle" value="Sign In - SmartStay Hotel" />
        </jsp:include>
        <jsp:include page="/WEB-INF/views/common/navbar.jsp" />

        <div class="container my-5 py-4">
            <div class="row justify-content-center">
                <div class="col-lg-5 col-md-7">
                    <div class="bg-white p-4 p-md-5 rounded-3 shadow border">
                        <div class="text-center mb-4">
                            <i class="bi bi-building text-gold display-6 mb-2 d-inline-block"></i>
                            <h3 class="font-serif text-navy mb-1">Welcome Back</h3>
                            <p class="text-muted small">Sign in to your SmartStay guest, staff, or admin account</p>
                        </div>

                        <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                        <c:if test="${param.loggedOut == 'true'}">
                            <div class="alert alert-info alert-dismissible fade show small" role="alert">
                                <i class="bi bi-info-circle me-1"></i> You have been securely signed out.
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/login" method="POST">
                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                            <input type="hidden" name="redirect" value="<c:out value='${redirect}' />">

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-uppercase text-secondary">Email
                                    Address</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i
                                            class="bi bi-envelope"></i></span>
                                    <input type="email" name="email" id="loginEmail" class="form-control" required
                                        placeholder="e.g. guest@example.com" value="<c:out value='${email}' />">
                                </div>
                            </div>

                            <div class="mb-4">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <label
                                        class="form-label small fw-bold text-uppercase text-secondary mb-0">Password</label>
                                </div>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                                    <input type="password" name="password" id="loginPassword" class="form-control"
                                        required placeholder="Enter your password">
                                    <button class="btn btn-outline-secondary" type="button" id="togglePasswordBtn"
                                        onclick="togglePasswordVisibility('loginPassword', this)">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-navy w-100 py-2 fw-semibold mb-3">
                                <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
                            </button>
                        </form>

                        <div class="text-center small text-muted border-top pt-3">
                            Don't have an account yet?
                            <a href="${pageContext.request.contextPath}/register"
                                class="text-gold fw-bold text-decoration-none">Create Guest Account</a>
                        </div>

                        <!-- Seeded Demo Accounts Quick Helper -->
                        <div class="mt-4 p-3 bg-light rounded border text-start">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge bg-navy text-gold text-uppercase" style="font-size: 0.65rem;">1-Click
                                    Demo Evaluation Logins</span>
                                <small class="text-muted" style="font-size: 0.7rem;">Click any role to auto-fill
                                    credentials</small>
                            </div>
                            <div class="d-flex flex-column gap-2 small text-muted" style="font-size: 0.75rem;">
                                <div
                                    class="d-flex justify-content-between align-items-center p-1 rounded bg-white border">
                                    <div>
                                        <strong class="text-navy">Super Admin:</strong>
                                        <code>admin@smartstay.com</code> <span
                                            class="badge bg-secondary ms-1">admin123</span>
                                    </div>
                                    <button type="button" onclick="fillAccount('admin@smartstay.com', 'admin123')"
                                        class="btn btn-sm btn-outline-navy py-0 px-2" style="font-size: 0.7rem;">Auto
                                        Fill</button>
                                </div>
                                <div
                                    class="d-flex justify-content-between align-items-center p-1 rounded bg-white border">
                                    <div>
                                        <strong class="text-navy">Hotel Owner:</strong>
                                        <code>owner@smartstay.com</code> <span
                                            class="badge bg-secondary ms-1">owner123</span>
                                    </div>
                                    <button type="button" onclick="fillAccount('owner@smartstay.com', 'owner123')"
                                        class="btn btn-sm btn-outline-navy py-0 px-2" style="font-size: 0.7rem;">Auto
                                        Fill</button>
                                </div>
                                <div
                                    class="d-flex justify-content-between align-items-center p-1 rounded bg-white border">
                                    <div>
                                        <strong class="text-navy">Front Desk Staff:</strong>
                                        <code>frontdesk@smartstay.com</code> <span
                                            class="badge bg-secondary ms-1">staff123</span>
                                    </div>
                                    <button type="button" onclick="fillAccount('frontdesk@smartstay.com', 'staff123')"
                                        class="btn btn-sm btn-outline-navy py-0 px-2" style="font-size: 0.7rem;">Auto
                                        Fill</button>
                                </div>
                                <div
                                    class="d-flex justify-content-between align-items-center p-1 rounded bg-white border">
                                    <div>
                                        <strong class="text-navy">Housekeeping Staff:</strong>
                                        <code>housekeeping@smartstay.com</code> <span
                                            class="badge bg-secondary ms-1">staff123</span>
                                    </div>
                                    <button type="button"
                                        onclick="fillAccount('housekeeping@smartstay.com', 'staff123')"
                                        class="btn btn-sm btn-outline-navy py-0 px-2" style="font-size: 0.7rem;">Auto
                                        Fill</button>
                                </div>
                                <div
                                    class="d-flex justify-content-between align-items-center p-1 rounded bg-white border">
                                    <div>
                                        <strong class="text-navy">Customer / Guest:</strong>
                                        <code>john.doe@example.com</code> <span
                                            class="badge bg-secondary ms-1">customer123</span>
                                    </div>
                                    <button type="button" onclick="fillAccount('john.doe@example.com', 'customer123')"
                                        class="btn btn-sm btn-outline-gold text-dark py-0 px-2"
                                        style="font-size: 0.7rem;">Auto Fill</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function fillAccount(email, password) {
                var emailInput = document.getElementById('loginEmail');
                var passInput = document.getElementById('loginPassword');
                if (emailInput) {
                    emailInput.value = email;
                }
                if (passInput && password) {
                    passInput.value = password;
                }
            }

            function togglePasswordVisibility(fieldId, btn) {
                var field = document.getElementById(fieldId);
                if (!field) return;
                var icon = btn.querySelector('i');
                if (field.type === 'password') {
                    field.type = 'text';
                    if (icon) {
                        icon.classList.remove('bi-eye');
                        icon.classList.add('bi-eye-slash');
                    }
                } else {
                    field.type = 'password';
                    if (icon) {
                        icon.classList.remove('bi-eye-slash');
                        icon.classList.add('bi-eye');
                    }
                }
            }
        </script>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
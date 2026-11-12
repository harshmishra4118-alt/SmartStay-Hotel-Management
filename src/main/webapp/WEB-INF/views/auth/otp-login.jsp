<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Passwordless OTP Login - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100 d-flex align-items-center">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card border-0 shadow-lg rounded-4 overflow-hidden">
                    <!-- Card Header -->
                    <div class="bg-navy p-4 text-center text-white position-relative">
                        <div class="mb-2">
                            <i class="bi bi-shield-check text-gold fs-1"></i>
                        </div>
                        <h3 class="font-serif text-white mb-1">Passwordless Sign In</h3>
                        <p class="text-light small mb-0">Secure 6-digit verification code sent to your Gmail / Email</p>
                    </div>

                    <div class="card-body p-4 p-md-5">
                        <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                        <c:choose>
                            <c:when test="${otpSent}">
                                <!-- Step 2: Enter 6-digit code -->
                                <form action="${pageContext.request.contextPath}/otp-login" method="POST">
                                    <input type="hidden" name="action" value="verify" />
                                    <input type="hidden" name="email" value="${email}" />
                                    <input type="hidden" name="type" value="LOGIN" />

                                    <div class="text-center mb-4">
                                        <p class="small text-muted mb-1">We sent a verification code to:</p>
                                        <strong class="text-navy">${email}</strong>
                                    </div>

                                    <div class="mb-4 text-center">
                                        <label class="form-label small fw-bold text-navy">Enter 6-Digit Code</label>
                                        <input type="text" name="code" class="form-control form-control-lg text-center font-monospace tracking-wider fw-bold fs-3" 
                                               maxlength="6" placeholder="000000" pattern="[0-9]{6}" required autofocus />
                                    </div>

                                    <button type="submit" class="btn btn-navy w-100 py-3 fw-bold mb-3 shadow-sm">
                                        <i class="bi bi-box-arrow-in-right me-2 text-gold"></i>Verify Code & Sign In
                                    </button>

                                    <!-- Countdown and Resend -->
                                    <div class="text-center small">
                                        <span id="countdownText" class="text-muted">Resend available in <span id="timer" class="fw-bold text-navy">60</span>s</span>
                                        <button type="button" id="btnResend" class="btn btn-link btn-sm text-gold fw-bold d-none p-0 text-decoration-none">
                                            Resend OTP Code
                                        </button>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <!-- Step 1: Enter Email -->
                                <form action="${pageContext.request.contextPath}/otp-login" method="POST">
                                    <input type="hidden" name="action" value="send" />
                                    <input type="hidden" name="type" value="LOGIN" />

                                    <div class="mb-4">
                                        <label class="form-label small fw-bold text-navy">Registered Email Address</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-white"><i class="bi bi-envelope text-muted"></i></span>
                                            <input type="email" name="email" class="form-control form-control-lg" placeholder="name@example.com" value="${email}" required autofocus />
                                        </div>
                                    </div>

                                    <button type="submit" class="btn btn-navy w-100 py-3 fw-bold mb-3 shadow-sm">
                                        <i class="bi bi-send-check me-2 text-gold"></i>Send Verification Code
                                    </button>

                                    <!-- Demo helpers -->
                                    <div class="border-top pt-3 text-center">
                                        <small class="text-muted d-block mb-2">Quick Demo Accounts:</small>
                                        <div class="d-flex justify-content-center gap-2">
                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="document.querySelector('input[name=email]').value='john.doe@example.com'">
                                                Guest John
                                            </button>
                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="document.querySelector('input[name=email]').value='sophia.miller@example.com'">
                                                Guest Sophia
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </c:otherwise>
                        </c:choose>

                        <div class="text-center mt-4 pt-3 border-top small">
                            <span class="text-muted">Prefer password login?</span>
                            <a href="${pageContext.request.contextPath}/login" class="text-navy fw-bold text-decoration-none ms-1">Password Sign In</a>
                            <br />
                            <span class="text-muted">Don't have an account?</span>
                            <a href="${pageContext.request.contextPath}/otp-register" class="text-gold fw-bold text-decoration-none ms-1">Register with OTP</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    let timeLeft = parseInt('${cooldownSeconds}') || 60;
    const timerElem = document.getElementById('timer');
    const countdownElem = document.getElementById('countdownText');
    const btnResend = document.getElementById('btnResend');

    if (timerElem && countdownElem && btnResend) {
        const interval = setInterval(function() {
            timeLeft--;
            timerElem.innerText = timeLeft;
            if (timeLeft <= 0) {
                clearInterval(interval);
                countdownElem.classList.add('d-none');
                btnResend.classList.remove('d-none');
            }
        }, 1000);

        btnResend.addEventListener('click', function() {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/otp-login';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'send';
            form.appendChild(actionInput);

            const emailInput = document.createElement('input');
            emailInput.type = 'hidden';
            emailInput.name = 'email';
            emailInput.value = '${email}';
            form.appendChild(emailInput);

            document.body.appendChild(form);
            form.submit();
        });
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


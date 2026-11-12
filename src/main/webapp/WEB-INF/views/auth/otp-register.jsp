<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Register with OTP - SmartStay" />
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100 d-flex align-items-center">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card border-0 shadow-lg rounded-4 overflow-hidden">
                    <div class="bg-navy p-4 text-center text-white">
                        <i class="bi bi-person-check text-gold fs-1 mb-2 d-block"></i>
                        <h3 class="font-serif text-white mb-1">Create Guest Account</h3>
                        <p class="text-light small mb-0">Instant verification via secure Gmail / Email OTP</p>
                    </div>

                    <div class="card-body p-4 p-md-5">
                        <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                        <c:choose>
                            <c:when test="${otpSent}">
                                <form action="${pageContext.request.contextPath}/otp-register" method="POST">
                                    <input type="hidden" name="action" value="verify" />
                                    <input type="hidden" name="email" value="${email}" />
                                    <input type="hidden" name="type" value="REGISTRATION" />

                                    <div class="text-center mb-4">
                                        <p class="small text-muted mb-1">We sent a verification code to:</p>
                                        <strong class="text-navy">${email}</strong>
                                    </div>

                                    <div class="mb-4 text-center">
                                        <label class="form-label small fw-bold text-navy">Enter 6-Digit Code</label>
                                        <input type="text" name="code" class="form-control form-control-lg text-center font-monospace tracking-wider fw-bold fs-3" 
                                               maxlength="6" placeholder="000000" pattern="[0-9]{6}" required autofocus />
                                    </div>

                                    <button type="submit" class="btn btn-gold text-dark w-100 py-3 fw-bold mb-3 shadow-sm">
                                        <i class="bi bi-check-circle-fill me-2"></i>Verify & Create Account
                                    </button>

                                    <div class="text-center small">
                                        <span id="countdownText" class="text-muted">Resend code in <span id="timer" class="fw-bold text-navy">60</span>s</span>
                                        <a href="${pageContext.request.contextPath}/otp-register" id="btnResend" class="text-gold fw-bold d-none text-decoration-none">
                                            Start Over
                                        </a>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/otp-register" method="POST">
                                    <input type="hidden" name="action" value="send" />
                                    <input type="hidden" name="type" value="REGISTRATION" />

                                    <div class="mb-3">
                                        <label class="form-label small fw-bold text-navy">Full Name</label>
                                        <input type="text" name="fullName" class="form-control" placeholder="Aarav Sharma" value="${fullName}" required autofocus />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label small fw-bold text-navy">Phone Number</label>
                                        <input type="tel" name="phone" class="form-control" placeholder="+91 98765 43210" value="${phone}" required />
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label small fw-bold text-navy">Email Address</label>
                                        <input type="email" name="email" class="form-control" placeholder="name@example.com" value="${email}" required />
                                    </div>

                                    <button type="submit" class="btn btn-navy w-100 py-3 fw-bold mb-3 shadow-sm">
                                        <i class="bi bi-send-check me-2 text-gold"></i>Send Verification Code
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>

                        <div class="text-center mt-4 pt-3 border-top small">
                            <span class="text-muted">Already registered?</span>
                            <a href="${pageContext.request.contextPath}/otp-login" class="text-navy fw-bold text-decoration-none ms-1">OTP Login</a>
                            <span class="mx-1">•</span>
                            <a href="${pageContext.request.contextPath}/login" class="text-secondary text-decoration-none">Password Login</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
    let timeLeft = 60;
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
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


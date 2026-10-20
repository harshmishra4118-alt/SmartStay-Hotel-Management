<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="System Error - SmartStay"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container py-5 my-5 text-center">
    <div class="py-5">
        <i class="bi bi-shield-exclamation text-danger" style="font-size: 4.5rem;"></i>
        <h1 class="display-4 font-serif text-navy mt-3">Unexpected System Disturbance</h1>
        <p class="text-secondary lead mx-auto" style="max-width: 580px;">
            An unexpected error occurred while processing your request. Our technical operations 
            team has logged the incident for immediate review.
        </p>
        <div class="mt-4 d-flex justify-content-center gap-3">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-navy">
                <i class="bi bi-house-door me-2"></i>Return to Home
            </a>
            <a href="${pageContext.request.contextPath}/contact" class="btn btn-outline-secondary">
                <i class="bi bi-headset me-2"></i>Contact Concierge Desk
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

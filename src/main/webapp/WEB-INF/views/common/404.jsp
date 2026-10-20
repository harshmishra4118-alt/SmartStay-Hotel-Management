<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Page Not Found - SmartStay"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container py-5 my-5 text-center">
    <div class="py-5">
        <i class="bi bi-compass text-gold" style="font-size: 4.5rem;"></i>
        <h1 class="display-4 font-serif text-navy mt-3">404 - Sanctuary Not Found</h1>
        <p class="text-secondary lead mx-auto" style="max-width: 550px;">
            The luxury suite or destination you are searching for does not exist or has been moved. 
            Allow our virtual concierge to guide you back.
        </p>
        <div class="mt-4 d-flex justify-content-center gap-3">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-navy">
                <i class="bi bi-house-door me-2"></i>Return Home
            </a>
            <a href="${pageContext.request.contextPath}/rooms" class="btn btn-gold">
                <i class="bi bi-door-open me-2"></i>Explore Suites
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

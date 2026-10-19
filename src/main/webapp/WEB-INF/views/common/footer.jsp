<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<footer class="bg-navy text-light mt-auto pt-5 pb-4 border-top border-secondary">
    <div class="container">
        <div class="row g-4">
            <!-- Col 1: Brand & Bio -->
            <div class="col-lg-4 col-md-6">
                <h5 class="font-serif text-white mb-3">
                    <i class="bi bi-gem text-gold me-2"></i>AuraStay Suites & Resort
                </h5>
                <p class="text-secondary small mb-3">
                    A refined sanctuary where timeless architectural elegance meets modern smart hospitality. 
                    Crafted to provide unforgettable leisure and executive business stays.
                </p>
                <div class="d-flex gap-3 fs-5">
                    <a href="#" class="text-gold" aria-label="Instagram"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="text-gold" aria-label="Facebook"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="text-gold" aria-label="LinkedIn"><i class="bi bi-linkedin"></i></a>
                    <a href="#" class="text-gold" aria-label="Twitter"><i class="bi bi-twitter-x"></i></a>
                </div>
            </div>

            <!-- Col 2: Quick Links -->
            <div class="col-lg-2 col-md-6">
                <h6 class="text-gold text-uppercase tracking-wider small fw-bold mb-3">Explore</h6>
                <ul class="list-unstyled small d-flex flex-column gap-2 mb-0">
                    <li><a href="${pageContext.request.contextPath}/rooms" class="text-decoration-none text-light opacity-75 hover-opacity-100">Rooms & Suites</a></li>
                    <li><a href="${pageContext.request.contextPath}/rooms/recommend" class="text-decoration-none text-light opacity-75 hover-opacity-100">Smart Recommendation</a></li>
                    <li><a href="${pageContext.request.contextPath}/about" class="text-decoration-none text-light opacity-75 hover-opacity-100">Our Heritage</a></li>
                    <li><a href="${pageContext.request.contextPath}/faq" class="text-decoration-none text-light opacity-75 hover-opacity-100">FAQ & Concierge</a></li>
                </ul>
            </div>

            <!-- Col 3: Policies & Support -->
            <div class="col-lg-3 col-md-6">
                <h6 class="text-gold text-uppercase tracking-wider small fw-bold mb-3">Policies & Security</h6>
                <ul class="list-unstyled small d-flex flex-column gap-2 mb-0">
                    <li><a href="${pageContext.request.contextPath}/policies#cancellation" class="text-decoration-none text-light opacity-75 hover-opacity-100">Cancellation Policy</a></li>
                    <li><a href="${pageContext.request.contextPath}/policies#checkin" class="text-decoration-none text-light opacity-75 hover-opacity-100">Check-In / Out Times</a></li>
                    <li><a href="${pageContext.request.contextPath}/policies#privacy" class="text-decoration-none text-light opacity-75 hover-opacity-100">Privacy & Data Protection</a></li>
                    <li><a href="${pageContext.request.contextPath}/policies#demo" class="text-decoration-none text-light opacity-75 hover-opacity-100">Demo Payments Notice</a></li>
                </ul>
            </div>

            <!-- Col 4: Contact & Concierge -->
            <div class="col-lg-3 col-md-6">
                <h6 class="text-gold text-uppercase tracking-wider small fw-bold mb-3">Concierge Desk</h6>
                <p class="small text-secondary mb-1">
                    <i class="bi bi-geo-alt-fill text-gold me-2"></i>7 Royal Palms Boulevard, Marina Bay
                </p>
                <p class="small text-secondary mb-1">
                    <i class="bi bi-telephone-fill text-gold me-2"></i>+91 (022) 8900 1200
                </p>
                <p class="small text-secondary mb-3">
                    <i class="bi bi-envelope-fill text-gold me-2"></i>concierge@aurastay.com
                </p>
                <span class="badge bg-navy-secondary text-gold border border-secondary px-3 py-2" style="font-size: 0.75rem;">
                    <i class="bi bi-clock-history me-1"></i>24/7 Front Desk Active
                </span>
            </div>
        </div>

        <hr class="border-secondary my-4 opacity-25">

        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center small text-secondary">
            <p class="mb-0">&copy; <%= java.time.LocalDate.now().getYear() %> AuraStay Luxury Suites & Resort. All rights reserved.</p>
            <p class="mb-0">Built with Java 17, Jakarta Servlets, JSP & MySQL.</p>
        </div>
    </div>
</footer>

<!-- Include Chatbot Widget -->
<jsp:include page="/WEB-INF/views/common/chatbot-widget.jsp" />

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Custom Main JS -->
<script src="${pageContext.request.contextPath}/assets/js/hotel-main.js"></script>
</body>
</html>

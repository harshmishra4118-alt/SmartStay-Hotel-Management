<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Contact Concierge - SmartStay Hotel"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-5 text-white">
    <div class="container text-center">
        <span class="text-gold text-uppercase small fw-bold tracking-wider">Connect With Us</span>
        <h1 class="font-serif display-5 mt-1">Concierge & Inquiries</h1>
        <p class="text-light opacity-75 mx-auto mb-0" style="max-width: 600px;">
            Our dedicated hospitality team is available 24/7 to assist with reservations, event bookings, and bespoke requests.
        </p>
    </div>
</div>

<div class="container my-5">
    <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

    <div class="row g-5">
        <!-- Contact Form -->
        <div class="col-lg-7">
            <div class="bg-white p-4 p-md-5 rounded-3 shadow-sm border">
                <h3 class="font-serif text-navy mb-2">Send a Message</h3>
                <p class="text-muted small mb-4">Please submit your inquiry and a concierge manager will respond within 4 hours.</p>

                <form action="${pageContext.request.contextPath}/contact" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Your Name</label>
                            <input type="text" name="name" class="form-control" required placeholder="e.g. Johnathan Doe">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Email Address</label>
                            <input type="email" name="email" class="form-control" required placeholder="e.g. guest@example.com">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-secondary">Subject</label>
                        <input type="text" name="subject" class="form-control" required placeholder="e.g. Private Dining Inquiry or Suite Availability">
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-uppercase text-secondary">Message</label>
                        <textarea name="message" class="form-control" rows="5" required placeholder="How may our concierge desk assist your stay?"></textarea>
                    </div>
                    <button type="submit" class="btn btn-gold px-4 py-2">
                        <i class="bi bi-send-fill me-2"></i>Send Message
                    </button>
                </form>
            </div>
        </div>

        <!-- Contact Cards -->
        <div class="col-lg-5">
            <div class="d-flex flex-column gap-4">
                <div class="p-4 bg-white rounded-3 shadow-sm border">
                    <div class="d-flex align-items-start gap-3">
                        <div class="kpi-icon bg-navy text-gold flex-shrink-0">
                            <i class="bi bi-geo-alt-fill"></i>
                        </div>
                        <div>
                            <h5 class="font-serif text-navy mb-1">Our Location</h5>
                            <p class="text-muted small mb-0">
                                7 Royal Palms Boulevard,<br>
                                Marina Bay Waterfront District,<br>
                                Mumbai, Maharashtra 400001
                            </p>
                        </div>
                    </div>
                </div>

                <div class="p-4 bg-white rounded-3 shadow-sm border">
                    <div class="d-flex align-items-start gap-3">
                        <div class="kpi-icon bg-gold text-dark flex-shrink-0">
                            <i class="bi bi-telephone-fill"></i>
                        </div>
                        <div>
                            <h5 class="font-serif text-navy mb-1">Telephone</h5>
                            <p class="text-muted small mb-1">Front Desk: +91 (022) 8900 1200</p>
                            <p class="text-muted small mb-0">Reservations: +91 (022) 8900 1201</p>
                        </div>
                    </div>
                </div>

                <div class="p-4 bg-white rounded-3 shadow-sm border">
                    <div class="d-flex align-items-start gap-3">
                        <div class="kpi-icon bg-navy text-gold flex-shrink-0">
                            <i class="bi bi-envelope-fill"></i>
                        </div>
                        <div>
                            <h5 class="font-serif text-navy mb-1">Electronic Mail</h5>
                            <p class="text-muted small mb-1">General: concierge@SmartStay.com</p>
                            <p class="text-muted small mb-0">Corporate Events: events@SmartStay.com</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

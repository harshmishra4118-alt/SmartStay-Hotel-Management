<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Hotel Policies & Terms - SmartStay Hotel"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-5 text-white">
    <div class="container text-center">
        <span class="text-gold text-uppercase small fw-bold tracking-wider">Terms of Hospitality</span>
        <h1 class="font-serif display-5 mt-1">Hotel Policies & Guest Rights</h1>
        <p class="text-light opacity-75 mx-auto mb-0" style="max-width: 600px;">
            Clear, transparent guidelines designed to ensure harmony, safety, and mutual respect during every stay.
        </p>
    </div>
</div>

<div class="container my-5" style="max-width: 900px;">
    <div class="bg-white p-4 p-md-5 rounded-3 shadow-sm border mb-4" id="checkin">
        <h4 class="font-serif text-navy mb-3"><i class="bi bi-clock-history text-gold me-2"></i> 1. Check-In and Check-Out Policy</h4>
        <p class="text-secondary small leading-relaxed">
            Guest check-in is scheduled from 2:00 PM onward. All adult guests are legally required to produce valid 
            government-issued photographic identification (Passport, Driving License, National Identity Card, or Voter ID) 
            upon arrival. Check-out must be completed by 11:00 AM on the scheduled departure date to allow housekeeping teams 
            sufficient time for deep sanitation and inspection.
        </p>
    </div>

    <div class="bg-white p-4 p-md-5 rounded-3 shadow-sm border mb-4" id="cancellation">
        <h4 class="font-serif text-navy mb-3"><i class="bi bi-arrow-repeat text-gold me-2"></i> 2. Cancellation and Refund Policy</h4>
        <p class="text-secondary small leading-relaxed">
            Reservations may be cancelled without penalty at any time prior to the check-in date directly via the 
            <em>My Bookings</em> portal. If advance demo payment was recorded, the status of the related invoice will be 
            automatically transitioned to <strong>REFUNDED</strong>. Cancellations for bookings starting on the current day 
            or past dates cannot be executed online and require front desk authorization.
        </p>
    </div>

    <div class="bg-white p-4 p-md-5 rounded-3 shadow-sm border mb-4" id="demo">
        <div class="p-3 bg-light rounded border-start border-4 border-warning mb-3">
            <h5 class="text-navy fw-bold mb-1"><i class="bi bi-exclamation-triangle-fill text-warning me-2"></i> Demo Payments Disclosure</h5>
            <small class="text-muted">
                This software application is built for educational, academic demonstration and portfolio purposes. 
                All online transactions represent <strong>simulated demo records</strong>. No real financial transactions 
                occur, no banking secrets or real credit card CVVs are stored, and no real currency is transferred.
            </small>
        </div>
        <p class="text-secondary small leading-relaxed">
            The demo payment simulator models realistic transaction logging, invoice state transitions, and audit records 
            for academic grading. Demo receipts generated in this portal bear the watermark "DEMO TRANSACTION - NO COMMERCIAL VALUE".
        </p>
    </div>

    <div class="bg-white p-4 p-md-5 rounded-3 shadow-sm border mb-4" id="privacy">
        <h4 class="font-serif text-navy mb-3"><i class="bi bi-shield-lock-fill text-gold me-2"></i> 4. Privacy & Data Minimization</h4>
        <p class="text-secondary small leading-relaxed">
            SmartStay adheres strictly to data minimization and secure storage practices:
        </p>
        <ul class="text-secondary small">
            <li>User passwords are never stored in plaintext and are securely salted and hashed using cryptographic <strong>BCrypt (12 rounds)</strong>.</li>
            <li>HTTP sessions are guarded against session fixation attacks via session ID renewal upon authentication.</li>
            <li>All administrative operations and logins are logged in internal audit tables with timestamp and IP address.</li>
            <li>Customer profile documents and contact details are accessible strictly to authorized front desk staff and administrators.</li>
        </ul>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

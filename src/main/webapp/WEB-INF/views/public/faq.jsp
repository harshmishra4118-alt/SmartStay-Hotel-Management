<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Frequently Asked Questions - SmartStay"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-5 text-white">
    <div class="container text-center">
        <span class="text-gold text-uppercase small fw-bold tracking-wider">Guest Assistance</span>
        <h1 class="font-serif display-5 mt-1">Frequently Asked Questions</h1>
        <p class="text-light opacity-75 mx-auto mb-3" style="max-width: 600px;">
            Find immediate answers regarding check-in times, dining schedules, hotel policies, and amenities.
        </p>
        <button type="button" class="btn btn-gold btn-sm px-4" onclick="document.getElementById('chatbotToggle').click();">
            <i class="bi bi-chat-dots-fill me-2"></i>Ask Virtual Concierge
        </button>
    </div>
</div>

<div class="container my-5" style="max-width: 850px;">
    <div class="accordion accordion-flush bg-white rounded-3 shadow-sm border p-3" id="faqAccordion">

        <!-- Timings -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingOne">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="false" aria-controls="collapseOne">
                    <i class="bi bi-clock-history text-gold me-2"></i> What are the standard check-in and check-out timings?
                </button>
            </h2>
            <div id="collapseOne" class="accordion-collapse collapse" aria-labelledby="headingOne" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    Standard guest check-in begins at <strong>2:00 PM</strong>, and check-out is until <strong>11:00 AM</strong>. 
                    Early check-in and late check-out can be arranged through the front desk subject to suite availability.
                </div>
            </div>
        </div>

        <!-- Breakfast & Dining -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingTwo">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                    <i class="bi bi-cup-hot text-gold me-2"></i> Is breakfast included with room reservations?
                </button>
            </h2>
            <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    Yes. All reservations made through the official SmartStay portal include complimentary gourmet breakfast at 
                    <em>The Gold Leaf</em> restaurant, served daily between 7:00 AM and 10:30 AM.
                </div>
            </div>
        </div>

        <!-- Cancellation Policy -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingThree">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseThree" aria-expanded="false" aria-controls="collapseThree">
                    <i class="bi bi-arrow-repeat text-gold me-2"></i> What is your cancellation and refund policy?
                </button>
            </h2>
            <div id="collapseThree" class="accordion-collapse collapse" aria-labelledby="headingThree" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    Reservations can be cancelled online without penalty prior to the check-in date. Any advance demo payments 
                    will be refunded immediately upon online cancellation. Bookings starting today or in the past must be handled 
                    through front desk staff.
                </div>
            </div>
        </div>

        <!-- Wi-Fi & Connectivity -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingFour">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseFour" aria-expanded="false" aria-controls="collapseFour">
                    <i class="bi bi-wifi text-gold me-2"></i> Is high-speed internet available throughout the hotel?
                </button>
            </h2>
            <div id="collapseFour" class="accordion-collapse collapse" aria-labelledby="headingFour" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    Complimentary optical fiber Wi-Fi with symmetric speeds up to 300 Mbps is accessible in all guest suites, 
                    meeting salons, and public resort areas.
                </div>
            </div>
        </div>

        <!-- Swimming Pool & Fitness -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingFive">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseFive" aria-expanded="false" aria-controls="collapseFive">
                    <i class="bi bi-water text-gold me-2"></i> What are the operating hours for the infinity pool & gym?
                </button>
            </h2>
            <div id="collapseFive" class="accordion-collapse collapse" aria-labelledby="headingFive" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    Our rooftop infinity pool is open daily from 6:00 AM to 10:00 PM. The fitness center and sauna are open 
                    24/7 with room keycard access.
                </div>
            </div>
        </div>

        <!-- Airport Transfers -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingSix">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseSix" aria-expanded="false" aria-controls="collapseSix">
                    <i class="bi bi-airplane text-gold me-2"></i> Do you provide airport transfers?
                </button>
            </h2>
            <div id="collapseSix" class="accordion-collapse collapse" aria-labelledby="headingSix" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    Yes, private Mercedes chauffeur transfers to and from Chhatrapati Shivaji Maharaj International Airport (BOM) 
                    can be reserved through our concierge at least 12 hours prior to arrival.
                </div>
            </div>
        </div>

        <!-- Demo Payments Disclosure -->
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingSeven">
                <button class="accordion-button collapsed font-serif text-navy fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#collapseSeven" aria-expanded="false" aria-controls="collapseSeven">
                    <i class="bi bi-credit-card-2-front text-gold me-2"></i> What payment methods are accepted online?
                </button>
            </h2>
            <div id="collapseSeven" class="accordion-collapse collapse" aria-labelledby="headingSeven" data-bs-parent="#faqAccordion">
                <div class="accordion-body text-secondary small">
                    This college project application uses a <strong>simulated demo payment environment</strong>. 
                    You can record payments using demo credit cards, demo debit cards, demo UPI, or cash at front desk. 
                    No real banking transactions take place, and no sensitive credit card numbers or CVVs are collected.
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

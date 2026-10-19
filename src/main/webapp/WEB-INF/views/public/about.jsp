<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Our Story & Heritage - AuraStay Luxury Suites"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="bg-navy py-5 text-white">
    <div class="container text-center">
        <span class="text-gold text-uppercase small fw-bold tracking-wider">Heritage & Philosophy</span>
        <h1 class="font-serif display-5 mt-1">The AuraStay Story</h1>
        <p class="text-light opacity-75 mx-auto mb-0" style="max-width: 650px;">
            Established to redefine luxury living through architectural brilliance, artisanal dining, and seamless smart hospitality.
        </p>
    </div>
</div>

<div class="container my-5">
    <div class="row g-5 align-items-center mb-5">
        <div class="col-lg-6">
            <span class="text-gold text-uppercase small fw-bold">An Architectural Masterpiece</span>
            <h2 class="font-serif text-navy mt-1 mb-3">Crafted for Discerning Travelers</h2>
            <p class="text-secondary leading-relaxed">
                Founded with a bold vision, AuraStay stands as an emblem of timeless hospitality in the heart of the city. 
                Our properties merge neoclassical grandeur with contemporary minimalist aesthetics, creating serene 
                urban sanctuaries shielded from bustling cityscapes.
            </p>
            <p class="text-secondary leading-relaxed">
                From our Italian Carrara marble bathrooms to acoustic double-glazed panoramic windows and smart room temperature 
                controls, every nuance has been engineered for peace of mind, restorative sleep, and unmatched privacy.
            </p>
            <div class="row g-3 pt-3">
                <div class="col-sm-4 text-center p-3 bg-white rounded border shadow-sm">
                    <h3 class="font-serif text-gold mb-0">150+</h3>
                    <small class="text-muted">Bespoke Suites</small>
                </div>
                <div class="col-sm-4 text-center p-3 bg-white rounded border shadow-sm">
                    <h3 class="font-serif text-gold mb-0">99.4%</h3>
                    <small class="text-muted">Guest Satisfaction</small>
                </div>
                <div class="col-sm-4 text-center p-3 bg-white rounded border shadow-sm">
                    <h3 class="font-serif text-gold mb-0">12</h3>
                    <small class="text-muted">Global Awards</small>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="rounded-3 overflow-hidden shadow-lg">
                <img src="https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80" alt="AuraStay Grand Lobby" class="w-100 object-fit-cover" style="min-height: 400px;">
            </div>
        </div>
    </div>

    <!-- Pillars of Excellence -->
    <div class="bg-ivory p-5 rounded-3 border my-5">
        <div class="text-center mb-5">
            <span class="text-gold text-uppercase fw-bold small">Our Core Pillars</span>
            <h3 class="font-serif text-navy mt-1">Commitment to Distinction</h3>
        </div>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="p-4 bg-white rounded border h-100 shadow-sm">
                    <i class="bi bi-shield-check text-gold fs-2 mb-3 d-block"></i>
                    <h5 class="font-serif text-navy">Uncompromising Quality</h5>
                    <p class="small text-muted mb-0">Precision housekeeping standards, hypoallergenic premium linens, and rigorous cleanliness inspections before every check-in.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded border h-100 shadow-sm">
                    <i class="bi bi-stars text-gold fs-2 mb-3 d-block"></i>
                    <h5 class="font-serif text-navy">Smart Intuitive Service</h5>
                    <p class="small text-muted mb-0">Frictionless digital check-ins, automated preferences recording, and instant rule-based concierge support around the clock.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4 bg-white rounded border h-100 shadow-sm">
                    <i class="bi bi-flower1 text-gold fs-2 mb-3 d-block"></i>
                    <h5 class="font-serif text-navy">Sustainable Luxury</h5>
                    <p class="small text-muted mb-0">Energy-efficient HVAC systems, locally sourced organic gourmet dining ingredients, and zero single-use plastics across all suites.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

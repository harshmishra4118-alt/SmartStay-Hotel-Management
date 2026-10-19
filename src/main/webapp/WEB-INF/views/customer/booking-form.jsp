<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Complete Reservation - ${room.name}"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container my-5">
    <div class="row g-5">
        <!-- Left: Form -->
        <div class="col-lg-8">
            <div class="bg-white p-4 p-md-5 rounded-3 shadow-sm border">
                <span class="badge bg-gold text-dark mb-2 px-3 py-1 fw-bold text-uppercase">Direct Reservation</span>
                <h2 class="font-serif text-navy mb-1">Confirm Your Stay</h2>
                <p class="text-muted small mb-4">Please verify dates and provide guest information for the room voucher.</p>

                <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

                <form action="${pageContext.request.contextPath}/customer/book" method="POST" id="bookingForm">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <input type="hidden" name="roomId" value="${room.id}">
                    <input type="hidden" id="roomPricePerNight" value="${room.pricePerNight}">

                    <!-- Dates & Capacity -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">1. Stay Schedule</h5>
                    <div class="row g-3 mb-4">
                        <div class="col-md-5 col-sm-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Check-In Date</label>
                            <input type="date" name="checkIn" class="form-control" value="${checkIn}" required>
                        </div>
                        <div class="col-md-5 col-sm-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Check-Out Date</label>
                            <input type="date" name="checkOut" class="form-control" value="${checkOut}" required>
                        </div>
                        <div class="col-md-2 col-sm-12">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Guests</label>
                            <select name="guests" class="form-select">
                                <c:forEach begin="1" end="${room.capacity}" var="g">
                                    <option value="${g}" ${guests == g ? 'selected' : ''}>${g}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <!-- Primary Guest Details -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">2. Primary Guest Information</h5>
                    <div class="row g-3 mb-3">
                        <div class="col-md-12">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Full Name (as per Photo ID)</label>
                            <input type="text" name="guestName" class="form-control" required 
                                   value="${not empty guestName ? guestName : sessionScope.currentUser.fullName}" placeholder="e.g. Johnathan Doe">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Email Address</label>
                            <input type="email" name="guestEmail" class="form-control" required 
                                   value="${not empty guestEmail ? guestEmail : sessionScope.currentUser.email}" placeholder="guest@example.com">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Phone Number</label>
                            <input type="tel" name="guestPhone" class="form-control" required 
                                   value="${not empty guestPhone ? guestPhone : sessionScope.currentUser.phone}" placeholder="+91 98765 43210">
                        </div>
                    </div>

                    <!-- Special Requests -->
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-uppercase text-secondary">Special Requests (Optional)</label>
                        <textarea name="specialRequests" class="form-control" rows="3" placeholder="e.g. High floor, extra pillows, early flight arrival time...">${specialRequests}</textarea>
                        <small class="text-muted" style="font-size: 0.75rem;">Special requests are subject to availability upon check-in.</small>
                    </div>

                    <div class="p-3 bg-light rounded border mb-4 text-secondary small">
                        <i class="bi bi-shield-check text-success me-1"></i>
                        By proceeding, you agree to AuraStay's standard check-in terms and cancellation policies. 
                        No immediate card charge is made; demo payment can be recorded upon confirmation or settled at the front desk.
                    </div>

                    <button type="submit" class="btn btn-gold btn-lg w-100 py-3 fw-bold">
                        <i class="bi bi-lock-fill me-2"></i>Confirm & Generate Booking Voucher
                    </button>
                </form>
            </div>
        </div>

        <!-- Right: Summary Card -->
        <div class="col-lg-4">
            <div class="bg-white p-4 rounded-3 shadow border sticky-top" style="top: 100px;">
                <h5 class="font-serif text-navy mb-3">Reservation Summary</h5>

                <div class="rounded-3 overflow-hidden mb-3" style="height: 180px;">
                    <img src="${room.primaryImageUrl}" alt="${room.name}" class="w-100 h-100 object-fit-cover">
                </div>

                <h5 class="font-serif text-navy mb-1">${room.name}</h5>
                <span class="badge bg-light text-secondary border small mb-3">${room.roomType.displayName} &bull; Room #${room.roomNumber}</span>

                <div class="border-top pt-3 mt-2">
                    <div class="d-flex justify-content-between small text-secondary mb-2">
                        <span>Nightly Rate:</span>
                        <strong>₹<fmt:formatNumber value="${room.pricePerNight}" pattern="#,##0.00"/></strong>
                    </div>
                    <div class="d-flex justify-content-between small text-secondary mb-2">
                        <span>Duration:</span>
                        <strong id="calcNights">${pricing.nights} night${pricing.nights > 1 ? 's' : ''}</strong>
                    </div>
                    <div class="d-flex justify-content-between small text-secondary mb-2">
                        <span>Base Room Charge:</span>
                        <strong id="calcBase">₹<fmt:formatNumber value="${pricing.baseAmount}" pattern="#,##0.00"/></strong>
                    </div>
                    <div class="d-flex justify-content-between small text-secondary mb-2">
                        <span>Taxes & GST (12%):</span>
                        <strong id="calcTax">₹<fmt:formatNumber value="${pricing.taxAmount}" pattern="#,##0.00"/></strong>
                    </div>
                    <div class="d-flex justify-content-between border-top pt-2 mt-2 fs-5 text-navy fw-bold">
                        <span>Total Payable:</span>
                        <span class="text-gold" id="calcTotal">₹<fmt:formatNumber value="${pricing.totalAmount}" pattern="#,##0.00"/></span>
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top small text-muted">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <i class="bi bi-cup-hot text-gold"></i>
                        <span>Includes Gourmet Breakfast</span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-wifi text-gold"></i>
                        <span>Complimentary Optical Fiber Wi-Fi</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

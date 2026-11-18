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
                            <input type="date" name="checkIn" id="checkInDate" class="form-control" value="${checkIn}" required>
                        </div>
                        <div class="col-md-5 col-sm-6">
                            <label class="form-label small fw-bold text-uppercase text-secondary">Check-Out Date</label>
                            <input type="date" name="checkOut" id="checkOutDate" class="form-control" value="${checkOut}" required>
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

                    <!-- Promotional Coupon Code -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">3. Promotional Offers & Coupons</h5>
                    <div class="row g-2 align-items-center mb-4">
                        <div class="col-md-8">
                            <div class="input-group">
                                <span class="input-group-text bg-white"><i class="bi bi-tag-fill text-gold"></i></span>
                                <input type="text" id="couponCodeInput" name="couponCode" class="form-control text-uppercase" placeholder="e.g. WELCOME500, SMARTSTAY10, ROYALSTAY" value="${param.couponCode}">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <button type="button" id="btnApplyCoupon" class="btn btn-navy w-100">
                                Apply Coupon
                            </button>
                        </div>
                        <div class="col-12">
                            <div id="couponFeedback" class="small mt-1"></div>
                        </div>
                    </div>

                    <!-- Payment Mode Selection -->
                    <h5 class="font-serif text-navy mb-3 border-bottom pb-2">4. Payment Preference</h5>
                    <div class="vstack gap-2 mb-4">
                        <div class="form-check p-3 border rounded-3 bg-light d-flex align-items-center gap-2">
                            <input class="form-check-input ms-0 me-2" type="radio" name="paymentOption" id="payDemo" value="DEMO" checked>
                            <label class="form-check-label w-100 cursor-pointer" for="payDemo">
                                <strong class="text-navy d-block"><i class="bi bi-shield-check text-success me-1"></i>Demo Instant Payment Simulator (Default / Offline Demo)</strong>
                                <small class="text-muted">Instantly confirm and settle with simulated Cards/UPI sandbox (Ideal for offline college project demonstration).</small>
                            </label>
                        </div>
                        <div class="form-check p-3 border rounded-3 d-flex align-items-center gap-2">
                            <input class="form-check-input ms-0 me-2" type="radio" name="paymentOption" id="payRazorpay" value="RAZORPAY">
                            <label class="form-check-label w-100 cursor-pointer" for="payRazorpay">
                                <strong class="text-navy d-block"><i class="bi bi-credit-card-2-front text-gold me-1"></i>Pay Online with Razorpay (Live Integration)</strong>
                                <small class="text-muted">Interactive live checkout gateway for UPI, Cards, NetBanking, and Wallets (Requires active network).</small>
                            </label>
                        </div>
                        <div class="form-check p-3 border rounded-3 d-flex align-items-center gap-2">
                            <input class="form-check-input ms-0 me-2" type="radio" name="paymentOption" id="payLater" value="LATER">
                            <label class="form-check-label w-100 cursor-pointer" for="payLater">
                                <strong class="text-navy d-block"><i class="bi bi-building me-1"></i>Pay at Front Desk / Settle Upon Arrival</strong>
                                <small class="text-muted">Generate reservation voucher now and settle invoice balance upon check-in.</small>
                            </label>
                        </div>
                    </div>

                    <div class="p-3 bg-light rounded border mb-4 text-secondary small">
                        <i class="bi bi-shield-check text-success me-1"></i>
                        By proceeding, you agree to SmartStay's standard five-star hospitality terms and cancellation policies.
                    </div>

                    <button type="submit" class="btn btn-gold btn-lg w-100 py-3 fw-bold">
                        <i class="bi bi-lock-fill me-2"></i>Confirm & Proceed to Voucher / Payment
                    </button>
                </form>
            </div>
        </div>

        <!-- Right: Summary Card -->
        <div class="col-lg-4">
            <div class="bg-white p-4 rounded-3 shadow border sticky-top" style="top: 100px;">
                <h5 class="font-serif text-navy mb-3">Reservation Summary</h5>

                <div class="rounded-3 overflow-hidden mb-3" style="height: 180px;">
                    <img src="${not empty room.primaryImageUrl ? room.primaryImageUrl : 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=900&q=80'}"
                         alt="${room.name}" class="w-100 h-100 object-fit-cover"
                         onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=900&q=80';">
                </div>

                <c:if test="${not empty hotel}">
                    <div class="mb-2">
                        <span class="badge bg-gold text-dark fw-bold">${hotel.city}</span>
                        <h6 class="font-serif text-navy fw-bold mt-1 mb-0">${hotel.name}</h6>
                    </div>
                </c:if>

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
                    <div id="rowDiscount" class="d-flex justify-content-between small text-success mb-2 d-none">
                        <span><i class="bi bi-tag-fill me-1"></i>Coupon Discount:</span>
                        <strong id="calcDiscount">-₹0.00</strong>
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

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Setup date constraints
    const checkInInput = document.getElementById('checkInDate');
    const checkOutInput = document.getElementById('checkOutDate');
    if (checkInInput && checkOutInput) {
        const today = new Date().toISOString().split('T')[0];
        checkInInput.min = today;
        if (!checkInInput.value) {
            checkInInput.value = today;
        }

        function updateCheckOutMin() {
            if (checkInInput.value) {
                const checkInDate = new Date(checkInInput.value);
                checkInDate.setDate(checkInDate.getDate() + 1);
                const nextDay = checkInDate.toISOString().split('T')[0];
                checkOutInput.min = nextDay;
                if (!checkOutInput.value || checkOutInput.value <= checkInInput.value) {
                    checkOutInput.value = nextDay;
                }
            }
        }

        checkInInput.addEventListener('change', updateCheckOutMin);
        updateCheckOutMin();
    }

    const btnApply = document.getElementById('btnApplyCoupon');
    const inputCoupon = document.getElementById('couponCodeInput');
    const feedback = document.getElementById('couponFeedback');
    const rowDiscount = document.getElementById('rowDiscount');
    const calcDiscount = document.getElementById('calcDiscount');
    const calcTotal = document.getElementById('calcTotal');
    const baseAmount = ${not empty pricing && not empty pricing.baseAmount ? pricing.baseAmount : (not empty room && not empty room.pricePerNight ? room.pricePerNight : 0)};

    if (btnApply && inputCoupon) {
        btnApply.addEventListener('click', function() {
            const code = inputCoupon.value.trim();
            if (!code) {
                feedback.innerHTML = '<span class="text-danger">Please enter a coupon code.</span>';
                return;
            }

            btnApply.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';
            fetch('${pageContext.request.contextPath}/api/coupon/validate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'code=' + encodeURIComponent(code) + '&amount=' + baseAmount
            })
            .then(res => res.json())
            .then(data => {
                btnApply.innerText = 'Apply Coupon';
                if (data.valid) {
                    feedback.innerHTML = '<span class="text-success fw-bold"><i class="bi bi-check-circle me-1"></i>' + data.message + '</span>';
                    rowDiscount.classList.remove('d-none');
                    calcDiscount.innerText = '-₹' + parseFloat(data.discountAmount).toFixed(2);

                    const discountedBase = Math.max(0, baseAmount - data.discountAmount);
                    const newTax = discountedBase * 0.12;
                    const newTotal = discountedBase + newTax;
                    calcTotal.innerText = '₹' + newTotal.toFixed(2);
                } else {
                    feedback.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>' + data.message + '</span>';
                    rowDiscount.classList.add('d-none');
                }
            })
            .catch(err => {
                btnApply.innerText = 'Apply Coupon';
                feedback.innerHTML = '<span class="text-danger">Error verifying coupon.</span>';
            });
        });
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

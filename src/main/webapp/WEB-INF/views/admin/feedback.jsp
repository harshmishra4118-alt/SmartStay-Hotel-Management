<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Guest Reviews & Sentiment Moderation - SmartStay Admin"/>
</jsp:include>

<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Admin Sidebar -->
        <div class="col-lg-2 col-md-3">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
        </div>

        <!-- Main Content Area -->
        <div class="col-lg-10 col-md-9 bg-light min-vh-100 p-4">
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <div>
                    <h2 class="font-serif text-navy mb-1">Guest Reviews & Sentiment Moderation</h2>
                    <p class="text-secondary small mb-0">Evaluate guest satisfaction, review rule-based sentiment classification, and publish testimonials.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/alerts.jsp" />

            <c:if test="${param.success == 'true'}">
                <div class="alert alert-success alert-dismissible fade show small mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Review moderation action recorded successfully.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Filter Status Bar -->
            <div class="card border-0 shadow-sm rounded-3 mb-4 bg-white p-3">
                <div class="d-flex flex-wrap gap-2 align-items-center">
                    <span class="text-secondary small fw-bold text-uppercase me-2">Moderation Filter:</span>
                    <a href="${pageContext.request.contextPath}/admin/feedback" class="btn btn-sm ${empty selectedApproved ? 'btn-navy' : 'btn-outline-secondary'}">
                        All Reviews (${feedbacks != null ? feedbacks.size() : 0})
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/feedback?approved=true" class="btn btn-sm ${selectedApproved == 'true' ? 'btn-navy' : 'btn-outline-secondary'}">
                        Published to Website
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/feedback?approved=false" class="btn btn-sm ${selectedApproved == 'false' ? 'btn-navy' : 'btn-outline-secondary'}">
                        Pending Moderation
                    </a>
                </div>
            </div>

            <!-- Feedbacks List Cards -->
            <div class="row g-4">
                <c:choose>
                    <c:when test="${not empty feedbacks}">
                        <c:forEach var="fb" items="${feedbacks}">
                            <div class="col-12">
                                <div class="card border-0 shadow-sm rounded-3 bg-white p-4">
                                    <div class="d-flex flex-wrap justify-content-between align-items-start border-bottom pb-3 mb-3">
                                        <div>
                                            <div class="d-flex align-items-center gap-2 mb-1">
                                                <h5 class="font-serif text-navy mb-0">${fb.userFullName}</h5>
                                                <span class="badge ${fb.approved ? 'bg-success' : 'bg-warning text-dark'}">
                                                    ${fb.approved ? 'PUBLISHED' : 'PENDING'}
                                                </span>
                                            </div>
                                            <small class="text-muted">Submitted: ${fb.createdAt} &bull; Booking ID: #${fb.bookingId}</small>
                                        </div>
                                        <div class="text-end">
                                            <!-- Pure Java Rule-Based Sentiment Analysis Badge -->
                                            <c:choose>
                                                <c:when test="${fb.sentiment.name() == 'POSITIVE'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2 fs-6">
                                                        <i class="bi bi-emoji-smile-fill me-1"></i>Rule AI: Positive
                                                    </span>
                                                </c:when>
                                                <c:when test="${fb.sentiment.name() == 'NEGATIVE'}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-2 fs-6">
                                                        <i class="bi bi-emoji-frown-fill me-1"></i>Rule AI: Needs Attention
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary-subtle text-secondary border px-3 py-2 fs-6">
                                                        <i class="bi bi-emoji-neutral-fill me-1"></i>Rule AI: Neutral
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <!-- Rating breakdown -->
                                    <div class="d-flex flex-wrap gap-4 mb-3 p-3 bg-light rounded">
                                        <div>
                                            <small class="text-secondary fw-bold d-block">Overall Rating</small>
                                            <span class="text-gold fs-5">
                                                <c:forEach begin="1" end="${fb.rating}"><i class="bi bi-star-fill"></i></c:forEach>
                                                <c:forEach begin="${fb.rating + 1}" end="5"><i class="bi bi-star"></i></c:forEach>
                                            </span>
                                            <span class="fw-bold text-navy ms-1">(${fb.rating}/5)</span>
                                        </div>
                                        <div class="border-start ps-3">
                                            <small class="text-secondary fw-bold d-block">Cleanliness</small>
                                            <span class="fw-bold text-navy">${fb.cleanlinessRating}/5</span>
                                        </div>
                                        <div class="border-start ps-3">
                                            <small class="text-secondary fw-bold d-block">Staff Service</small>
                                            <span class="fw-bold text-navy">${fb.serviceRating}/5</span>
                                        </div>
                                        <div class="border-start ps-3">
                                            <small class="text-secondary fw-bold d-block">Amenities</small>
                                            <span class="fw-bold text-navy">${fb.amenitiesRating}/5</span>
                                        </div>
                                    </div>

                                    <!-- Comment -->
                                    <p class="text-secondary mb-3 fst-italic">"${fb.comments}"</p>

                                    <!-- Management reply if exists -->
                                    <c:if test="${not empty fb.adminReply}">
                                        <div class="p-3 bg-light border-start border-4 border-gold rounded mb-3">
                                            <small class="fw-bold text-navy text-uppercase d-block mb-1">
                                                <i class="bi bi-reply-fill text-gold me-1"></i>Official Management Response:
                                            </small>
                                            <p class="mb-0 small text-secondary">${fb.adminReply}</p>
                                        </div>
                                    </c:if>

                                    <!-- Actions: Toggle Approval & Reply Modal Trigger -->
                                    <div class="d-flex justify-content-between align-items-center border-top pt-3">
                                        <div>
                                            <form action="${pageContext.request.contextPath}/admin/feedback" method="POST" class="d-inline">
                                                <input type="hidden" name="csrfToken" value="${csrfToken}">
                                                <input type="hidden" name="action" value="toggleApproval">
                                                <input type="hidden" name="feedbackId" value="${fb.id}">
                                                <input type="hidden" name="approved" value="${!fb.approved}">
                                                <button type="submit" class="btn ${fb.approved ? 'btn-outline-danger' : 'btn-outline-success'} btn-sm fw-semibold">
                                                    <i class="bi ${fb.approved ? 'bi-eye-slash' : 'bi-check-circle'} me-1"></i>
                                                    ${fb.approved ? 'Unpublish from Website' : 'Approve & Publish'}
                                                </button>
                                            </form>
                                        </div>
                                        <div>
                                            <button type="button" class="btn btn-navy btn-sm" data-bs-toggle="modal" data-bs-target="#replyModal_${fb.id}">
                                                <i class="bi bi-chat-left-dots me-1"></i> Post Management Reply
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Reply Modal -->
                            <div class="modal fade" id="replyModal_${fb.id}" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header bg-navy text-white">
                                            <h6 class="modal-title font-serif">Management Response to ${fb.userFullName}</h6>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/admin/feedback" method="POST">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                                            <input type="hidden" name="action" value="reply">
                                            <input type="hidden" name="feedbackId" value="${fb.id}">

                                            <div class="modal-body">
                                                <p class="small text-muted mb-2 fst-italic">"${fb.comments}"</p>
                                                <div class="mb-3">
                                                    <label class="form-label small fw-bold text-secondary text-uppercase">Your Public Response</label>
                                                    <textarea name="reply" class="form-control" rows="4" placeholder="Dear ${fb.userFullName}, thank you for choosing SmartStay..." required>${fb.adminReply}</textarea>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn btn-gold btn-sm fw-bold">Post Response</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12">
                            <div class="card border-0 shadow-sm rounded-3 bg-white p-5 text-center">
                                <i class="bi bi-star text-muted" style="font-size: 3rem;"></i>
                                <h5 class="font-serif text-navy mt-3">No Reviews Found</h5>
                                <p class="text-secondary small mb-0">No guest reviews currently match the selected moderation filter.</p>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

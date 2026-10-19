package com.hotel.service;

import com.hotel.dao.AuditLogDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.dao.FeedbackDAO;
import com.hotel.model.Booking;
import com.hotel.model.Feedback;
import com.hotel.util.ValidationUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.*;

public class FeedbackService {

    private static final Logger logger = LoggerFactory.getLogger(FeedbackService.class);

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    // Plain Java rule-based keyword dictionaries (no ML/Python/external APIs)
    private static final Set<String> POSITIVE_KEYWORDS = new HashSet<>(Arrays.asList(
            "excellent", "amazing", "clean", "luxury", "friendly", "spacious", "loved",
            "great", "wonderful", "comfortable", "quiet", "perfect", "beautiful",
            "delightful", "impressed", "helpful", "delicious", "superb", "enjoyed"
    ));

    private static final Set<String> NEGATIVE_KEYWORDS = new HashSet<>(Arrays.asList(
            "dirty", "poor", "broken", "bad", "terrible", "rude", "noisy",
            "disappointed", "smell", "slow", "cold", "horrible", "uncomfortable",
            "leak", "bug", "stain", "worst", "unacceptable", "delay"
    ));

    public static class SentimentAnalysisResult {
        public Feedback.SentimentLabel label;
        public String matchedKeywords;
    }

    /**
     * Rule-based keyword matching sentiment analyzer implemented in plain Java.
     */
    public SentimentAnalysisResult analyzeSentiment(String comments) {
        SentimentAnalysisResult result = new SentimentAnalysisResult();
        if (comments == null || comments.trim().isEmpty()) {
            result.label = Feedback.SentimentLabel.NEUTRAL;
            result.matchedKeywords = "none";
            return result;
        }

        String lower = comments.toLowerCase().replaceAll("[^a-z0-9\\s]", " ");
        String[] words = lower.split("\\s+");

        int posCount = 0;
        int negCount = 0;
        List<String> matched = new ArrayList<>();

        for (String w : words) {
            if (POSITIVE_KEYWORDS.contains(w)) {
                posCount++;
                if (!matched.contains("+" + w)) matched.add("+" + w);
            }
            if (NEGATIVE_KEYWORDS.contains(w)) {
                negCount++;
                if (!matched.contains("-" + w)) matched.add("-" + w);
            }
        }

        if (posCount > negCount) {
            result.label = Feedback.SentimentLabel.POSITIVE;
        } else if (negCount > posCount) {
            result.label = Feedback.SentimentLabel.NEGATIVE;
        } else {
            result.label = Feedback.SentimentLabel.NEUTRAL;
        }

        result.matchedKeywords = matched.isEmpty() ? "none" : String.join(", ", matched);
        return result;
    }

    public Long submitFeedback(Long bookingId, Long userId, int rating, int cleanliness,
                               int service, int amenities, String comments, String clientIp) throws Exception {

        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (!booking.getUserId().equals(userId)) {
            throw new SecurityException("You can only submit reviews for your own stays.");
        }
        if (booking.getBookingStatus() != Booking.BookingStatus.CHECKED_OUT &&
            booking.getBookingStatus() != Booking.BookingStatus.CONFIRMED) {
            throw new IllegalStateException("Reviews can only be submitted for completed or active stays.");
        }

        Feedback existing = feedbackDAO.findByBookingId(bookingId);
        if (existing != null) {
            throw new IllegalStateException("You have already submitted a review for this reservation.");
        }

        if (!ValidationUtil.isNotEmpty(comments)) {
            throw new IllegalArgumentException("Feedback comments cannot be empty.");
        }

        SentimentAnalysisResult sentiment = analyzeSentiment(comments);

        Feedback fb = new Feedback();
        fb.setBookingId(bookingId);
        fb.setUserId(userId);
        fb.setRoomId(booking.getRoomId());
        fb.setRating(Math.min(5, Math.max(1, rating)));
        fb.setCleanlinessRating(Math.min(5, Math.max(1, cleanliness)));
        fb.setServiceRating(Math.min(5, Math.max(1, service)));
        fb.setAmenitiesRating(Math.min(5, Math.max(1, amenities)));
        fb.setComments(comments.trim());
        fb.setSentimentLabel(sentiment.label);
        fb.setRuleKeywordsMatched(sentiment.matchedKeywords);
        fb.setApproved(true); // Auto-approve initially or moderate

        Long id = feedbackDAO.create(fb);

        auditLogDAO.log(userId, "FEEDBACK_SUBMITTED", "Feedback", String.valueOf(id),
                "Submitted " + fb.getRating() + "-star feedback (Rule sentiment: " + sentiment.label + ")", clientIp);

        return id;
    }

    public List<Feedback> getApprovedReviewsForRoom(Long roomId, int limit) throws SQLException {
        return feedbackDAO.listApprovedForRoom(roomId, limit);
    }

    public List<Feedback> listAllFeedback(Boolean approvedFilter, int offset, int limit) throws SQLException {
        return feedbackDAO.listAll(approvedFilter, offset, limit);
    }

    public void setApproval(Long feedbackId, boolean approved, Long staffUserId, String clientIp) throws SQLException {
        feedbackDAO.updateApproval(feedbackId, approved);
        auditLogDAO.log(staffUserId, "FEEDBACK_MODERATED", "Feedback", String.valueOf(feedbackId),
                "Approval status set to: " + approved, clientIp);
    }

    public void addAdminReply(Long feedbackId, String reply, Long staffUserId, String clientIp) throws SQLException {
        feedbackDAO.reply(feedbackId, reply.trim());
        auditLogDAO.log(staffUserId, "FEEDBACK_REPLIED", "Feedback", String.valueOf(feedbackId),
                "Management reply added", clientIp);
    }
}

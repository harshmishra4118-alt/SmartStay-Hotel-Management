package com.hotel.service;

import com.hotel.model.Feedback;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class FeedbackServiceTest {

    private final FeedbackService feedbackService = new FeedbackService();

    @Test
    public void testPositiveSentimentClassification() {
        String review = "The room was absolutely amazing, luxury, clean and very comfortable. We loved the friendly staff!";
        FeedbackService.SentimentAnalysisResult result = feedbackService.analyzeSentiment(review);

        assertEquals(Feedback.SentimentLabel.POSITIVE, result.label);
        assertTrue(result.matchedKeywords.contains("+amazing"));
        assertTrue(result.matchedKeywords.contains("+clean"));
        assertTrue(result.matchedKeywords.contains("+friendly"));
    }

    @Test
    public void testNegativeSentimentClassification() {
        String review = "The bathroom was dirty and the shower was broken. The room was noisy and cold. Very disappointed.";
        FeedbackService.SentimentAnalysisResult result = feedbackService.analyzeSentiment(review);

        assertEquals(Feedback.SentimentLabel.NEGATIVE, result.label);
        assertTrue(result.matchedKeywords.contains("-dirty"));
        assertTrue(result.matchedKeywords.contains("-broken"));
        assertTrue(result.matchedKeywords.contains("-disappointed"));
    }

    @Test
    public void testNeutralSentimentClassification() {
        String review = "Our stay was from Friday to Sunday.";
        FeedbackService.SentimentAnalysisResult result = feedbackService.analyzeSentiment(review);

        assertEquals(Feedback.SentimentLabel.NEUTRAL, result.label);
    }
}

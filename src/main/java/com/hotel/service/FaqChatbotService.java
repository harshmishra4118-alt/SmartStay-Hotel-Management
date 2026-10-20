package com.hotel.service;

import java.util.*;

/**
 * Pure Java Rule-Based FAQ Assistant.
 * Uses keyword matching and regex heuristics without external AI APIs or Python.
 */
public class FaqChatbotService {

    public static class ChatResponse {
        private String answer;
        private String category;
        private boolean matched;
        private List<String> suggestedQuestions;

        public ChatResponse(String answer, String category, boolean matched, List<String> suggestedQuestions) {
            this.answer = answer;
            this.category = category;
            this.matched = matched;
            this.suggestedQuestions = suggestedQuestions;
        }

        public String getAnswer() { return answer; }
        public String getCategory() { return category; }
        public boolean isMatched() { return matched; }
        public List<String> getSuggestedQuestions() { return suggestedQuestions; }
    }

    private static class FaqRule {
        String category;
        List<String> keywords;
        String answer;

        FaqRule(String category, List<String> keywords, String answer) {
            this.category = category;
            this.keywords = keywords;
            this.answer = answer;
        }
    }

    private static final List<FaqRule> RULES = new ArrayList<>();

    static {
        RULES.add(new FaqRule(
                "Timings",
                Arrays.asList("check in", "check out", "checkin", "checkout", "timing", "hours", "arrival", "departure"),
                "Standard Check-in begins at 2:00 PM, and Check-out is until 11:00 AM. Early check-in and late check-out can be requested subject to room availability."
        ));

        RULES.add(new FaqRule(
                "Cancellation",
                Arrays.asList("cancel", "cancellation", "refund", "modify", "policy"),
                "Cancellations made prior to the check-in date are eligible for full refund under standard reservation terms. Cancellations can be performed directly from 'My Bookings'."
        ));

        RULES.add(new FaqRule(
                "Dining",
                Arrays.asList("breakfast", "dining", "restaurant", "buffet", "food", "lunch", "dinner", "room service"),
                "Complimentary gourmet buffet breakfast is served daily at 'The Gold Leaf' restaurant from 7:00 AM to 10:30 AM. 24/7 in-room dining is also available."
        ));

        RULES.add(new FaqRule(
                "Amenities",
                Arrays.asList("wifi", "wi-fi", "internet", "speed"),
                "High-speed fiber optical Wi-Fi (up to 300 Mbps) is complimentary in all guest rooms and throughout the hotel premises. No password is required after guest verification."
        ));

        RULES.add(new FaqRule(
                "Wellness",
                Arrays.asList("pool", "swimming", "gym", "fitness", "workout", "spa"),
                "Our heated rooftop infinity pool is open daily from 6:00 AM to 10:00 PM. The 24-hour fitness center features state-of-the-art cardio and strength equipment."
        ));

        RULES.add(new FaqRule(
                "Parking",
                Arrays.asList("parking", "car", "valet", "vehicle", "garage"),
                "Secure covered valet parking is available for all registered guests at no additional fee. EV charging stations are also provided on Basement Level 1."
        ));

        RULES.add(new FaqRule(
                "Transportation",
                Arrays.asList("airport", "shuttle", "taxi", "cab", "pick up", "drop"),
                "We provide luxury airport transfer service to and from the international airport. Please notify our front desk at least 12 hours prior to your flight."
        ));

        RULES.add(new FaqRule(
                "Pets",
                Arrays.asList("pet", "dog", "cat", "animals"),
                "We are delighted to be a pet-friendly hotel for domesticated dogs and cats up to 15 kg. Please inform us during reservation so we can prepare pet amenities."
        ));

        RULES.add(new FaqRule(
                "Payments",
                Arrays.asList("payment", "pay", "card", "upi", "cash", "demo"),
                "We accept Demo Credit/Debit cards, UPI, and Cash at the front desk. Please note that this educational application processes simulated demo payments only."
        ));
    }

    public ChatResponse processQuery(String userMessage) {
        if (userMessage == null || userMessage.trim().isEmpty()) {
            return new ChatResponse(
                    "Hello! I am SmartStay's Virtual Concierge. How may I assist your stay today?",
                    "Greeting",
                    true,
                    getDefaultSuggestions()
            );
        }

        String query = userMessage.toLowerCase().trim();

        // Check each rule by keyword matching
        FaqRule bestMatch = null;
        int maxKeywordHits = 0;

        for (FaqRule rule : RULES) {
            int hits = 0;
            for (String kw : rule.keywords) {
                if (query.contains(kw)) {
                    hits++;
                }
            }
            if (hits > maxKeywordHits) {
                maxKeywordHits = hits;
                bestMatch = rule;
            }
        }

        if (bestMatch != null && maxKeywordHits > 0) {
            return new ChatResponse(bestMatch.answer, bestMatch.category, true, getContextualSuggestions(bestMatch.category));
        }

        // Honest Fallback
        return new ChatResponse(
                "I am a rule-based concierge assistant and didn't find an exact match for your question. " +
                "You can ask about check-in hours, breakfast, cancellation rules, pool & gym, or airport transfers, " +
                "or reach out to our front desk team directly.",
                "Fallback",
                false,
                getDefaultSuggestions()
        );
    }

    private List<String> getDefaultSuggestions() {
        return Arrays.asList(
                "What are the check-in and check-out timings?",
                "Is breakfast included with the room?",
                "What is the cancellation policy?",
                "Is airport shuttle service available?"
        );
    }

    private List<String> getContextualSuggestions(String category) {
        switch (category) {
            case "Timings":
                return Arrays.asList("What is the cancellation policy?", "Is airport shuttle available?");
            case "Dining":
                return Arrays.asList("What time is breakfast served?", "Is room service available 24/7?");
            case "Cancellation":
                return Arrays.asList("How do I cancel my booking?", "What are the payment options?");
            default:
                return getDefaultSuggestions();
        }
    }
}

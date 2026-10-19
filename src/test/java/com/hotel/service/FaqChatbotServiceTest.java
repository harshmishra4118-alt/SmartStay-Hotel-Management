package com.hotel.service;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class FaqChatbotServiceTest {

    private final FaqChatbotService chatbotService = new FaqChatbotService();

    @Test
    public void testCheckInTimingIntent() {
        FaqChatbotService.ChatResponse resp = chatbotService.processQuery("What is the check in time?");
        assertTrue(resp.isMatched());
        assertEquals("Timings", resp.getCategory());
        assertTrue(resp.getAnswer().contains("2:00 PM"));
    }

    @Test
    public void testBreakfastIntent() {
        FaqChatbotService.ChatResponse resp = chatbotService.processQuery("Can I get breakfast buffet?");
        assertTrue(resp.isMatched());
        assertEquals("Dining", resp.getCategory());
        assertTrue(resp.getAnswer().contains("7:00 AM to 10:30 AM"));
    }

    @Test
    public void testCancellationPolicyIntent() {
        FaqChatbotService.ChatResponse resp = chatbotService.processQuery("How can I cancel my reservation?");
        assertTrue(resp.isMatched());
        assertEquals("Cancellation", resp.getCategory());
    }

    @Test
    public void testFallbackIntent() {
        FaqChatbotService.ChatResponse resp = chatbotService.processQuery("Quantum physics algorithms");
        assertFalse(resp.isMatched());
        assertEquals("Fallback", resp.getCategory());
        assertNotNull(resp.getSuggestedQuestions());
        assertFalse(resp.getSuggestedQuestions().isEmpty());
    }
}

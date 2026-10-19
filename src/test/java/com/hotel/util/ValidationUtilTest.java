package com.hotel.util;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

public class ValidationUtilTest {

    @Test
    public void testEmailValidation() {
        assertTrue(ValidationUtil.isValidEmail("guest@aurastay.com"));
        assertTrue(ValidationUtil.isValidEmail("user.name+tag@domain.co.uk"));
        assertFalse(ValidationUtil.isValidEmail("invalid-email"));
        assertFalse(ValidationUtil.isValidEmail("@domain.com"));
        assertFalse(ValidationUtil.isValidEmail("user@.com"));
        assertFalse(ValidationUtil.isValidEmail(""));
        assertFalse(ValidationUtil.isValidEmail(null));
    }

    @Test
    public void testPhoneValidation() {
        assertTrue(ValidationUtil.isValidPhone("+91 98765 43210"));
        assertTrue(ValidationUtil.isValidPhone("123-456-7890"));
        assertTrue(ValidationUtil.isValidPhone("+1 (555) 019-2834"));
        assertFalse(ValidationUtil.isValidPhone("abc"));
        assertFalse(ValidationUtil.isValidPhone("123")); // too short
        assertFalse(ValidationUtil.isValidPhone(null));
    }

    @Test
    public void testDateRangeValidation() {
        LocalDate today = LocalDate.now();
        LocalDate tomorrow = today.plusDays(1);
        LocalDate threeDaysLater = today.plusDays(3);
        LocalDate yesterday = today.minusDays(1);

        assertTrue(ValidationUtil.isValidDateRange(today, tomorrow));
        assertTrue(ValidationUtil.isValidDateRange(tomorrow, threeDaysLater));

        // Past check-in should be rejected
        assertFalse(ValidationUtil.isValidDateRange(yesterday, tomorrow));

        // Checkout before check-in should be rejected
        assertFalse(ValidationUtil.isValidDateRange(threeDaysLater, tomorrow));

        // Same day check-in and check-out should be rejected (must be at least 1 night)
        assertFalse(ValidationUtil.isValidDateRange(today, today));

        // Null checks
        assertFalse(ValidationUtil.isValidDateRange(null, tomorrow));
        assertFalse(ValidationUtil.isValidDateRange(today, null));
    }

    @Test
    public void testCsvFormulaInjectionProtection() {
        // Cells starting with dangerous symbols should be prepended with a single quote
        String formula1 = "=cmd|' /C calc'!A0";
        String escaped1 = ValidationUtil.escapeForCsv(formula1);
        assertTrue(escaped1.startsWith("\"'="), "Formula starting with = must be neutralized with apostrophe");

        String formula2 = "+1+2";
        String escaped2 = ValidationUtil.escapeForCsv(formula2);
        assertTrue(escaped2.startsWith("\"'+"), "Formula starting with + must be neutralized");

        String formula3 = "-2+3";
        String escaped3 = ValidationUtil.escapeForCsv(formula3);
        assertTrue(escaped3.startsWith("\"'-"), "Formula starting with - must be neutralized");

        String formula4 = "@SUM(A1:A10)";
        String escaped4 = ValidationUtil.escapeForCsv(formula4);
        assertTrue(escaped4.startsWith("\"'@"), "Formula starting with @ must be neutralized");

        // Normal strings should be quoted safely
        String normal = "AuraStay Deluxe Suite";
        assertEquals("\"AuraStay Deluxe Suite\"", ValidationUtil.escapeForCsv(normal));
    }

    @Test
    public void testHtmlEntityEscaping() {
        String unsafe = "<script>alert('xss');</script>&\"test\"";
        String safe = ValidationUtil.escapeHtml(unsafe);
        assertFalse(safe.contains("<script>"));
        assertTrue(safe.contains("&lt;script&gt;"));
        assertTrue(safe.contains("&amp;"));
        assertTrue(safe.contains("&quot;"));
        assertTrue(safe.contains("&#x27;"));
    }
}

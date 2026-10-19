package com.hotel.util;

import java.time.LocalDate;
import java.util.regex.Pattern;

/**
 * Robust input validation and security sanitization utilities.
 */
public class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}$"
    );

    private static final Pattern PHONE_PATTERN = Pattern.compile(
            "^[+]?[0-9\\s\\-().]{7,25}$"
    );

    private static final Pattern ROOM_NUMBER_PATTERN = Pattern.compile(
            "^[A-Za-z0-9\\-]{1,10}$"
    );

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null) return false;
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isValidRoomNumber(String roomNumber) {
        if (roomNumber == null) return false;
        return ROOM_NUMBER_PATTERN.matcher(roomNumber.trim()).matches();
    }

    public static boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }

    public static String safeTrim(String str) {
        return str == null ? "" : str.trim();
    }

    /**
     * Validates that check-in date is today or in the future,
     * check-out is after check-in, and total duration is <= 60 nights.
     */
    public static boolean isValidDateRange(LocalDate checkIn, LocalDate checkOut) {
        if (checkIn == null || checkOut == null) {
            return false;
        }
        LocalDate today = LocalDate.now();
        if (checkIn.isBefore(today)) {
            return false;
        }
        if (!checkOut.isAfter(checkIn)) {
            return false;
        }
        long nights = java.time.temporal.ChronoUnit.DAYS.between(checkIn, checkOut);
        return nights >= 1 && nights <= 60;
    }

    /**
     * Sanitizes strings for CSV export to prevent spreadsheet formula injection.
     * Prevents attacks where cells starting with =, +, -, @, tab, or carriage return execute formulas.
     */
    public static String escapeForCsv(String value) {
        if (value == null) {
            return "\"\"";
        }
        String clean = value.replace("\r", " ").replace("\n", " ");

        // If cell starts with dangerous formula symbols, prepend an apostrophe
        if (clean.startsWith("=") || clean.startsWith("+") || clean.startsWith("-") || 
            clean.startsWith("@") || clean.startsWith("\t")) {
            clean = "'" + clean;
        }

        // Escape double quotes by doubling them
        clean = clean.replace("\"", "\"\"");
        return "\"" + clean + "\"";
    }

    /**
     * HTML entity escaping for XSS prevention.
     */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder(input.length());
        for (char c : input.toCharArray()) {
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#x27;"); break;
                case '/': sb.append("&#x2F;"); break;
                default: sb.append(c); break;
            }
        }
        return sb.toString();
    }
}

package com.hotel.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for secure BCrypt password hashing and verification.
 * Uses 12 log rounds for strong cryptographic resistance.
 */
public class PasswordUtil {

    private static final int LOG_ROUNDS = 12;

    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(LOG_ROUNDS));
    }

    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }

    public static void main(String[] args) {
        System.out.println("admin123=" + hashPassword("admin123"));
        System.out.println("owner123=" + hashPassword("owner123"));
        System.out.println("staff123=" + hashPassword("staff123"));
        System.out.println("customer123=" + hashPassword("customer123"));
    }
}

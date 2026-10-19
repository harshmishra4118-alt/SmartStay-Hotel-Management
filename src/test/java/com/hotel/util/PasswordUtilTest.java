package com.hotel.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    public void testPasswordHashingAndVerification() {
        String plain = "TestSecret#2026";
        String hashed = PasswordUtil.hashPassword(plain);

        assertNotNull(hashed);
        assertTrue(hashed.startsWith("$2a$12$"), "BCrypt hash should start with $2a$12$");
        assertTrue(PasswordUtil.verifyPassword(plain, hashed));
        assertFalse(PasswordUtil.verifyPassword("WrongPassword", hashed));
        assertFalse(PasswordUtil.verifyPassword("", hashed));
        assertFalse(PasswordUtil.verifyPassword(null, hashed));
    }

    @Test
    public void testEmptyPasswordThrows() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(""));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
    }
}

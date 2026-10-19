package com.hotel.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.util.Properties;

/**
 * Central application configuration loader.
 * Prioritizes environment variables, then db.properties on classpath, then default fallbacks.
 */
public class AppConfig {

    private static final Logger logger = LoggerFactory.getLogger(AppConfig.class);
    private static final Properties properties = new Properties();

    static {
        loadProperties();
    }

    private static void loadProperties() {
        try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                properties.load(in);
                logger.info("Loaded configuration from db.properties");
            } else {
                logger.warn("db.properties not found on classpath, checking db.properties.example or environment");
                try (InputStream exIn = AppConfig.class.getClassLoader().getResourceAsStream("db.properties.example")) {
                    if (exIn != null) {
                        properties.load(exIn);
                        logger.info("Loaded default configuration from db.properties.example");
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Failed to load database properties file", e);
        }
    }

    public static String get(String key, String defaultValue) {
        // First check environment variables (converting db.url -> DB_URL)
        String envKey = key.toUpperCase().replace('.', '_');
        String envVal = System.getenv(envKey);
        if (envVal != null && !envVal.trim().isEmpty()) {
            return envVal.trim();
        }

        // Then check system properties
        String sysVal = System.getProperty(key);
        if (sysVal != null && !sysVal.trim().isEmpty()) {
            return sysVal.trim();
        }

        // Then check loaded properties file
        return properties.getProperty(key, defaultValue);
    }

    public static int getInt(String key, int defaultValue) {
        String val = get(key, String.valueOf(defaultValue));
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            logger.warn("Invalid integer value for key '{}': {}. Falling back to default: {}", key, val, defaultValue);
            return defaultValue;
        }
    }

    public static long getLong(String key, long defaultValue) {
        String val = get(key, String.valueOf(defaultValue));
        try {
            return Long.parseLong(val.trim());
        } catch (NumberFormatException e) {
            logger.warn("Invalid long value for key '{}': {}. Falling back to default: {}", key, val, defaultValue);
            return defaultValue;
        }
    }
}

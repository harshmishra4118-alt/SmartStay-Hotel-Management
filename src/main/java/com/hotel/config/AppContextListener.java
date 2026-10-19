package com.hotel.config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;

/**
 * Servlet Context Listener to manage lifecycle resources like HikariCP and JDBC drivers.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger logger = LoggerFactory.getLogger(AppContextListener.class);

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("===============================================================");
        logger.info("Initializing Smart Hotel Management System (AuraStay)...");
        logger.info("===============================================================");
        try {
            // Eagerly test database connection
            DatabaseConfig.getDataSource();
            logger.info("Database connection pool established successfully.");
        } catch (Exception e) {
            logger.warn("Database connection could not be immediately verified on startup. " +
                        "Application will retry on first request. Reason: {}", e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("Shutting down Smart Hotel Management System...");
        DatabaseConfig.shutdown();

        // Deregister JDBC drivers to prevent memory leaks in Tomcat
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            try {
                DriverManager.deregisterDriver(driver);
                logger.info("Deregistered JDBC driver: {}", driver);
            } catch (Exception e) {
                logger.warn("Error deregistering JDBC driver {}: {}", driver, e.getMessage());
            }
        }
        logger.info("Smart Hotel Management System context destroyed.");
    }
}

package com.hotel.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Thread-safe singleton for HikariCP JDBC Connection Pool.
 */
public class DatabaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);
    private static volatile HikariDataSource dataSource = null;
    private static final Object lock = new Object();

    private DatabaseConfig() {
        // Utility / Singleton class
    }

    public static DataSource getDataSource() {
        if (dataSource == null) {
            synchronized (lock) {
                if (dataSource == null) {
                    initDataSource();
                }
            }
        }
        return dataSource;
    }

    private static void initDataSource() {
        try {
            logger.info("Initializing HikariCP DataSource...");
            HikariConfig config = new HikariConfig();

            String driver = AppConfig.get("db.driver", "com.mysql.cj.jdbc.Driver");
            String url = AppConfig.get("db.url", "jdbc:mysql://localhost:3306/smart_hotel_management?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8");
            String user = AppConfig.get("db.username", "root");
            String pass = AppConfig.get("db.password", "root");

            config.setDriverClassName(driver);
            config.setJdbcUrl(url);
            config.setUsername(user);
            config.setPassword(pass);

            // Pool settings
            int maxPoolSize = AppConfig.getInt("db.pool.maximumPoolSize", 15);
            int minIdle = AppConfig.getInt("db.pool.minimumIdle", 3);
            long idleTimeout = AppConfig.getLong("db.pool.idleTimeoutMs", 300000L);
            long connTimeout = AppConfig.getLong("db.pool.connectionTimeoutMs", 20000L);
            long maxLifetime = AppConfig.getLong("db.pool.maxLifetimeMs", 1800000L);

            config.setMaximumPoolSize(maxPoolSize);
            config.setMinimumIdle(minIdle);
            config.setIdleTimeout(idleTimeout);
            config.setConnectionTimeout(connTimeout);
            config.setMaxLifetime(maxLifetime);
            config.setPoolName("AuraStay-HikariPool");

            // Recommended MySQL performance properties
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");
            config.addDataSourceProperty("useLocalSessionState", "true");
            config.addDataSourceProperty("rewriteBatchedStatements", "true");
            config.addDataSourceProperty("cacheResultSetMetadata", "true");
            config.addDataSourceProperty("cacheServerConfiguration", "true");
            config.addDataSourceProperty("elideSetAutoCommits", "true");
            config.addDataSourceProperty("maintainTimeStats", "false");

            dataSource = new HikariDataSource(config);
            logger.info("HikariCP DataSource initialized successfully with pool size {}", maxPoolSize);

        } catch (Exception e) {
            logger.error("CRITICAL: Failed to initialize database connection pool", e);
            throw new RuntimeException("Could not initialize database connection pool", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return getDataSource().getConnection();
    }

    public static void shutdown() {
        synchronized (lock) {
            if (dataSource != null && !dataSource.isClosed()) {
                logger.info("Closing HikariCP DataSource...");
                dataSource.close();
                dataSource = null;
                logger.info("HikariCP DataSource closed.");
            }
        }
    }
}

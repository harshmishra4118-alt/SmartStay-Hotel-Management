package com.hotel.dao;

import com.hotel.config.DatabaseConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Base DAO providing standard connection management and safe resource cleanup.
 */
public abstract class BaseDAO {

    protected final Logger logger = LoggerFactory.getLogger(getClass());

    protected Connection getConnection() throws SQLException {
        return DatabaseConfig.getConnection();
    }

    protected void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { logger.warn("Failed to close ResultSet", e); }
        }
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException e) { logger.warn("Failed to close Statement", e); }
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { logger.warn("Failed to close Connection", e); }
        }
    }

    protected void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }

    protected void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
                logger.info("Transaction rolled back successfully.");
            } catch (SQLException e) {
                logger.error("Failed to rollback transaction", e);
            }
        }
    }
}

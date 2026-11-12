-- =====================================================================
-- SMART HOTEL MANAGEMENT SYSTEM (SmartStay Multi-Hotel Platform)
-- Database: smart_hotel_management
-- Target: MySQL 8.0+
-- Character Set: utf8mb4 / utf8mb4_unicode_ci
-- =====================================================================

CREATE DATABASE IF NOT EXISTS smart_hotel_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE smart_hotel_management;

-- ---------------------------------------------------------------------
-- 1. Table: users
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(191) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('CUSTOMER', 'STAFF', 'ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_role (role),
    INDEX idx_users_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. Table: customer_profiles
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customer_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    id_document_type VARCHAR(50) DEFAULT 'PASSPORT',
    id_document_number VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    postal_code VARCHAR(20),
    emergency_contact VARCHAR(100),
    preferences_notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_profile_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. Table: hotels (Multi-Hotel Core Entity)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hotels (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    tagline VARCHAR(255),
    description TEXT NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    postal_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    star_rating DECIMAL(2, 1) NOT NULL DEFAULT 4.5,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(191) NOT NULL,
    primary_image_url VARCHAR(500) NOT NULL,
    min_price DECIMAL(10, 2) NOT NULL DEFAULT 3500.00,
    max_price DECIMAL(10, 2) NOT NULL DEFAULT 35000.00,
    checkin_time VARCHAR(20) NOT NULL DEFAULT '14:00',
    checkout_time VARCHAR(20) NOT NULL DEFAULT '11:00',
    cancellation_policy TEXT,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_hotels_city (city),
    INDEX idx_hotels_status (status),
    INDEX idx_hotels_rating (star_rating),
    INDEX idx_hotels_price (min_price, max_price),
    INDEX idx_hotels_coords (latitude, longitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. Table: hotel_images (Multi-Category Gallery)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hotel_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hotel_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    category ENUM('EXTERIOR', 'BEDROOM', 'DELUXE_ROOM', 'LUXURY_SUITE', 'BATHROOM', 'SWIMMING_POOL', 'RESTAURANT', 'RECEPTION', 'FACILITY', 'OTHER') NOT NULL DEFAULT 'EXTERIOR',
    caption VARCHAR(200),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_images_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE CASCADE,
    INDEX idx_hotel_images_hotel_cat (hotel_id, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. Table: hotel_facilities
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hotel_facilities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hotel_id BIGINT NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    facility_icon VARCHAR(50) NOT NULL DEFAULT 'bi-check-circle',
    is_highlighted BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_hotel_facilities_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE CASCADE,
    INDEX idx_hotel_facilities_hotel (hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. Table: staff_details
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS staff_details (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    employee_code VARCHAR(50) NOT NULL UNIQUE,
    department ENUM('FRONT_DESK', 'HOUSEKEEPING', 'MANAGEMENT', 'MAINTENANCE') NOT NULL DEFAULT 'FRONT_DESK',
    hire_date DATE NULL,
    shift ENUM('MORNING', 'EVENING', 'NIGHT', 'ROTATING') NOT NULL DEFAULT 'MORNING',
    emergency_phone VARCHAR(30),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_details_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 7. Table: hotel_staff_assignments (Hotel Scoped Staffing)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hotel_staff_assignments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hotel_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    assigned_role VARCHAR(50) NOT NULL DEFAULT 'STAFF',
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_assign_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_assign_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_staff_hotel (hotel_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 8. Table: rooms
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rooms (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hotel_id BIGINT NOT NULL DEFAULT 1,
    room_number VARCHAR(20) NOT NULL,
    room_type ENUM('STANDARD', 'DELUXE', 'EXECUTIVE_SUITE', 'PRESIDENTIAL_SUITE', 'FAMILY_STUDIO') NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price_per_night DECIMAL(10, 2) NOT NULL,
    capacity INT NOT NULL DEFAULT 2,
    bed_type VARCHAR(50) NOT NULL DEFAULT 'King Bed',
    size_sqft INT NOT NULL DEFAULT 350,
    floor_number INT NOT NULL DEFAULT 1,
    operational_status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
    housekeeping_status ENUM('CLEAN', 'DIRTY', 'INSPECTING', 'OUT_OF_SERVICE') NOT NULL DEFAULT 'CLEAN',
    primary_image_url VARCHAR(500),
    amenities TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rooms_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE CASCADE,
    UNIQUE KEY uk_hotel_room_number (hotel_id, room_number),
    INDEX idx_rooms_hotel (hotel_id),
    INDEX idx_rooms_type (room_type),
    INDEX idx_rooms_operational (operational_status),
    INDEX idx_rooms_housekeeping (housekeeping_status),
    INDEX idx_rooms_capacity (capacity),
    INDEX idx_rooms_price (price_per_night)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 9. Table: room_images
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS room_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(150),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_room_images_room FOREIGN KEY (room_id) 
        REFERENCES rooms(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 10. Table: bookings
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bookings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(30) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    hotel_id BIGINT NOT NULL DEFAULT 1,
    room_id BIGINT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_nights INT NOT NULL,
    num_guests INT NOT NULL DEFAULT 1,
    guest_name VARCHAR(150) NOT NULL,
    guest_email VARCHAR(191) NOT NULL,
    guest_phone VARCHAR(30) NOT NULL,
    room_price_per_night DECIMAL(10, 2) NOT NULL,
    base_amount DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    booking_status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
    special_requests TEXT,
    cancellation_reason TEXT,
    cancelled_at DATETIME NULL,
    checked_in_at DATETIME NULL,
    checked_out_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_room FOREIGN KEY (room_id) 
        REFERENCES rooms(id) ON DELETE RESTRICT,
    INDEX idx_bookings_dates (check_in_date, check_out_date),
    INDEX idx_bookings_status (booking_status),
    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_hotel (hotel_id),
    INDEX idx_bookings_room (room_id),
    INDEX idx_bookings_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 11. Table: invoices
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(40) NOT NULL UNIQUE,
    booking_id BIGINT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    issue_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal_amount DECIMAL(10, 2) NOT NULL,
    tax_rate DECIMAL(5, 2) NOT NULL DEFAULT 12.00,
    tax_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_payable DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('UNPAID', 'PARTIAL', 'PAID', 'REFUNDED') NOT NULL DEFAULT 'UNPAID',
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoices_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings(id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoices_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_invoices_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 12. Table: payments
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_reference VARCHAR(40) NOT NULL UNIQUE,
    invoice_id BIGINT NOT NULL,
    booking_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('CREDIT_CARD_DEMO', 'DEBIT_CARD_DEMO', 'UPI_DEMO', 'CASH', 'BANK_TRANSFER_DEMO', 'RAZORPAY') NOT NULL DEFAULT 'CREDIT_CARD_DEMO',
    payment_status ENUM('SUCCESS', 'PENDING', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'SUCCESS',
    transaction_notes VARCHAR(255),
    is_demo BOOLEAN NOT NULL DEFAULT TRUE,
    paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id) 
        REFERENCES invoices(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings(id) ON DELETE RESTRICT,
    INDEX idx_payments_status (payment_status),
    INDEX idx_payments_invoice (invoice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 13. Table: payment_transactions (Razorpay Payment Architecture)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payment_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    transaction_reference VARCHAR(100) NOT NULL UNIQUE,
    gateway_order_id VARCHAR(100) NULL,
    gateway_payment_id VARCHAR(100) NULL,
    gateway_signature VARCHAR(255) NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50) NOT NULL DEFAULT 'RAZORPAY',
    refund_id VARCHAR(100) NULL,
    refund_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    error_description TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pay_trans_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings(id) ON DELETE RESTRICT,
    INDEX idx_pay_trans_status (status),
    INDEX idx_pay_trans_order (gateway_order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 14. Table: feedback (Hotel Reviews)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    hotel_id BIGINT NOT NULL DEFAULT 1,
    room_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    cleanliness_rating INT NOT NULL CHECK (cleanliness_rating BETWEEN 1 AND 5),
    service_rating INT NOT NULL CHECK (service_rating BETWEEN 1 AND 5),
    amenities_rating INT NOT NULL CHECK (amenities_rating BETWEEN 1 AND 5),
    comments TEXT NOT NULL,
    sentiment_label ENUM('POSITIVE', 'NEUTRAL', 'NEGATIVE') NOT NULL DEFAULT 'POSITIVE',
    rule_keywords_matched VARCHAR(255),
    is_approved BOOLEAN NOT NULL DEFAULT TRUE,
    admin_reply TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_room FOREIGN KEY (room_id) 
        REFERENCES rooms(id) ON DELETE CASCADE,
    INDEX idx_feedback_hotel (hotel_id),
    INDEX idx_feedback_rating (rating),
    INDEX idx_feedback_approved (is_approved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 15. Table: hotel_favorites
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hotel_favorites (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    hotel_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_favorites_hotel FOREIGN KEY (hotel_id) 
        REFERENCES hotels(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_hotel_fav (user_id, hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 16. Table: otp_verifications
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS otp_verifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(191) NOT NULL,
    otp_hash VARCHAR(255) NOT NULL,
    otp_type ENUM('REGISTRATION', 'LOGIN', 'PASSWORD_RESET') NOT NULL,
    attempts INT NOT NULL DEFAULT 0,
    resend_count INT NOT NULL DEFAULT 0,
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    expires_at DATETIME NOT NULL,
    last_sent_at DATETIME NOT NULL,
    user_metadata TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_otp_lookup (email, otp_type, is_used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 17. Table: coupons
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coupons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    discount_type ENUM('PERCENTAGE', 'FIXED_AMOUNT') NOT NULL DEFAULT 'PERCENTAGE',
    discount_value DECIMAL(10, 2) NOT NULL,
    min_booking_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    max_discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 5000.00,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    usage_limit INT NOT NULL DEFAULT 1000,
    used_count INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_coupons_code (code, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 18. Table: notifications
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('BOOKING', 'PAYMENT', 'CHECKIN', 'CHECKOUT', 'SYSTEM') NOT NULL DEFAULT 'BOOKING',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    reference_link VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_user_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 19. Table: audit_logs
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(50),
    details TEXT,
    ip_address VARCHAR(45),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_audit_action (action),
    INDEX idx_audit_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 20. Table: application_settings
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS application_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT NOT NULL,
    description VARCHAR(255),
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

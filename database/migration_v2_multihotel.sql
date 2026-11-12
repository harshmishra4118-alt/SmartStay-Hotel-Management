-- =====================================================================
-- SMARTSTAY HOTEL MANAGEMENT SYSTEM - DATABASE MIGRATION V2 (MULTI-HOTEL)
-- Target: MySQL 8.0+ / utf8mb4
-- Description: Upgrades single-hotel schema to multi-hotel discovery,
--              booking, geolocation, OTP authentication, and Razorpay transactions.
-- =====================================================================

USE smart_hotel_management;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. Table: hotels
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
-- 2. Table: hotel_images
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
-- 3. Table: hotel_facilities
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
-- 4. Table: hotel_staff_assignments
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
-- 5. Table: hotel_favorites
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
-- 6. Table: otp_verifications
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
-- 7. Table: payment_transactions (Razorpay & Online Architecture)
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
-- 8. Table: coupons
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
-- 9. Table Modifications for Multi-Hotel Support
-- ---------------------------------------------------------------------

-- Alter rooms to associate each room with a hotel
SET @dbname = DATABASE();
SET @tablename = "rooms";
SET @columnname = "hotel_id";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE rooms ADD COLUMN hotel_id BIGINT NOT NULL DEFAULT 1 AFTER id"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Alter bookings to associate each booking with a hotel directly
SET @tablename = "bookings";
SET @columnname = "hotel_id";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE bookings ADD COLUMN hotel_id BIGINT NULL AFTER user_id"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Alter feedback to associate review with a hotel directly
SET @tablename = "feedback";
SET @columnname = "hotel_id";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE feedback ADD COLUMN hotel_id BIGINT NULL AFTER booking_id"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- SEED DATA: 6 REALISTIC LUXURY DESTINATIONS ACROSS INDIA
-- =====================================================================

-- 1. Insert Hotels
INSERT INTO hotels (id, name, tagline, description, address, city, state, country, postal_code, latitude, longitude, star_rating, phone, email, primary_image_url, min_price, max_price, checkin_time, checkout_time, cancellation_policy, status, is_featured) VALUES
(1, 'SmartStay Grand Palace & Spa', 'Where Timeless Elegance Meets Bayfront Luxury', 
 'An iconic landmark nestled along the prestigious Marine Drive promenade. SmartStay Grand Palace & Spa offers panoramic views of the Arabian Sea, opulent colonial-modern suites, an Olympic-size horizon pool, Michelin-inspired dining, and our signature Ayurvedic Wellness Haven.',
 '742 Marine Drive, Promenade District', 'Mumbai', 'Maharashtra', 'India', '400020', 
 18.92200000, 72.83470000, 4.9, '+91 (022) 8900 1200', 'mumbai@smartstay.com',
 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
 4200.00, 35000.00, '14:00', '11:00',
 'Free cancellation up to 24 hours before check-in. Non-refundable for same-day cancellations.', 'ACTIVE', TRUE),

(2, 'SmartStay Royal Heritage Palace', 'Regal Splendor in the Historic Heart of the Pink City', 
 'Experience aristocratic Rajasthani royalty reimagined with modern 5-star smart automation. Featuring hand-carved jharokhas, courtyards illuminated by evening diya ceremonies, an azure marble courtyard pool, and traditional royal thali dining.',
 '15 Palace Road, Near City Palace', 'Jaipur', 'Rajasthan', 'India', '302002', 
 26.91240000, 75.78730000, 4.8, '+91 (141) 7788 9900', 'jaipur@smartstay.com',
 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1200&q=80',
 3800.00, 28000.00, '14:00', '11:00',
 'Complimentary cancellation up to 48 hours prior to arrival. 1-night deposit for late cancellations.', 'ACTIVE', TRUE),

(3, 'SmartStay Silicon Valley Tech Suites', 'Next-Gen Luxury for Visionaries and Global Leaders', 
 'Situated in Bangalore prime high-tech corridor, offering voice-activated smart automation, ergonomic executive workstations, ultra-high-speed fiber connectivity, a 24-hour rooftop sky lounge, and state-of-the-art conference auditoriums.',
 '88 Outer Ring Road, Whitefield Tech Zone', 'Bengaluru', 'Karnataka', 'India', '560066', 
 12.97160000, 77.59460000, 4.7, '+91 (080) 6677 8899', 'bengaluru@smartstay.com',
 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
 3500.00, 22000.00, '13:00', '12:00',
 'Free cancellation up to 12 hours before check-in for registered business guests.', 'ACTIVE', TRUE),

(4, 'SmartStay Himalayan Alpine Sanctuary', 'Pristine Snow Peaks, Pine Fragrance, and Fireside Luxury', 
 'Set amidst whispering cedar forests with breathtaking panoramic vistas of the Solang Valley. Features heated timber suites, stone fireplaces, private cedarwood balconies, open-air hot spring jacuzzis, and guided alpine treks.',
 'Alpine Ridge Way, Upper Solang', 'Manali', 'Himachal Pradesh', 'India', '175131', 
 32.24320000, 77.18920000, 4.9, '+91 (1902) 255 100', 'manali@smartstay.com',
 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
 4800.00, 32000.00, '14:00', '11:00',
 'Free cancellation up to 72 hours prior to arrival during winter peak season.', 'ACTIVE', TRUE),

(5, 'SmartStay Emerald Coastline Beach Resort', 'Sun-Kissed Sands, Tropical Azure Waters, and Coastal Bliss', 
 'Direct private beach access on the serene golden sands of Candolim. Enjoy private plunge pool villas, beachside cabanas, fresh seafood shacks, sunset cocktails, and water sport concierge services.',
 '24 Coastal Serenity Avenue, Candolim Beach', 'Goa', 'Goa', 'India', '403515', 
 15.51860000, 73.76810000, 4.8, '+91 (832) 244 5500', 'goa@smartstay.com',
 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
 5200.00, 38000.00, '15:00', '11:00',
 'Free cancellation up to 48 hours prior to arrival date.', 'ACTIVE', TRUE),

(6, 'SmartStay Capital Diplomatic Court', 'Imperial Grandeur in the Heart of India Power Center', 
 'Located moments from Connaught Place and India Gate. A favorite among diplomats, state guests, and luxury travelers. Featuring bulletproof diplomatic suites, a Grand Ballroom, high-security private wings, and bespoke butler service.',
 '12 Barakhamba Road, Connaught Place', 'New Delhi', 'Delhi', 'India', '110001', 
 28.63150000, 77.21670000, 4.8, '+91 (011) 4321 0000', 'delhi@smartstay.com',
 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
 4600.00, 34000.00, '14:00', '12:00',
 'Free cancellation up to 24 hours prior to check-in.', 'ACTIVE', TRUE)
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    tagline = VALUES(tagline),
    description = VALUES(description),
    address = VALUES(address),
    city = VALUES(city),
    latitude = VALUES(latitude),
    longitude = VALUES(longitude),
    star_rating = VALUES(star_rating),
    primary_image_url = VALUES(primary_image_url),
    min_price = VALUES(min_price),
    max_price = VALUES(max_price);

-- ---------------------------------------------------------------------
-- 2. Populate Comprehensive Hotel Image Galleries (Distinct photos per hotel)
-- Categories: EXTERIOR, BEDROOM, DELUXE_ROOM, LUXURY_SUITE, BATHROOM, 
--             SWIMMING_POOL, RESTAURANT, RECEPTION, FACILITY
-- ---------------------------------------------------------------------
DELETE FROM hotel_images;

INSERT INTO hotel_images (hotel_id, image_url, category, caption, is_primary, display_order) VALUES
-- Hotel 1: Mumbai Grand Palace
(1, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 'Illuminated Bayfront Facade along Marine Drive', TRUE, 1),
(1, 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80', 'LUXURY_SUITE', 'Presidential Bay View Master Suite', FALSE, 2),
(1, 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'BEDROOM', 'Classic City King Bedroom with Plush Italian Linens', FALSE, 3),
(1, 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=1200&q=80', 'DELUXE_ROOM', 'Deluxe Twin Studio with Skyline View', FALSE, 4),
(1, 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=1200&q=80', 'BATHROOM', 'Carrara Marble Spa En-Suite with Deep Soaking Tub', FALSE, 5),
(1, 'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=1200&q=80', 'SWIMMING_POOL', 'Horizon Ocean-Facing Heated Infinity Pool', FALSE, 6),
(1, 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80', 'RESTAURANT', 'The Promenade Fine Dining & Sunset Wine Cellar', FALSE, 7),
(1, 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80', 'RECEPTION', 'Grand Crystal Chandelier Concierge Reception', FALSE, 8),
(1, 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?auto=format&fit=crop&w=1200&q=80', 'FACILITY', 'Holistic Ayurvedic Spa & Hydrotherapy Sanctuary', FALSE, 9),

-- Hotel 2: Jaipur Royal Heritage
(2, 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 'Heritage Sandstone Palace Facade and Jharokhas', TRUE, 1),
(2, 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80', 'LUXURY_SUITE', 'Maharaja Royal Courtyard Suite', FALSE, 2),
(2, 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'BEDROOM', 'Heritage King Bed with Hand-Woven Silk Drapes', FALSE, 3),
(2, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'DELUXE_ROOM', 'Royal Garden View Deluxe Room', FALSE, 4),
(2, 'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?auto=format&fit=crop&w=1200&q=80', 'BATHROOM', 'Royal Copper Soaking Tub and Brass Fittings', FALSE, 5),
(2, 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80', 'SWIMMING_POOL', 'Courtyard Marble Pool Surrounded by Frangipani Trees', FALSE, 6),
(2, 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=1200&q=80', 'RESTAURANT', 'Darbar Hall Authentic Royal Cuisine Dining', FALSE, 7),
(2, 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80', 'RECEPTION', 'Traditional Marble Arch Welcome Pavilion', FALSE, 8),
(2, 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=1200&q=80', 'FACILITY', 'Private Royal Courtyard with Folk Music Pavilions', FALSE, 9),

-- Hotel 3: Bengaluru Tech Suites
(3, 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 'Sleek Glass and Steel Architectural Tower in Whitefield', TRUE, 1),
(3, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80', 'LUXURY_SUITE', 'Silicon Executive Smart Penthouse Suite', FALSE, 2),
(3, 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'BEDROOM', 'Modern Ergonomic King Bedroom with Smart Lighting', FALSE, 3),
(3, 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1200&q=80', 'DELUXE_ROOM', 'Tech Deluxe Studio with Dual 4K Displays', FALSE, 4),
(3, 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?auto=format&fit=crop&w=1200&q=80', 'BATHROOM', 'Minimalist Glass Walk-In Rain Shower En-Suite', FALSE, 5),
(3, 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=1200&q=80', 'SWIMMING_POOL', 'Rooftop Heated Glass-Edge Pool Overlooking Skyline', FALSE, 6),
(3, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80', 'RESTAURANT', 'The Algorithm Bistro & Craft Microbrewery Lounge', FALSE, 7),
(3, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80', 'RECEPTION', 'Futuristic Digital Check-in Concierge Bar', FALSE, 8),
(3, 'https://images.unsplash.com/photo-1517502884422-41eaead166d4?auto=format&fit=crop&w=1200&q=80', 'FACILITY', '24/7 Co-Working Hub & Private Podcast Studios', FALSE, 9),

-- Hotel 4: Manali Alpine Sanctuary
(4, 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 'Alpine Wooden Chalet Surrounded by Snow-Capped Pines', TRUE, 1),
(4, 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80', 'LUXURY_SUITE', 'Solang Panoramic Mountain Penthouse with Fireplace', FALSE, 2),
(4, 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'BEDROOM', 'Cedar Wood King Room with Mountain Balcony', FALSE, 3),
(4, 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=1200&q=80', 'DELUXE_ROOM', 'Alpine Deluxe Room with Heated Oak Floors', FALSE, 4),
(4, 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=1200&q=80', 'BATHROOM', 'Cedar Scented Jacuzzi Spa Bathroom', FALSE, 5),
(4, 'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=1200&q=80', 'SWIMMING_POOL', 'Open-Air Steaming Thermal Hot Spring Jacuzzi', FALSE, 6),
(4, 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80', 'RESTAURANT', 'The Timber Lodge Fireside Grill & Mulled Cider Bar', FALSE, 7),
(4, 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80', 'RECEPTION', 'Rustic Stone Fireplace Lodge Reception', FALSE, 8),
(4, 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?auto=format&fit=crop&w=1200&q=80', 'FACILITY', 'Ski Equipment Room and Private Stargazing Deck', FALSE, 9),

-- Hotel 5: Goa Beach Resort
(5, 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 'Beachfront Palm Oasis with Direct Sand Shoreline Access', TRUE, 1),
(5, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80', 'LUXURY_SUITE', 'Private Plunge Pool Oceanfront Cabana Suite', FALSE, 2),
(5, 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'BEDROOM', 'Coastal Boho King Bed with Sea Breeze Veranda', FALSE, 3),
(5, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'DELUXE_ROOM', 'Tropical Garden View Deluxe Bungalow', FALSE, 4),
(5, 'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?auto=format&fit=crop&w=1200&q=80', 'BATHROOM', 'Outdoor Open-Sky Rain Shower Under Palm Canopies', FALSE, 5),
(5, 'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=1200&q=80', 'SWIMMING_POOL', 'Lagoon Pool with Swim-Up Tiki Cocktail Bar', FALSE, 6),
(5, 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=1200&q=80', 'RESTAURANT', 'Candlelit Beach Shack Fresh Catch Grill', FALSE, 7),
(5, 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80', 'RECEPTION', 'Open-Air Thatched Tropical Arrival Lounge', FALSE, 8),
(5, 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=1200&q=80', 'FACILITY', 'Private Water Sports Deck and Catamaran Rentals', FALSE, 9),

-- Hotel 6: New Delhi Diplomatic Court
(6, 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 'Grand Classical Neoclassical White Facade in Connaught Place', TRUE, 1),
(6, 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'LUXURY_SUITE', 'Imperial Diplomatic Suite with Private Conference Boardroom', FALSE, 2),
(6, 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'BEDROOM', 'Ambassador King Bedroom with Teak Wood Paneling', FALSE, 3),
(6, 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=1200&q=80', 'DELUXE_ROOM', 'Diplomatic Deluxe Twin Studio', FALSE, 4),
(6, 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?auto=format&fit=crop&w=1200&q=80', 'BATHROOM', 'Gold-Trimmed Italian Marble Spa Bathroom', FALSE, 5),
(6, 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=1200&q=80', 'SWIMMING_POOL', 'Indoor Temperature-Controlled Olympic Lap Pool', FALSE, 6),
(6, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80', 'RESTAURANT', 'The Viceroy Hall Continental & Pan-Asian Dining', FALSE, 7),
(6, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80', 'RECEPTION', 'Secure Diplomatic Arrival Pavilion & Valet Porte-Cochere', FALSE, 8),
(6, 'https://images.unsplash.com/photo-1517502884422-41eaead166d4?auto=format&fit=crop&w=1200&q=80', 'FACILITY', 'Diplomatic Grand Ballroom & High-Security Helipad Access', FALSE, 9);

-- ---------------------------------------------------------------------
-- 3. Populate Hotel Facilities & Icons
-- ---------------------------------------------------------------------
DELETE FROM hotel_facilities;

INSERT INTO hotel_facilities (hotel_id, facility_name, facility_icon, is_highlighted) VALUES
-- Hotel 1 (Mumbai)
(1, 'High-Speed Wi-Fi', 'bi-wifi', TRUE),
(1, 'Infinity Swimming Pool', 'bi-water', TRUE),
(1, 'Fine Dining Restaurant', 'bi-cup-hot', TRUE),
(1, 'Luxury Spa & Sauna', 'bi-flower1', TRUE),
(1, '24/7 Room Service', 'bi-clock-history', TRUE),
(1, 'Valet Parking', 'bi-car-front', TRUE),
(1, 'Fitness Center & Gym', 'bi-activity', TRUE),
(1, 'Sea View Terrace', 'bi-binoculars', TRUE),
(1, 'Airport Chauffeur Shuttle', 'bi-airplane', FALSE),

-- Hotel 2 (Jaipur)
(2, 'High-Speed Wi-Fi', 'bi-wifi', TRUE),
(2, 'Marble Courtyard Pool', 'bi-water', TRUE),
(2, 'Royal Thali Dining', 'bi-cup-hot', TRUE),
(2, 'Evening Folk Shows', 'bi-music-note-beamed', TRUE),
(2, 'Ayurvedic Massage Centre', 'bi-flower1', TRUE),
(2, 'Heritage Guided Tours', 'bi-compass', TRUE),
(2, 'Free Valet Parking', 'bi-p-circle', TRUE),
(2, 'Air Conditioned Suites', 'bi-snow', TRUE),

-- Hotel 3 (Bengaluru)
(3, 'Ultra-Fast 1Gbps Fiber Wi-Fi', 'bi-wifi', TRUE),
(3, 'Rooftop Sky Pool', 'bi-water', TRUE),
(3, 'Smart In-Room Automation', 'bi-cpu', TRUE),
(3, '24/7 Executive Lounge', 'bi-briefcase', TRUE),
(3, 'Craft Brewery & Bistro', 'bi-cup-straw', TRUE),
(3, 'High-Tech Gym & Steam', 'bi-activity', TRUE),
(3, 'EV Charging Station', 'bi-ev-station', TRUE),
(3, 'Podcast & Media Studios', 'bi-mic', FALSE),

-- Hotel 4 (Manali)
(4, 'High-Speed Wi-Fi', 'bi-wifi', TRUE),
(4, 'Thermal Hot Spring Jacuzzi', 'bi-water', TRUE),
(4, 'Fireside Timber Grill', 'bi-fire', TRUE),
(4, 'Ski & Snowboard Concierge', 'bi-snow', TRUE),
(4, 'Panoramic Mountain View', 'bi-image', TRUE),
(4, 'Heated Timber Suites', 'bi-thermometer-sun', TRUE),
(4, 'Stargazing Balconies', 'bi-moon-stars', TRUE),
(4, 'Alpine Trek Guide', 'bi-compass', FALSE),

-- Hotel 5 (Goa)
(5, 'High-Speed Wi-Fi', 'bi-wifi', TRUE),
(5, 'Direct Beach Access', 'bi-umbrella', TRUE),
(5, 'Swim-Up Lagoon Bar', 'bi-cup-straw', TRUE),
(5, 'Fresh Seafood Shack', 'bi-egg-fried', TRUE),
(5, 'Water Sports & Jet Ski', 'bi-tsunami', TRUE),
(5, 'Open-Air Sunset Yoga', 'bi-peace', TRUE),
(5, 'Private Plunge Pool', 'bi-water', TRUE),
(5, 'Scooter & Car Rental', 'bi-bicycle', FALSE),

-- Hotel 6 (Delhi)
(6, 'High-Speed Wi-Fi', 'bi-wifi', TRUE),
(6, 'Indoor Olympic Lap Pool', 'bi-water', TRUE),
(6, 'Viceroy Continental Dining', 'bi-cup-hot', TRUE),
(6, 'Executive Boardrooms', 'bi-briefcase', TRUE),
(6, 'Bulletproof Diplomatic Wings', 'bi-shield-check', TRUE),
(6, '24/7 Personal Butler Service', 'bi-person-badge', TRUE),
(6, 'Secure VIP Valet Parking', 'bi-car-front', TRUE),
(6, 'Grand Banquet Ballroom', 'bi-bank', TRUE);

-- ---------------------------------------------------------------------
-- 4. Associate Existing Rooms with Hotel 1 (Mumbai) and Seed Rooms for other Hotels
-- ---------------------------------------------------------------------
UPDATE rooms SET hotel_id = 1 WHERE hotel_id IS NULL OR hotel_id = 0;

-- Insert distinctive rooms for Jaipur, Bengaluru, Manali, Goa, and Delhi
INSERT INTO rooms (id, hotel_id, room_number, room_type, name, description, price_per_night, capacity, bed_type, size_sqft, floor_number, operational_status, housekeeping_status, primary_image_url, amenities) VALUES
-- Jaipur (Hotel 2)
(9, 2, 'J-101', 'STANDARD', 'Heritage Courtyard King', 'Decorated with authentic block print textiles, teakwood furnishings, and modern air-conditioned comfort overlooking the palace garden.', 3800.00, 2, 'King Bed', 400, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'High-Speed Wi-Fi, Rajasthani Art, AC, LED TV, Rain Shower, Tea Station'),
(10, 2, 'J-201', 'DELUXE', 'Royal Jharokha Deluxe Suite', 'Featuring private marble balcony alcoves (jharokhas), deep soaking copper tub, and plush regal linens.', 6200.00, 2, 'King Bed', 540, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'Private Jharokha Balcony, Copper Soaking Tub, High-Speed Wi-Fi, Handcrafted Bar, Smart TV'),
(11, 2, 'J-301', 'EXECUTIVE_SUITE', 'Maharaja Palace Suite', 'Spectacular high ceilings, carved archways, private dining chamber, and personal valet service.', 14500.00, 4, 'Royal Four-Poster King', 950, 3, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80', 'Private Dining Chamber, Four-Poster Bed, Jacuzzi, Butler Service, Folk Music Lounge Access'),

-- Bengaluru (Hotel 3)
(12, 3, 'B-101', 'STANDARD', 'Silicon Smart Studio', 'Optimized for productivity with high-speed mesh Wi-Fi, ergonomic Herman Miller chair, and automated climate controls.', 3500.00, 2, 'Queen Bed', 350, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1200&q=80', '1Gbps Wi-Fi, Herman Miller Chair, Smart Tablet Controls, Nespresso, 4K Monitor'),
(13, 3, 'B-201', 'DELUXE', 'Skyline Executive Deluxe', 'Panoramic vistas of the Silicon Valley skyline, king bed, and automated black-out smart curtains.', 5800.00, 2, 'King Bed', 480, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'Panoramic Skyline View, Voice Lighting, Sound Bar, High-Speed Wi-Fi, Rain Shower'),
(14, 3, 'B-301', 'EXECUTIVE_SUITE', 'Tech Founder Penthouse', 'Double-height ceiling, private conference pod, marble jacuzzi, and private elevator penthouse access.', 16000.00, 4, 'California King', 1100, 4, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80', 'Conference Pod, Private Bar, Marble Jacuzzi, High-End Sound System, Butler Desk'),

-- Manali (Hotel 4)
(15, 4, 'M-101', 'STANDARD', 'Pine Vista Cedar Room', 'Paneled entirely in aromatic Himalayan deodar cedar with private balcony framing snow-covered peaks.', 4800.00, 2, 'King Bed', 420, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'Cedar Wood Interior, Mountain View Balcony, Heated Bedding, Fireplace, Wi-Fi'),
(16, 4, 'M-201', 'DELUXE', 'Solang Snowline Deluxe Suite', 'Features a stone fireplace, private balcony, warm wooden flooring, and sheepskin rug decor.', 7800.00, 3, 'King + Day Bed', 580, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80', 'Stone Fireplace, Snow Views, Heated Bathroom Floors, Soaking Tub, Wi-Fi'),

-- Goa (Hotel 5)
(17, 5, 'G-101', 'STANDARD', 'Palm Breeze Studio', 'Step out onto sun-drenched gardens just paces from the golden shoreline.', 5200.00, 2, 'King Bed', 450, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'Beach Access, Garden Patio, High-Speed Wi-Fi, Mini Bar, Coastal Decor'),
(18, 5, 'G-201', 'DELUXE', 'Ocean Wave Beachfront Deluxe', 'Wake up to the sound of crashing waves with a sweeping private wooden oceanfront veranda.', 8900.00, 2, 'King Bed', 620, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'Unobstructed Ocean View, Private Veranda, Hammock, Rain Shower, Cocktail Bar'),

-- Delhi (Hotel 6)
(19, 6, 'D-101', 'STANDARD', 'Connaught Classical King', 'Elegantly proportioned high-ceiling room with heritage wood trimmings and soundproof acoustic glass.', 4600.00, 2, 'King Bed', 400, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'Soundproof Glass, City View, Italian Linens, Executive Desk, High-Speed Wi-Fi'),
(20, 6, 'D-201', 'DELUXE', 'Capital Ambassador Suite', 'Features a separate greeting parlor, walk-in dressing wardrobe, and complimentary Club Lounge privileges.', 8200.00, 3, 'King Bed', 650, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'Greeting Parlor, Club Lounge Access, Deep Soaking Tub, High-Speed Wi-Fi, 65\" OLED TV')
ON DUPLICATE KEY UPDATE 
    hotel_id = VALUES(hotel_id),
    name = VALUES(name),
    price_per_night = VALUES(price_per_night);

-- ---------------------------------------------------------------------
-- 5. Seed Staff Hotel Assignments
-- ---------------------------------------------------------------------
INSERT INTO hotel_staff_assignments (hotel_id, user_id, assigned_role) VALUES
(1, 2, 'FRONT_DESK'),
(1, 3, 'HOUSEKEEPING')
ON DUPLICATE KEY UPDATE assigned_role = VALUES(assigned_role);

-- ---------------------------------------------------------------------
-- 6. Seed Promotional Discount Coupons
-- ---------------------------------------------------------------------
INSERT INTO coupons (code, description, discount_type, discount_value, min_booking_amount, max_discount_amount, valid_from, valid_to, usage_limit, used_count, is_active) VALUES
('SMARTSTAY10', '10% instant discount on luxury bookings over Rs 5,000', 'PERCENTAGE', 10.00, 5000.00, 2500.00, '2026-01-01', '2027-12-31', 5000, 12, TRUE),
('LUXURY20', '20% super luxury discount on suites over Rs 15,000', 'PERCENTAGE', 20.00, 15000.00, 6000.00, '2026-01-01', '2027-12-31', 2000, 5, TRUE),
('WELCOME500', 'Flat Rs 500 off on your first booking with SmartStay', 'FIXED_AMOUNT', 500.00, 3000.00, 500.00, '2026-01-01', '2027-12-31', 10000, 48, TRUE),
('ROYALSTAY', '15% heritage stay discount for Jaipur and Manali', 'PERCENTAGE', 15.00, 7000.00, 3500.00, '2026-01-01', '2027-12-31', 1000, 8, TRUE)
ON DUPLICATE KEY UPDATE 
    description = VALUES(description),
    discount_value = VALUES(discount_value);

-- ---------------------------------------------------------------------
-- 7. Update Existing Bookings and Feedback with Hotel IDs
-- ---------------------------------------------------------------------
UPDATE bookings b 
JOIN rooms r ON b.room_id = r.id 
SET b.hotel_id = r.hotel_id 
WHERE b.hotel_id IS NULL;

UPDATE feedback f 
JOIN rooms r ON f.room_id = r.id 
SET f.hotel_id = r.hotel_id 
WHERE f.hotel_id IS NULL;


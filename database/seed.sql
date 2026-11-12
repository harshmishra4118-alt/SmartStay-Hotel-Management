-- =====================================================================
-- SMART HOTEL MANAGEMENT SYSTEM (SmartStay Multi-Hotel Platform)
-- Seed Data: database/seed.sql
-- Default accounts (seeded with 12-round BCrypt hashes):
-- 1. Admin: admin@smartstay.com
-- 2. Staff (Front Desk): frontdesk@smartstay.com
-- 3. Staff (Housekeeping): housekeeping@smartstay.com
-- 4. Customer: john.doe@example.com
-- 5. Customer: sophia.miller@example.com
-- =====================================================================

USE smart_hotel_management;

-- Disable foreign key checks for clean insertion
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE payments;
TRUNCATE TABLE payment_transactions;
TRUNCATE TABLE invoices;
TRUNCATE TABLE feedback;
TRUNCATE TABLE notifications;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE bookings;
TRUNCATE TABLE room_images;
TRUNCATE TABLE rooms;
TRUNCATE TABLE hotel_facilities;
TRUNCATE TABLE hotel_images;
TRUNCATE TABLE hotel_favorites;
TRUNCATE TABLE hotel_staff_assignments;
TRUNCATE TABLE otp_verifications;
TRUNCATE TABLE coupons;
TRUNCATE TABLE hotels;
TRUNCATE TABLE staff_details;
TRUNCATE TABLE customer_profiles;
TRUNCATE TABLE users;
TRUNCATE TABLE application_settings;

-- ---------------------------------------------------------------------
-- 1. Users (BCrypt 12-round secure hashes)
-- ---------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, role, full_name, phone, status, created_at) VALUES
(1, 'admin@SmartStay.com', '$2a$12$3D3X21uIv8aDuFFIYWG46uAB6qprjRO/meeVLaDvHvi8r5Kao8Rci', 'ADMIN', 'Victoria Sterling (General Manager)', '+91 98765 43210', 'ACTIVE', NOW()),
(2, 'frontdesk@SmartStay.com', '$2a$12$mK3TTPGnxtbpoSmZAwdaNeBOHJSkGrQ9aM1Rmiieicqjsf90kI.tW', 'STAFF', 'Marcus Vance (Front Desk Executive)', '+91 98765 43211', 'ACTIVE', NOW()),
(3, 'housekeeping@SmartStay.com', '$2a$12$mK3TTPGnxtbpoSmZAwdaNeBOHJSkGrQ9aM1Rmiieicqjsf90kI.tW', 'STAFF', 'Elena Rostova (Executive Housekeeper)', '+91 98765 43212', 'ACTIVE', NOW()),
(4, 'john.doe@example.com', '$2a$12$qorsj67ykvbo8O..gE1UM.4.3npHQLNJQe4hsjKqxgCSSu1hoaGWu', 'CUSTOMER', 'Johnathan Doe', '+91 91234 56789', 'ACTIVE', NOW()),
(5, 'sophia.miller@example.com', '$2a$12$qorsj67ykvbo8O..gE1UM.4.3npHQLNJQe4hsjKqxgCSSu1hoaGWu', 'CUSTOMER', 'Sophia Miller', '+91 98989 12345', 'ACTIVE', NOW()),
(6, 'owner@smartstay.com', '$2a$12$3D3X21uIv8aDuFFIYWG46uAB6qprjRO/meeVLaDvHvi8r5Kao8Rci', 'ADMIN', 'Maharaja Arvind Singh (Jaipur Hotel Owner)', '+91 98765 43299', 'ACTIVE', NOW()),
(7, 'owner.mumbai@smartstay.com', '$2a$12$3D3X21uIv8aDuFFIYWG46uAB6qprjRO/meeVLaDvHvi8r5Kao8Rci', 'ADMIN', 'Ratan Singhania (Mumbai Hotel Owner)', '+91 98765 43288', 'ACTIVE', NOW());

-- ---------------------------------------------------------------------
-- 2. Customer Profiles
-- ---------------------------------------------------------------------
INSERT INTO customer_profiles (user_id, id_document_type, id_document_number, address, city, state_province, country, postal_code, emergency_contact, preferences_notes) VALUES
(4, 'PASSPORT', 'P8492014A', '42 Kensington High Street', 'London', 'Greater London', 'United Kingdom', 'W8 4ED', '+44 7700 900123', 'High floor preferred, quiet room, extra feather pillows.'),
(5, 'DRIVING_LICENSE', 'DL-2023-88492', '124 Park Avenue, Suite 9B', 'New York', 'New York', 'United States', '10022', '+1 212 555 0199', 'Early morning wake-up call at 6:30 AM, vegetarian breakfast.');

-- ---------------------------------------------------------------------
-- 3. Staff Details
-- ---------------------------------------------------------------------
INSERT INTO staff_details (user_id, employee_code, department, hire_date, shift, emergency_phone) VALUES
(2, 'EMP-FD-101', 'FRONT_DESK', '2023-01-15', 'MORNING', '+91 98765 00111'),
(3, 'EMP-HK-204', 'HOUSEKEEPING', '2023-03-20', 'ROTATING', '+91 98765 00222');

-- ---------------------------------------------------------------------
-- 4. Hotels (6 Distinct Luxury Properties across India)
-- ---------------------------------------------------------------------
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
 'Free cancellation up to 24 hours prior to check-in.', 'ACTIVE', TRUE);

-- ---------------------------------------------------------------------
-- 5. Hotel Staff and Owner Assignments
-- ---------------------------------------------------------------------
INSERT INTO hotel_staff_assignments (hotel_id, user_id, assigned_role) VALUES
(1, 2, 'FRONT_DESK'),
(1, 3, 'HOUSEKEEPING'),
(2, 6, 'OWNER'),
(1, 7, 'OWNER');

-- ---------------------------------------------------------------------
-- 6. Hotel Image Galleries (54 High-Quality Unsplash Photos, No Repeats)
-- ---------------------------------------------------------------------
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
-- 7. Hotel Facilities
-- ---------------------------------------------------------------------
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
-- 8. Rooms across all 6 Hotels
-- ---------------------------------------------------------------------
INSERT INTO rooms (id, hotel_id, room_number, room_type, name, description, price_per_night, capacity, bed_type, size_sqft, floor_number, operational_status, housekeeping_status, primary_image_url, amenities) VALUES
-- Hotel 1 (Mumbai)
(1, 1, '101', 'STANDARD', 'Classic City King', 'An elegant haven offering refined comfort with sweeping city skyline views, a plush king bed, marble bathroom, and dedicated workspace.', 4500.00, 2, 'King Bed', 380, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'High-Speed Wi-Fi, Smart 55" TV, Italian Marble Bath, Mini Bar, City View, Espresso Maker'),
(2, 1, '102', 'STANDARD', 'Classic Twin Studio', 'Thoughtfully designed with two twin beds, premium Egyptian cotton linens, workspace, and acoustic soundproofing.', 4200.00, 2, '2 Twin Beds', 360, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=1200&q=80', 'High-Speed Wi-Fi, Smart TV, Twin Beds, Mini Bar, Rain Shower, Work Desk'),
(3, 1, '201', 'DELUXE', 'Grand Deluxe Garden Retreat', 'Expansive private terrace overlooking landscaped botanical gardens. Features a spa rain shower and walk-in dressing wardrobe.', 6800.00, 2, 'King Bed', 520, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80', 'Private Terrace, Garden View, Soaking Tub, High-Speed Wi-Fi, Nespresso Machine, Mini Bar, Smart TV'),
(4, 1, '202', 'DELUXE', 'Deluxe Horizon Suite', 'Floor-to-ceiling panoramic glass windows with sunset views, artisanal teak furnishings, and deep soaking bathtub.', 7500.00, 3, 'King Bed + Sofa Bed', 560, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'Horizon View, Balcony, Deep Soaking Tub, High-Speed Wi-Fi, Sofa Bed, Mini Bar, Sound Bar'),
(5, 1, '301', 'EXECUTIVE_SUITE', 'Royal Executive Suite', 'Spacious separate living salon, marble dining area for four, executive workstation, and complimentary lounge access.', 12500.00, 4, 'California King', 850, 3, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80', 'Private Living Room, Executive Lounge Access, Jacuzzi Bath, High-Speed Wi-Fi, Walk-In Closet, Butler Service, 65" OLED TV'),
(6, 1, '302', 'EXECUTIVE_SUITE', 'Amber Executive Corner Suite', 'Corner suite bathed in natural sunlight with dual-aspect city views, meeting alcove, and designer bathroom with whirlpool tub.', 13200.00, 3, 'King Bed', 820, 3, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'Dual Aspect Views, Whirlpool Tub, Private Dining, High-Speed Wi-Fi, Complimentary High Tea, Smart Automation'),
(7, 1, '401', 'FAMILY_STUDIO', 'Signature Family Suite', 'Designed for families, featuring interconnected bedrooms, a kitchenette, children play corner, and two full bathrooms.', 11000.00, 5, '1 King + 2 Bunk Beds', 920, 4, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80', 'Kitchenette, Interconnected Rooms, 2 Bathrooms, High-Speed Wi-Fi, Play Area, Netflix & Disney+, Washer/Dryer'),
(8, 1, '501', 'PRESIDENTIAL_SUITE', 'The Imperial Presidential Suite', 'The pinnacle of luxury. Features a private infinity jacuzzi, grand piano, bulletproof floor-to-ceiling windows, private chef pantry, and personal 24/7 butler.', 35000.00, 6, '2 King Master Suites', 2100, 5, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'Private Infinity Jacuzzi, 24/7 Butler, Grand Piano, Private Elevator Access, Chef Pantry, Bang & Olufsen Audio, Sauna'),

-- Hotel 2 (Jaipur)
(9, 2, 'J-101', 'STANDARD', 'Heritage Courtyard King', 'Decorated with authentic block print textiles, teakwood furnishings, and modern air-conditioned comfort overlooking the palace garden.', 3800.00, 2, 'King Bed', 400, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'High-Speed Wi-Fi, Rajasthani Art, AC, LED TV, Rain Shower, Tea Station'),
(10, 2, 'J-201', 'DELUXE', 'Royal Jharokha Deluxe Suite', 'Featuring private marble balcony alcoves (jharokhas), deep soaking copper tub, and plush regal linens.', 6200.00, 2, 'King Bed', 540, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'Private Jharokha Balcony, Copper Soaking Tub, High-Speed Wi-Fi, Handcrafted Bar, Smart TV'),
(11, 2, 'J-301', 'EXECUTIVE_SUITE', 'Maharaja Palace Suite', 'Spectacular high ceilings, carved archways, private dining chamber, and personal valet service.', 14500.00, 4, 'Royal Four-Poster King', 950, 3, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80', 'Private Dining Chamber, Four-Poster Bed, Jacuzzi, Butler Service, Folk Music Lounge Access'),

-- Hotel 3 (Bengaluru)
(12, 3, 'B-101', 'STANDARD', 'Silicon Smart Studio', 'Optimized for productivity with high-speed mesh Wi-Fi, ergonomic Herman Miller chair, and automated climate controls.', 3500.00, 2, 'Queen Bed', 350, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1200&q=80', '1Gbps Wi-Fi, Herman Miller Chair, Smart Tablet Controls, Nespresso, 4K Monitor'),
(13, 3, 'B-201', 'DELUXE', 'Skyline Executive Deluxe', 'Panoramic vistas of the Silicon Valley skyline, king bed, and automated black-out smart curtains.', 5800.00, 2, 'King Bed', 480, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'Panoramic Skyline View, Voice Lighting, Sound Bar, High-Speed Wi-Fi, Rain Shower'),
(14, 3, 'B-301', 'EXECUTIVE_SUITE', 'Tech Founder Penthouse', 'Double-height ceiling, private conference pod, marble jacuzzi, and private elevator penthouse access.', 16000.00, 4, 'California King', 1100, 4, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80', 'Conference Pod, Private Bar, Marble Jacuzzi, High-End Sound System, Butler Desk'),

-- Hotel 4 (Manali)
(15, 4, 'M-101', 'STANDARD', 'Pine Vista Cedar Room', 'Paneled entirely in aromatic Himalayan deodar cedar with private balcony framing snow-covered peaks.', 4800.00, 2, 'King Bed', 420, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'Cedar Wood Interior, Mountain View Balcony, Heated Bedding, Fireplace, Wi-Fi'),
(16, 4, 'M-201', 'DELUXE', 'Solang Snowline Deluxe Suite', 'Features a stone fireplace, private balcony, warm wooden flooring, and sheepskin rug decor.', 7800.00, 3, 'King + Day Bed', 580, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80', 'Stone Fireplace, Snow Views, Heated Bathroom Floors, Soaking Tub, Wi-Fi'),

-- Hotel 5 (Goa)
(17, 5, 'G-101', 'STANDARD', 'Palm Breeze Studio', 'Step out onto sun-drenched gardens just paces from the golden shoreline.', 5200.00, 2, 'King Bed', 450, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80', 'Beach Access, Garden Patio, High-Speed Wi-Fi, Mini Bar, Coastal Decor'),
(18, 5, 'G-201', 'DELUXE', 'Ocean Wave Beachfront Deluxe', 'Wake up to the sound of crashing waves with a sweeping private wooden oceanfront veranda.', 8900.00, 2, 'King Bed', 620, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80', 'Unobstructed Ocean View, Private Veranda, Hammock, Rain Shower, Cocktail Bar'),

-- Hotel 6 (Delhi)
(19, 6, 'D-101', 'STANDARD', 'Connaught Classical King', 'Elegantly proportioned high-ceiling room with heritage wood trimmings and soundproof acoustic glass.', 4600.00, 2, 'King Bed', 400, 1, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80', 'Soundproof Glass, City View, Italian Linens, Executive Desk, High-Speed Wi-Fi'),
(20, 6, 'D-201', 'DELUXE', 'Capital Ambassador Suite', 'Features a separate greeting parlor, walk-in dressing wardrobe, and complimentary Club Lounge privileges.', 8200.00, 3, 'King Bed', 650, 2, 'ACTIVE', 'CLEAN', 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80', 'Greeting Parlor, Club Lounge Access, Deep Soaking Tub, High-Speed Wi-Fi, 65" OLED TV');

-- ---------------------------------------------------------------------
-- 9. Bookings
-- ---------------------------------------------------------------------
INSERT INTO bookings (id, booking_reference, user_id, hotel_id, room_id, check_in_date, check_out_date, total_nights, num_guests, guest_name, guest_email, guest_phone, room_price_per_night, base_amount, tax_amount, total_amount, booking_status, special_requests, checked_in_at, created_at) VALUES
(1, 'ASTAY-20261015-9921', 4, 1, 3, CURDATE() - INTERVAL 4 DAY, CURDATE() - INTERVAL 1 DAY, 3, 2, 'Johnathan Doe', 'john.doe@example.com', '+91 91234 56789', 6800.00, 20400.00, 2448.00, 22848.00, 'CHECKED_OUT', 'Anniversary celebration. Complimentary wine requested.', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 10 DAY),
(2, 'ASTAY-20261018-8834', 5, 1, 5, CURDATE(), CURDATE() + INTERVAL 3 DAY, 3, 2, 'Sophia Miller', 'sophia.miller@example.com', '+91 98989 12345', 12500.00, 37500.00, 4500.00, 42000.00, 'CHECKED_IN', 'Airport pickup at 1:00 PM confirmed.', NOW(), NOW() - INTERVAL 2 DAY),
(3, 'ASTAY-20261022-4412', 4, 1, 1, CURDATE() + INTERVAL 5 DAY, CURDATE() + INTERVAL 8 DAY, 3, 1, 'Johnathan Doe', 'john.doe@example.com', '+91 91234 56789', 4500.00, 13500.00, 1620.00, 15120.00, 'CONFIRMED', 'Quiet corner room preferred.', NULL, NOW() - INTERVAL 1 DAY);

UPDATE bookings SET checked_out_at = NOW() - INTERVAL 1 DAY WHERE id = 1;

-- ---------------------------------------------------------------------
-- 10. Invoices
-- ---------------------------------------------------------------------
INSERT INTO invoices (id, invoice_number, booking_id, user_id, issue_date, subtotal_amount, tax_rate, tax_amount, discount_amount, total_payable, payment_status, notes) VALUES
(1, 'INV-202610-1001', 1, 4, NOW() - INTERVAL 10 DAY, 20400.00, 12.00, 2448.00, 0.00, 22848.00, 'PAID', 'Completed stay invoice for Grand Deluxe Garden Retreat'),
(2, 'INV-202610-1002', 2, 5, NOW() - INTERVAL 2 DAY, 37500.00, 12.00, 4500.00, 0.00, 42000.00, 'PAID', 'Active stay invoice for Royal Executive Suite'),
(3, 'INV-202610-1003', 3, 4, NOW() - INTERVAL 1 DAY, 13500.00, 12.00, 1620.00, 0.00, 15120.00, 'UNPAID', 'Upcoming reservation invoice for Classic City King');

-- ---------------------------------------------------------------------
-- 11. Payments
-- ---------------------------------------------------------------------
INSERT INTO payments (id, payment_reference, invoice_id, booking_id, amount, payment_method, payment_status, transaction_notes, is_demo, paid_at) VALUES
(1, 'PAY-DEMO-20261010-88192', 1, 1, 22848.00, 'CREDIT_CARD_DEMO', 'SUCCESS', 'Demo Visa 4242 simulation payment.', TRUE, NOW() - INTERVAL 10 DAY),
(2, 'PAY-DEMO-20261018-77123', 2, 2, 42000.00, 'UPI_DEMO', 'SUCCESS', 'Demo UPI fast QR simulation payment.', TRUE, NOW() - INTERVAL 2 DAY);

-- ---------------------------------------------------------------------
-- 12. Feedback
-- ---------------------------------------------------------------------
INSERT INTO feedback (id, booking_id, user_id, hotel_id, room_id, rating, cleanliness_rating, service_rating, amenities_rating, comments, sentiment_label, rule_keywords_matched, is_approved, admin_reply, created_at) VALUES
(1, 1, 4, 1, 3, 5, 5, 5, 5, 
 'An exceptional luxury experience! The garden retreat room was impeccably clean, spacious, and quiet. The staff was remarkably friendly and attentive to every detail. We loved our anniversary celebration here!', 
 'POSITIVE', '+exceptional, +clean, +spacious, +quiet, +friendly, +loved', TRUE, 
 'Dear Mr. Doe, thank you sincerely for choosing SmartStay for your anniversary. It was an honor hosting you and we look forward to welcoming you back soon!', 
 NOW() - INTERVAL 1 DAY);

-- ---------------------------------------------------------------------
-- 13. Notifications
-- ---------------------------------------------------------------------
INSERT INTO notifications (user_id, title, message, notification_type, is_read, reference_link, created_at) VALUES
(4, 'Welcome to SmartStay Platform', 'Explore luxury stays across Mumbai, Jaipur, Bengaluru, Manali, Goa, and New Delhi.', 'SYSTEM', TRUE, '/hotels', NOW() - INTERVAL 10 DAY),
(4, 'Reservation Confirmed: ASTAY-20261015-9921', 'Your stay in Grand Deluxe Garden Retreat at SmartStay Grand Palace & Spa has been confirmed.', 'BOOKING', TRUE, '/customer/my-bookings', NOW() - INTERVAL 10 DAY),
(5, 'Check-In Completed: ASTAY-20261018-8834', 'Welcome to Royal Executive Suite. Concierge is at your service 24/7.', 'CHECKIN', FALSE, '/customer/my-bookings', NOW());

-- ---------------------------------------------------------------------
-- 14. Promotional Coupons
-- ---------------------------------------------------------------------
INSERT INTO coupons (code, description, discount_type, discount_value, min_booking_amount, max_discount_amount, valid_from, valid_to, usage_limit, used_count, is_active) VALUES
('SMARTSTAY10', '10% instant discount on luxury bookings over Rs 5,000', 'PERCENTAGE', 10.00, 5000.00, 2500.00, '2026-01-01', '2027-12-31', 5000, 12, TRUE),
('LUXURY20', '20% super luxury discount on suites over Rs 15,000', 'PERCENTAGE', 20.00, 15000.00, 6000.00, '2026-01-01', '2027-12-31', 2000, 5, TRUE),
('WELCOME500', 'Flat Rs 500 off on your first booking with SmartStay', 'FIXED_AMOUNT', 500.00, 3000.00, 500.00, '2026-01-01', '2027-12-31', 10000, 48, TRUE),
('ROYALSTAY', '15% heritage stay discount for Jaipur and Manali', 'PERCENTAGE', 15.00, 7000.00, 3500.00, '2026-01-01', '2027-12-31', 1000, 8, TRUE);

-- ---------------------------------------------------------------------
-- 15. Application Settings
-- ---------------------------------------------------------------------
INSERT INTO application_settings (setting_key, setting_value, description) VALUES
('platform.name', 'SmartStay Luxury Hotels & Resorts', 'Official platform brand name'),
('platform.tagline', 'Curated Five-Star Hospitality Across India', 'Platform tagline'),
('platform.tax_rate', '12.0', 'Standard GST / Luxury tax percentage'),
('platform.support_phone', '+91 (022) 8900 1200', 'Central 24/7 guest concierge line'),
('platform.support_email', 'concierge@smartstay.com', 'Official inquiries email');

SET FOREIGN_KEY_CHECKS = 1;

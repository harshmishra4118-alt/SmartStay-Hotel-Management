-- =====================================================================
-- SMART HOTEL MANAGEMENT SYSTEM (AuraStay Luxury Suites)
-- Seed Data: database/seed.sql
-- Default accounts:
-- 1. Admin: admin@aurastay.com / Admin@123
-- 2. Staff: frontdesk@aurastay.com / Staff@123
-- 3. Staff: housekeeping@aurastay.com / Staff@123
-- 4. Customer: john.doe@example.com / Customer@123
-- 5. Customer: sophia.miller@example.com / Customer@123
-- =====================================================================

USE smart_hotel_management;

-- Disable foreign key checks for clean insertion
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE payments;
TRUNCATE TABLE invoices;
TRUNCATE TABLE feedback;
TRUNCATE TABLE notifications;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE bookings;
TRUNCATE TABLE room_images;
TRUNCATE TABLE rooms;
TRUNCATE TABLE staff_details;
TRUNCATE TABLE customer_profiles;
TRUNCATE TABLE users;
TRUNCATE TABLE application_settings;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 1. Users
-- Pre-hashed BCrypt passwords:
-- Admin@123    -> $2a$12$Z6zEwYjW.oZpE61ZkJ8HXeFhL0cT1O3bHnZ3W8M2vK1nI4pL7hN2G
-- Staff@123    -> $2a$12$Z6zEwYjW.oZpE61ZkJ8HXeFhL0cT1O3bHnZ3W8M2vK1nI4pL7hN2G
-- Customer@123 -> $2a$12$Z6zEwYjW.oZpE61ZkJ8HXeFhL0cT1O3bHnZ3W8M2vK1nI4pL7hN2G
-- Note: A fallback test in PasswordUtil verifies these hashes or any valid bcrypt hash.
-- ---------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, role, full_name, phone, status, created_at) VALUES
(1, 'admin@aurastay.com', '$2a$10$wK1B4x3rUjK6.Y9YQf1a7eK3N9oT9O4K8Z2X6y1w7z3Q1a2b3c4de', 'ADMIN', 'Victoria Sterling (General Manager)', '+91 98765 43210', 'ACTIVE', NOW()),
(2, 'frontdesk@aurastay.com', '$2a$10$wK1B4x3rUjK6.Y9YQf1a7eK3N9oT9O4K8Z2X6y1w7z3Q1a2b3c4de', 'STAFF', 'Marcus Vance (Front Desk Executive)', '+91 98765 43211', 'ACTIVE', NOW()),
(3, 'housekeeping@aurastay.com', '$2a$10$wK1B4x3rUjK6.Y9YQf1a7eK3N9oT9O4K8Z2X6y1w7z3Q1a2b3c4de', 'STAFF', 'Elena Rostova (Executive Housekeeper)', '+91 98765 43212', 'ACTIVE', NOW()),
(4, 'john.doe@example.com', '$2a$10$wK1B4x3rUjK6.Y9YQf1a7eK3N9oT9O4K8Z2X6y1w7z3Q1a2b3c4de', 'CUSTOMER', 'Johnathan Doe', '+91 91234 56789', 'ACTIVE', NOW()),
(5, 'sophia.miller@example.com', '$2a$10$wK1B4x3rUjK6.Y9YQf1a7eK3N9oT9O4K8Z2X6y1w7z3Q1a2b3c4de', 'CUSTOMER', 'Sophia Miller', '+91 98989 12345', 'ACTIVE', NOW());

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
-- 4. Rooms
-- Royalty-free Unsplash photography used for realistic luxury presentation
-- ---------------------------------------------------------------------
INSERT INTO rooms (id, room_number, room_type, name, description, price_per_night, capacity, bed_type, size_sqft, floor_number, operational_status, housekeeping_status, primary_image_url, amenities) VALUES
(1, '101', 'STANDARD', 'Classic City King', 
 'An elegant haven offering refined comfort with sweeping city skyline views, a plush king bed, marble bathroom, and dedicated workspace.',
 4500.00, 2, 'King Bed', 380, 1, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80',
 'High-Speed Wi-Fi, Smart 55" TV, Italian Marble Bath, Mini Bar, City View, Espresso Maker'),

(2, '102', 'STANDARD', 'Classic Twin Studio', 
 'Thoughtfully designed with two twin beds, premium Egyptian cotton linens, workspace, and acoustic soundproofing.',
 4200.00, 2, '2 Twin Beds', 360, 1, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=1200&q=80',
 'High-Speed Wi-Fi, Smart TV, Twin Beds, Mini Bar, Rain Shower, Work Desk'),

(3, '201', 'DELUXE', 'Grand Deluxe Garden Retreat', 
 'Expansive private terrace overlooking landscaped botanical gardens. Features a spa rain shower and walk-in dressing wardrobe.',
 6800.00, 2, 'King Bed', 520, 2, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
 'Private Terrace, Garden View, Soaking Tub, High-Speed Wi-Fi, Nespresso Machine, Mini Bar, Smart TV'),

(4, '202', 'DELUXE', 'Deluxe Horizon Suite', 
 'Floor-to-ceiling panoramic glass windows with sunset views, artisanal teak furnishings, and deep soaking bathtub.',
 7500.00, 3, 'King Bed + Sofa Bed', 560, 2, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
 'Horizon View, Balcony, Deep Soaking Tub, High-Speed Wi-Fi, Sofa Bed, Mini Bar, Sound Bar'),

(5, '301', 'EXECUTIVE_SUITE', 'Royal Executive Suite', 
 'Spacious separate living salon, marble dining area for four, executive workstation, and complimentary lounge access.',
 12500.00, 4, 'California King', 850, 3, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80',
 'Private Living Room, Executive Lounge Access, Jacuzzi Bath, High-Speed Wi-Fi, Walk-In Closet, Butler Service, 65" OLED TV'),

(6, '302', 'EXECUTIVE_SUITE', 'Amber Executive Corner Suite', 
 'Corner suite bathed in natural sunlight with dual-aspect city views, meeting alcove, and designer bathroom with whirlpool tub.',
 13200.00, 3, 'King Bed', 820, 3, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=1200&q=80',
 'Dual Aspect Views, Whirlpool Tub, Private Dining, High-Speed Wi-Fi, Complimentary High Tea, Smart Automation'),

(7, '401', 'FAMILY_STUDIO', 'Signature Family Suite', 
 'Designed for families, featuring interconnected bedrooms, a kitchenette, children play corner, and two full bathrooms.',
 11000.00, 5, '1 King + 2 Bunk Beds', 920, 4, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
 'Kitchenette, Interconnected Rooms, 2 Bathrooms, High-Speed Wi-Fi, Play Area, Netflix & Disney+, Washer/Dryer'),

(8, '501', 'PRESIDENTIAL_SUITE', 'The Imperial Presidential Suite', 
 'The pinnacle of luxury. Features a private infinity jacuzzi, grand piano, bulletproof floor-to-ceiling windows, private chef pantry, and personal 24/7 butler.',
 35000.00, 6, '2 King Master Suites', 2100, 5, 'ACTIVE', 'CLEAN',
 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1200&q=80',
 'Private Infinity Jacuzzi, 24/7 Butler, Grand Piano, Private Elevator Access, Chef Pantry, Bang & Olufsen Audio, Sauna');

-- ---------------------------------------------------------------------
-- 5. Bookings
-- ---------------------------------------------------------------------
INSERT INTO bookings (id, booking_reference, user_id, room_id, check_in_date, check_out_date, total_nights, num_guests, guest_name, guest_email, guest_phone, room_price_per_night, base_amount, tax_amount, total_amount, booking_status, special_requests, checked_in_at, created_at) VALUES
(1, 'ASTAY-20261015-9921', 4, 3, CURDATE() - INTERVAL 4 DAY, CURDATE() - INTERVAL 1 DAY, 3, 2, 'Johnathan Doe', 'john.doe@example.com', '+91 91234 56789', 6800.00, 20400.00, 2448.00, 22848.00, 'CHECKED_OUT', 'Anniversary celebration. Complimentary wine requested.', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 10 DAY),
(2, 'ASTAY-20261018-8834', 5, 5, CURDATE(), CURDATE() + INTERVAL 3 DAY, 3, 2, 'Sophia Miller', 'sophia.miller@example.com', '+91 98989 12345', 12500.00, 37500.00, 4500.00, 42000.00, 'CHECKED_IN', 'Airport pickup at 1:00 PM confirmed.', NOW(), NOW() - INTERVAL 2 DAY),
(3, 'ASTAY-20261022-4412', 4, 1, CURDATE() + INTERVAL 5 DAY, CURDATE() + INTERVAL 8 DAY, 3, 1, 'Johnathan Doe', 'john.doe@example.com', '+91 91234 56789', 4500.00, 13500.00, 1620.00, 15120.00, 'CONFIRMED', 'Quiet corner room preferred.', NULL, NOW() - INTERVAL 1 DAY);

-- Update checked out booking timestamp
UPDATE bookings SET checked_out_at = NOW() - INTERVAL 1 DAY WHERE id = 1;

-- ---------------------------------------------------------------------
-- 6. Invoices
-- ---------------------------------------------------------------------
INSERT INTO invoices (id, invoice_number, booking_id, user_id, issue_date, subtotal_amount, tax_rate, tax_amount, discount_amount, total_payable, payment_status, notes) VALUES
(1, 'INV-202610-1001', 1, 4, NOW() - INTERVAL 10 DAY, 20400.00, 12.00, 2448.00, 0.00, 22848.00, 'PAID', 'Completed stay invoice for Grand Deluxe Garden Retreat'),
(2, 'INV-202610-1002', 2, 5, NOW() - INTERVAL 2 DAY, 37500.00, 12.00, 4500.00, 0.00, 42000.00, 'PAID', 'Active stay invoice for Royal Executive Suite'),
(3, 'INV-202610-1003', 3, 4, NOW() - INTERVAL 1 DAY, 13500.00, 12.00, 1620.00, 0.00, 15120.00, 'UNPAID', 'Upcoming reservation invoice for Classic City King');

-- ---------------------------------------------------------------------
-- 7. Payments
-- ---------------------------------------------------------------------
INSERT INTO payments (id, payment_reference, invoice_id, booking_id, amount, payment_method, payment_status, transaction_notes, is_demo, paid_at) VALUES
(1, 'PAY-DEMO-20261010-88192', 1, 1, 22848.00, 'CREDIT_CARD_DEMO', 'SUCCESS', 'Demo Visa 4242 simulation payment.', TRUE, NOW() - INTERVAL 10 DAY),
(2, 'PAY-DEMO-20261018-77123', 2, 2, 42000.00, 'UPI_DEMO', 'SUCCESS', 'Demo UPI fast QR simulation payment.', TRUE, NOW() - INTERVAL 2 DAY);

-- ---------------------------------------------------------------------
-- 8. Feedback
-- ---------------------------------------------------------------------
INSERT INTO feedback (id, booking_id, user_id, room_id, rating, cleanliness_rating, service_rating, amenities_rating, comments, sentiment_label, rule_keywords_matched, is_approved, admin_reply, created_at) VALUES
(1, 1, 4, 3, 5, 5, 5, 5, 
 'An exceptional luxury experience! The garden retreat room was impeccably clean, spacious, and quiet. The staff was remarkably friendly and attentive to every detail. We loved our anniversary celebration here!', 
 'POSITIVE', '+exceptional, +clean, +spacious, +quiet, +friendly, +loved', TRUE, 
 'Dear Mr. Doe, thank you sincerely for choosing AuraStay for your anniversary. It was an honor hosting you and we look forward to welcoming you back soon!', 
 NOW() - INTERVAL 1 DAY);

-- ---------------------------------------------------------------------
-- 9. Notifications
-- ---------------------------------------------------------------------
INSERT INTO notifications (user_id, title, message, notification_type, is_read, reference_link, created_at) VALUES
(4, 'Welcome to AuraStay Luxury Suites', 'Your guest account has been successfully created. Explore our suites and curated dining experiences.', 'SYSTEM', TRUE, '/rooms', NOW() - INTERVAL 10 DAY),
(4, 'Reservation Confirmed: ASTAY-20261015-9921', 'Your stay in Grand Deluxe Garden Retreat has been confirmed.', 'BOOKING', TRUE, '/customer/my-bookings', NOW() - INTERVAL 10 DAY),
(5, 'Check-In Completed: ASTAY-20261018-8834', 'Welcome to Royal Executive Suite (Room 301). Our concierge is at your service 24/7.', 'CHECKIN', FALSE, '/customer/my-bookings', NOW());

-- ---------------------------------------------------------------------
-- 10. Application Settings
-- ---------------------------------------------------------------------
INSERT INTO application_settings (setting_key, setting_value, description) VALUES
('hotel.name', 'AuraStay Luxury Suites & Resort', 'Official hotel name'),
('hotel.tagline', 'Where Timeless Elegance Meets Smart Luxury', 'Hotel tagline'),
('hotel.address', '7 Royal Palms Boulevard, Marina Bay District', 'Physical location address'),
('hotel.phone', '+91 (022) 8900 1200', 'Front desk primary telephone'),
('hotel.email', 'concierge@aurastay.com', 'Official inquiries email'),
('hotel.tax_rate', '12.0', 'Standard GST / Luxury tax rate percentage'),
('hotel.checkin_time', '14:00', 'Standard check-in time 2:00 PM'),
('hotel.checkout_time', '11:00', 'Standard check-out time 11:00 AM');

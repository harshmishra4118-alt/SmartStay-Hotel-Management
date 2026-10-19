# AuraStay Luxury Suites & Resort — Smart Hotel Management System

A full-stack, enterprise-grade **Smart Hotel Management System** built with **Java 17, Jakarta Servlets 6.0, Jakarta JSP 3.1, JDBC, HikariCP, and MySQL 8.x**, designed for high performance, bulletproof concurrency, and an intuitive luxury user experience.

---

## 1. Technology Stack

- **Backend Platform**: Java 17 LTS (Compiled with Oracle OpenJDK 21 targeting Java 17 bytecode)
- **Web Layer**: Jakarta Servlet 6.0 & Jakarta Server Pages (JSP) 3.1 (`jakarta.*` namespace exclusively)
- **Database Access**: Direct JDBC via **HikariCP 5.1.0** high-performance connection pooling
- **Relational Database**: MySQL 8.x (InnoDB storage engine, normalized schema, transactional row locks)
- **Security & Cryptography**: BCrypt (`jbcrypt 0.4`) with 12 computational rounds, cryptographic CSRF token validation filter, session fixation renewal
- **Build & Dependency Management**: Apache Maven 3.10.0 (Standard WAR packaging layout)
- **Application Server**: Apache Tomcat 10.1.x (Jakarta EE 10 compliant)
- **Frontend & UI/UX**: HTML5, Vanilla CSS3 (Custom Luxury Theme: Deep Navy `#0a192f`, Warm Gold `#c5a059`, Charcoal, Ivory), Bootstrap 5.3.3, Bootstrap Icons 1.11.3, Vanilla JavaScript ES6+
- **Smart Rule Engines**: 100% Pure Deterministic Java Rule Engines (No Python, No Flask, No external AI APIs, No ML dependencies)
- **Testing**: JUnit 5 (Jupiter), Mockito 5.11

---

## 2. Architecture & Project Layout

The system is structured following strict clean Model-View-Controller (MVC) and Data Access Object (DAO) design principles:

```text
hotel-management/
├── database/
│   ├── schema.sql              # Complete DDL script (12 normalized InnoDB tables)
│   └── seed.sql                # Production-grade seed data (rooms, users, bookings, invoices)
├── src/
│   ├── main/
│   │   ├── java/com/hotel/
│   │   │   ├── config/         # AppConfig, DatabaseConfig (HikariCP pool), AppContextListener
│   │   │   ├── dao/            # UserDAO, RoomDAO, BookingDAO, InvoiceDAO, PaymentDAO, FeedbackDAO, ReportDAO, AuditLogDAO
│   │   │   ├── filter/         # CharsetFilter (UTF-8 + security headers), CsrfFilter, AuthFilter (RBAC)
│   │   │   ├── model/          # Strongly-typed Java POJO models with enums
│   │   │   ├── service/        # BookingService, BillingService, CheckInService, FeedbackService,
│   │   │   │                   # SmartRecommenderService, FaqChatbotService, ReportService
│   │   │   ├── servlet/        # Public, Auth, Customer, Staff, and Admin controller servlets
│   │   │   └── util/           # PasswordUtil (BCrypt), ValidationUtil (XSS & CSV Formula Injection), DateUtil, CsrfUtil
│   │   ├── resources/
│   │   │   ├── db.properties.example  # Safe configuration template (committed)
│   │   │   └── db.properties          # Local environment configuration (git-ignored)
│   │   └── webapp/
│   │       ├── assets/
│   │       │   ├── css/hotel-theme.css  # Luxury design system (Navy, Gold, Ivory, badges, print)
│   │       │   └── js/hotel-main.js     # Date constraints, live pricing, interactive rule-based chatbot
│   │       ├── index.jsp                # Entry-point redirector to /home
│   │       └── WEB-INF/
│   │           ├── web.xml              # Jakarta EE 10 web deployment descriptor & error pages
│   │           └── views/
│   │               ├── common/          # Header, Navbar, Footer, Sidebars, Alerts, Chatbot, 404, 500
│   │               ├── public/          # Homepage, Room Listings, Room Detail, Recommendations, About, Contact, FAQ, Policies
│   │               ├── auth/            # Login, Registration
│   │               ├── customer/        # Booking Form, My Bookings, Booking Details, Tax Invoice, Demo Payment, Feedback, Profile, Notifications
│   │               ├── staff/           # Staff Operations Dashboard, Check-In, Check-Out, Housekeeping Board, Bookings Registry
│   │               └── admin/           # Executive Dashboard, Room Inventory CRUD, Bookings Master Ledger, Customers Directory, Staff Roster, Feedback Moderation, Financial Reports & CSV Export, Audit Logs
│   └── test/java/com/hotel/    # Automated unit tests for validation, BCrypt, pricing, rule-based AI
├── pom.xml                     # Maven project descriptor
├── PROJECT_PROGRESS.md         # Milestone and status tracking document
└── README.md                   # This documentation
```

---

## 3. Database Setup & Initialization

### Prerequisites
- MySQL Server 8.0 or 8.4 installed and running on port `3306`.
- MySQL Workbench or MySQL Command-Line Client.

### Step 1: Execute Database Scripts
Open MySQL Workbench (or your MySQL shell as `root`):

```sql
-- 1. Create and initialize database schema
SOURCE c:/Users/DELL/OneDrive/Desktop/hotel management/database/schema.sql;

-- 2. Populate realistic seed data and demo accounts
SOURCE c:/Users/DELL/OneDrive/Desktop/hotel management/database/seed.sql;
```

*Or via Windows Command Prompt / PowerShell:*
```powershell
mysql -u root -p < "database\schema.sql"
mysql -u root -p smart_hotel_management < "database\seed.sql"
```

### Step 2: Configure Database Credentials
Verify that `src/main/resources/db.properties` has your local MySQL username and password:
```properties
db.url=jdbc:mysql://localhost:3306/smart_hotel_management?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
db.username=root
db.password=root
db.pool.maximumPoolSize=10
db.pool.minimumIdle=3
db.pool.idleTimeout=300000
db.pool.connectionTimeout=20000
db.pool.maxLifetime=1200000
```

---

## 4. Pre-Configured Demo Accounts

All demo accounts are seeded with secure 12-round BCrypt hashed passwords:

| Role | Email Identifier | Password | Access Portal & Capabilities |
|---|---|---|---|
| **Administrator** | `admin@aurastay.com` | `Admin@123` | Executive Dashboard, Inventory CRUD, Master Bookings, User Directory, Staff Roster, Feedback Moderation, Financial Analytics & CSV, Audit Trail |
| **Front Desk Staff** | `frontdesk@aurastay.com` | `Staff@123` | Front Desk Terminal, Express Check-In, Express Check-Out, Housekeeping Board, Reservations Lookup |
| **Housekeeping Staff** | `housekeeping@aurastay.com` | `Staff@123` | Housekeeping Room Status Updates (Clean, Dirty, Inspecting, Out of Service) |
| **Guest / Customer 1** | `john.doe@example.com` | `Guest@123` | Search & Book Rooms, My Bookings, Printable Tax Invoices, Demo Payment Simulator, Verified Reviews, Profile & Preferences |
| **Guest / Customer 2** | `sophia.miller@example.com` | `Guest@123` | Room Recommendations, Reservation Vouchers, Notifications, Password Change |

*Self-registration is also available directly on the website via `/register`.*

---

## 5. Building the Project

### Using Apache Maven
Open PowerShell in the project directory:

```powershell
# Run automated tests and compile classes
mvn test

# Package complete WAR artifact
mvn clean package
```

The compiled and assembled web application package will be generated at:
```text
target/smart-hotel-management.war
```

---

## 6. Deployment Guide

### Option A: Standalone Apache Tomcat 10.1
1. Verify Tomcat 10.1 is installed (e.g. at `C:\apache-tomcat-10.1.59`).
2. Copy `target/smart-hotel-management.war` into your Tomcat `webapps/` folder:
   ```powershell
   Copy-Item "target\smart-hotel-management.war" -Destination "C:\apache-tomcat-10.1.59\webapps\ROOT.war"
   ```
   *(Renaming to `ROOT.war` serves the application directly at `http://localhost:8080/`, or keep it as `smart-hotel-management.war` to serve at `http://localhost:8080/smart-hotel-management`).*
3. Start Tomcat:
   ```powershell
   & "C:\apache-tomcat-10.1.59\bin\startup.bat"
   ```
4. Access the portal in your browser:
   ```text
   http://localhost:8080/
   ```

### Option B: Eclipse IDE Deployment
1. Open **Eclipse IDE for Enterprise Java and Web Developers**.
2. Select **File &rarr; Import... &rarr; Maven &rarr; Existing Maven Projects**.
3. Browse to the workspace directory: `c:\Users\DELL\OneDrive\Desktop\hotel management`.
4. Click **Finish** to let Eclipse import and configure the project.
5. In the **Servers** tab, click **New &rarr; Server &rarr; Apache &rarr; Tomcat v10.1 Server**.
6. Set the Tomcat installation path to `C:\apache-tomcat-10.1.59` and ensure JRE is set to Java 17 or higher.
7. Right-click the project &rarr; **Run As &rarr; Run on Server**.

---

## 7. Pure Java Rule-Based Smart Features

In strict accordance with project specifications, no external AI/ML APIs, Python microservices, or paid third-party dependencies are used. All smart capabilities run natively inside the JVM using deterministic algorithms:

### 1. Smart Room Recommendation Engine (`SmartRecommenderService.java`)
- **Algorithm**: Multi-criteria weighted scoring algorithm evaluating:
  - **Budget Proximity**: Scores suites based on tariff closeness to guest maximum budget.
  - **Party Size & Capacity**: Ensures room capacity is adequate while penalizing over-sized suites.
  - **Feature & Keyword Match**: Evaluates amenities tags against guest vacation intent (e.g. "oceanfront", "jacuzzi", "honeymoon", "family", "business").
- **Output**: Ranked list of top 3 matching suites with percentage match confidence.

### 2. Rule-Based Hospitality FAQ Chatbot (`FaqChatbotService.java`)
- **Algorithm**: Pure Java pattern and keyword matcher operating on normalized token streams.
- **Coverage**: Check-in/check-out timings, parking & valet, airport shuttle transfers, pet policies, cancellation deadlines, Wi-Fi passwords, and breakfast hours.
- **Fallback**: Graceful fallback routing with direct front desk contact information.

### 3. Rule-Based Review Sentiment Classifier (`FeedbackService.java`)
- **Algorithm**: Weighted sentiment lexicon evaluating positive indicators (e.g., *exceptional, immaculate, outstanding, courteous, luxurious*) and negative indicators (e.g., *noisy, delayed, dirty, rude, disappointing*), with contextual negation detection (e.g., *not clean, never polite*).
- **Output**: Categorizes reviews into `POSITIVE`, `NEUTRAL`, or `NEGATIVE` to assist administrative moderation and quality assurance.

---

## 8. Enterprise Security & Concurrency Defenses

1. **Double-Booking Prevention**:
   - High-concurrency room reservations are protected using transactional database row locking:
   ```sql
   SELECT id FROM bookings 
   WHERE room_id = ? AND booking_status IN ('CONFIRMED', 'CHECKED_IN')
   AND check_in_date < ? AND check_out_date > ? 
   FOR UPDATE;
   ```
   - Wrapped in atomic transactions with explicit rollback on date overlaps.
2. **Cryptographic Password Security**:
   - BCrypt hashing with 12 computational cost rounds. Passwords are never stored or transmitted in plain text.
3. **Cross-Site Request Forgery (CSRF) Defense**:
   - `CsrfFilter` generates cryptographically secure 32-byte tokens per user session and verifies tokens on all state-changing `POST` requests.
4. **Role-Based Access Control (RBAC)**:
   - `AuthFilter` strictly gates URL patterns:
     - `/customer/*` requires active `CUSTOMER`, `STAFF`, or `ADMIN` session.
     - `/staff/*` requires active `STAFF` or `ADMIN` session.
     - `/admin/*` requires active `ADMIN` session.
   - Unauthorized attempts receive HTTP 403 Forbidden or are redirected to login.
5. **Session Fixation Defense**:
   - On successful authentication in `LoginServlet`, the old HTTP session is invalidated and renewed to defeat session hijacking attacks.
6. **Spreadsheet Formula Injection Defense (CWE-1236)**:
   - `ValidationUtil.escapeForCsv()` neutralizes cell formula triggers (`=`, `+`, `-`, `@`, tab, CR) by prepending a single quote (`'`), ensuring safe opening in Microsoft Excel and LibreOffice Calc.
7. **Demo Payment Sandbox Transparency**:
   - No real banking or cardholder data is collected. All demo payments are tagged with `is_demo = true` and stored with clear disclaimer banners.

---

## 9. Database Backup & Export Instructions

To take a complete snapshot of the database including schema, tables, and seed transactions:

```powershell
# Export database to SQL dump file
mysqldump -u root -p --routines --triggers smart_hotel_management > "aurastay_db_backup_20261019.sql"

# Restore database from backup
mysql -u root -p smart_hotel_management < "aurastay_db_backup_20261019.sql"
```

---

## 10. Verification & Test Summary

- **Unit Test Suite**: 17 Automated Tests run via `mvn test`:
  - `BookingServiceTest` (Pricing breakdowns, tax calculation, night computations)
  - `FaqChatbotServiceTest` (Keyword routing, policy retrieval, fallback handling)
  - `FeedbackServiceTest` (Pure Java sentiment analysis and negation rules)
  - `PasswordUtilTest` (BCrypt hashing, verification, invalid password rejection)
  - `ValidationUtilTest` (Email formatting, phone checks, date ranges, formula injection escaping)
- **Results**: **17 Tests Run, 0 Failures, 0 Errors, 0 Skipped — BUILD SUCCESS**.

---

*AuraStay Luxury Suites & Resort &mdash; Designed and Engineered for College Capstone Evaluation.*

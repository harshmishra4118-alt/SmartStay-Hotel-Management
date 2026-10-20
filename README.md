# SmartStay Hotel — Smart Hotel Management System

A full-stack, enterprise-grade **Smart Hotel Management System** built with **Java 17, Jakarta Servlets 6.0, Jakarta JSP 3.1, JDBC, HikariCP, and MySQL 8.x**, designed for high performance, bulletproof concurrency, and an intuitive modern hospitality experience.

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
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/smart_hotel_management?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
db.username=root
db.password=root
db.pool.maximumPoolSize=15
db.pool.minimumIdle=3
db.pool.idleTimeoutMs=300000
db.pool.connectionTimeoutMs=20000
db.pool.maxLifetimeMs=1800000
```

### Step 3: MySQL Database Export Procedure (`mysqldump`)
To create a live snapshot export of the database structure and data:

**Using Command Prompt or PowerShell:**
```powershell
mysqldump -u root -p --databases smart_hotel_management --routines --triggers --single-transaction > "database\smart_hotel_management_export.sql"
```

**Using MySQL Workbench GUI:**
1. Open MySQL Workbench and connect to your local MySQL instance.
2. From the top navigation menu, choose **Server** &rarr; **Data Export**.
3. In the left panel, select `smart_hotel_management`.
4. Choose **Dump Structure and Data**.
5. Under **Export Options**, select **Export to Self-Contained File** and set the path (e.g. `database/smart_hotel_management_export.sql`).
6. Click **Start Export**.

To import or restore the export file later:
```powershell
mysql -u root -p < "database\smart_hotel_management_export.sql"
```

---

## 4. Pre-Configured Seed Accounts & Security

All accounts seeded by `database/seed.sql` are securely hashed using **12-round BCrypt** (`$2a$12$...`). In compliance with security best practices, plaintext passwords are not published in public documentation.

| Role | Email Identifier | Password Hash Status | Access Portal & Capabilities |
|---|---|---|---|
| **Administrator** | `admin@smartstay.com` | `$2a$12$3D3X21uIv8aDuFFIYWG46uAB6qprjRO/meeVLaDvHvi8r5Kao8Rci` | Executive Dashboard, Inventory CRUD, Master Bookings, User Directory, Staff Roster, Feedback Moderation, Financial Analytics & CSV, Audit Trail |
| **Front Desk Staff** | `frontdesk@smartstay.com` | `$2a$12$mK3TTPGnxtbpoSmZAwdaNeBOHJSkGrQ9aM1Rmiieicqjsf90kI.tW` | Front Desk Terminal, Express Check-In, Express Check-Out, Housekeeping Board, Reservations Lookup |
| **Housekeeping Staff** | `housekeeping@smartstay.com` | `$2a$12$mK3TTPGnxtbpoSmZAwdaNeBOHJSkGrQ9aM1Rmiieicqjsf90kI.tW` | Housekeeping Room Status Updates (Clean, Dirty, Inspecting, Out of Service) |
| **Guest / Customer 1** | `john.doe@example.com` | `$2a$12$qorsj67ykvbo8O..gE1UM.4.3npHQLNJQe4hsjKqxgCSSu1hoaGWu` | Search & Book Rooms, My Bookings, Printable Tax Invoices, Demo Payment Simulator, Verified Reviews, Profile & Preferences |
| **Guest / Customer 2** | `sophia.miller@example.com` | `$2a$12$qorsj67ykvbo8O..gE1UM.4.3npHQLNJQe4hsjKqxgCSSu1hoaGWu` | Room Recommendations, Reservation Vouchers, Notifications, Password Change |

> [!NOTE]
> **Password Management & Customization**:
> - New accounts can be registered at `/register`.
> - Logged-in users can update their password under their profile management page.
> - To generate a new BCrypt hash for custom administrative credentials, invoke `PasswordUtil.hashPassword("YourStrongPassword")` or use standard BCrypt tooling (cost factor 12).
> - Default seeds can be customized directly in `database/seed.sql` prior to running the script in MySQL Workbench.

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

### Verified Local Environment Paths
- **Java Runtime**: Oracle JDK 21.0.10 LTS (`C:\Program Files\Java\jdk-21.0.10`)
- **Maven**: Apache Maven 3.10.0 (`C:\apache-maven-3.10.0`)
- **Tomcat**: Apache Tomcat 10.1.59 (`C:\apache-tomcat-10.1.59`)
- **Tomcat HTTP Port**: `8080` (configured in `C:\apache-tomcat-10.1.59\conf\server.xml`)
- **MySQL Server 8.0**: Running on port `3306` (`C:\Program Files\MySQL\MySQL Server 8.0`)
- **MySQL Workbench 8.0**: Installed at `C:\Program Files\MySQL\MySQL Workbench 8.0`
- **Application Context Path**: `/smart-hotel-management`
- **Exact Application URL**: `http://localhost:8080/smart-hotel-management`

---

### Quick Launch (Simplest for Beginners)
To run the system with minimal manual steps:
1. **Initialize Database**:
   - Run `setup_database.bat` in PowerShell or Command Prompt (or double-click it in Windows Explorer).
   - Enter your local MySQL root password when prompted.
   - The script automatically creates `smart_hotel_management`, imports `schema.sql` and `seed.sql`, and syncs `db.properties`.
2. **Start Server**:
   - Run `start_tomcat.bat` (or keep the currently active background server running).
3. **Open Browser**:
   - Navigate to `http://localhost:8080/smart-hotel-management/`
4. **Stop Server**:
   - Run `stop_tomcat.bat` when finished.

---

### Option A: Manual Apache Tomcat 10.1 Setup
1. **Configure Database Credentials**:
   Ensure `src/main/resources/db.properties` contains your local MySQL root password:
   ```properties
   db.url=jdbc:mysql://localhost:3306/smart_hotel_management?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
   db.username=root
   db.password=YOUR_LOCAL_MYSQL_PASSWORD
   ```
2. **Execute Database Scripts in MySQL Workbench**:
   - Open MySQL Workbench &rarr; connect to local MySQL (port 3306).
   - Execute `database/schema.sql` (creates schema and 12 normalized tables).
   - Execute `database/seed.sql` (populates rooms, bookings, and BCrypt-hashed role accounts).
3. **Build the WAR Package**:
   ```powershell
   & "C:\apache-maven-3.10.0\bin\mvn.cmd" clean package -DskipTests
   ```
4. **Deploy to Tomcat Webapps**:
   ```powershell
   Copy-Item "target\smart-hotel-management.war" -Destination "C:\apache-tomcat-10.1.59\webapps\smart-hotel-management.war"
   ```
   *(Note: The WAR has already been copied to `C:\apache-tomcat-10.1.59\webapps\smart-hotel-management.war`).*
5. **Start Tomcat**:
   ```powershell
   & "C:\apache-tomcat-10.1.59\bin\startup.bat"
   ```
6. **Open in Browser**:
   ```text
   http://localhost:8080/smart-hotel-management
   ```
7. **Stop Tomcat**:
   ```powershell
   & "C:\apache-tomcat-10.1.59\bin\shutdown.bat"
   ```

---

### Option B: Eclipse IDE Deployment
1. Open **Eclipse IDE for Enterprise Java and Web Developers**.
2. Select **File &rarr; Import... &rarr; Maven &rarr; Existing Maven Projects**.
3. Browse to the workspace directory: `c:\Users\DELL\OneDrive\Desktop\hotel management`.
4. Click **Finish** to let Eclipse import and configure the project.
5. In the **Servers** tab, click **New &rarr; Server &rarr; Apache &rarr; Tomcat v10.1 Server**.
6. Set the Tomcat installation path to `C:\apache-tomcat-10.1.59` and ensure JRE is set to Java 17 or higher.
7. Right-click the project &rarr; **Run As &rarr; Run on Server**.
8. Access at `http://localhost:8080/smart-hotel-management`.

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
mysqldump -u root -p --routines --triggers smart_hotel_management > "smartstay_db_backup.sql"

# Restore database from backup
mysql -u root -p smart_hotel_management < "smartstay_db_backup.sql"
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

*SmartStay Hotel &mdash; Designed and Engineered for College Capstone Evaluation.*

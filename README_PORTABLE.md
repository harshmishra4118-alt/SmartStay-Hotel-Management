# 🏨 SmartStay Hotel Management System — Portable Edition

Welcome to the **SmartStay Hotel Management System Portable Edition**!  
This standalone distribution is designed for **100% Zero-Configuration, Zero-Installation** deployment on Windows.

> **Zero Prerequisites Required:**
> You do **NOT** need to install Java, Apache Tomcat, Maven, MySQL Server, or any VS Code extensions on your computer. Everything required to run the full application and database is embedded inside this folder.

---

## ⚡ Quick Start Guide (Under 30 Seconds)

### Option 1: One-Click Startup via Batch Script (Easiest)
1. **Extract** the entire `SmartStay-Portable.zip` archive into any folder on your computer.
2. **Double-click** `START_PROJECT.bat`.
3. The launcher will automatically:
   - Start the embedded portable MySQL database engine on port `3307`.
   - Start the embedded portable Apache Tomcat 10.1 application server on port `8080`.
   - Open your default web browser to the homepage:  
     👉 **`http://localhost:8080/smart-hotel-management/`**

### Option 2: Run via Visual Studio Code
1. Open Visual Studio Code.
2. Select **File > Open Folder...** and select the extracted `hotel management` folder.
3. Open the command palette (`Ctrl + Shift + P`) and choose **Tasks: Run Task** > **Run SmartStay**  
   *(or simply press `Ctrl + Shift + B`)*.
4. The terminal panel will open, launch both services, and launch your browser.

---

## 🛑 How to Stop the System Cleanly

When you are done testing or demonstrating the project:
- **Double-click** `STOP_PROJECT.bat` (or run the **Stop SmartStay** task in VS Code).
- This gracefully flushes the database buffers and stops both Tomcat and MySQL without corrupting data or leaving background processes running.

---

## 🔑 Pre-Configured Demo Accounts

The database comes fully populated with hotels, luxury suites, active bookings, transactions, and user accounts. You can log in immediately using any of these roles:

| Role | Email Address | Password | Features Accessible |
|---|---|---|---|
| 👑 **Super Admin** | `admin@smartstay.com` | `admin123` | Platform-wide oversight, manage all hotels, rooms, bookings, staff, revenue reports & audit logs. |
| 🛎️ **Hotel Staff (Frontdesk)** | `frontdesk@smartstay.com` | `staff123` | Guest check-in, check-out, room status updates, guest arrivals/departures board. |
| 🧹 **Housekeeping** | `housekeeping@smartstay.com` | `staff123` | Room cleaning schedules, maintenance inspection logs, room readiness updates. |
| 👤 **Customer / Guest** | `john.doe@example.com` | `customer123` | Search properties, interactive Leaflet map, book rooms, simulate payments, view voucher & PDF receipt. |

> *Tip: You can also register a brand-new customer account on the registration page (`/register`), which will save immediately to the embedded database and let you log in right away.*

---

## 🌟 Core Features Included & Operational

1. **Multi-Hotel Marketplace**: Real-time property browsing across multiple cities with interactive OpenStreetMap geolocation pins.
2. **Live Room Availability Engine**: Real-time concurrency checks with atomic row locking to prevent double bookings.
3. **Customer Registration & Authentication**: 12-round BCrypt password hashing, session fixation protection, and CSRF token security.
4. **Instant Booking & Payments**: Complete reservation workflow with coupon validation and simulated card/UPI payment settlement.
5. **PDF Invoicing & Vouchers**: On-demand ISO-32000 binary PDF receipt download (`/customer/invoice/pdf`) and printable booking vouchers.
6. **Role-Based Access Control**: Strict multi-tier security filter protecting Admin, Staff, and Customer zones.
7. **Housekeeping & Operations**: Live room turnover management for hotel receptionists and cleaning teams.

---

## 💻 System Requirements & Specifications

- **Operating System**: Windows 10 (64-bit) or Windows 11 (64-bit).
- **RAM**: Minimum 4 GB RAM recommended (Embedded runtimes are configured to use < 600 MB RAM total).
- **Free Disk Space**: ~1.5 GB for extracted files and database storage.
- **Network Ports**:
  - `8080`: Apache Tomcat HTTP Web Server
  - `3307`: Portable MySQL 8.0 Server (Isolated on 3307 to avoid collisions if you already have MySQL on port 3306)
- **First-Startup Time**: ~8 to 15 seconds (to initialize local InnoDB storage and deploy the application WAR). Subsequent startups take ~3 to 5 seconds.

---

## 📦 What is Inside This Portable Package?

```text
hotel-management/
├── START_PROJECT.bat          <-- Double-click to start MySQL, Tomcat & Browser
├── STOP_PROJECT.bat           <-- Double-click to stop all services cleanly
├── README_PORTABLE.md         <-- This beginner-friendly guide
├── README.md                  <-- Full technical architecture and API specification
├── PROJECT_PROGRESS.md        <-- Project verification and module tracking report
├── pom.xml                    <-- Maven build descriptor
├── .vscode/
│   ├── tasks.json             <-- "Run SmartStay" and "Stop SmartStay" task definitions
│   └── launch.json            <-- One-click browser launch configuration
├── portable/
│   ├── java/                  <-- Stripped, lightweight Java 21 LTS Runtime Environment (~79 MB)
│   ├── tomcat/                <-- Portable Apache Tomcat 10.1 Application Server
│   │   ├── bin/setenv.bat     <-- Automatic relative path & port 3307 configuration
│   │   └── webapps/
│   │       ├── smart-hotel-management.war  <-- Pre-compiled production application archive
│   │       └── ROOT/                       <-- Root redirector to /smart-hotel-management/
│   └── mysql/                 <-- Portable MySQL 8.0 Database Engine (Port 3307)
│       ├── my.ini             <-- Optimized standalone InnoDB configuration
│       └── data/              <-- Pre-initialized data directory with all tables and records
├── database/
│   ├── schema.sql             <-- Relational database DDL schema (20 normalized tables)
│   ├── seed.sql               <-- Initial sample data seed script
│   └── backup_dump_20261112.sql <-- Complete SQL snapshot backup
└── src/                       <-- Full Java & Web application source code
```

---

## ❓ Troubleshooting & FAQs

### Q: Port 8080 or 3307 is already in use by another program. What should I do?
- **Tomcat (Port 8080)**: If another software uses port 8080, open `portable\tomcat\conf\server.xml`, search for `port="8080"`, and change it to `8090`. Then update `APP_URL` in `START_PROJECT.bat`.
- **MySQL (Port 3307)**: SmartStay defaults to port `3307` specifically to avoid conflicting with any standard MySQL server running on port `3306`. If needed, you can modify `port=3307` in `portable\mysql\my.ini` and update `portable\tomcat\bin\setenv.bat`.

### Q: Windows Defender or SmartScreen shows an alert when running the batch file.
- Because the script is an un-signed batch file downloaded from the web or created locally, click **More info** and then click **Run anyway**. All binaries are official OpenJDK, Apache Tomcat, and MySQL releases.

### Q: Do I ever lose my booking data when stopping the application?
- **No.** The database is stored persistently in `portable\mysql\data\`. Stopping the system via `STOP_PROJECT.bat` safely commits all transactions and writes changes to disk.

---
*Created for SmartStay Hotel Management System — Enterprise Hospitality Platform.*


@echo off
setlocal enabledelayedexpansion
title SmartStay Hotel Management - Automated Database Setup

echo =====================================================================
echo  SmartStay Hotel - Automated MySQL Database Setup
echo =====================================================================
echo.

set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not exist "!MYSQL_EXE!" (
    echo [ERROR] MySQL 8.0 was not found at: !MYSQL_EXE!
    echo Please execute database\schema.sql and database\seed.sql in MySQL Workbench.
    pause
    exit /b 1
)

set /p "DB_PASS=Please enter your local MySQL root password: "

echo.
echo [1/4] Testing connection to MySQL Server on port 3306...
"!MYSQL_EXE!" -u root -p!DB_PASS! -e "SELECT 1;" >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Authentication failed! Incorrect password for user 'root'@'localhost'.
    echo Please verify your MySQL root password and try again.
    pause
    exit /b 1
)
echo [SUCCESS] Connected to MySQL successfully!

echo.
echo [2/4] Executing schema.sql (creating smart_hotel_management database)...
"!MYSQL_EXE!" -u root -p!DB_PASS! < "%~dp0database\schema.sql"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to execute schema.sql.
    pause
    exit /b 1
)
echo [SUCCESS] Database schema and 12 tables created!

echo.
echo [3/4] Executing seed.sql (populating luxury rooms, bookings, and demo accounts)...
"!MYSQL_EXE!" -u root -p!DB_PASS! smart_hotel_management < "%~dp0database\seed.sql"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to execute seed.sql.
    pause
    exit /b 1
)
echo [SUCCESS] Seed data imported successfully!

echo.
echo [4/4] Updating local db.properties configuration...
set "DB_PASS_VAL=!DB_PASS!"
powershell -NoProfile -Command "$pass = [System.Environment]::GetEnvironmentVariable('DB_PASS_VAL'); $p1 = '%~dp0src\main\resources\db.properties'; $c1 = [System.IO.File]::ReadAllText($p1) -replace 'db.password=.*', ('db.password=' + $pass); [System.IO.File]::WriteAllText($p1, $c1, [System.Text.UTF8Encoding]::new($false)); $p2 = 'C:\apache-tomcat-10.1.59\webapps\smart-hotel-management\WEB-INF\classes\db.properties'; if (Test-Path $p2) { $c2 = [System.IO.File]::ReadAllText($p2) -replace 'db.password=.*', ('db.password=' + $pass); [System.IO.File]::WriteAllText($p2, $c2, [System.Text.UTF8Encoding]::new($false)) }"

echo.
echo =====================================================================
echo  DATABASE INITIALIZATION COMPLETE!
echo =====================================================================
echo.
echo Your Smart Hotel Management System is LIVE and ready in your browser:
echo.
echo   - Homepage:        http://localhost:8080/smart-hotel-management/
echo   - Rooms & Suites:  http://localhost:8080/smart-hotel-management/rooms
echo   - Sign In Portal:  http://localhost:8080/smart-hotel-management/login
echo.
echo Simply refresh the page in Chrome!
echo =====================================================================
pause

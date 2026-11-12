@echo off
title SmartStay Hotel Management - Portable Runner
color 0B
cls

echo =========================================================================
echo               SMARTSTAY HOTEL MANAGEMENT SYSTEM
echo                   Portable One-Click Launcher
echo =========================================================================
echo.

set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"

set "JAVA_HOME=%ROOT_DIR%\portable\java"
set "JRE_HOME=%ROOT_DIR%\portable\java"
set "MYSQL_HOME=%ROOT_DIR%\portable\mysql"
set "TOMCAT_HOME=%ROOT_DIR%\portable\tomcat"
set "CATALINA_HOME=%ROOT_DIR%\portable\tomcat"
set "CATALINA_BASE=%ROOT_DIR%\portable\tomcat"
set "PATH=%JAVA_HOME%\bin;%MYSQL_HOME%\bin;%PATH%"

echo [*] Initializing portable environment...
echo     Base Directory: %ROOT_DIR%
echo     Java Runtime:   %JAVA_HOME%
echo     MySQL Portable: %MYSQL_HOME%
echo     Tomcat Server:  %TOMCAT_HOME%
echo.

rem -------------------------------------------------------------------------
rem 1. Check & Start Portable MySQL (Port 3307)
rem -------------------------------------------------------------------------
echo [*] Checking Portable MySQL Server on port 3307...
"%MYSQL_HOME%\bin\mysqladmin.exe" -u root -pharsh@27 -P 3307 ping >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Portable MySQL is already running on port 3307.
    goto MYSQL_READY
)

echo [*] Starting Portable MySQL Database Engine...
start "SmartStay Portable MySQL" "%MYSQL_HOME%\bin\mysqld.exe" --defaults-file="%MYSQL_HOME%\my.ini" --basedir="%MYSQL_HOME%" --datadir="%MYSQL_HOME%\data" --console

set /a RETRIES=0
:WAIT_MYSQL
ping 127.0.0.1 -n 3 >nul
"%MYSQL_HOME%\bin\mysqladmin.exe" -u root -pharsh@27 -P 3307 ping >nul 2>&1
if %ERRORLEVEL% EQU 0 goto MYSQL_READY
set /a RETRIES+=1
if %RETRIES% LSS 12 (
    echo     Waiting for MySQL database engine to initialize... [attempt %RETRIES% of 12]
    goto WAIT_MYSQL
)
echo [!] Warning: MySQL took longer than expected to start. Continuing...

:MYSQL_READY
echo [OK] Portable MySQL is ready and accepting queries on port 3307.
echo.

rem -------------------------------------------------------------------------
rem 2. Check & Start Apache Tomcat 10.1 (Port 8080)
rem -------------------------------------------------------------------------
echo [*] Checking if Apache Tomcat is already listening on port 8080...
set "TOMCAT_RUNNING=0"
for /f "tokens=*" %%H in ('powershell -NoProfile -Command "try { (Invoke-WebRequest -Uri 'http://127.0.0.1:8080/smart-hotel-management/' -UseBasicParsing -TimeoutSec 2).StatusCode } catch { if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { '000' } }" 2^>nul') do (
    if "%%H"=="200" set "TOMCAT_RUNNING=1"
    if "%%H"=="302" set "TOMCAT_RUNNING=1"
)

if "%TOMCAT_RUNNING%"=="1" (
    echo [OK] Apache Tomcat is already active and responding on port 8080.
    goto APP_READY
)

echo [*] Starting Apache Tomcat 10.1 Application Server...
pushd "%TOMCAT_HOME%"
start "SmartStay Apache Tomcat" bin\catalina.bat run
popd
echo [OK] Apache Tomcat process spawned.

rem -------------------------------------------------------------------------
rem 3. Active Readiness Probe - Wait for HTTP 200/302 Response
rem -------------------------------------------------------------------------
echo [*] Waiting for SmartStay application to deploy and open port 8080...
set /a T_RETRIES=0

:WAIT_TOMCAT
ping 127.0.0.1 -n 3 >nul
set "HTTP_STATUS=000"
for /f "tokens=*" %%S in ('powershell -NoProfile -Command "try { (Invoke-WebRequest -Uri 'http://127.0.0.1:8080/smart-hotel-management/' -UseBasicParsing -TimeoutSec 2).StatusCode } catch { if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { '000' } }" 2^>nul') do set "HTTP_STATUS=%%S"

if "%HTTP_STATUS%"=="200" goto APP_READY
if "%HTTP_STATUS%"=="302" goto APP_READY

set /a T_RETRIES+=1
if %T_RETRIES% LSS 30 (
    echo     Deploying SmartStay web application... [%T_RETRIES% of 30] (HTTP %HTTP_STATUS%)
    goto WAIT_TOMCAT
)

echo.
echo [!] ERROR: Apache Tomcat did not respond with HTTP 200 within expected time.
echo [*] Inspecting last 15 lines of Tomcat log:
if exist "%TOMCAT_HOME%\logs" (
    powershell -NoProfile -Command "Get-ChildItem -Path '%TOMCAT_HOME%\logs\catalina.*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content -Tail 15"
)
echo.
echo [!] Please check if port 8080 is blocked by another application.
goto END

:APP_READY
echo.
echo [OK] SmartStay Hotel Management is fully online and verified! (HTTP 200)
echo.

rem -------------------------------------------------------------------------
rem 4. Launch Web Browser
rem -------------------------------------------------------------------------
set "APP_URL=http://127.0.0.1:8080/smart-hotel-management/"
echo [*] Opening default web browser at %APP_URL% ...
start "" "%APP_URL%"

echo.
echo =========================================================================
echo             SMARTSTAY IS RUNNING SUCCESSFULLY!
echo =========================================================================
echo.
echo   Application URL:  %APP_URL%
echo.
echo   Demo Login Accounts (Pre-configured):
echo   ---------------------------------------------------------------------
echo   * Customer Portal:   john.doe@example.com       Password: customer123
echo   * Super Admin:       admin@smartstay.com        Password: admin123
echo   * Hotel Staff:       frontdesk@smartstay.com    Password: staff123
echo   * Housekeeping:      housekeeping@smartstay.com  Password: staff123
echo.
echo   To stop all services cleanly, double-click STOP_PROJECT.bat.
echo =========================================================================
echo.

:END
if "%~1"=="/nowait" goto FINISH
pause
:FINISH

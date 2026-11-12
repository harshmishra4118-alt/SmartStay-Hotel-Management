@echo off
title SmartStay Hotel Management - Shutdown Utility
color 0C
cls

echo =========================================================================
echo               SMARTSTAY HOTEL MANAGEMENT SYSTEM
echo                   Portable Services Shutdown
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

rem -------------------------------------------------------------------------
rem 1. Shutdown Apache Tomcat
rem -------------------------------------------------------------------------
echo [*] Gracefully stopping Apache Tomcat...
if exist "%TOMCAT_HOME%\bin\catalina.bat" (
    pushd "%TOMCAT_HOME%"
    call bin\catalina.bat stop 2 -force >nul 2>&1
    popd
)
rem Terminate any stray java process originating from the portable directory
powershell -NoProfile -Command "Get-Process java -ErrorAction SilentlyContinue | Where-Object { try { $_.Path -like '*portable\java*' } catch { $false } } | Stop-Process -Force" >nul 2>&1
echo [OK] Apache Tomcat stopped.

rem -------------------------------------------------------------------------
rem 2. Shutdown Portable MySQL Server
rem -------------------------------------------------------------------------
echo [*] Gracefully stopping Portable MySQL Database Server...
if exist "%MYSQL_HOME%\bin\mysqladmin.exe" (
    "%MYSQL_HOME%\bin\mysqladmin.exe" -u root -pharsh@27 -P 3307 shutdown >nul 2>&1
)
rem Terminate any lingering mysqld process originating from the portable directory
powershell -NoProfile -Command "Get-Process mysqld -ErrorAction SilentlyContinue | Where-Object { try { $_.Path -like '*portable\mysql*' } catch { $false } } | Stop-Process -Force" >nul 2>&1
echo [OK] Portable MySQL stopped.

echo.
echo =========================================================================
echo   [SUCCESS] All SmartStay Portable services have been stopped safely.
echo =========================================================================
echo.
if "%~1"=="/nowait" goto END
ping 127.0.0.1 -n 3 >nul
:END

@echo off
REM =====================================================================
REM AuraStay Smart Hotel Management System - Tomcat 10.1 Shutdown Script
REM =====================================================================
set "JAVA_HOME=C:\Program Files\Java\jdk-21.0.10"
set "JRE_HOME=C:\Program Files\Java\jdk-21.0.10"
set "CATALINA_HOME=C:\apache-tomcat-10.1.59"
set "CATALINA_BASE=C:\apache-tomcat-10.1.59"

echo Stopping Apache Tomcat 10.1...
call "%CATALINA_HOME%\bin\catalina.bat" stop

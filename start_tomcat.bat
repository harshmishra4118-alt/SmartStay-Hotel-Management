@echo off
REM =====================================================================
REM SmartStay Hotel Management System - Tomcat 10.1 Launcher
REM =====================================================================
set "JAVA_HOME=C:\Program Files\Java\jdk-21.0.10"
set "JRE_HOME=C:\Program Files\Java\jdk-21.0.10"
set "CATALINA_HOME=C:\apache-tomcat-10.1.59"
set "CATALINA_BASE=C:\apache-tomcat-10.1.59"

echo Starting Apache Tomcat 10.1 for Smart Hotel Management System...
echo Java Home: %JAVA_HOME%
echo Catalina Home: %CATALINA_HOME%
call "%CATALINA_HOME%\bin\catalina.bat" run

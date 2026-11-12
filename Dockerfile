FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests package

FROM tomcat:10.1.59-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/* && sed -i 's/port="8080"/port="10000"/' /usr/local/tomcat/conf/server.xml
COPY --from=build /app/target/smart-hotel-management.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 10000
CMD ["catalina.sh", "run"]

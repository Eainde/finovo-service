FROM maven:3.9.8-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml ./
RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests spring-boot:repackage

# Stage 2: Create the runtime image with Java 21 JRE
FROM openjdk:21-jdk-slim

RUN useradd -m springuser
USER springuser

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /build

COPY pom.xml ./
COPY src ./src
RUN mvn -DskipTests clean package && cp target/*.jar app.jar

FROM eclipse-temurin:17-jre
WORKDIR /app
EXPOSE 8080
COPY --from=builder /build/app.jar app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
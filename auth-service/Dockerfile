FROM eclipse-temurin:17
WORKDIR /auth

EXPOSE 8080

COPY target/*.jar auth-service.jar

ENTRYPOINT ["java", "-jar", "auth-service.jar"]
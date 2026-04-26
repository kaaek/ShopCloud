FROM eclipse-temurin:17
WORKDIR /admin
EXPOSE 8084
COPY target/*.jar admin-service.jar
ENTRYPOINT ["java", "-jar", "admin-service.jar"]
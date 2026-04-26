FROM eclipse-temurin:17
WORKDIR /catalog

EXPOSE 8081

COPY target/*.jar catalog-service.jar

ENTRYPOINT ["java", "-jar", "catalog-service.jar"]
FROM eclipse-temurin:17
WORKDIR /catalog
# Expose the same port specified in ./src/main/resources/application.yaml
EXPOSE 8081
# Copy the .jar representing our application
COPY target/*.jar /catalog/catalog.jar
ENTRYPOINT ["java", "-jar", "catalog.jar"]
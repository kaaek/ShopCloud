FROM eclipse-temurin:17
WORKDIR /checkout
EXPOSE 8083
COPY target/*.jar checkout-service.jar
ENTRYPOINT ["java", "-jar", "checkout-service.jar"]
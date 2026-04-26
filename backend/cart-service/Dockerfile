FROM eclipse-temurin:17
WORKDIR /cart
EXPOSE 8082
COPY target/*.jar cart-service.jar
ENTRYPOINT ["java", "-jar", "cart-service.jar"]
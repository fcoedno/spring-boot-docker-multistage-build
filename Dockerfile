FROM openjdk:11.0.4-jdk-stretch AS builder
WORKDIR /app
COPY build.gradle gradlew gradlew.bat settings.gradle ./
COPY gradle gradle
# Using the custom task:
# RUN ./gradlew resolveDependencies
# Using the configuration-resolver plugin:
RUN ./gradlew resolveConfigurations
COPY src src
RUN ./gradlew build

FROM openjdk:11.0.4-jre-stretch
WORKDIR /app
COPY --from=builder /app/build/libs/hello-0.0.1-SNAPSHOT.jar ./app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

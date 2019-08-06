# Spring boot with multistage docker build

This is a simple hello world project to demonstrate how to use docker multistage build
to generate container images for spring boot applications.

## Building and Running

To build the container, run:

    docker build -t hello .
    
To execute it:

    docker run --rm -p 8080:8080 hello    
    
## Details    

The idea is first copying gradle-specific files and then resolving all the dependencies
so that we can make use of the layer caching mechanism from docker build. After that, we copy
over the source code and actually run the build.

```dockerfile
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
```

To resolve the dependencies I would recommend the 
[configuration resolver plugin](https://github.com/palantir/gradle-configuration-resolver-plugin).
However, if you're looking for a quick and dirty solution, you can just add this gradle task to your
`build.gradle` file:

```groovy
task resolveDependencies {
    doLast {
        project.rootProject.allprojects.each { subProject ->
            subProject.buildscript.configurations.each { configuration ->
                if (configuration.isCanBeResolved()) {
                    configuration.resolve()
                }
            }
            subProject.configurations.each { configuration ->
                if (configuration.isCanBeResolved()) {
                    configuration.resolve()
                }
            }
        }
    }
}
```

FROM maven:3.6.3-openjdk-11 AS maven_build
# todo: dont use tmp
COPY src /app
WORKDIR /app
FROM openjdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]

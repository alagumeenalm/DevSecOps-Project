FROM openjdk:17-jdk-alpine
WORKDIR /opt/app
COPY target/devsecops-project.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
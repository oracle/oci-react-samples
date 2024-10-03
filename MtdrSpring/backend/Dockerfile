## MyToDoReact version 2.0.0
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as
## shown at https://oss.oracle.com/licenses/upl/

FROM openjdk:17

WORKDIR /app

COPY target/MyTodoList-2.0.0.jar todolistapp-spring-boot.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","todolistapp-spring-boot.jar"]
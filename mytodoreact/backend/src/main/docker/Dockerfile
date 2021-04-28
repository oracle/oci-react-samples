## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
FROM openjdk:11
# In order to use the same application.yaml file both in the container
# and in the IDE, we need to copy the wallet directory under /target/classes/wallet.
# This way the JDBC URL can point to jdbc:oracle:thin:@xxx?TNS_ADMIN=target/classes/wallet-->

ADD target/classes/wallet /target/classes/wallet
ADD target/libs /target/libs
ADD target/todolistapp-helidon-se.jar /target/todolistapp-helidon-se.jar
ENTRYPOINT ["java", "-jar", "/target/todolistapp-helidon-se.jar"]

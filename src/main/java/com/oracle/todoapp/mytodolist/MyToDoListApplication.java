/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/

package com.oracle.todoapp.mytodolist;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MyToDoListApplication {

	public static void main(String[] args) {	
		// -Doracle.jdbc.diagnostic.enableLogging=true -Doracle.jdbc.diagnostic.enableSensitiveDiagnostics=true -Doracle.jdbc.diagnostic.permitSensitiveDiagnostics=true -Djava.util.logging.config.file=./logging.config	
		System.setProperty("oracle.jdbc.diagnostic.enableLogging", "true");
		System.setProperty("oracle.jdbc.diagnostic.enableSensitiveDiagnostics", "true");
		System.setProperty("oracle.jdbc.diagnostic.permitSensitiveDiagnostics", "true");
		System.setProperty("java.util.logging.config.file", "./jdbclogging.properties");
		SpringApplication.run(MyToDoListApplication.class, args);
	}

}

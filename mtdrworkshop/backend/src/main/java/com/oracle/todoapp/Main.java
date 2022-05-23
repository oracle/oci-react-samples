/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/
package com.oracle.todoapp;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.LogManager;

import io.helidon.config.Config;
import io.helidon.media.jsonp.JsonpSupport;
import io.helidon.webserver.ErrorHandler;
import io.helidon.webserver.Routing;
import io.helidon.webserver.WebServer;
import io.helidon.webserver.cors.CorsSupport;
import io.helidon.webserver.cors.CrossOriginConfig;

/*
 * This is the helidon-se backend.
 * @author jean.de.lavarene@oracle.com
 */
public final class Main {

  public static void main(final String[] args)
      throws IOException, SQLException {
    System.out.println("Working Directory = " + System.getProperty("user.dir"));
    System.setProperty("oracle.jdbc.fanEnabled", "false");
    LogManager
        .getLogManager()
        .readConfiguration(
            Main.class.getResourceAsStream("/logging.properties"));
    Config config = Config.create();

    WebServer.builder()
      .config(config.get("server")) //update this server configuration from the config provided
      .addMediaSupport(JsonpSupport.create())
      .routing(createRouting(config))
      .build()
      .start()
      .thenAccept(ws -> {
        System.out.printf(
          "webserver is up! http://localhost:%s/todolist%n", ws.port());
        ws.whenShutdown().thenRun(() ->
          System.out.println("WEB server is DOWN. Good bye!"));
      })
      .exceptionally(t -> {
        System.err.printf("Startup failed: %s%n", t.getMessage());
        t.printStackTrace(System.err);
        return null;
      });
  }

  private static Routing createRouting(Config config) throws SQLException {

    // Creates a Helidon's Service implementation.
    // Use database configuration from application.yaml that
    // can be over-ridden by System.properties
    TodoListAppService todoListAppService = new TodoListAppService(config.get("database"));

    CorsSupport corsSupport = CorsSupport.builder()
    .addCrossOrigin(CrossOriginConfig.builder()
        .allowOrigins("http://localhost:3000",
           "https://objectstorage.us-phoenix-1.oraclecloud.com",
           "https://petstore.swagger.io")
        .allowMethods("POST", "PUT", "DELETE")
        .exposeHeaders("location")
        .build())
    .addCrossOrigin(CrossOriginConfig.create())
        .build();

    // Create routing and register
    return Routing
        .builder()
        .register("/todolist", corsSupport, todoListAppService)
        .error(Throwable.class, handleErrors())
        .build();
  }
  private static ErrorHandler<Throwable> handleErrors() {
    return (req, res, t) -> {
        if (t instanceof TodoItemNotFoundException) {
            res.status(404).send(t.getMessage());
        } else {
            req.next(t);
        }
    };
  }
}

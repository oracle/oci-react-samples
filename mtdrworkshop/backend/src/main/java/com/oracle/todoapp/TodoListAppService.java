/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/
package com.oracle.todoapp;

import java.net.URI;
import java.util.logging.Logger;

import javax.json.JsonObject;

import io.helidon.config.Config;
import io.helidon.webserver.Routing.Rules;
import io.helidon.webserver.ServerRequest;
import io.helidon.webserver.ServerResponse;
import io.helidon.webserver.Service;

/*
 * This Helidon service implements the REST APIs that are used in the Todo List application. The
 * implementation uses asynchronous APIs.
 * @author  jean.de.lavarene@oracle.com
 */
public class TodoListAppService implements Service {
  private final static Logger LOGGER = Logger.getLogger(TodoListAppService.class.getName());

  // object responsible for the persistence of the todo items:
  private final TodoItemStorage todoItems;

  public TodoListAppService(Config config) {
    todoItems = TodoItemStorage.get(config);
  }

  @Override
  public void update(Rules rules) {
    rules
      .get("/", this::getAllTodos)
      .post("/", this::saveTodo)
      .get("/{id}", this::getTodoById)
      .put("/{id}", this::updateTodo)
      .delete("/{id}", this::deleteTodoById);
  }

  private void getAllTodos(ServerRequest serverRequest, ServerResponse serverResponse) {
    LOGGER.fine("getAllTodos");
    serverResponse.send(TodoItem.toJsonArray(this.todoItems.all()));
  }

  private void saveTodo(ServerRequest serverRequest, ServerResponse serverResponse) {
    LOGGER.fine("saveTodo");
    serverRequest.content().as(JsonObject.class)
      .thenApply(
          /* convert from JSON to TodoItem object */
          TodoItem::fromJsonObject)
      .thenApply(todoItem ->
          TodoItem.of(todoItem.getId(),todoItem.getDescription(),
            todoItem.getCreatedAt(),todoItem.isDone())
      )
      .thenApply(this.todoItems::save) // this blocking

      // Use async APIs when avaiable:
      // .thenCompose(this.todoItems::asyncSave)
      .thenCompose(
          todoItem -> {
              serverResponse.status(201)
                  .headers()
                  .location(URI.create(""+todoItem.getId()));
              return serverResponse.send();
          }
      );

  }

  private void getTodoById(ServerRequest serverRequest, ServerResponse serverResponse) {
    LOGGER.fine("getTodoById");
    String id = serverRequest.path().param("id");
    TodoItem todo = this.todoItems.getById(id);
    if (todo == null) {
      // todo  identified by "id" wasn't found:
      serverRequest.next(new TodoItemNotFoundException(id));
    } else {
      serverResponse.status(200).send(TodoItem.toJsonObject(todo));
    }
  }
  private void updateTodo(ServerRequest serverRequest, ServerResponse serverResponse) {
    LOGGER.fine("updateTodo");
    TodoItem item = this.todoItems.getById(serverRequest.path().param("id"));
    serverRequest.content().as(JsonObject.class)
        .thenApply(TodoItem::fromJsonObject)
        .thenApply(reqItem -> {
          item.setDescription(reqItem.getDescription());
          item.setDone(reqItem.isDone());
          return item;
        })
        .thenApply(this.todoItems::save) // this is blocking
        // Use async APIs when avaiable:
        // .thenCompose(this.todiItems::asyncSave)
        .thenCompose(
            p -> serverResponse.status(204).send()
        );
  }
  void deleteTodoById(ServerRequest serverRequest, ServerResponse serverResponse) {
    LOGGER.fine("updateTodo");
    this.todoItems.deleteById(serverRequest.path().param("id"));
    serverResponse.status(204).send();
  }
}

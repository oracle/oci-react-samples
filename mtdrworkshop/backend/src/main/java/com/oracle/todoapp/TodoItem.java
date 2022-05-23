/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/
package com.oracle.todoapp;

import java.io.Serializable;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.logging.Logger;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObject;

/*
 * This class is used to represent a Todo item in Java. Each such item has a unique identifier,
 * a description, a creation date and a boolean that indicates if the item is
 * done (in other words "complete") or not.
 * @author  jean.de.lavarene@oracle.com
 */

class TodoItem implements Serializable {
  private static final long serialVersionUID = 4168008245514009223L;
  private final static Logger LOGGER = Logger.getLogger(TodoItem.class.getName());
  // This is the mapping with the database rows:
  int id;
  String description;
  OffsetDateTime createdAt;
  boolean done;

  static TodoItem of(int id, String description, OffsetDateTime when, boolean done){
    TodoItem todoItem = new TodoItem();
    todoItem.setId(id);
    todoItem.setCreatedAt(when);
    todoItem.setDescription(description);
    todoItem.setDone(done);
    return todoItem;
  }
  void setDescription(String description) {
    this.description = description;
  }
  void setDone(boolean done){
    this.done = done;
  }
  private void setCreatedAt(OffsetDateTime now) {
    this.createdAt = now;

  }
  private void setId(int idStr) {
    this.id = idStr;
  }
  int getId() {
    return this.id;
  }

  String getDescription() {
    return this.description;
  }

  OffsetDateTime getCreatedAt() {
    return createdAt;
  }
  boolean isDone(){
    return done;
  }
  @Override
  public String toString() {
    String ret= "TodoItem { \"id\": "+this.id
      +", \"description\": "+this.description
      +", \"createdAt\": "+this.createdAt
      +", \"done\" : "+((done)?"true":"false")
      +" }";
    return ret;
  }

  /**
   * Returns the Json representation of the given TodoItem instance.
   * @param item an object of TodoItem
   * @return
   */
  static JsonObject toJsonObject(TodoItem item) {
    return Json.createObjectBuilder()
        .add("id", item.getId())
        .add("description", item.getDescription()==null?"":item.getDescription())
        .add("createdAt", item.getCreatedAt().toString())
        .add("done", item.isDone())
        .build();

  }

  /**
   * Returns an instance of TodoItem that corresponds to the given item in Json.
   * @param json a json object representing a todo item
   * @return an instance of this class
   */
  static TodoItem fromJsonObject(JsonObject json) {
    TodoItem item = new TodoItem();
    item.setId(json.get("id") == null ? -1 : json.getInt("id"));
    item.setDescription(json.get("description") == null ? null : json.getString("description"));
    item.setCreatedAt(json.get("createdAt") == null ? null : OffsetDateTime.parse(json.getString("createdAt")));
    item.setDone(json.get("done") == null ? false : json.getBoolean("done"));
    LOGGER.fine(()->"fromJsonObject returns:"+item);
    return item;
  }

  static JsonArray toJsonArray(List<TodoItem> items) {
    JsonArrayBuilder jsonArrayBuilder = Json.createArrayBuilder();
    items.forEach(p -> {
        jsonArrayBuilder.add(toJsonObject(p));
    });

    return jsonArrayBuilder.build();
  }
}

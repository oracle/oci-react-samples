/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/

package com.oracle.todoapp.mytodolist;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

@RestController
public class ToDoItemController {
    private final static Logger LOGGER = Logger.getLogger(ToDoItemController.class.getName());
    @Autowired
    private ToDoItemService toDoItemService;

    @GetMapping(value = "/todolist")
    public List<ToDoItem> getAllToDoItems() {
        LOGGER.fine("getAllToDoItems");
        return toDoItemService.findAll();
    }

    @GetMapping(value = "/todolist/{id}")
    public ResponseEntity<ToDoItem> getToDoItemById(@PathVariable int id) {
        LOGGER.fine("getToDoItemById");
        try {
            Optional<ToDoItem> todoData = toDoItemService.getItemById(id);
            if (todoData.isPresent()) {
                return new ResponseEntity<>(todoData.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping(value = "/todolist")
    public ResponseEntity<String> addToDoItem(@RequestBody ToDoItem todoItem) throws Exception {
        LOGGER.fine("addToDoItem");
        ToDoItem td = toDoItemService.addToDoItem(todoItem);
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("location", "" + td.getId());
        responseHeaders.set("Access-Control-Expose-Headers", "location");
        // URI location = URI.create(""+td.getID())
        return ResponseEntity.ok()
                .headers(responseHeaders).build();
    }

    @PutMapping(value = "/todolist/{id}")
    public ResponseEntity<ToDoItem> updateToDoItem(@RequestBody ToDoItem toDoItem, @PathVariable int id) {
        LOGGER.fine("updateToDoItem");
        try {
            ToDoItem toDoItem1 = toDoItemService.updateToDoItem(id, toDoItem);
            System.out.println(toDoItem1.toString());
            return new ResponseEntity<>(toDoItem1, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping(value = "/todolist/{id}")
    public ResponseEntity<Boolean> deleteToDoItem(@PathVariable("id") int id) {
        LOGGER.fine("deleteToDoItem");
        Boolean flag = false;
        try {
            flag = toDoItemService.deleteToDoItem(id);
            return new ResponseEntity<>(flag, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(flag, HttpStatus.NOT_FOUND);
        }
    }
}
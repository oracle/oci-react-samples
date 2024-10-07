/**
 * Copyright (c) 2024 Oracle and/or its affiliates.

 * The Universal Permissive License (UPL), Version 1.0

 * Subject to the condition set forth below, permission is hereby granted to any
 * person obtaining a copy of this software, associated documentation and/or data
 * (collectively the "Software"), free of charge and under any and all copyright
 * rights in the Software, and any and all patent rights owned or freely
 * licensable by each licensor hereunder covering either (i) the unmodified
 * Software as contributed to or provided by such licensor, or (ii) the Larger
 * Works (as defined below), to deal in both

 * (a) the Software, and
 * (b) any piece of software and/or hardware listed in the lrgrwrks.txt file if
 * one is included with the Software (each a "Larger Work" to which the Software
 * is contributed by such licensors),

 * without restriction, including without limitation the rights to copy, create
 * derivative works of, display, perform, and distribute the Software and make,
 * use, sell, offer for sale, import, export, have made, and have sold the
 * Software and the Larger Work(s), and to sublicense the foregoing rights on
 * either these or other terms.

 * This license is subject to the following condition:
 * The above copyright notice and either this complete permission notice or at
 * a minimum a reference to the UPL must be included in all copies or
 * substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.

 */

package com.springboot.MyTodoList.todo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping(path="/api")
public class ToDoItemController {


  @Autowired
  private ToDoItemRepository repository;

  @GetMapping(value = "/health")
  public String getHealth(){
    return "OK";
  }

  @GetMapping(value = "/todolist")
  public List<ToDoItem> getAllToDoItems(){
    return repository.findAll();
  }

  @CrossOrigin
  @GetMapping(value = "/todolist/{id}")
  public ResponseEntity<ToDoItem> getToDoItemById(@PathVariable int id){

    Optional<ToDoItem> item = repository.findById(id);
    return item.map(ResponseEntity::ok)
        .orElseGet(() -> ResponseEntity.notFound().build());

  }

  @CrossOrigin
  @PostMapping(value = "/todolist")
  public ResponseEntity<String> addToDoItem(@RequestBody ToDoItem todoItem) throws Exception{

    ToDoItem td = repository.save(
        new ToDoItem(todoItem.getDescription())
    );

    HttpHeaders responseHeaders = new HttpHeaders();
    responseHeaders.set("location",""+td.getID());
    responseHeaders.set("Access-Control-Expose-Headers","location");

    return ResponseEntity.ok()
        .headers(responseHeaders).build();
  }

  @CrossOrigin
  @PutMapping(value = "todolist/{id}")
  public ResponseEntity<ToDoItem> updateToDoItem(@RequestBody ToDoItem todoitem, @PathVariable int id){

    return repository.findById(id)
        .map(found -> {
          found.setDone(todoitem.isDone());
          found.setDescription(todoitem.getDescription());
          ToDoItem td = repository.save(found);
          return ResponseEntity.ok(td);
        })
        .orElseGet(() -> ResponseEntity.notFound().build());
  }

  @CrossOrigin
  @DeleteMapping(value = "todolist/{id}")
  public ResponseEntity<String> deleteToDoItem(@PathVariable("id") int id){

    Integer d = repository.deleteByID(id);
    return d > 0 ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();

  }

}

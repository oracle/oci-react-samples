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

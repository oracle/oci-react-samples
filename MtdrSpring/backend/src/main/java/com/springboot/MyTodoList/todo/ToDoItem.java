package com.springboot.MyTodoList.todo;


import jakarta.persistence.*;
import java.time.OffsetDateTime;

/*
    representation of the TODOITEM table that exists already
    in the autonomous database
*/

@Entity
@Table(name = "TODOITEM", schema = "TODOOWNER")
public class ToDoItem {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    int ID;

    @Column(name = "DESCRIPTION")
    String description;

    @Column(name = "CREATION_TS")
    OffsetDateTime creation_ts;

    @Column(name = "done")
    boolean done;

    public ToDoItem(){}

    public ToDoItem(String description) {
        this.description = description;
        this.creation_ts = OffsetDateTime.now();
    }

    public ToDoItem(int ID, String description, OffsetDateTime creation_ts, boolean done) {
        this.ID = ID;
        this.description = description;
        this.creation_ts = creation_ts;
        this.done = done;
    }

    public int getID() {
        return ID;
    }

    public void setID(int ID) {
        this.ID = ID;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public OffsetDateTime getCreation_ts() {
        return creation_ts;
    }

    public void setCreation_ts(OffsetDateTime creation_ts) {
        this.creation_ts = creation_ts;
    }

    public boolean isDone() {
        return done;
    }

    public void setDone(boolean done) {
        this.done = done;
    }

    @Override
    public String toString() {
        return "ToDoItem{" +
                "ID=" + ID +
                ", description='" + description + '\'' +
                ", creation_ts=" + creation_ts +
                ", done=" + done +
                '}';
    }
}

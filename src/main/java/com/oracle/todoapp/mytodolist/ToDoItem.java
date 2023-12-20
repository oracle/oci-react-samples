/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/

package com.oracle.todoapp.mytodolist;

import java.time.OffsetDateTime;

import jakarta.persistence.*;

/*
If the table needs to be created manually:

 CREATE TABLE todoitem (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    description VARCHAR2(32000),
    creation_ts TIMESTAMP WITH TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP ,
    done NUMBER(1,0) DEFAULT 0,
    PRIMARY KEY (id)
   );

 */
@Entity
@Table(name = "todoitem")
public class ToDoItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    @Column(name = "description")
    String description;
    @Column(name = "creation_ts", columnDefinition = "TIMESTAMP WITH TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP")
    OffsetDateTime creation_ts;
    @Column(name = "done", columnDefinition = "NUMBER(1,0) DEFAULT 0")
    Boolean done = Boolean.FALSE;

    public ToDoItem() {
    }

    public ToDoItem(int id, String description, OffsetDateTime creation_ts, Boolean done) {
        this.id = id;
        this.description = description;
        this.creation_ts = creation_ts;
        this.done = done;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public Boolean isDone() {
        return done;
    }

    public void setDone(Boolean done) {
        this.done = done;
    }

    @Override
    public String toString() {
        return "ToDoItem{" +
                "id=" + id +
                ", description='" + description + '\'' +
                ", creation_ts=" + creation_ts +
                ", done=" + done +
                '}';
    }
}
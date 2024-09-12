package com.springboot.MyTodoList.todo;


import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Repository
@EnableTransactionManagement
public interface ToDoItemRepository extends JpaRepository<ToDoItem,Integer> {

  @Transactional
  Integer deleteByID(int id);

}

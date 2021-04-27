/*
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/
package com.oracle.todoapp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.time.OffsetDateTime;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletionStage;
import java.util.logging.Level;
import java.util.logging.Logger;

import io.helidon.config.Config;
import oracle.ucp.jdbc.PoolDataSource;
import oracle.ucp.jdbc.PoolDataSourceFactory;

/*
 * This class takes care of the storage of the todo items. It uses an Autonomous Database
 * from the Oracle Cloud (ATP). The following table is used to store the todo items:
 *
 * CREATE USER todoapp IDENTIFIED BY "kj4sd#Bsd@#!!23";
 * GRANT CREATE SESSION TO todoapp;

BEGIN
   ORDS_ADMIN.ENABLE_SCHEMA(
     p_enabled => TRUE,
     p_schema => 'todoapp',
     p_url_mapping_type => 'BASE_PATH',
     p_url_mapping_pattern => 'schema-alias',
     p_auto_rest_auth => TRUE
   );
   COMMIT;
END;
/

GRANT DWROLE TO todoapp;



 * CREATE TABLE todoitem (
 *   id NUMBER GENERATED ALWAYS AS IDENTITY,
 *   description VARCHAR2(32000),
 *   creation_ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
 *   done NUMBER(1,0),
 *   PRIMARY KEY (id)
 *  );
 *
 * @author  jean.de.lavarene@oracle.com
 */

class TodoItemStorage {
  private final static Logger LOGGER = Logger.getLogger(TodoItemStorage.class.getName());

  private final PoolDataSource pool;

  // singleton repository:
  private static TodoItemStorage storage = null;

  synchronized static TodoItemStorage get(Config config) {
    if(storage == null) {
      try {
        storage = new TodoItemStorage(config);
      } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, ()->config.toString());
        LOGGER.log(Level.SEVERE, ex, ()->"in TodoItemRepository.get(...)");
      }
    }
    return storage;
  }

  private TodoItemStorage(Config config)  throws SQLException {
    LOGGER.log(Level.CONFIG, ()->config.toString());
    String url = config.get("url").asString().get();
    String user = config.get("user").asString().get();
    String password = config.get("password").asString().get();
    System.out.printf("Using url: %s%n", url);
    pool = PoolDataSourceFactory.getPoolDataSource();
    pool.setURL(url);
    pool.setUser(user);
    pool.setPassword(password);
    pool.setInactiveConnectionTimeout(60);
    pool.setConnectionFactoryClassName("oracle.jdbc.pool.OracleDataSource");
    pool.setMaxStatements(10);
  }

  /**
   * The Oracle Database can also return the rows in a JSON format:
   * SELECT
   *   json_arrayagg(json_object('id' VALUE id, 'description' VALUE description, 'date' VALUE creation_ts))
   * FROM
   *   todoitem
   * ORDER BY creation_ts DESC
   *
   * @return
   */
  List<TodoItem> all() {
    LOGGER.fine("all");
    ArrayList<TodoItem> list = new ArrayList<TodoItem>();
    try (
      Connection conn = pool.getConnection();
      PreparedStatement pstmt = conn.prepareStatement("SELECT id, description, creation_ts, done FROM todoitem ORDER BY creation_ts DESC");
      ResultSet rs = pstmt.executeQuery();
    ) {
      while(rs.next()) {
        TodoItem item = TodoItem.of(
          rs.getInt("id"),
          rs.getString("description"),
          rs.getObject("creation_ts", OffsetDateTime.class),
          rs.getBoolean("done"));
        list.add(item);
      }
    } catch (SQLException e) {
      LOGGER.log(Level.SEVERE, e, ()->"in all()");
    }
    LOGGER.fine("all() returns:");
    LOGGER.fine(()->list.toString());
    return list;
  }

  TodoItem getById(int id) {
    LOGGER.fine(()->"getById("+id+")");
    TodoItem ret = null;
    try (
        Connection conn = pool.getConnection();
        PreparedStatement pstmt = conn.prepareStatement("SELECT id, description, creation_ts, done FROM todoitem WHERE id=?");
        ){
      pstmt.setInt(1, id);
      try (ResultSet rs = pstmt.executeQuery();) {
        if(rs.next()) {
          ret = TodoItem.of(rs.getInt("id"), rs.getString("description"),
            rs.getObject("creation_ts", OffsetDateTime.class), rs.getBoolean("done"));
        }
      }
    } catch (SQLException e) {
      LOGGER.log(Level.SEVERE, e, ()->"in getById("+id+")");
    }
    if(ret != null){
      LOGGER.fine(()->"getById("+id+") returns:");
      LOGGER.fine(ret.toString());
    } else {
      LOGGER.fine(()->"getById("+id+") returns: null");
    }
    return ret;
  }

  TodoItem getById(String id) {
    try {
      int idInt = Integer.parseInt(id);
      return getById(idInt);
    } catch (NumberFormatException e) {
      LOGGER.log(Level.INFO, ()->"NumberFormatException in getById("+id+"): "+e.getMessage());
    }
    return null;
  }
  CompletionStage<TodoItem> asyncSave(TodoItem item) {
    // Use 20c JDBC and UCP in order to use the async APIs
    return null;
  }
  TodoItem save(TodoItem item) {
    LOGGER.fine("save("+item.toString()+")");
    int idInt = item.getId();
    try (
      Connection conn = pool.getConnection();
    ){
      if(idInt >=0 ) {
        try(
          PreparedStatement pstmt = conn.prepareStatement("UPDATE todoitem SET description=?, done=? WHERE id=?");
        ){
          pstmt.setString(1, item.getDescription());
          pstmt.setInt(2, item.isDone()?1:0);
          pstmt.setInt(3, idInt);
          int updateCount = pstmt.executeUpdate();
          LOGGER.info(()->"save - update case - updateCount="+updateCount);
        }
        return this.getById(idInt);
      } else {
        try (
          PreparedStatement pstmt = conn.prepareStatement("INSERT INTO todoitem (description) VALUES (?)", new String[]{"id"});
        ){
          pstmt.setString(1, item.getDescription());

          int updateCount = pstmt.executeUpdate(); // this call blocks the thread
          ResultSet rs = pstmt.getGeneratedKeys();

          rs.next();
          int id = rs.getInt(1);

          LOGGER.fine(()->"save - insert case - updateCount="+updateCount);
          return this.getById(id);
        }
      }
    } catch (SQLException e) {
      LOGGER.log(Level.SEVERE, e, ()->"in save(...)");
    }
    return this.getById(idInt);
  }

  boolean deleteById(String id) {
    try {
      int idInt = Integer.parseInt(id);
      return deleteById(idInt);
    } catch (NumberFormatException e) {
      LOGGER.log(Level.INFO, ()->"NumberFormatException in deleteById("+id+"): "+e.getMessage());
    }
    return false;
  }
  boolean deleteById(int id) {
    LOGGER.fine(()->"deleteById(" + id + ")");
    int ret = 0;
    try (
        Connection conn = pool.getConnection();
        PreparedStatement pstmt = conn.prepareStatement("DELETE FROM todoitem WHERE id=?");
      ){
      pstmt.setInt(1, id);
      ret = pstmt.executeUpdate();
    } catch (SQLException e) {
      LOGGER.log(Level.SEVERE, e, ()->"in deleteById("+id+")");
    }
    return (ret == 1);
  }
}

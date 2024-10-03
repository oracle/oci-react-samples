package com.springboot.MyTodoList.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import oracle.jdbc.pool.OracleDataSource;

import java.sql.SQLException;

@Configuration
public class DatasourceConfig {

  @Value("${database.url:#{null}}")
  private String DB_URL;


  @Value("${database.user:#{null}}")
  private String DB_USERNAME;

  @Value("${database.password:#{null}}")
  private String DB_PASSWORD;

  @Value("${oracle.jdbc.config.file:#{null}}")
  private String DB_CONFIG_FILE_PATH;

  @Bean
  public OracleDataSource dataSource() throws SQLException {
    OracleDataSource ds = new OracleDataSource();
    ds.setDriverType("oracle.jdbc.OracleDriver");

    if (this.DB_CONFIG_FILE_PATH != null) {
      ds.setConnectionProperty("oracle.jdbc.config.file", this.DB_CONFIG_FILE_PATH);
    }

    if (this.DB_URL != null) {
      ds.setURL(this.DB_URL);
    }

    if (this.DB_USERNAME != null) {
      ds.setUser(this.DB_USERNAME);
    }

    if (this.DB_PASSWORD != null) {
      ds.setPassword(this.DB_PASSWORD);
    }

    return ds;
  }

}

package com.oracle.todoapp.mytodolist;

import java.sql.SQLException;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import oracle.jdbc.replay.OracleDataSource;
import oracle.jdbc.replay.OracleDataSourceFactory;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@Configuration
public class DataSourceConfiguration {

  @Value("${spring.datasource.url}")
  private String JDBC_URL;
  @Value("${spring.datasource.username}")
  private String DB_USER;
  @Value("${spring.datasource.password}")
  private String DB_PASSWORD;

  @Bean
  public DataSource getDataSource() throws SQLException {
    // Create Oracle replay data source
    OracleDataSource replayDatasource = OracleDataSourceFactory.getOracleDataSource();
    replayDatasource.setURL(JDBC_URL);
    replayDatasource.setUser(DB_USER);
    replayDatasource.setPassword(DB_PASSWORD);
    replayDatasource.setConnectionProperty("oracle.jdbc.defaultConnectionValidation",
        "LOCAL");
    // Configure Hikari Pool
    System.setProperty("com.zaxxer.hikari.aliveBypassWindowMs", "-1");
    HikariConfig config = new HikariConfig();
    config.setMaximumPoolSize(20);
    config.setDataSource(replayDatasource);
    // Create Hikari data source
    return new HikariDataSource(config);
  }
}

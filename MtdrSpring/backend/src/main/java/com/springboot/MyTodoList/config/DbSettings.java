package com.springboot.MyTodoList.config;


import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

// This is only used for local testing.
@Configuration
@ConfigurationProperties(prefix = "spring.datasource")
public class DbSettings {
    private String url;
    private String username;
    private String password;
    private String driver_class_name;

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getDriver_class_name() {
        return driver_class_name;
    }

    public void setDriver_class_name(String driver_class_name) {
        this.driver_class_name = driver_class_name;
    }
}

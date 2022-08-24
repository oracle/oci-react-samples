package com.cloudbank.authservice.config;


import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Adds ViewControllers directing requests against /transfer and /accounts (React Router routes)
 * to go to /index.html (which is our build file)
 */
@Configuration
public class WebMVCConfig implements WebMvcConfigurer {


    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/transfer/**").setViewName("/index.html");
        registry.addViewController("/accounts/**").setViewName("/index.html");
    }
}

package com.cloudbank.authservice.config;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;


/**
 * Sets SecurityFilterChain to setup CSRF token repository (Line 29)
 * and use the default Form Login for authentication. (Lin 31)
 */
@EnableWebSecurity
@Configuration
public class WebSecurityConfig {

    /**
     * 
     * @param httpSecurity
     * @return
     * @throws Exception
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity httpSecurity) throws Exception {

        httpSecurity.csrf().csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse());

        httpSecurity.authorizeRequests().anyRequest().authenticated().and().httpBasic();

        return httpSecurity.build();

    }
}

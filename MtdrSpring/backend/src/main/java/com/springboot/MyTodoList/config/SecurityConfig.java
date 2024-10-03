/*
## MyToDoReact version 2.0.0
##
## Copyright (c) 2024 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
*/
package com.springboot.MyTodoList.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.LogoutConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.cors.CorsConfiguration;


import java.util.List;

import static org.springframework.security.config.Customizer.withDefaults;

@Configuration
@EnableWebSecurity
public class SecurityConfig {


  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

    http.cors(Customizer.withDefaults());
    http.csrf(AbstractHttpConfigurer::disable);
    http
        .authorizeHttpRequests((requests) ->
            requests.requestMatchers("/api/health").permitAll().anyRequest().authenticated())
        .httpBasic(withDefaults())
        .formLogin(withDefaults())
        .logout(LogoutConfigurer::permitAll);

    return http.build();
  }

  @Bean
  public CorsFilter corsFilter() {

    CorsConfiguration config = new CorsConfiguration();
//    config.setAllowCredentials(true);
    config.setAllowedOrigins(List.of("*"));
    config.addAllowedHeader("*");
    config.addAllowedMethod("*");
    config.addExposedHeader("location");

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);
    return new CorsFilter(source);

  }
}

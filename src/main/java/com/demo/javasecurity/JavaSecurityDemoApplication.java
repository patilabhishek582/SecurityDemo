package com.demo.javasecurity;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;

@SpringBootApplication
@EnableMethodSecurity(prePostEnabled = true)
public class JavaSecurityDemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(JavaSecurityDemoApplication.class, args);
    }
}

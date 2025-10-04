package com.demo.javasecurity.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/public")
public class PublicController {

    @GetMapping("/hello")
    public ResponseEntity<Map<String, Object>> publicEndpoint() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This is a public endpoint - no authentication required");
        response.put("timestamp", System.currentTimeMillis());
        response.put("security", "NONE");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getPublicInfo() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", "Java Security Demo");
        response.put("version", "1.0.0");
        response.put("description", "Demonstrating Basic, Method Level, and JWT Security");
        response.put("endpoints", new String[]{
            "/api/public/** - No authentication",
            "/api/basic/** - HTTP Basic Authentication",
            "/api/jwt/** - JWT Token Authentication",
            "/api/method/** - Method Level Security with Role Checks",
            "/api/admin/** - Admin Role Required"
        });
        return ResponseEntity.ok(response);
    }
}

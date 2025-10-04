package com.demo.javasecurity.controller;

import com.demo.javasecurity.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/jwt")
public class JwtSecurityController {

    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getUserProfile() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "JWT Authentication successful");
        response.put("username", user.getUsername());
        response.put("role", user.getRole());
        response.put("authorities", user.getAuthorities());
        response.put("security", "JWT_TOKEN");
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to your secure dashboard");
        response.put("user", user.getUsername());
        response.put("role", user.getRole());
        response.put("dashboardData", Map.of(
            "totalUsers", 125,
            "activeUsers", 98,
            "systemStatus", "HEALTHY"
        ));
        response.put("security", "JWT_TOKEN");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/secure-action")
    public ResponseEntity<Map<String, Object>> performSecureAction(@RequestBody Map<String, Object> request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Secure action performed with JWT authentication");
        response.put("performedBy", user.getUsername());
        response.put("userRole", user.getRole());
        response.put("action", request.get("action"));
        response.put("result", "SUCCESS");
        response.put("security", "JWT_TOKEN");

        return ResponseEntity.ok(response);
    }

    @GetMapping("/data")
    public ResponseEntity<Map<String, Object>> getSecureData() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This is JWT-protected sensitive data");
        response.put("data", Map.of(
            "customerCount", 1542,
            "revenue", "$125,000",
            "transactions", 3421
        ));
        response.put("security", "JWT_TOKEN");

        return ResponseEntity.ok(response);
    }
}

package com.demo.javasecurity.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/basic")
public class BasicSecurityController {

    @GetMapping("/user-info")
    public ResponseEntity<Map<String, Object>> getUserInfo() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Basic Authentication successful");
        response.put("username", authentication.getName());
        response.put("authorities", authentication.getAuthorities());
        response.put("security", "HTTP_BASIC");
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/protected")
    public ResponseEntity<Map<String, Object>> getProtectedData() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is protected by Basic Authentication");
        response.put("data", "Secret data accessible to authenticated users");
        response.put("security", "HTTP_BASIC");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/action")
    public ResponseEntity<Map<String, Object>> performAction(@RequestBody Map<String, Object> request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Action performed successfully");
        response.put("performedBy", authentication.getName());
        response.put("action", request.get("action"));
        response.put("security", "HTTP_BASIC");

        return ResponseEntity.ok(response);
    }
}

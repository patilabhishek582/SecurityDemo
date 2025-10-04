package com.demo.javasecurity.controller;

import com.demo.javasecurity.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getAdminDashboard() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Admin Dashboard - Configuration Level Security");
        response.put("username", user.getUsername());
        response.put("role", user.getRole());
        response.put("adminStats", Map.of(
            "totalUsers", 150,
            "activeUsers", 142,
            "systemHealth", "EXCELLENT",
            "securityAlerts", 0,
            "lastBackup", "2025-10-04 08:00:00"
        ));
        response.put("security", "CONFIGURATION_LEVEL_ADMIN_ONLY");

        return ResponseEntity.ok(response);
    }

    @GetMapping("/users")
    public ResponseEntity<Map<String, Object>> getAllUsers() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "All users data - Admin access required");
        response.put("users", new Object[]{
            Map.of("id", 1, "username", "admin", "role", "ADMIN", "status", "ACTIVE"),
            Map.of("id", 2, "username", "user", "role", "USER", "status", "ACTIVE")
        });
        response.put("security", "CONFIGURATION_LEVEL_ADMIN_ONLY");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/system-config")
    public ResponseEntity<Map<String, Object>> updateSystemConfig(@RequestBody Map<String, Object> config) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "System configuration updated");
        response.put("updatedBy", user.getUsername());
        response.put("configChanges", config);
        response.put("result", "SUCCESS");
        response.put("security", "CONFIGURATION_LEVEL_ADMIN_ONLY");

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable Long userId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "User deletion simulated (Admin only operation)");
        response.put("deletedUserId", userId);
        response.put("performedBy", user.getUsername());
        response.put("result", "SIMULATED_SUCCESS");
        response.put("security", "CONFIGURATION_LEVEL_ADMIN_ONLY");

        return ResponseEntity.ok(response);
    }
}

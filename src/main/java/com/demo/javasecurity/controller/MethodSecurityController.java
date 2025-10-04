package com.demo.javasecurity.controller;

import com.demo.javasecurity.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/method")
public class MethodSecurityController {

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN') or hasRole('USER')")
    public ResponseEntity<Map<String, Object>> getAllowedForAll() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is accessible to both ADMIN and USER roles");
        response.put("username", user.getUsername());
        response.put("role", user.getRole());
        response.put("security", "METHOD_LEVEL_SECURITY");
        response.put("accessLevel", "ALL_AUTHENTICATED");

        return ResponseEntity.ok(response);
    }

    @GetMapping("/admin-only")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getAdminOnlyData() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is accessible only to ADMIN role");
        response.put("username", user.getUsername());
        response.put("role", user.getRole());
        response.put("adminData", Map.of(
            "systemLogs", "Access granted to system logs",
            "userManagement", "Full user management access",
            "systemSettings", "Configuration access granted"
        ));
        response.put("security", "METHOD_LEVEL_SECURITY");
        response.put("accessLevel", "ADMIN_ONLY");

        return ResponseEntity.ok(response);
    }

    @GetMapping("/user-only")
    @PreAuthorize("hasRole('USER') and !hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getUserOnlyData() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is accessible only to USER role (not ADMIN)");
        response.put("username", user.getUsername());
        response.put("role", user.getRole());
        response.put("userData", Map.of(
            "personalDashboard", "User-specific dashboard",
            "userPreferences", "Personal settings access",
            "userReports", "User activity reports"
        ));
        response.put("security", "METHOD_LEVEL_SECURITY");
        response.put("accessLevel", "USER_ONLY");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/admin-action")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> performAdminAction(@RequestBody Map<String, Object> request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Admin action performed successfully");
        response.put("performedBy", user.getUsername());
        response.put("action", request.get("action"));
        response.put("result", "ADMIN_ACTION_COMPLETED");
        response.put("security", "METHOD_LEVEL_SECURITY");
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/check-username/{username}")
    @PreAuthorize("#username == authentication.name or hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> checkUserData(@PathVariable String username) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "User can access their own data or ADMIN can access any user data");
        response.put("requestedUser", username);
        response.put("currentUser", user.getUsername());
        response.put("role", user.getRole());
        response.put("security", "METHOD_LEVEL_SECURITY");
        response.put("accessType", user.getRole().name().equals("ADMIN") ? "ADMIN_ACCESS" : "SELF_ACCESS");

        return ResponseEntity.ok(response);
    }
}

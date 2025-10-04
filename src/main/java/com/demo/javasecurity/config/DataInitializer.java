package com.demo.javasecurity.config;

import com.demo.javasecurity.model.Role;
import com.demo.javasecurity.model.User;
import com.demo.javasecurity.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Initialize demo users if they don't exist
        if (userRepository.count() == 0) {
            logger.info("Initializing demo users...");

            // Create Admin User
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(Role.ADMIN);
            admin.setEnabled(true);
            userRepository.save(admin);

            // Create Regular User
            User user = new User();
            user.setUsername("user");
            user.setPassword(passwordEncoder.encode("user123"));
            user.setRole(Role.USER);
            user.setEnabled(true);
            userRepository.save(user);

            logger.info("Demo users created successfully:");
            logger.info("Admin - username: admin, password: admin123");
            logger.info("User - username: user, password: user123");
        } else {
            logger.info("Demo users already exist, skipping initialization.");
        }
    }
}

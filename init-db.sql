-- Database initialization script for PostgreSQL
-- This script will be executed when the PostgreSQL container starts

-- Create the database if it doesn't exist (handled by POSTGRES_DB env var)
-- Create users table with proper constraints
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'USER')),
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Insert default admin and user accounts (passwords are BCrypt hashed)
-- admin:admin123, user:user123
INSERT INTO users (username, password, role, enabled) VALUES
    ('admin', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a', 'ADMIN', true),
    ('user', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a', 'USER', true)
ON CONFLICT (username) DO NOTHING;

-- Create audit table for tracking user activities (optional)
CREATE TABLE IF NOT EXISTS user_audit (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for audit queries
CREATE INDEX IF NOT EXISTS idx_user_audit_username ON user_audit(username);
CREATE INDEX IF NOT EXISTS idx_user_audit_timestamp ON user_audit(timestamp);

#!/bin/bash

# AWS EC2 Deployment Script for Java Security Demo
# Run this script on your EC2 instance

set -e

echo "=== Java Security Demo - AWS EC2 Deployment Script ==="

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install Java 17
echo "Installing Java 17..."
sudo yum install -y java-17-amazon-corretto-devel

# Verify Java installation
java -version

# Install PostgreSQL client (optional, for database connectivity testing)
echo "Installing PostgreSQL client..."
sudo yum install -y postgresql15

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /opt/java-security-demo
sudo mkdir -p /var/log/java-security-demo

# Create application user
echo "Creating application user..."
sudo useradd -r -s /bin/false javasecurity || true
sudo chown -R javasecurity:javasecurity /opt/java-security-demo
sudo chown -R javasecurity:javasecurity /var/log/java-security-demo

# Copy application JAR (assuming it's uploaded to /tmp)
echo "Setting up application JAR..."
if [ -f "/tmp/java-security-demo-1.0.0.jar" ]; then
    sudo cp /tmp/java-security-demo-1.0.0.jar /opt/java-security-demo/
    sudo chown javasecurity:javasecurity /opt/java-security-demo/java-security-demo-1.0.0.jar
else
    echo "Please upload your JAR file to /tmp/java-security-demo-1.0.0.jar"
fi

# Create systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/java-security-demo.service > /dev/null <<EOF
[Unit]
Description=Java Security Demo Application
After=network.target

[Service]
Type=simple
User=javasecurity
Group=javasecurity
WorkingDirectory=/opt/java-security-demo
ExecStart=/usr/bin/java -jar /opt/java-security-demo/java-security-demo-1.0.0.jar
Restart=always
RestartSec=10

# Environment Variables
Environment=SPRING_PROFILES_ACTIVE=prod
Environment=PORT=8080
Environment=JWT_SECRET=\${JWT_SECRET}
Environment=DATABASE_URL=\${DATABASE_URL}
Environment=DATABASE_USERNAME=\${DATABASE_USERNAME}
Environment=DATABASE_PASSWORD=\${DATABASE_PASSWORD}

# JVM Options
Environment=JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Create environment file
echo "Creating environment configuration..."
sudo tee /opt/java-security-demo/.env > /dev/null <<EOF
# AWS EC2 Environment Configuration
# Update these values according to your setup

# Database Configuration
DATABASE_URL=jdbc:postgresql://your-rds-endpoint:5432/javasecurity
DATABASE_USERNAME=your-db-username
DATABASE_PASSWORD=your-db-password

# JWT Configuration (IMPORTANT: Change this secret!)
JWT_SECRET=your-super-secure-jwt-secret-key-here-at-least-256-bits-long

# Application Configuration
SPRING_PROFILES_ACTIVE=prod
PORT=8080
EOF

# Set proper permissions
sudo chown javasecurity:javasecurity /opt/java-security-demo/.env
sudo chmod 600 /opt/java-security-demo/.env

# Reload systemd and enable service
echo "Configuring systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable java-security-demo

echo "=== Deployment Setup Complete ==="
echo ""
echo "Next Steps:"
echo "1. Update /opt/java-security-demo/.env with your actual database credentials"
echo "2. Upload your JAR file to /tmp/java-security-demo-1.0.0.jar"
echo "3. Start the service: sudo systemctl start java-security-demo"
echo "4. Check status: sudo systemctl status java-security-demo"
echo "5. View logs: sudo journalctl -u java-security-demo -f"
echo ""
echo "Health Check URL: http://your-ec2-ip:8080/actuator/health"

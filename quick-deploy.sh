#!/bin/bash

# Quick Deployment Script for Java Security Demo on AWS EC2
# This script automates the build and deployment process

set -e

echo "🚀 Java Security Demo - Quick AWS Deployment Script"
echo "=================================================="

# Configuration
APP_NAME="java-security-demo"
VERSION="1.0.0"
JAR_NAME="${APP_NAME}-${VERSION}.jar"

# Check if EC2 details are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <ec2-public-ip> <path-to-key.pem> [database-url] [jwt-secret]"
    echo "Example: $0 3.85.123.45 ~/my-key.pem"
    exit 1
fi

EC2_HOST=$1
KEY_PATH=$2
DB_URL=${3:-"jdbc:postgresql://localhost:5432/javasecurity"}
JWT_SECRET=${4:-"change-this-jwt-secret-in-production-minimum-32-characters"}

echo "📦 Building application..."
mvn clean package -DskipTests

if [ ! -f "target/${JAR_NAME}" ]; then
    echo "❌ Build failed! JAR file not found."
    exit 1
fi

echo "✅ Build successful!"

echo "📤 Uploading files to EC2..."
# Upload deployment script
scp -i "$KEY_PATH" deploy-ec2.sh ec2-user@$EC2_HOST:/tmp/

# Upload JAR file
scp -i "$KEY_PATH" "target/${JAR_NAME}" ec2-user@$EC2_HOST:/tmp/

# Upload Docker files (optional)
scp -i "$KEY_PATH" docker-compose.yml ec2-user@$EC2_HOST:/tmp/
scp -i "$KEY_PATH" Dockerfile ec2-user@$EC2_HOST:/tmp/
scp -i "$KEY_PATH" init-db.sql ec2-user@$EC2_HOST:/tmp/

echo "🔧 Setting up application on EC2..."
ssh -i "$KEY_PATH" ec2-user@$EC2_HOST << EOF
    # Make deployment script executable
    chmod +x /tmp/deploy-ec2.sh

    # Run deployment script
    sudo /tmp/deploy-ec2.sh

    # Update environment configuration
    sudo tee /opt/java-security-demo/.env > /dev/null << EOL
DATABASE_URL=$DB_URL
DATABASE_USERNAME=\${DATABASE_USERNAME:-postgres}
DATABASE_PASSWORD=\${DATABASE_PASSWORD:-password}
JWT_SECRET=$JWT_SECRET
SPRING_PROFILES_ACTIVE=prod
PORT=8080
DATABASE_DRIVER=org.postgresql.Driver
DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
DDL_AUTO=update
EOL

    # Set proper permissions
    sudo chown javasecurity:javasecurity /opt/java-security-demo/.env
    sudo chmod 600 /opt/java-security-demo/.env

    # Start the service
    sudo systemctl start java-security-demo
    sudo systemctl enable java-security-demo

    # Wait a moment for startup
    sleep 10

    echo "🔍 Checking application status..."
    sudo systemctl status java-security-demo --no-pager

    echo "🏥 Testing health endpoint..."
    curl -f http://localhost:8080/actuator/health || echo "Health check failed - check logs"
EOF

echo ""
echo "✅ Deployment completed!"
echo "🌐 Application should be available at: http://$EC2_HOST:8080"
echo "🏥 Health check: http://$EC2_HOST:8080/actuator/health"
echo ""
echo "📋 Quick test commands:"
echo "curl -X POST http://$EC2_HOST:8080/api/auth/signin \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"username\": \"admin\", \"password\": \"admin123\"}'"
echo ""
echo "📊 To check logs: ssh -i $KEY_PATH ec2-user@$EC2_HOST 'sudo journalctl -u java-security-demo -f'"
echo "🔧 To restart: ssh -i $KEY_PATH ec2-user@$EC2_HOST 'sudo systemctl restart java-security-demo'"

# Java Security Demo - AWS EC2 Deployment Guide

This guide provides step-by-step instructions for deploying your Java Security demo application to AWS EC2 with production-ready configurations.

## 🚀 Deployment Options

### Option 1: Manual EC2 Deployment
### Option 2: Docker-based Deployment  
### Option 3: AWS CloudFormation (Infrastructure as Code)

---

## 📋 Prerequisites

1. **AWS Account** with EC2 and RDS permissions
2. **AWS CLI** configured with your credentials
3. **Java 17** (for local building)
4. **Maven 3.6+** (for building)
5. **Docker** (for containerized deployment)

---

## 🔧 Changes Made for AWS Deployment

### 1. Application Configuration
- ✅ **Environment-based configuration** using `application-prod.properties`
- ✅ **External database support** (PostgreSQL/MySQL)
- ✅ **Health checks** via Spring Boot Actuator
- ✅ **Security headers** and production settings
- ✅ **Logging configuration** for production

### 2. Database Changes
- ✅ **PostgreSQL/MySQL drivers** added to pom.xml
- ✅ **Database initialization script** (`init-db.sql`)
- ✅ **Environment variable configuration** for database connection
- ✅ **Production JPA settings** (validate instead of create-drop)

### 3. Security Enhancements
- ✅ **JWT secret externalized** to environment variables
- ✅ **Secure cookie settings** for production
- ✅ **HTTPS support** configuration
- ✅ **Database credentials** via environment variables

---

## 🚀 Option 1: Manual EC2 Deployment

### Step 1: Launch EC2 Instance
```bash
# 1. Launch Amazon Linux 2 EC2 instance (t3.micro or larger)
# 2. Configure Security Group:
#    - Port 22 (SSH)
#    - Port 8080 (Application)
#    - Port 80/443 (HTTP/HTTPS)
```

### Step 2: Connect and Setup
```bash
# Connect to your EC2 instance
ssh -i your-key.pem ec2-user@your-ec2-public-ip

# Upload and run deployment script
scp -i your-key.pem deploy-ec2.sh ec2-user@your-ec2-public-ip:/tmp/
ssh -i your-key.pem ec2-user@your-ec2-public-ip
chmod +x /tmp/deploy-ec2.sh
sudo /tmp/deploy-ec2.sh
```

### Step 3: Build and Deploy Application
```bash
# On your local machine, build the JAR
mvn clean package -DskipTests

# Upload JAR to EC2
scp -i your-key.pem target/java-security-demo-1.0.0.jar ec2-user@your-ec2-public-ip:/tmp/

# On EC2, configure environment
sudo nano /opt/java-security-demo/.env
# Update database and JWT settings

# Start the application
sudo systemctl start java-security-demo
sudo systemctl status java-security-demo
```

---

## 🐳 Option 2: Docker Deployment

### Step 1: Setup Docker on EC2
```bash
# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Step 2: Deploy with Docker Compose
```bash
# Upload project files
scp -i your-key.pem -r . ec2-user@your-ec2-public-ip:/home/ec2-user/java-security-demo/

# SSH to EC2 and deploy
ssh -i your-key.pem ec2-user@your-ec2-public-ip
cd java-security-demo

# Update environment variables in docker-compose.yml
nano docker-compose.yml

# Build and run
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f java-security-demo
```

---

## ☁️ Option 3: AWS CloudFormation Deployment

### Step 1: Deploy Infrastructure
```bash
# Deploy the CloudFormation stack
aws cloudformation create-stack \
  --stack-name java-security-demo \
  --template-body file://aws-infrastructure.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=your-key-name \
               ParameterKey=DBPassword,ParameterValue=your-secure-password \
               ParameterKey=JWTSecret,ParameterValue=your-jwt-secret-32-chars-min \
  --capabilities CAPABILITY_IAM

# Monitor stack creation
aws cloudformation describe-stacks --stack-name java-security-demo
```

### Step 2: Deploy Application
```bash
# Get stack outputs
aws cloudformation describe-stacks --stack-name java-security-demo \
  --query 'Stacks[0].Outputs'

# SSH to the created EC2 instance
ssh -i your-key.pem ec2-user@<EC2-Public-IP>

# Upload and deploy your application
scp -i your-key.pem target/java-security-demo-1.0.0.jar ec2-user@<EC2-Public-IP>:/tmp/
```

---

## 🛠️ Environment Variables Configuration

Create `/opt/java-security-demo/.env` with these variables:

```bash
# Database Configuration
DATABASE_URL=jdbc:postgresql://your-rds-endpoint:5432/javasecurity
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your-secure-password
DATABASE_DRIVER=org.postgresql.Driver
DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect

# JWT Configuration (CRITICAL: Change this!)
JWT_SECRET=your-super-secure-jwt-secret-key-minimum-256-bits-long

# Application Settings
SPRING_PROFILES_ACTIVE=prod
PORT=8080
DDL_AUTO=validate

# Optional: Logging
SECURITY_LOG_LEVEL=INFO
APP_LOG_LEVEL=INFO
ROOT_LOG_LEVEL=WARN
```

---

## 🗄️ Database Setup Options

### Option A: AWS RDS PostgreSQL (Recommended)
```bash
# Create RDS PostgreSQL instance via AWS Console or CLI
# Update DATABASE_URL in your environment configuration
DATABASE_URL=jdbc:postgresql://your-rds-endpoint.region.rds.amazonaws.com:5432/javasecurity
```

### Option B: EC2-hosted PostgreSQL
```bash
# Install PostgreSQL on EC2
sudo yum install -y postgresql15-server postgresql15
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configure database
sudo -u postgres createdb javasecurity
sudo -u postgres psql -c "CREATE USER javademo WITH PASSWORD 'password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE javasecurity TO javademo;"
```

---

## 🔒 Security Checklist

- [ ] **JWT Secret**: Use a strong, unique secret (32+ characters)
- [ ] **Database Password**: Use a strong password
- [ ] **Security Groups**: Restrict access to necessary ports only
- [ ] **SSL/TLS**: Configure HTTPS with SSL certificate
- [ ] **Environment Variables**: Never hardcode secrets in code
- [ ] **Database**: Use RDS with encryption enabled
- [ ] **Backup**: Configure automated backups
- [ ] **Monitoring**: Setup CloudWatch alarms
- [ ] **Updates**: Keep OS and Java runtime updated

---

## 🔍 Testing Your Deployment

### Health Check
```bash
curl http://your-ec2-ip:8080/actuator/health
```

### Authentication Test
```bash
# Get JWT token
curl -X POST http://your-ec2-ip:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Test protected endpoint
curl -X GET http://your-ec2-ip:8080/api/admin/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📊 Monitoring and Maintenance

### Application Logs
```bash
# SystemD service logs
sudo journalctl -u java-security-demo -f

# Docker logs
docker-compose logs -f java-security-demo

# Application log file
sudo tail -f /var/log/java-security-demo.log
```

### Performance Monitoring
```bash
# CPU and Memory usage
htop

# Application metrics
curl http://your-ec2-ip:8080/actuator/metrics
```

---

## 🔄 Updating Your Application

### Rolling Update Process
```bash
# 1. Build new version
mvn clean package -DskipTests

# 2. Upload new JAR
scp -i your-key.pem target/java-security-demo-1.0.0.jar ec2-user@your-ec2-ip:/tmp/

# 3. Update application
sudo systemctl stop java-security-demo
sudo cp /tmp/java-security-demo-1.0.0.jar /opt/java-security-demo/
sudo systemctl start java-security-demo

# 4. Verify deployment
curl http://your-ec2-ip:8080/actuator/health
```

---

## 🚨 Troubleshooting

### Common Issues

1. **Application won't start**
   ```bash
   sudo journalctl -u java-security-demo -n 50
   ```

2. **Database connection failed**
   ```bash
   # Check database connectivity
   telnet your-db-endpoint 5432
   ```

3. **Memory issues**
   ```bash
   # Adjust JVM memory in systemd service
   sudo nano /etc/systemd/system/java-security-demo.service
   # Add: Environment=JAVA_OPTS="-Xms256m -Xmx512m"
   ```

4. **Port already in use**
   ```bash
   sudo netstat -tlnp | grep :8080
   sudo kill -9 <process-id>
   ```

---

## 💰 Cost Optimization

- **Instance Type**: Start with t3.micro, scale as needed
- **RDS**: Use t3.micro for development, scale for production
- **Storage**: Use gp3 storage for better cost/performance
- **Reserved Instances**: Use for long-term deployments
- **Auto Scaling**: Configure based on CPU/memory usage

---

## 📞 Support

For issues or questions:
1. Check application logs first
2. Verify environment variables
3. Test database connectivity
4. Check security group settings
5. Review CloudFormation stack events (if using)

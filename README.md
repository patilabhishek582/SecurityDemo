### 1. Testing Public Endpoints
```bash
# No authentication required
curl -X GET http://localhost:8080/api/public/hello
curl -X GET http://localhost:8080/api/public/info
```

### 2. Testing Basic Authentication
```bash
# Using curl with basic auth
curl -X GET http://localhost:8080/api/basic/user-info \
  -H "Authorization: Basic YWRtaW46YWRtaW4xMjM="

# Or with username:password
curl -X GET http://localhost:8080/api/basic/protected \
  -u admin:admin123
```

### 3. Testing JWT Authentication

**Step 1: Get JWT Token**
```bash
curl -X POST http://localhost:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

**Step 2: Use JWT Token**
```bash
# Replace {JWT_TOKEN} with actual token from step 1
curl -X GET http://localhost:8080/api/jwt/profile \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

### 4. Testing Method Level Security

**Admin Access:**
```bash
# Get JWT token for admin
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' | \
  grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Access admin-only endpoint
curl -X GET http://localhost:8080/api/method/admin-only \
  -H "Authorization: Bearer $TOKEN"
```

**User Access:**
```bash
# Get JWT token for user
USER_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "user123"}' | \
  grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Try to access admin-only endpoint (should fail)
curl -X GET http://localhost:8080/api/method/admin-only \
  -H "Authorization: Bearer $USER_TOKEN"
```

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Controllers   │    │  Security Layer  │    │   Data Layer    │
│                 │    │                  │    │                 │
│ • PublicCtrl    │    │ • WebSecurityCfg │    │ • User Entity   │
│ • AuthCtrl      │    │ • AuthTokenFilter│    │ • UserRepo      │
│ • BasicCtrl     │◄──►│ • JwtUtil        │◄──►│ • Role Enum     │
│ • JwtCtrl       │    │ • UserDetailsSvc │    │ • H2 Database   │
│ • MethodCtrl    │    │ • AuthEntryPoint │    │                 │
│ • AdminCtrl     │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Best Practices Implemented

### Security Best Practices
- ✅ **Password Encryption**: Using BCrypt for secure password hashing
- ✅ **JWT Security**: Signed tokens with configurable expiration
- ✅ **CORS Configuration**: Properly configured for cross-origin requests
- ✅ **CSRF Protection**: Disabled for stateless API (appropriate for JWT)
- ✅ **Error Handling**: Secure error responses without sensitive information
- ✅ **Role-based Access**: Proper RBAC implementation
- ✅ **Stateless Sessions**: No server-side session storage for JWT

### Code Best Practices
- ✅ **Separation of Concerns**: Clear separation between layers
- ✅ **Dependency Injection**: Proper use of Spring's DI container
- ✅ **Exception Handling**: Comprehensive error handling
- ✅ **Validation**: Input validation using Jakarta Bean Validation
- ✅ **Logging**: Proper logging for security events
- ✅ **Configuration Management**: Externalized configuration

### API Design Best Practices
- ✅ **RESTful Design**: Proper HTTP methods and status codes
- ✅ **Consistent Response Format**: Standardized JSON responses
- ✅ **API Versioning**: Structured endpoint versioning
- ✅ **Documentation**: Comprehensive API documentation

## Security Configuration Details

### JWT Configuration
- **Algorithm**: HMAC512
- **Expiration**: 24 hours (configurable)
- **Secret**: Environment-based (change in production)
- **Claims**: Username, issued date, expiration

### Password Security
- **Algorithm**: BCrypt
- **Strength**: Default BCrypt strength (10 rounds)
- **Salt**: Automatic per-password salt generation

### Database Security
- **Type**: H2 in-memory (for demo)
- **Console**: Enabled for development
- **Credentials**: Configurable via properties

## Production Considerations

When deploying to production, consider:

1. **Use External Database**: Replace H2 with PostgreSQL/MySQL
2. **Environment Variables**: Use environment variables for secrets
3. **HTTPS Only**: Enable SSL/TLS encryption
4. **JWT Secret**: Use strong, randomly generated secrets
5. **Rate Limiting**: Implement API rate limiting
6. **Monitoring**: Add security monitoring and alerting
7. **Audit Logging**: Implement comprehensive audit logs

## Troubleshooting
# Java Security Demo - Spring Boot
### Common Issues

1. **401 Unauthorized**: Check credentials and token validity
2. **403 Forbidden**: Verify user has required role/permissions
3. **JWT Expired**: Refresh token or re-authenticate
4. **Database Issues**: Check H2 console at `/h2-console`

### Debug Mode
Enable debug logging by adding to `application.properties`:
```properties
logging.level.org.springframework.security=DEBUG
logging.level.com.demo=DEBUG
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is for educational purposes and demonstrates security implementations in Spring Boot.

---

**⚠️ Important**: This is a demonstration project. In production environments, ensure proper security hardening, use HTTPS, implement proper error handling, and follow your organization's security guidelines.

A comprehensive demonstration of Java security implementations using Spring Boot, showcasing three different security approaches:
1. **Basic Authentication** - HTTP Basic Auth
2. **Method Level Security** - Role-based access control with annotations
3. **JWT Token Authentication** - JSON Web Token with Role-based Access Control (RBAC)

## Table of Contents
- [Features](#features)
- [Security Implementations](#security-implementations)
- [Setup and Installation](#setup-and-installation)
- [Demo Users](#demo-users)
- [API Endpoints](#api-endpoints)
- [Testing the Security](#testing-the-security)
- [Architecture Overview](#architecture-overview)
- [Best Practices Implemented](#best-practices-implemented)

## Features

- ✅ **HTTP Basic Authentication** for simple endpoint protection
- ✅ **JWT Token Authentication** with role-based access control
- ✅ **Method-level Security** using Spring Security annotations
- ✅ **Role-based Access Control (RBAC)** with ADMIN and USER roles
- ✅ **In-memory User Management** with encrypted passwords
- ✅ **RESTful API endpoints** demonstrating different security levels
- ✅ **Comprehensive error handling** and security responses
- ✅ **Industry best practices** for security implementation

## Security Implementations

### 1. Basic Authentication (`/api/basic/**`)
- Uses HTTP Basic Authentication
- Requires username and password in Base64 encoded format
- Suitable for simple internal APIs

### 2. JWT Token Authentication (`/api/jwt/**`)
- Stateless authentication using JSON Web Tokens
- Token-based authentication with configurable expiration
- Suitable for modern web applications and mobile apps

### 3. Method Level Security (`/api/method/**`)
- Uses Spring Security's `@PreAuthorize` annotations
- Fine-grained access control at method level
- Supports complex authorization rules

### 4. Configuration Level Security (`/api/admin/**`)
- Configured at Spring Security configuration level
- Role-based access (ADMIN only)
- Demonstrates URL-based security rules

## Setup and Installation

### Prerequisites
- Java 17 or higher
- Maven 3.6 or higher

### Installation Steps

1. **Clone and navigate to the project:**
   ```bash
   cd "C:\Users\abhishek_patil1\Desktop\IP Demos\JavaSecurity"
   ```

2. **Build the project:**
   ```bash
   mvn clean install
   ```

3. **Run the application:**
   ```bash
   mvn spring-boot:run
   ```

4. **Access the application:**
   - API Base URL: `http://localhost:8080`
   - H2 Console: `http://localhost:8080/h2-console`

## Demo Users

The application automatically creates two demo users:

| Username | Password | Role  | Description |
|----------|----------|-------|-------------|
| `admin`  | `admin123` | ADMIN | Full access to all endpoints |
| `user`   | `user123`  | USER  | Limited access based on role |

## API Endpoints

### Public Endpoints (No Authentication Required)
```
GET /api/public/hello         - Public greeting endpoint
GET /api/public/info          - Application information
GET /api/auth/test            - Authentication service test
```

### Authentication Endpoints
```
POST /api/auth/signin         - JWT Login endpoint
Body: {"username": "admin", "password": "admin123"}
```

### Basic Authentication Endpoints
```
GET /api/basic/user-info      - Get user information (Basic Auth)
GET /api/basic/protected      - Protected data (Basic Auth)
POST /api/basic/action        - Perform action (Basic Auth)
```

### JWT Authentication Endpoints
```
GET /api/jwt/profile          - User profile (JWT required)
GET /api/jwt/dashboard        - User dashboard (JWT required)
GET /api/jwt/data             - Secure data (JWT required)
POST /api/jwt/secure-action   - Secure action (JWT required)
```

### Method Level Security Endpoints
```
GET /api/method/all                    - Accessible to ADMIN and USER
GET /api/method/admin-only             - ADMIN role required
GET /api/method/user-only              - USER role only (not ADMIN)
GET /api/method/check-username/{user}  - Self-access or ADMIN
POST /api/method/admin-action          - ADMIN action required
```

### Admin Only Endpoints (Configuration Level)
```
GET /api/admin/dashboard        - Admin dashboard
GET /api/admin/users           - All users list
POST /api/admin/system-config  - System configuration
DELETE /api/admin/user/{id}    - Delete user
```

## Testing the Security



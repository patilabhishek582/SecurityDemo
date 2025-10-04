#!/bin/bash

# Java Security Demo - Admin Endpoints Test Script
# Make sure the application is running on http://localhost:8080

echo "=== Java Security Demo - Admin Endpoints Test ==="
echo ""

# Step 1: Get Admin Token
echo "1. Getting Admin JWT Token..."
ADMIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

echo "Admin login response: $ADMIN_RESPONSE"
echo ""

# Extract token (basic extraction for demo)
ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Failed to get admin token. Make sure the application is running."
    exit 1
fi

echo "Admin token obtained: ${ADMIN_TOKEN:0:50}..."
echo ""

# Step 2: Test Admin Endpoints
echo "2. Testing Admin Dashboard..."
curl -s -X GET http://localhost:8080/api/admin/dashboard \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.' || echo "Response received"
echo ""

echo "3. Testing Admin Users List..."
curl -s -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.' || echo "Response received"
echo ""

echo "4. Testing Admin System Config Update..."
curl -s -X POST http://localhost:8080/api/admin/system-config \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"maintenance": "enabled", "maxUsers": 200}' | jq '.' || echo "Response received"
echo ""

echo "5. Testing Admin User Deletion (Simulated)..."
curl -s -X DELETE http://localhost:8080/api/admin/user/999 \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.' || echo "Response received"
echo ""

# Step 3: Test with Regular User (Should Fail)
echo "6. Testing with Regular User (Should get 403 Forbidden)..."
USER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "user123"}')

USER_TOKEN=$(echo $USER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

echo "Attempting admin dashboard access with USER token..."
curl -s -X GET http://localhost:8080/api/admin/dashboard \
  -H "Authorization: Bearer $USER_TOKEN" | jq '.' || echo "Expected 403 Forbidden response"
echo ""

echo "=== Admin Endpoints Test Complete ==="

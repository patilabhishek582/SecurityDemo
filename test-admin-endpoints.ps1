# Java Security Demo - Admin Endpoints Test Script (PowerShell)
# Make sure the application is running on http://localhost:8080

Write-Host "=== Java Security Demo - Admin Endpoints Test ===" -ForegroundColor Green
Write-Host ""

# Step 1: Get Admin Token
Write-Host "1. Getting Admin JWT Token..." -ForegroundColor Yellow
$adminResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/signin" `
    -Method Post `
    -ContentType "application/json" `
    -Body '{"username": "admin", "password": "admin123"}'

Write-Host "Admin login successful. Role: $($adminResponse.role)" -ForegroundColor Green
$adminToken = $adminResponse.token
Write-Host "Token obtained: $($adminToken.Substring(0, 50))..." -ForegroundColor Cyan
Write-Host ""

# Step 2: Test Admin Endpoints
Write-Host "2. Testing Admin Dashboard..." -ForegroundColor Yellow
$headers = @{ "Authorization" = "Bearer $adminToken" }
$dashboardResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard" -Headers $headers
Write-Host "Dashboard Response:" -ForegroundColor Green
$dashboardResponse | ConvertTo-Json -Depth 3
Write-Host ""

Write-Host "3. Testing Admin Users List..." -ForegroundColor Yellow
$usersResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/users" -Headers $headers
Write-Host "Users List Response:" -ForegroundColor Green
$usersResponse | ConvertTo-Json -Depth 3
Write-Host ""

Write-Host "4. Testing Admin System Config Update..." -ForegroundColor Yellow
$configBody = '{"maintenance": "enabled", "maxUsers": 200, "backupEnabled": true}'
$configResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/system-config" `
    -Method Post `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $configBody
Write-Host "Config Update Response:" -ForegroundColor Green
$configResponse | ConvertTo-Json -Depth 3
Write-Host ""

Write-Host "5. Testing Admin User Deletion (Simulated)..." -ForegroundColor Yellow
$deleteResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/user/999" `
    -Method Delete `
    -Headers $headers
Write-Host "Delete Response:" -ForegroundColor Green
$deleteResponse | ConvertTo-Json -Depth 3
Write-Host ""

# Step 3: Test with Regular User (Should Fail)
Write-Host "6. Testing with Regular User (Should get 403 Forbidden)..." -ForegroundColor Yellow
$userResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/signin" `
    -Method Post `
    -ContentType "application/json" `
    -Body '{"username": "user", "password": "user123"}'

$userToken = $userResponse.token
$userHeaders = @{ "Authorization" = "Bearer $userToken" }

Write-Host "Attempting admin dashboard access with USER token..." -ForegroundColor Red
try {
    $failedResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard" -Headers $userHeaders
    Write-Host "Unexpected success - this should have failed!" -ForegroundColor Red
} catch {
    Write-Host "Expected 403 Forbidden received: $($_.Exception.Message)" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Admin Endpoints Test Complete ===" -ForegroundColor Green

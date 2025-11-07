# Test Application with Real Azure Services
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTING APPLICATION WITH REAL AZURE SERVICES" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Waiting for app to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "`n1. Testing Health Endpoint..." -ForegroundColor Magenta
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5000/api/health" -Method GET
    Write-Host "✅ Health Check:" -ForegroundColor Green
    $health | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Health check failed: $_" -ForegroundColor Red
}

Write-Host "`n2. Testing Event Submission..." -ForegroundColor Magenta
try {
    $eventData = @{
        eventType = "PageView"
        userId = "user123"
        productId = "prod456"
        timestamp = (Get-Date).ToString("o")
    } | ConvertTo-Json

    $result = Invoke-RestMethod -Uri "http://localhost:5000/api/events" -Method POST -Body $eventData -ContentType "application/json"
    Write-Host "✅ Event Submitted:" -ForegroundColor Green
    $result | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Event submission failed: $_" -ForegroundColor Red
}

Write-Host "`n3. Testing Stats Endpoint..." -ForegroundColor Magenta
try {
    $stats = Invoke-RestMethod -Uri "http://localhost:5000/api/stats" -Method GET
    Write-Host "✅ Stats Retrieved:" -ForegroundColor Green
    $stats | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Stats retrieval failed: $_" -ForegroundColor Red
}

Write-Host "`n4. Testing Swagger UI..." -ForegroundColor Magenta
Write-Host "   Open in browser: http://localhost:5000/swagger" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "LOCAL TESTING COMPLETE!" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

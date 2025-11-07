# Load Testing Script for E-Commerce Real-Time Data Processing System
# CLDV7112w Practicum - ST10129307
# This script simulates heavy traffic loads to test autoscaling

param(
    [string]$BaseUrl = "http://localhost:5000",
    [int]$DurationSeconds = 120,
    [int]$ConcurrentRequests = 10,
    [int]$LoadIntensity = 8  # 1-10, higher = more CPU intensive
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "E-Commerce Load Testing Script" -ForegroundColor Cyan
Write-Host "Student: ST10129307" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Base URL: $BaseUrl" -ForegroundColor White
Write-Host "  Duration: $DurationSeconds seconds" -ForegroundColor White
Write-Host "  Concurrent Requests: $ConcurrentRequests" -ForegroundColor White
Write-Host "  Load Intensity: $LoadIntensity/10" -ForegroundColor White
Write-Host ""

# Test if server is accessible
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/" -Method Get -TimeoutSec 5
    Write-Host "✓ Server is accessible" -ForegroundColor Green
    Write-Host "  API: $($response.name)" -ForegroundColor Gray
    Write-Host "  Student: $($response.student)" -ForegroundColor Gray
}
catch {
    Write-Host "✗ Error: Cannot connect to $BaseUrl" -ForegroundColor Red
    Write-Host "  Make sure the WebApp is running (cd src/WebApp; dotnet run)" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Starting load test in 3 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Statistics
$script:totalRequests = 0
$script:successfulRequests = 0
$script:failedRequests = 0
$script:totalResponseTime = 0
$script:responseTimes = @()

# Function to generate load
function Invoke-LoadTest {
    param($EndpointUrl, $Method = "GET")
    
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $response = Invoke-RestMethod -Uri $EndpointUrl -Method $Method -TimeoutSec 30
        $sw.Stop()
        
        $script:totalRequests++
        $script:successfulRequests++
        $script:totalResponseTime += $sw.ElapsedMilliseconds
        $script:responseTimes += $sw.ElapsedMilliseconds
        
        return @{
            Success = $true
            ResponseTime = $sw.ElapsedMilliseconds
            StatusCode = 200
        }
    }
    catch {
        $sw.Stop()
        $script:totalRequests++
        $script:failedRequests++
        
        return @{
            Success = $false
            ResponseTime = $sw.ElapsedMilliseconds
            Error = $_.Exception.Message
        }
    }
}

# Endpoints to test
$endpoints = @(
    @{ Url = "$BaseUrl/api/health"; Weight = 2; Name = "Health Check" },
    @{ Url = "$BaseUrl/api/generate-load?intensity=$LoadIntensity"; Weight = 5; Name = "CPU Load" },
    @{ Url = "$BaseUrl/api/simulate/pageview"; Weight = 3; Name = "Simulate Event" },
    @{ Url = "$BaseUrl/api/stats"; Weight = 1; Name = "System Stats" }
)

Write-Host ""
Write-Host "Load test running... Press Ctrl+C to stop" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date
$endTime = $startTime.AddSeconds($DurationSeconds)

# Main load testing loop
$jobs = @()
while ((Get-Date) -lt $endTime) {
    # Launch concurrent requests
    for ($i = 0; $i -lt $ConcurrentRequests; $i++) {
        # Weighted random endpoint selection
        $totalWeight = ($endpoints | Measure-Object -Property Weight -Sum).Sum
        $random = Get-Random -Minimum 0 -Maximum $totalWeight
        $cumulative = 0
        $selectedEndpoint = $endpoints[0]
        
        foreach ($endpoint in $endpoints) {
            $cumulative += $endpoint.Weight
            if ($random -lt $cumulative) {
                $selectedEndpoint = $endpoint
                break
            }
        }
        
        # Execute request in background job
        $job = Start-Job -ScriptBlock {
            param($Url)
            try {
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $response = Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 30
                $sw.Stop()
                return @{ Success = $true; Time = $sw.ElapsedMilliseconds }
            }
            catch {
                return @{ Success = $false; Error = $_.Exception.Message }
            }
        } -ArgumentList $selectedEndpoint.Url
        
        $jobs += @{ Job = $job; Endpoint = $selectedEndpoint.Name }
    }
    
    # Wait a bit before next batch
    Start-Sleep -Milliseconds 100
    
    # Collect completed jobs
    $completedJobs = $jobs | Where-Object { $_.Job.State -eq 'Completed' }
    foreach ($completedJob in $completedJobs) {
        $result = Receive-Job -Job $completedJob.Job
        Remove-Job -Job $completedJob.Job
        
        $script:totalRequests++
        if ($result.Success) {
            $script:successfulRequests++
            if ($result.Time) {
                $script:totalResponseTime += $result.Time
                $script:responseTimes += $result.Time
            }
        }
        else {
            $script:failedRequests++
        }
    }
    
    # Remove completed jobs from tracking
    $jobs = $jobs | Where-Object { $_.Job.State -ne 'Completed' }
    
    # Progress update every 10 seconds
    $elapsed = ((Get-Date) - $startTime).TotalSeconds
    if ([math]::Floor($elapsed) % 10 -eq 0 -and $script:totalRequests -gt 0) {
        $avgResponseTime = if ($script:successfulRequests -gt 0) { 
            [math]::Round($script:totalResponseTime / $script:successfulRequests, 2) 
        } else { 0 }
        
        Write-Host "[$([math]::Round($elapsed, 0))s] Requests: $($script:totalRequests) | Success: $($script:successfulRequests) | Failed: $($script:failedRequests) | Avg: ${avgResponseTime}ms" -ForegroundColor Gray
        Start-Sleep -Milliseconds 1000  # Prevent multiple prints in same second
    }
}

# Wait for remaining jobs to complete
Write-Host ""
Write-Host "Waiting for remaining requests to complete..." -ForegroundColor Yellow
$jobs | ForEach-Object { Wait-Job -Job $_.Job | Out-Null }
$jobs | ForEach-Object {
    $result = Receive-Job -Job $_.Job -ErrorAction SilentlyContinue
    Remove-Job -Job $_.Job
    if ($result) {
        $script:totalRequests++
        if ($result.Success) {
            $script:successfulRequests++
            if ($result.Time) {
                $script:totalResponseTime += $result.Time
                $script:responseTimes += $result.Time
            }
        }
        else {
            $script:failedRequests++
        }
    }
}

# Calculate statistics
$avgResponseTime = if ($script:successfulRequests -gt 0) { 
    [math]::Round($script:totalResponseTime / $script:successfulRequests, 2) 
} else { 0 }

$sortedTimes = $script:responseTimes | Sort-Object
$minTime = if ($sortedTimes.Count -gt 0) { $sortedTimes[0] } else { 0 }
$maxTime = if ($sortedTimes.Count -gt 0) { $sortedTimes[-1] } else { 0 }
$medianTime = if ($sortedTimes.Count -gt 0) { 
    $mid = [math]::Floor($sortedTimes.Count / 2)
    if ($sortedTimes.Count % 2 -eq 0) {
        ($sortedTimes[$mid - 1] + $sortedTimes[$mid]) / 2
    } else {
        $sortedTimes[$mid]
    }
} else { 0 }

$p95Index = [math]::Floor($sortedTimes.Count * 0.95)
$p95Time = if ($p95Index -lt $sortedTimes.Count) { $sortedTimes[$p95Index] } else { 0 }

$requestsPerSecond = if ($DurationSeconds -gt 0) { 
    [math]::Round($script:totalRequests / $DurationSeconds, 2) 
} else { 0 }

$successRate = if ($script:totalRequests -gt 0) { 
    [math]::Round(($script:successfulRequests / $script:totalRequests) * 100, 2) 
} else { 0 }

# Display results
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Load Test Results" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Request Statistics:" -ForegroundColor Yellow
Write-Host "  Total Requests:      $($script:totalRequests)" -ForegroundColor White
Write-Host "  Successful:          $($script:successfulRequests) ($successRate%)" -ForegroundColor Green
Write-Host "  Failed:              $($script:failedRequests)" -ForegroundColor $(if ($script:failedRequests -gt 0) { "Red" } else { "White" })
Write-Host "  Requests/Second:     $requestsPerSecond" -ForegroundColor White
Write-Host ""
Write-Host "Response Time Statistics:" -ForegroundColor Yellow
Write-Host "  Average:             ${avgResponseTime}ms" -ForegroundColor White
Write-Host "  Median:              ${medianTime}ms" -ForegroundColor White
Write-Host "  Min:                 ${minTime}ms" -ForegroundColor White
Write-Host "  Max:                 ${maxTime}ms" -ForegroundColor White
Write-Host "  95th Percentile:     ${p95Time}ms" -ForegroundColor White
Write-Host ""
Write-Host "Test Duration:         $DurationSeconds seconds" -ForegroundColor Gray
Write-Host "Concurrent Requests:   $ConcurrentRequests" -ForegroundColor Gray
Write-Host "Load Intensity:        $LoadIntensity/10" -ForegroundColor Gray
Write-Host ""

# Performance assessment
Write-Host "Performance Assessment:" -ForegroundColor Yellow
if ($successRate -ge 99) {
    Write-Host "  ✓ Excellent stability ($successRate% success rate)" -ForegroundColor Green
} elseif ($successRate -ge 95) {
    Write-Host "  ✓ Good stability ($successRate% success rate)" -ForegroundColor Green
} elseif ($successRate -ge 90) {
    Write-Host "  ⚠ Acceptable stability ($successRate% success rate)" -ForegroundColor Yellow
} else {
    Write-Host "  ✗ Poor stability ($successRate% success rate)" -ForegroundColor Red
}

if ($avgResponseTime -lt 100) {
    Write-Host "  ✓ Excellent response time (${avgResponseTime}ms avg)" -ForegroundColor Green
} elseif ($avgResponseTime -lt 500) {
    Write-Host "  ✓ Good response time (${avgResponseTime}ms avg)" -ForegroundColor Green
} elseif ($avgResponseTime -lt 1000) {
    Write-Host "  ⚠ Acceptable response time (${avgResponseTime}ms avg)" -ForegroundColor Yellow
} else {
    Write-Host "  ✗ Slow response time (${avgResponseTime}ms avg)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Check Azure Portal for autoscaling events" -ForegroundColor White
Write-Host "  2. Monitor CPU metrics (should see spike > 70%)" -ForegroundColor White
Write-Host "  3. Observe instance count changes (1 → 2 → 3)" -ForegroundColor White
Write-Host "  4. Capture screenshots for submission" -ForegroundColor White
Write-Host ""

# Export results to file
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "load-test-results_$timestamp.txt"
$reportPath = Join-Path (Split-Path $PSCommandPath -Parent) $reportFile

$report = @"
E-Commerce Load Test Results
Student: ST10129307
Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
========================================

Configuration:
- Base URL: $BaseUrl
- Duration: $DurationSeconds seconds
- Concurrent Requests: $ConcurrentRequests
- Load Intensity: $LoadIntensity/10

Request Statistics:
- Total Requests: $($script:totalRequests)
- Successful: $($script:successfulRequests) ($successRate%)
- Failed: $($script:failedRequests)
- Requests/Second: $requestsPerSecond

Response Time Statistics:
- Average: ${avgResponseTime}ms
- Median: ${medianTime}ms
- Min: ${minTime}ms
- Max: ${maxTime}ms
- 95th Percentile: ${p95Time}ms

"@

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Report saved to: $reportPath" -ForegroundColor Gray
Write-Host ""

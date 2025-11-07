# Load Testing Script for E-Commerce Real-Time Data Processing System
# CLDV7112w Practicum - Performance Testing

param(
    [Parameter(Mandatory=$true)]
    [string]$WebAppUrl,
    
    [Parameter(Mandatory=$false)]
    [int]$ConcurrentUsers = 100,
    
    [Parameter(Mandatory=$false)]
    [int]$DurationMinutes = 10,
    
    [Parameter(Mandatory=$false)]
    [int]$RampUpSeconds = 60
)

Write-Host "=== E-Commerce Load Testing Script ===" -ForegroundColor Green
Write-Host "Target URL: $WebAppUrl" -ForegroundColor Yellow
Write-Host "Concurrent Users: $ConcurrentUsers" -ForegroundColor Yellow
Write-Host "Duration: $DurationMinutes minutes" -ForegroundColor Yellow
Write-Host "Ramp-up: $RampUpSeconds seconds" -ForegroundColor Yellow

# Function to simulate e-commerce events
function Send-ECommerceEvent {
    param(
        [string]$BaseUrl,
        [int]$UserId,
        [string]$EventType
    )
    
    $eventData = @{
        EventId = [Guid]::NewGuid().ToString()
        EventType = $EventType
        UserId = "user_$UserId"
        SessionId = [Guid]::NewGuid().ToString()
        Timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        ProductId = "product_$(Get-Random -Minimum 1 -Maximum 1000)"
        CategoryId = "category_$(Get-Random -Minimum 1 -Maximum 50)"
        Price = [Math]::Round((Get-Random -Minimum 10 -Maximum 500) + (Get-Random), 2)
        Quantity = Get-Random -Minimum 1 -Maximum 5
        Currency = "USD"
        Source = @("Web", "Mobile", "API") | Get-Random
        Metadata = @{
            Browser = "Chrome"
            OS = "Windows"
            Country = @("US", "CA", "UK", "DE", "FR") | Get-Random
        }
    } | ConvertTo-Json -Depth 3

    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/api/events" -Method POST -Body $eventData -ContentType "application/json" -TimeoutSec 30
        return @{
            Success = $true
            StatusCode = $response.StatusCode
            ResponseTime = $response.Headers.'Request-Duration'
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            ResponseTime = 0
        }
    }
}

# Function to simulate browsing behavior
function Send-PageViewEvent {
    param([string]$BaseUrl, [int]$UserId)
    return Send-ECommerceEvent -BaseUrl $BaseUrl -UserId $UserId -EventType "PageView"
}

# Function to simulate product searches
function Send-SearchEvent {
    param([string]$BaseUrl, [int]$UserId)
    return Send-ECommerceEvent -BaseUrl $BaseUrl -UserId $UserId -EventType "Search"
}

# Function to simulate add to cart
function Send-AddToCartEvent {
    param([string]$BaseUrl, [int]$UserId)
    return Send-ECommerceEvent -BaseUrl $BaseUrl -UserId $UserId -EventType "AddToCart"
}

# Function to simulate purchases
function Send-PurchaseEvent {
    param([string]$BaseUrl, [int]$UserId)
    return Send-ECommerceEvent -BaseUrl $BaseUrl -UserId $UserId -EventType "Purchase"
}

# Initialize results tracking
$results = @{
    TotalRequests = 0
    SuccessfulRequests = 0
    FailedRequests = 0
    AverageResponseTime = 0
    ResponseTimes = @()
    ErrorMessages = @()
}

# Create user simulation script block
$userSimulationScript = {
    param($WebAppUrl, $UserId, $DurationSeconds)
    
    $localResults = @{
        Requests = 0
        Successes = 0
        Failures = 0
        ResponseTimes = @()
        Errors = @()
    }
    
    $endTime = (Get-Date).AddSeconds($DurationSeconds)
    
    while ((Get-Date) -lt $endTime) {
        # Simulate realistic user behavior
        $eventTypes = @(
            { Send-PageViewEvent -BaseUrl $WebAppUrl -UserId $UserId },
            { Send-PageViewEvent -BaseUrl $WebAppUrl -UserId $UserId },
            { Send-SearchEvent -BaseUrl $WebAppUrl -UserId $UserId },
            { Send-AddToCartEvent -BaseUrl $WebAppUrl -UserId $UserId },
            { Send-PurchaseEvent -BaseUrl $WebAppUrl -UserId $UserId }
        )
        
        # Weighted random selection (more page views than purchases)
        $weights = @(40, 30, 15, 10, 5)
        $randomValue = Get-Random -Minimum 0 -Maximum 100
        $selectedEvent = 0
        $cumulative = 0
        
        for ($i = 0; $i -lt $weights.Length; $i++) {
            $cumulative += $weights[$i]
            if ($randomValue -lt $cumulative) {
                $selectedEvent = $i
                break
            }
        }
        
        $startTime = Get-Date
        $result = & $eventTypes[$selectedEvent]
        $endTime = Get-Date
        $responseTime = ($endTime - $startTime).TotalMilliseconds
        
        $localResults.Requests++
        $localResults.ResponseTimes += $responseTime
        
        if ($result.Success) {
            $localResults.Successes++
        } else {
            $localResults.Failures++
            $localResults.Errors += $result.Error
        }
        
        # Simulate think time between requests
        Start-Sleep -Milliseconds (Get-Random -Minimum 1000 -Maximum 3000)
    }
    
    return $localResults
}

Write-Host "`nStarting load test..." -ForegroundColor Green

# Start timer
$testStartTime = Get-Date

# Create jobs for concurrent users with ramp-up
$jobs = @()
for ($i = 1; $i -le $ConcurrentUsers; $i++) {
    # Stagger user start times for ramp-up
    $delaySeconds = [math]::Round(($i - 1) * ($RampUpSeconds / $ConcurrentUsers))
    
    $job = Start-Job -ScriptBlock $userSimulationScript -ArgumentList $WebAppUrl, $i, ($DurationMinutes * 60)
    $jobs += @{
        Job = $job
        UserId = $i
        StartDelay = $delaySeconds
    }
    
    # Add ramp-up delay
    if ($delaySeconds -gt 0) {
        Start-Sleep -Milliseconds ($delaySeconds * 1000 / $ConcurrentUsers)
    }
    
    Write-Host "Started user $i (delay: $delaySeconds seconds)" -ForegroundColor Cyan
}

Write-Host "`nUsers started. Running for $DurationMinutes minutes..." -ForegroundColor Yellow

# Monitor progress
$progressTimer = 0
while ($progressTimer -lt ($DurationMinutes * 60)) {
    Start-Sleep -Seconds 10
    $progressTimer += 10
    
    $runningJobs = $jobs | Where-Object { $_.Job.State -eq "Running" }
    $completedJobs = $jobs | Where-Object { $_.Job.State -eq "Completed" }
    
    Write-Host "Progress: $progressTimer/$($DurationMinutes * 60) seconds | Running: $($runningJobs.Count) | Completed: $($completedJobs.Count)" -ForegroundColor Gray
}

Write-Host "`nCollecting results..." -ForegroundColor Yellow

# Wait for all jobs to complete
$jobs.Job | Wait-Job -Timeout 60

# Collect results
$allResults = @()
foreach ($jobInfo in $jobs) {
    if ($jobInfo.Job.State -eq "Completed") {
        $jobResult = Receive-Job -Job $jobInfo.Job
        $allResults += $jobResult
        Remove-Job -Job $jobInfo.Job
    } else {
        Write-Warning "Job for user $($jobInfo.UserId) did not complete successfully"
        Stop-Job -Job $jobInfo.Job
        Remove-Job -Job $jobInfo.Job
    }
}

# Calculate aggregate results
$testEndTime = Get-Date
$testDuration = ($testEndTime - $testStartTime).TotalMinutes

$totalRequests = ($allResults | Measure-Object -Property Requests -Sum).Sum
$totalSuccesses = ($allResults | Measure-Object -Property Successes -Sum).Sum
$totalFailures = ($allResults | Measure-Object -Property Failures -Sum).Sum

$allResponseTimes = $allResults | ForEach-Object { $_.ResponseTimes }
$averageResponseTime = if ($allResponseTimes.Count -gt 0) { 
    ($allResponseTimes | Measure-Object -Average).Average 
} else { 0 }

$successRate = if ($totalRequests -gt 0) { 
    [math]::Round(($totalSuccesses / $totalRequests) * 100, 2) 
} else { 0 }

$throughput = if ($testDuration -gt 0) { 
    [math]::Round($totalRequests / $testDuration, 2) 
} else { 0 }

# Display results
Write-Host "`n=== Load Test Results ===" -ForegroundColor Green
Write-Host "Test Duration: $([math]::Round($testDuration, 2)) minutes" -ForegroundColor White
Write-Host "Concurrent Users: $ConcurrentUsers" -ForegroundColor White
Write-Host "Total Requests: $totalRequests" -ForegroundColor White
Write-Host "Successful Requests: $totalSuccesses" -ForegroundColor Green
Write-Host "Failed Requests: $totalFailures" -ForegroundColor Red
Write-Host "Success Rate: $successRate%" -ForegroundColor White
Write-Host "Average Response Time: $([math]::Round($averageResponseTime, 2)) ms" -ForegroundColor White
Write-Host "Throughput: $throughput requests/minute" -ForegroundColor White

if ($allResponseTimes.Count -gt 0) {
    $sortedResponseTimes = $allResponseTimes | Sort-Object
    $p50 = $sortedResponseTimes[[math]::Floor($sortedResponseTimes.Count * 0.5)]
    $p95 = $sortedResponseTimes[[math]::Floor($sortedResponseTimes.Count * 0.95)]
    $p99 = $sortedResponseTimes[[math]::Floor($sortedResponseTimes.Count * 0.99)]
    
    Write-Host "`nResponse Time Percentiles:" -ForegroundColor Yellow
    Write-Host "50th percentile: $([math]::Round($p50, 2)) ms" -ForegroundColor White
    Write-Host "95th percentile: $([math]::Round($p95, 2)) ms" -ForegroundColor White
    Write-Host "99th percentile: $([math]::Round($p99, 2)) ms" -ForegroundColor White
}

# Save detailed results to file
$reportData = @{
    TestConfiguration = @{
        WebAppUrl = $WebAppUrl
        ConcurrentUsers = $ConcurrentUsers
        DurationMinutes = $DurationMinutes
        RampUpSeconds = $RampUpSeconds
        ActualDurationMinutes = [math]::Round($testDuration, 2)
    }
    Results = @{
        TotalRequests = $totalRequests
        SuccessfulRequests = $totalSuccesses
        FailedRequests = $totalFailures
        SuccessRate = $successRate
        AverageResponseTime = [math]::Round($averageResponseTime, 2)
        Throughput = $throughput
    }
    ResponseTimePercentiles = if ($allResponseTimes.Count -gt 0) {
        @{
            P50 = [math]::Round($p50, 2)
            P95 = [math]::Round($p95, 2)
            P99 = [math]::Round($p99, 2)
        }
    } else { $null }
    Timestamp = Get-Date
}

$reportFile = "load-test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$reportData | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "`nDetailed results saved to: $reportFile" -ForegroundColor Cyan

# Performance recommendations
Write-Host "`n=== Performance Analysis ===" -ForegroundColor Yellow
if ($successRate -lt 95) {
    Write-Host "⚠️  Success rate is below 95%. Consider investigating error causes." -ForegroundColor Red
}
if ($averageResponseTime -gt 1000) {
    Write-Host "⚠️  Average response time exceeds 1 second. Consider optimizing performance." -ForegroundColor Red
}
if ($throughput -lt 100) {
    Write-Host "⚠️  Low throughput detected. Consider scaling up resources." -ForegroundColor Red
}

Write-Host "`nLoad testing completed!" -ForegroundColor Green
# PowerShell script to deploy applications to Azure for CLDV7112w Practicum
# Usage: .\deploy-applications.ps1 -ResourceGroupName "rg-cldv7112w-practicum"

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$StudentNumber = "ST10129307"
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "Starting application deployment for CLDV7112w Practicum..." -ForegroundColor Green

try {
    # Get deployment outputs
    Write-Host "Retrieving infrastructure deployment information..." -ForegroundColor Yellow
    
    # Get the latest deployment
    $latestDeployment = az deployment group list `
        --resource-group $ResourceGroupName `
        --query "[?contains(name, 'infrastructure-deployment')][0]" `
        --output json | ConvertFrom-Json
    
    if (-not $latestDeployment) {
        throw "No infrastructure deployment found. Please run deploy-infrastructure.ps1 first."
    }
    
    $outputs = az deployment group show `
        --resource-group $ResourceGroupName `
        --name $latestDeployment.name `
        --query properties.outputs `
        --output json | ConvertFrom-Json

    $webAppName = ($outputs.webAppUrl.value -split "//")[1] -replace "\.azurewebsites\.net.*", ""
    $functionAppName = $outputs.functionAppName.value

    Write-Host "Web App Name: $webAppName" -ForegroundColor Cyan
    Write-Host "Function App Name: $functionAppName" -ForegroundColor Cyan

    # Build and deploy web application
    Write-Host "`nBuilding web application..." -ForegroundColor Yellow
    Set-Location "src\WebApp"
    
    # Restore NuGet packages
    dotnet restore
    if ($LASTEXITCODE -ne 0) { throw "Failed to restore NuGet packages for web app" }
    
    # Build the application
    dotnet build --configuration Release
    if ($LASTEXITCODE -ne 0) { throw "Failed to build web application" }
    
    # Publish the application
    dotnet publish --configuration Release --output "..\..\publish\webapp"
    if ($LASTEXITCODE -ne 0) { throw "Failed to publish web application" }
    
    Set-Location "..\..\"

    # Deploy web application to Azure App Service
    Write-Host "Deploying web application to Azure App Service..." -ForegroundColor Yellow
    az webapp deployment source config-zip `
        --resource-group $ResourceGroupName `
        --name $webAppName `
        --src "publish\webapp.zip"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Web application deployed successfully!" -ForegroundColor Green
    }

    # Build and deploy Function App
    Write-Host "`nBuilding Function App..." -ForegroundColor Yellow
    Set-Location "src\Functions"
    
    # Restore NuGet packages
    dotnet restore
    if ($LASTEXITCODE -ne 0) { throw "Failed to restore NuGet packages for Function App" }
    
    # Build the application
    dotnet build --configuration Release
    if ($LASTEXITCODE -ne 0) { throw "Failed to build Function App" }
    
    # Publish the application
    dotnet publish --configuration Release --output "..\..\publish\functions"
    if ($LASTEXITCODE -ne 0) { throw "Failed to publish Function App" }
    
    Set-Location "..\..\"

    # Create deployment package for Function App
    Write-Host "Creating Function App deployment package..." -ForegroundColor Yellow
    Compress-Archive -Path "publish\functions\*" -DestinationPath "publish\functions.zip" -Force

    # Deploy Function App
    Write-Host "Deploying Function App to Azure..." -ForegroundColor Yellow
    az functionapp deployment source config-zip `
        --resource-group $ResourceGroupName `
        --name $functionAppName `
        --src "publish\functions.zip"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Function App deployed successfully!" -ForegroundColor Green
    }

    # Configure autoscaling for App Service
    Write-Host "`nConfiguring autoscaling for App Service..." -ForegroundColor Yellow
    
    # Create autoscale setting
    az monitor autoscale create `
        --resource-group $ResourceGroupName `
        --resource $webAppName `
        --resource-type "Microsoft.Web/sites" `
        --name "${webAppName}-autoscale" `
        --min-count 1 `
        --max-count 10 `
        --count 2

    # Add scale out rule (CPU > 70%)
    az monitor autoscale rule create `
        --resource-group $ResourceGroupName `
        --autoscale-name "${webAppName}-autoscale" `
        --condition "Percentage CPU > 70 avg 5m" `
        --scale out 1

    # Add scale in rule (CPU < 25%)
    az monitor autoscale rule create `
        --resource-group $ResourceGroupName `
        --autoscale-name "${webAppName}-autoscale" `
        --condition "Percentage CPU < 25 avg 5m" `
        --scale in 1

    Write-Host "Autoscaling configured successfully!" -ForegroundColor Green

    # Display deployment information
    Write-Host "`n=== Deployment Completed Successfully ===" -ForegroundColor Green
    Write-Host "Web Application URL: $($outputs.webAppUrl.value)" -ForegroundColor Cyan
    Write-Host "Function App deployed and configured" -ForegroundColor Cyan
    Write-Host "Autoscaling enabled with 1-10 instance range" -ForegroundColor Cyan

    # Next steps
    Write-Host "`n=== Next Steps ===" -ForegroundColor Yellow
    Write-Host "1. Configure connection strings in Azure portal"
    Write-Host "2. Test the application endpoints"
    Write-Host "3. Run load tests using the testing scripts"
    Write-Host "4. Monitor autoscaling behavior in Azure portal"
    Write-Host "5. Document results for practicum submission"

}
catch {
    Write-Host "`nApplication deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Return to original directory
    Set-Location $PSScriptRoot
}

Write-Host "`nApplication deployment completed!" -ForegroundColor Green
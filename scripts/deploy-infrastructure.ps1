# PowerShell script to deploy Azure infrastructure for CLDV7112w Practicum
# Usage: .\deploy-infrastructure.ps1 -StudentNumber "ST10129307" -ResourceGroupName "rg-cldv7112w-practicum"

param(
    [Parameter(Mandatory=$true)]
    [string]$StudentNumber,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-cldv7112w-practicum",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlanSku = "S1"
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "Starting Azure infrastructure deployment for CLDV7112w Practicum..." -ForegroundColor Green

try {
    # Check if user is logged in to Azure
    Write-Host "Checking Azure login status..." -ForegroundColor Yellow
    $context = az account show --query "user.name" --output tsv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Please log in to Azure first using 'az login'" -ForegroundColor Red
        exit 1
    }
    Write-Host "Logged in as: $context" -ForegroundColor Green

    # Create resource group if it doesn't exist
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create resource group"
    }

    # Deploy ARM template
    Write-Host "Deploying ARM template..." -ForegroundColor Yellow
    $deploymentName = "infrastructure-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "infrastructure\azuredeploy.json" `
        --parameters studentNumber=$StudentNumber `
                    location=$Location `
                    appServicePlanSku=$AppServicePlanSku `
        --name $deploymentName `
        --verbose

    if ($LASTEXITCODE -ne 0) {
        throw "ARM template deployment failed"
    }

    # Get deployment outputs
    Write-Host "Retrieving deployment outputs..." -ForegroundColor Yellow
    $outputs = az deployment group show `
        --resource-group $ResourceGroupName `
        --name $deploymentName `
        --query properties.outputs `
        --output json | ConvertFrom-Json

    # Display important information
    Write-Host "`n=== Deployment Completed Successfully ===" -ForegroundColor Green
    Write-Host "Web App URL: $($outputs.webAppUrl.value)" -ForegroundColor Cyan
    Write-Host "Function App Name: $($outputs.functionAppName.value)" -ForegroundColor Cyan
    Write-Host "Cosmos DB Account: $($outputs.cosmosDbAccountName.value)" -ForegroundColor Cyan
    Write-Host "Event Hub Namespace: $($outputs.eventHubNamespace.value)" -ForegroundColor Cyan
    Write-Host "Application Insights: $($outputs.applicationInsightsName.value)" -ForegroundColor Cyan

    # Save outputs to file
    $outputsPath = "deployment-outputs.json"
    $outputs | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputsPath -Encoding UTF8
    Write-Host "`nDeployment outputs saved to: $outputsPath" -ForegroundColor Yellow

    # Next steps
    Write-Host "`n=== Next Steps ===" -ForegroundColor Yellow
    Write-Host "1. Configure connection strings in your applications"
    Write-Host "2. Deploy your web application using deploy-applications.ps1"
    Write-Host "3. Test autoscaling with load-testing scripts"
    Write-Host "4. Monitor performance in Application Insights"

}
catch {
    Write-Host "`nDeployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nInfrastructure deployment completed!" -ForegroundColor Green
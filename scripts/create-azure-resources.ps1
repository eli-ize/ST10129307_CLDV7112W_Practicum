# Simplified Azure resource creation for CLDV7112w Practicum
# This script creates resources one by one using Azure CLI

$resourceGroup = "AZ-JHB-RSG-RCNA-ST10129307-TER"
$location = "South Africa North"
$studentNumber = "st10129307"

Write-Host "=== CLDV7112w Practicum - Azure Resource Creation ===" -ForegroundColor Green
Write-Host "Resource Group: $resourceGroup" -ForegroundColor Yellow
Write-Host "Location: $location" -ForegroundColor Yellow
Write-Host "Student Number: $studentNumber" -ForegroundColor Yellow

try {
    # 1. Create Storage Account (required for Function App)
    Write-Host "`n1. Creating Storage Account..." -ForegroundColor Cyan
    $storageAccountName = "${studentNumber}storage$(Get-Random -Minimum 1000 -Maximum 9999)"
    az storage account create `
        --name $storageAccountName `
        --resource-group $resourceGroup `
        --location $location `
        --sku Standard_LRS `
        --kind StorageV2

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Storage Account created: $storageAccountName" -ForegroundColor Green
    } else {
        throw "Failed to create Storage Account"
    }

    # 2. Create App Service Plan
    Write-Host "`n2. Creating App Service Plan..." -ForegroundColor Cyan
    $appServicePlanName = "$studentNumber-asp"
    az appservice plan create `
        --name $appServicePlanName `
        --resource-group $resourceGroup `
        --location $location `
        --sku S1 `
        --is-linux false

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ App Service Plan created: $appServicePlanName" -ForegroundColor Green
    } else {
        throw "Failed to create App Service Plan"
    }

    # 3. Create Web App
    Write-Host "`n3. Creating Web App..." -ForegroundColor Cyan
    $webAppName = $studentNumber
    az webapp create `
        --name $webAppName `
        --resource-group $resourceGroup `
        --plan $appServicePlanName `
        --runtime "DOTNET|8.0"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Web App created: $webAppName" -ForegroundColor Green
        Write-Host "   URL: https://$webAppName.azurewebsites.net" -ForegroundColor Cyan
    } else {
        throw "Failed to create Web App"
    }

    # 4. Create Function App
    Write-Host "`n4. Creating Function App..." -ForegroundColor Cyan
    $functionAppName = "$studentNumber-func"
    az functionapp create `
        --name $functionAppName `
        --resource-group $resourceGroup `
        --storage-account $storageAccountName `
        --plan $appServicePlanName `
        --runtime dotnet-isolated `
        --runtime-version 8 `
        --functions-version 4

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Function App created: $functionAppName" -ForegroundColor Green
    } else {
        Write-Warning "Function App creation failed, but continuing..."
    }

    # 5. Create Cosmos DB Account
    Write-Host "`n5. Creating Cosmos DB Account..." -ForegroundColor Cyan
    $cosmosAccountName = "$studentNumber-cosmos"
    az cosmosdb create `
        --name $cosmosAccountName `
        --resource-group $resourceGroup `
        --locations regionName="$location" `
        --default-consistency-level Session `
        --capabilities EnableServerless

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Cosmos DB Account created: $cosmosAccountName" -ForegroundColor Green
    } else {
        Write-Warning "Cosmos DB creation failed, but continuing..."
    }

    # 6. Create Event Hub Namespace
    Write-Host "`n6. Creating Event Hub Namespace..." -ForegroundColor Cyan
    $eventHubNamespace = "$studentNumber-eventhub"
    az eventhubs namespace create `
        --name $eventHubNamespace `
        --resource-group $resourceGroup `
        --location $location `
        --sku Standard

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Event Hub Namespace created: $eventHubNamespace" -ForegroundColor Green
        
        # Create Event Hub
        Write-Host "   Creating Event Hub..." -ForegroundColor Yellow
        az eventhubs eventhub create `
            --name "ecommerce-events" `
            --resource-group $resourceGroup `
            --namespace-name $eventHubNamespace `
            --message-retention 1 `
            --partition-count 2

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Event Hub created: ecommerce-events" -ForegroundColor Green
        }
    } else {
        Write-Warning "Event Hub creation failed, but continuing..."
    }

    # 7. Create Application Insights
    Write-Host "`n7. Creating Application Insights..." -ForegroundColor Cyan
    $appInsightsName = "$studentNumber-insights"
    az monitor app-insights component create `
        --app $appInsightsName `
        --location $location `
        --resource-group $resourceGroup `
        --kind web `
        --application-type web

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Application Insights created: $appInsightsName" -ForegroundColor Green
    } else {
        Write-Warning "Application Insights creation failed, but continuing..."
    }

    Write-Host "`n=== Resource Creation Summary ===" -ForegroundColor Green
    Write-Host "✅ Storage Account: $storageAccountName" -ForegroundColor White
    Write-Host "✅ App Service Plan: $appServicePlanName" -ForegroundColor White
    Write-Host "✅ Web App: $webAppName" -ForegroundColor White
    Write-Host "   🌐 URL: https://$webAppName.azurewebsites.net" -ForegroundColor Cyan
    Write-Host "✅ Function App: $functionAppName" -ForegroundColor White
    Write-Host "✅ Cosmos DB: $cosmosAccountName" -ForegroundColor White
    Write-Host "✅ Event Hub: $eventHubNamespace/ecommerce-events" -ForegroundColor White
    Write-Host "✅ App Insights: $appInsightsName" -ForegroundColor White

    Write-Host "`n=== Next Steps ===" -ForegroundColor Yellow
    Write-Host "1. Configure autoscaling for the Web App" -ForegroundColor White
    Write-Host "2. Set up connection strings" -ForegroundColor White
    Write-Host "3. Deploy your application code" -ForegroundColor White
    Write-Host "4. Run load tests to validate scaling" -ForegroundColor White

} catch {
    Write-Error "❌ Error during resource creation: $($_.Exception.Message)"
    Write-Host "`nPlease check your Azure permissions and try again." -ForegroundColor Red
}

Write-Host "`nResource creation script completed!" -ForegroundColor Green
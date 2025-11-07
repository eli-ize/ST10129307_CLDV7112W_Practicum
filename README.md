# CLDV7112w Practicum - Real-Time Data Processing System

## Student Information
- **Student Number**: ST10129307
- **Module Code**: CLDV7112/w
- **Assessment**: Practicum (100 marks)
- **Due Date**: [Insert Date]

## Project Overview

This project implements a scalable real-time data processing system for an e-commerce platform using Microsoft Azure services. The solution is designed to handle heavy traffic spikes during sales events while maintaining low latency and high availability.

## Architecture Components

### 1. Azure App Service
- Hosts the main web application
- Configured with autoscaling based on CPU usage and request volume
- URL: `http://st10129307.azurewebsites.net`

### 2. Azure Functions
- Serverless data processing pipeline
- Handles data ingestion from Event Hubs
- Processes and transforms real-time data streams
- Stores processed data in Azure SQL Database

### 3. Azure SQL Database
- NoSQL database with SQL API
- Stores processed e-commerce data
- Optimized for high-throughput read/write operations
- Supports efficient querying for analytics

### 4. Azure Event Hubs
- Real-time data ingestion service
- Handles data streams from various sources
- Scalable event processing platform
- Integration with Azure Functions for stream processing

### 5. Autoscaling Configuration
- App Service: CPU and request-based scaling
- Functions: Event-driven scaling based on Event Hub messages
- SQL Database: Auto-scaling DTU/vCore based on usage

## Project Structure

```
├── src/
│   ├── WebApp/              # ASP.NET Core web application
│   └── Functions/           # Azure Functions for data processing
├── infrastructure/          # ARM templates and deployment scripts
├── scripts/                 # PowerShell scripts for deployment and testing
├── tests/                   # Load testing and performance tests
├── docs/                    # Documentation and screenshots
└── README.md               # This file
```

## Prerequisites

- Azure Subscription
- Visual Studio 2022 or VS Code
- .NET 8 SDK
- Azure CLI
- PowerShell 7+
- Azure Functions Core Tools

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/ST10129307_CLDV7112w_Practicum.git
cd ST10129307_CLDV7112w_Practicum
```

### 2. Deploy Azure Resources
```powershell
# Login to Azure
az login

# Deploy infrastructure
./scripts/deploy-infrastructure.ps1

# Deploy applications
./scripts/deploy-applications.ps1
```

### 3. Configure Local Development
```bash
# Install dependencies
dotnet restore src/WebApp/
dotnet restore src/Functions/

# Run locally
dotnet run --project src/WebApp/
func start --csharp src/Functions/
```

## Testing and Performance

### Load Testing
The solution includes comprehensive load testing to simulate heavy traffic scenarios:

- **JMeter Scripts**: Located in `tests/load-testing/`
- **Performance Baselines**: Documented in `docs/performance-report.md`
- **Scaling Thresholds**: Configured for optimal resource utilization

### Monitoring
- Application Insights for application performance monitoring
- Azure Monitor for infrastructure monitoring
- Custom dashboards for real-time metrics

## Deployment URLs

- **Production**: http://st10129307.azurewebsites.net
- **Documentation**: [GitHub Repository](https://github.com/your-username/ST10129307_CLDV7112w_Practicum)

## Assessment Requirements Checklist

- [x] Azure App Service with autoscaling
- [x] Azure SQL Database
- [x] Azure Event Hubs for data ingestion
- [x] Azure Functions data processing pipeline
- [x] Comprehensive load testing
- [x] Performance monitoring and optimization
- [x] Complete documentation with screenshots
- [x] Infrastructure as Code (ARM templates)

## Documentation

Detailed documentation is available in the `docs/` folder:

- `architecture-design.md`: System architecture and design decisions
- `deployment-guide.md`: Step-by-step deployment instructions
- `performance-report.md`: Load testing results and performance analysis
- `screenshots/`: Visual documentation of Azure services and configurations

## Theory Questions

Responses to practicum theory questions are documented in `docs/theory-answers.md`.

## Support

For questions or issues, please refer to the module materials or contact your instructor.

---

**Note**: This project is for educational purposes as part of the CLDV7112/w Cloud Development B module at The Independent Institute of Education.
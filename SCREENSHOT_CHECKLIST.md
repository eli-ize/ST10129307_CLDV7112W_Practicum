# 📸 Screenshot Capture Checklist
## CLDV7112w Practicum - ST10129307

---

## 🎯 Priority Screenshots (Required for Submission)

### 1️⃣ Resource Group Overview ⭐⭐⭐
**Navigate to**: Azure Portal > Resource Groups > ST10129307-CLDV7112w-RG

**What to capture**:
- All 8 resources in the resource group
- Resource names, types, and locations
- Status indicators showing all resources are running

**Screenshot file name**: `01_resource_group_overview.png`

---

### 2️⃣ App Service Overview ⭐⭐⭐
**Navigate to**: Azure Portal > st10129307-personal > Overview

**What to capture**:
- App Service name and URL
- Status: Running
- Runtime stack: .NET 8
- Pricing tier: Basic B1
- Resource group location

**Screenshot file name**: `02_app_service_overview.png`

---

### 3️⃣ App Service Autoscaling Configuration ⭐⭐⭐
**Navigate to**: Azure Portal > st10129307-personal > Scale out (App Service plan) > st10129307-personal-plan

**What to capture**:
- Autoscaling settings enabled
- Scale-out rule: CPU > 70%
- Scale-in rule: CPU < 30%
- Instance limits: Min 1, Max 3

**Screenshot file name**: `03_app_service_autoscaling.png`

---

### 4️⃣ App Service Configuration (Connection Strings) ⭐⭐
**Navigate to**: Azure Portal > st10129307-personal > Configuration > Application settings

**What to capture**:
- Connection strings configured
- DefaultConnection (SQL Database)
- EventHub connection string
- *Note: Mask sensitive values in screenshot*

**Screenshot file name**: `04_app_service_configuration.png`

---

### 5️⃣ Function App Overview ⭐⭐⭐
**Navigate to**: Azure Portal > st10129307-functions-personal > Overview

**What to capture**:
- Function App name and URL
- Status: Running
- Runtime: .NET Isolated 8.0
- Hosting plan: Consumption
- Application Insights enabled

**Screenshot file name**: `05_function_app_overview.png`

---

### 6️⃣ Function App - Functions List ⭐⭐⭐
**Navigate to**: Azure Portal > st10129307-functions-personal > Functions

**What to capture**:
- EventProcessor function listed
- Function status
- Trigger type: Event Hub
- Runtime status

**Screenshot file name**: `06_function_app_functions.png`

---

### 7️⃣ Application Insights Overview ⭐⭐
**Navigate to**: Azure Portal > st10129307-functions-personal (Application Insights) > Overview

**What to capture**:
- Server requests graph
- Server response time
- Failed requests (should be 0 or minimal)
- Availability metrics

**Screenshot file name**: `07_application_insights_overview.png`

---

### 8️⃣ Application Insights Live Metrics ⭐
**Navigate to**: Azure Portal > Application Insights > Live Metrics

**What to capture**:
- Real-time request rate
- Response times
- Server health indicators
- Active instances

**Screenshot file name**: `08_application_insights_live.png`

---

### 9️⃣ SQL Database Connection & Firewall ⭐⭐⭐
**Navigate to**: Azure Portal > st10129307-sqlserver > Networking

**What to capture**:
- Firewall rules configured
- App Service outbound IPs allowed
- Connection status: Successful
- Database name: st10129307-database

**Screenshot file name**: `09_sql_database_firewall.png`

---

### 🔟 Event Hubs Namespace Overview ⭐⭐
**Navigate to**: Azure Portal > st10129307-eventhubs > Overview

**What to capture**:
- Event Hub name: ecommerce-events
- Status: Active
- Metrics showing incoming/outgoing messages
- Pricing tier

**Screenshot file name**: `10_event_hubs_overview.png`

---

### 1️⃣1️⃣ Event Hubs Metrics ⭐
**Navigate to**: Azure Portal > st10129307-eventhubs > Metrics

**What to capture**:
- Incoming messages chart
- Outgoing messages chart
- Time range: Last 1 hour
- Active connections

**Screenshot file name**: `11_event_hubs_metrics.png`

---

### 1️⃣2️⃣ Storage Account Overview ⭐
**Navigate to**: Azure Portal > st10129307storage2 > Overview

**What to capture**:
- Storage account name
- Performance: Standard
- Replication: LRS
- Status: Available

**Screenshot file name**: `12_storage_account_overview.png`

---

## 🌐 Web Application Screenshots

### 1️⃣3️⃣ Material Design Dashboard - Home ⭐⭐⭐
**Navigate to**: https://st10129307-personal.azurewebsites.net/index.html

**What to capture**:
- Professional Material Design interface
- Student information displayed
- All API endpoint cards visible
- Responsive layout

**Screenshot file name**: `13_webapp_dashboard.png`

---

### 1️⃣4️⃣ Web App - Health Check Response ⭐⭐
**Navigate to**: Dashboard > Click "Health Check" button

**What to capture**:
- Health status: "healthy"
- Service name displayed
- Student ID: ST10129307
- Timestamp shown
- Request count

**Screenshot file name**: `14_webapp_health_check.png`

---

### 1️⃣5️⃣ Web App - API Info Response ⭐⭐
**Navigate to**: Dashboard > Click "API Info" button

**What to capture**:
- System information
- List of available endpoints
- Student ID: ST10129307
- Timestamp

**Screenshot file name**: `15_webapp_api_info.png`

---

### 1️⃣6️⃣ Web App - Send Event Success ⭐⭐⭐
**Navigate to**: Dashboard > Fill event form > Click "Send Event"

**What to capture**:
- Event form filled with sample data
- Success response from API
- Event ID returned
- Status: "Processed"

**Screenshot file name**: `16_webapp_send_event.png`

---

### 1️⃣7️⃣ Swagger API Documentation ⭐⭐
**Navigate to**: https://st10129307-personal.azurewebsites.net/swagger

**What to capture**:
- Swagger UI interface
- List of all API endpoints
- GET/POST methods visible
- Models section

**Screenshot file name**: `17_swagger_documentation.png`

---

## 📊 Performance & Monitoring Screenshots

### 1️⃣8️⃣ App Service Metrics - CPU Usage ⭐⭐
**Navigate to**: Azure Portal > st10129307-personal > Metrics

**What to capture**:
- CPU Percentage over time
- Time range: Last 1 hour
- Any spike in usage (from load testing)
- Average CPU percentage

**Screenshot file name**: `18_app_service_cpu_metrics.png`

---

### 1️⃣9️⃣ App Service Metrics - Response Time ⭐⭐
**Navigate to**: Azure Portal > st10129307-personal > Metrics

**What to capture**:
- Average Response Time
- HTTP Server Errors (should be minimal/0)
- Http 2xx responses
- Time range: Last 1 hour

**Screenshot file name**: `19_app_service_response_time.png`

---

### 2️⃣0️⃣ Autoscaling History (Optional) ⭐
**Navigate to**: Azure Portal > st10129307-autoscale > Run history

**What to capture**:
- Scaling events (if any occurred)
- Instance count changes
- Timestamps of scaling operations
- Reason for scaling

**Screenshot file name**: `20_autoscaling_history.png`

---

## 🧪 Testing & Validation Screenshots

### 2️⃣1️⃣ Azure Portal - All Resources View ⭐
**Navigate to**: Azure Portal > All Resources > Filter by subscription

**What to capture**:
- Complete list of all resources
- Showing unified deployment
- Resource groups visible
- Status indicators

**Screenshot file name**: `21_all_resources_view.png`

---

### 2️⃣2️⃣ App Service Deployment Center ⭐
**Navigate to**: Azure Portal > st10129307-personal > Deployment Center

**What to capture**:
- Deployment method: External Git or Zip Deploy
- Deployment status: Success
- Last deployment time
- Deployment logs (if available)

**Screenshot file name**: `22_app_service_deployment.png`

---

### 2️⃣3️⃣ Function App Deployment Status ⭐
**Navigate to**: Azure Portal > st10129307-functions-personal > Deployment Center

**What to capture**:
- Deployment status: Success
- Last deployment timestamp
- Deployment source

**Screenshot file name**: `23_function_app_deployment.png`

---

## 💡 Tips for High-Quality Screenshots

### General Guidelines:
1. ✅ **Use full browser window** - Maximize browser for clarity
2. ✅ **Hide personal information** - Blur out email addresses if needed
3. ✅ **Use snipping tool** - Windows Snipping Tool (Win + Shift + S)
4. ✅ **Capture entire content** - Scroll and capture all relevant info
5. ✅ **Check resolution** - Ensure text is readable
6. ✅ **Consistent naming** - Follow the naming convention above
7. ✅ **Save as PNG** - Better quality than JPG for screenshots

### Azure Portal Navigation:
- Use search bar at top to quickly find resources
- Pin frequently accessed resources to dashboard
- Use breadcrumb navigation to go back

### Browser Developer Tools (F12):
- Use "Responsive Design Mode" to test mobile view
- Use "Network" tab to show API calls
- Use "Console" to show any errors (should be none)

---

## 📝 Screenshot Organization for Submission

### Recommended folder structure:
```
screenshots/
├── 01_azure_infrastructure/
│   ├── 01_resource_group_overview.png
│   ├── 02_app_service_overview.png
│   ├── 03_app_service_autoscaling.png
│   └── ...
├── 02_application_ui/
│   ├── 13_webapp_dashboard.png
│   ├── 14_webapp_health_check.png
│   └── ...
└── 03_monitoring/
    ├── 18_app_service_cpu_metrics.png
    ├── 19_app_service_response_time.png
    └── ...
```

---

## ✅ Verification Checklist

Before finalizing submission, verify:

- [ ] All 23 screenshots captured
- [ ] Screenshots are clear and readable
- [ ] No sensitive information exposed (passwords, keys)
- [ ] File names match the checklist
- [ ] Screenshots show "ST10129307" student ID where applicable
- [ ] All resources show "Running" or "Active" status
- [ ] Timestamps are recent (November 7, 2025)
- [ ] Web application is responsive and working
- [ ] API endpoints return successful responses

---

## 🚀 Quick Links for Screenshot Capture

**Azure Portal**: https://portal.azure.com  
**Resource Group**: https://portal.azure.com/#@/resource/subscriptions/f54cedd5-5651-48b3-b129-d2deb18e0183/resourceGroups/ST10129307-CLDV7112w-RG/overview  
**Web App**: https://st10129307-personal.azurewebsites.net  
**Dashboard**: https://st10129307-personal.azurewebsites.net/index.html  
**Swagger**: https://st10129307-personal.azurewebsites.net/swagger  

---

**Good luck with your screenshot capture and submission! 🎓**

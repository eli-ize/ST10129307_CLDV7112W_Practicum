# Theory Questions - CLDV7112w Practicum
**Student:** ST10129307  
**Module:** CLDV7112w Cloud Development B  
**Date:** November 7, 2025

---

## Question 1: Scaling Azure Applications vs IaaS-Based Applications

### Part A: Differences Between Scaling Azure PaaS Services and IaaS Applications

**Azure Platform-as-a-Service (PaaS) Scaling:**

Azure PaaS services like **Azure App Service**, **Azure Functions**, **SQL Database**, and **Event Hubs** provide **platform-level scaling** where the underlying infrastructure is abstracted away and managed by Microsoft. Scaling in PaaS is achieved through:

1. **Declarative Configuration**: Scaling rules are defined through Azure Portal, CLI, or ARM templates without managing the underlying virtual machines, networking, or storage infrastructure.

2. **Automatic Scaling**: Services automatically scale based on predefined metrics (CPU, memory, queue length, Event Hub partition backlog) without manual intervention in infrastructure provisioning.

3. **Granular Scaling Units**: 
   - **App Service**: Scales by adding/removing instances within an App Service Plan
   - **Azure Functions**: Scales dynamically based on event triggers (0 to 200 instances in Consumption Plan)
   - **SQL Database**: Scales compute (DTUs/vCores) and storage independently
   - **Event Hubs**: Scales throughput units or processing units

4. **Zero Downtime**: Scaling operations occur without application downtime or connection interruptions.

**IaaS (Infrastructure-as-a-Service) Scaling:**

In traditional IaaS models using **Virtual Machines**, scaling requires **infrastructure-level management**:

1. **Manual Infrastructure Provisioning**: Administrators must provision new VMs, configure networking, attach storage, install OS and application dependencies.

2. **Virtual Machine Scale Sets (VMSS)**: While Azure provides VMSS for IaaS automation, it still requires:
   - Custom VM images with pre-installed applications
   - Load balancer configuration
   - Network security group rules
   - Storage account management
   - OS patching and updates

3. **Application-Level Coordination**: Applications must be designed to handle new instances being added (session management, load distribution, health checks).

4. **Slower Scaling Response**: VM provisioning takes 3-5 minutes vs seconds for PaaS services.

**Key Differences:**

| Aspect | Azure PaaS (Managed Services) | IaaS (Self-Managed Infrastructure) |
|--------|-------------------------------|-------------------------------------|
| **Scaling Speed** | Seconds to add instances | Minutes to provision VMs |
| **Management Overhead** | Minimal - managed by platform | High - manual infrastructure management |
| **Infrastructure Visibility** | Abstracted (no VM access) | Full control over VMs and networking |
| **Scaling Granularity** | Service-specific units (instances, throughput) | VM-based (fixed sizes: D2v3, D4v3, etc.) |
| **Cost Model** | Pay for service units consumed | Pay for VM hours (running or stopped-allocated) |
| **Deployment Complexity** | Code-only deployment | OS + dependencies + code deployment |

---

### Part B: Platform-Level vs Infrastructure-Level Scaling Concepts

#### 1. Managed Services vs Self-Managed Infrastructure

**Azure PaaS Managed Services (Our Implementation):**

In our e-commerce real-time data processing system, we use fully managed Azure services:

- **Azure App Service**: Microsoft manages the underlying compute infrastructure, OS patching, runtime updates, load balancing, and SSL/TLS certificates. We only deploy application code and configure scaling rules.

- **Azure Functions (Consumption Plan)**: Completely serverless - Microsoft handles:
  - Automatic scaling from 0 to 200 instances based on Event Hub backlog
  - Event Hub trigger binding and partition management
  - Execution environment provisioning
  - Built-in monitoring and diagnostics
  
- **Azure SQL Database**: Fully managed relational database where Microsoft handles:
  - Automated backups and point-in-time restore
  - High availability and geo-replication
  - Performance tuning recommendations
  - Automatic patching and version upgrades
  
- **Azure Event Hubs**: Managed streaming platform where Microsoft manages:
  - Partition distribution and rebalancing
  - Message retention and storage
  - Throughput unit scaling
  - Built-in capture to Azure Storage/Data Lake

**Benefits of Managed Services:**
- **Reduced Operational Overhead**: No need for dedicated DevOps team for infrastructure
- **Built-in Security**: Automatic security patches and compliance certifications
- **SLA Guarantees**: Microsoft provides 99.95% uptime SLAs
- **Focus on Business Logic**: Developers focus on application code, not infrastructure

**IaaS Self-Managed Infrastructure:**

In an IaaS model, we would need to:

- **Provision and Configure VMs**: Deploy Windows/Linux VMs, install web servers (IIS/Nginx), configure firewalls
- **Implement Load Balancing**: Set up Azure Load Balancer or Application Gateway manually
- **Manage Databases**: Install SQL Server on VMs, configure Always On Availability Groups for HA
- **Build Event Processing**: Implement Kafka/RabbitMQ clusters on VMs, manage brokers and ZooKeeper
- **Maintain Infrastructure**: Apply OS patches, monitor disk space, manage backups, handle failures

**Drawbacks of Self-Managed Infrastructure:**
- **High Operational Cost**: Requires skilled infrastructure engineers
- **Slower Innovation**: Time spent on infrastructure instead of features
- **Higher Risk**: Human error in configuration can cause outages
- **Complexity at Scale**: Managing 100+ VMs becomes exponentially complex

---

#### 2. Impact on Deployment

**Azure PaaS Deployment (Our Implementation):**

```bash
# Deploy Web App - Single command
az webapp up --name st10129307 --runtime "DOTNETCORE:8.0"

# Deploy Azure Functions - Single command
func azure functionapp publish st10129307-functions

# Configure autoscaling - Declarative
az monitor autoscale create --resource st10129307 \
  --min-count 1 --max-count 3 \
  --count 1
```

**Deployment Characteristics:**
- **Code-Centric**: Only application code is deployed, runtime is managed
- **Continuous Deployment**: Integrated with GitHub Actions, Azure DevOps
- **Zero-Downtime Deployment**: Slot-based deployments with traffic shifting
- **Rollback**: One-click rollback to previous versions
- **Configuration Management**: App Settings stored separately from code

**IaaS Deployment:**

```bash
# Create VM Scale Set
az vmss create --name ecommerce-vmss --image Ubuntu2204 --instance-count 1

# Install dependencies on each VM
- Install .NET 8 Runtime
- Install Nginx/Apache
- Configure reverse proxy
- Copy application files
- Configure systemd service
- Configure health checks

# Update application
- Create new VM image with updated code
- Update VMSS model
- Perform rolling update (takes 10-20 minutes)
```

**Deployment Characteristics:**
- **Infrastructure-Heavy**: Must manage OS, dependencies, and application
- **Custom Images**: Requires maintaining VM images with baked-in dependencies
- **Slower Deployments**: Image creation and VM updates take significant time
- **Manual Rollback**: Complex rollback procedures involving image versioning
- **Configuration Drift**: Each VM may have slightly different configurations

---

#### 3. Impact on Management

**Azure PaaS Management (Our Implementation):**

**Monitoring:**
- **Built-in Application Insights**: Automatic instrumentation for performance monitoring
- **Azure Monitor**: Centralized metrics, logs, and alerts across all services
- **Service Health Dashboard**: Real-time service health and planned maintenance notifications

**Scaling Management:**
```json
// Autoscale Configuration (Declarative)
{
  "profiles": [{
    "capacity": { "minimum": "1", "maximum": "3", "default": "1" },
    "rules": [
      {
        "metricTrigger": { "metricName": "CpuPercentage", "threshold": 70 },
        "scaleAction": { "direction": "Increase", "value": "1" }
      },
      {
        "metricTrigger": { "metricName": "CpuPercentage", "threshold": 25 },
        "scaleAction": { "direction": "Decrease", "value": "1" }
      }
    ]
  }]
}
```

**Management Tasks:**
- Monitor metrics dashboards
- Adjust scaling thresholds based on performance
- Review cost optimization recommendations
- Update application settings (connection strings, feature flags)
- No OS patching, no infrastructure maintenance

**IaaS Management:**

**Infrastructure Tasks:**
- **OS Patching**: Schedule and apply Windows/Linux updates across all VMs
- **Capacity Planning**: Manually calculate and provision VM sizes
- **Load Balancer Management**: Configure health probes, backend pools, routing rules
- **Storage Management**: Monitor disk usage, attach additional disks
- **Networking**: Manage NSGs, VNets, subnets, private IPs
- **Backup Management**: Configure and test VM backups
- **Disaster Recovery**: Implement and test DR procedures

**Scaling Management:**
```bash
# Manual scaling - requires multiple steps
az vmss scale --new-capacity 3 --name ecommerce-vmss

# Monitor each VM individually
az vm list --query "[].{Name:name, State:powerState}"

# Custom health checks
- Implement health check endpoints
- Configure load balancer probes
- Handle failed instances manually
```

**Management Overhead Comparison:**
- **PaaS**: 2-3 hours/week for monitoring and optimization
- **IaaS**: 20-30 hours/week for infrastructure maintenance

---

#### 4. Impact on Cost

**Azure PaaS Cost Model (Our Implementation):**

**App Service (st10129307-appplan - B1 Basic):**
- **Cost**: ~$13/month (1 instance) to ~$39/month (3 instances when scaled)
- **Included**: Compute, storage, bandwidth, SSL certificates, auto-scaling, monitoring
- **Billing**: Per-second billing, only pay when instances are running
- **Optimization**: Scale in aggressively during low traffic (CPU < 25%)

**Azure Functions (st10129307-functions - Consumption Plan):**
- **Cost**: Pay-per-execution + execution time
  - First 1 million executions: Free
  - $0.20 per million executions thereafter
  - $0.000016/GB-s execution time
- **Example**: 10 million events/month ≈ $2-5/month
- **Benefit**: True pay-as-you-go, scales to zero when no events

**Azure SQL Database (Basic Tier):**
- **Cost**: ~$5/month for 5 DTU, 2GB storage
- **Included**: Automated backups, geo-replication options, built-in HA
- **Scaling**: Scale up to Standard/Premium as needed (DTU-based or vCore-based)

**Azure Event Hubs (Basic Tier):**
- **Cost**: ~$11/month base + $0.028 per million events
- **Included**: 2 partitions, 1-day retention, 1 throughput unit
- **Scaling**: Add throughput units as message volume increases

**Total Monthly Cost (PaaS):**
- **Low Traffic**: ~$31/month (1 App Service instance + Functions minimal use)
- **High Traffic**: ~$60/month (3 App Service instances + higher Functions/Event Hubs usage)
- **Peak Load**: Temporary cost increase only during load, scales back automatically

---

**IaaS Cost Model (Equivalent Infrastructure):**

**Web Application VMs (2x D2v3 VMs with Load Balancer):**
- **VMs**: 2 x $70/month = $140/month (running 24/7)
- **Load Balancer**: $18/month
- **Storage**: 2 x 128GB SSD = $20/month
- **Public IP**: $4/month
- **Total**: ~$182/month (fixed cost, even during low traffic)

**Database VM (1x D2v3 with SQL Server):**
- **VM**: $70/month
- **SQL Server License**: $50-200/month (depends on edition)
- **Storage**: Premium SSD 256GB = $30/month
- **Backup Storage**: $10/month
- **Total**: ~$160-310/month

**Message Broker (Kafka on 3x D2v3 VMs for HA):**
- **VMs**: 3 x $70/month = $210/month
- **Storage**: 3 x 256GB SSD = $60/month
- **Total**: ~$270/month

**Total Monthly Cost (IaaS):**
- **Minimum**: ~$612-762/month (always running, regardless of load)
- **Cannot Scale to Zero**: Fixed costs even with zero traffic
- **Hidden Costs**: 
  - DevOps engineer salary: $60-120k/year
  - Monitoring tools: $50-200/month
  - Backup solutions: $30-100/month

**Cost Comparison:**

| Scenario | PaaS Cost | IaaS Cost | Savings |
|----------|-----------|-----------|---------|
| **Low Traffic** | $31/month | $612/month | 95% cheaper |
| **High Traffic** | $60/month | $612/month | 90% cheaper |
| **Peak Load** | $100/month (temporary) | $612/month+ | 84% cheaper |
| **Annual** | $372-720/year | $7,344/year | 90% cheaper |

**Additional PaaS Benefits:**
- **No upfront costs**: No VM reservation required
- **Automatic optimization**: Azure provides cost optimization recommendations
- **Dev/Test pricing**: Discounted rates for non-production environments
- **Reserved instances**: Further savings with 1-3 year commitments (if needed)

---

### Part C: Comparison Table - Azure PaaS vs Traditional IaaS Scaling

| Aspect | Azure App Service (PaaS) | Azure Functions (PaaS) | Azure SQL Database (PaaS) | Azure Event Hubs (PaaS) | IaaS VMs with Custom Apps |
|--------|--------------------------|------------------------|---------------------------|-------------------------|---------------------------|
| **Scaling Model** | Horizontal (add instances) | Dynamic (0-200 instances) | Vertical (DTUs/vCores) | Throughput units | Manual VMSS scaling |
| **Scaling Speed** | 30-60 seconds | 10-20 seconds | 5-30 seconds | Instant | 3-5 minutes |
| **Scaling Triggers** | CPU, Memory, HTTP Queue | Event Hub backlog, Timer | Query performance, DTU % | Incoming message rate | Custom metrics via Azure Monitor |
| **Minimum Instances** | 1 (can't scale to zero) | 0 (true serverless) | 1 (always-on database) | N/A (always-on namespace) | 1 VM minimum |
| **Maximum Instances** | Up to 30 (Premium tier) | 200 (Consumption), unlimited (Premium) | N/A (scales vertically) | 40 throughput units (Auto-inflate) | Limited by quota/subnet size |
| **Infrastructure Access** | None (abstracted) | None (fully managed) | None (managed DB) | None (managed streaming) | Full VM access (SSH/RDP) |
| **Deployment Method** | Git, ZIP, Container | CLI, VS Code, CI/CD | SSMS, Azure Portal, CLI | Portal, CLI, SDK | Custom scripts, Ansible, Terraform |
| **Configuration Management** | App Settings (Key Vault) | Function App Settings | Connection strings, firewall | Access policies, SAS tokens | VM environment variables, config files |
| **Monitoring** | Built-in App Insights | Built-in telemetry | Query Performance Insight | Built-in metrics dashboard | Custom (Prometheus, Grafana, etc.) |
| **Patching/Updates** | Automatic (zero downtime) | Automatic (Microsoft managed) | Automatic (maintenance windows) | Automatic (transparent) | Manual (requires reboot) |
| **High Availability** | Built-in (99.95% SLA) | Built-in (multi-zone) | Built-in (geo-replication) | Built-in (zone redundancy) | Manual (availability sets, zones) |
| **Backup/DR** | Automatic daily backups | N/A (stateless) | Automated backups (PITR) | Built-in capture feature | Custom scripts, Azure Backup |
| **Cost Model** | Per-instance-hour | Per-execution + GB-s | Per-DTU or vCore-hour | Per-throughput unit + ingress | Per-VM-hour (always running) |
| **Cost at Zero Load** | Minimum 1 instance cost | $0 (scales to zero) | Minimum DB cost | Base namespace cost | Full VM cost (no scale to zero) |
| **Typical Monthly Cost** | $13-39 (B1: 1-3 instances) | $2-10 (1M-10M executions) | $5-50 (Basic to Standard) | $11-40 (1-2 throughput units) | $210-700 (3-10 VMs) |
| **Management Overhead** | 2-3 hours/week | 1 hour/week | 1-2 hours/week | 1 hour/week | 20-40 hours/week |
| **Expertise Required** | Application development | Application + event-driven patterns | SQL development | Event streaming concepts | Infrastructure + networking + security + OS |
| **Time to Production** | Hours | Minutes | Minutes | Minutes | Weeks (infrastructure setup) |
| **Scaling Automation** | Built-in autoscale rules | Automatic event-driven | Manual or elastic pool | Auto-inflate enabled | Custom VMSS autoscale rules |
| **Load Balancing** | Built-in (automatic) | Built-in (event partitioning) | N/A (single endpoint) | Partition-based distribution | Manual (Azure LB/App Gateway) |
| **Session Affinity** | ARR affinity cookies | Stateless (by design) | Connection pooling | Partition key-based | Manual sticky sessions |
| **Cold Start** | None (always warm) | 5-10 seconds (Consumption) | None | None | None (VMs always running) |
| **Best Use Case** | Web apps, APIs | Event processing, background jobs | Transactional data | Real-time streaming | Legacy apps, full control needed |

---

### Summary: Why We Chose Azure PaaS for Our E-Commerce System

Based on the comparison above, our e-commerce real-time data processing system uses **Azure PaaS services** because:

1. **Faster Time to Market**: Deployed in hours vs weeks with IaaS
2. **Cost Efficiency**: 90% cheaper than equivalent IaaS infrastructure
3. **Automatic Scaling**: Handles Black Friday traffic spikes without manual intervention
4. **Built-in HA/DR**: 99.95% SLA without complex setup
5. **Developer Productivity**: Focus on business logic, not infrastructure
6. **Security**: Automatic patching and compliance certifications
7. **Operational Simplicity**: 2-3 hours/week management vs 20-40 hours with IaaS

**When to Consider IaaS:**
- Legacy applications requiring specific OS configurations
- Applications needing kernel-level access or custom drivers
- Regulatory requirements for full infrastructure control
- Lift-and-shift migrations from on-premises

For modern cloud-native applications like our real-time data processing system, **Azure PaaS provides superior scalability, cost efficiency, and operational simplicity** compared to traditional IaaS models.

---

## Question 2: Azure App Service Autoscaling

### Explain the different autoscaling metrics available in Azure App Service and their use cases.

**Answer:**

Azure App Service provides several autoscaling metrics that can be used to automatically adjust the number of instances based on application demand:

#### CPU-based Scaling
- **Metric**: CPU Percentage
- **Use Case**: General-purpose scaling for CPU-intensive applications
- **Threshold Example**: Scale out when CPU > 70%, scale in when CPU < 25%
- **Advantages**: Simple to configure, works for most applications
- **Considerations**: May not reflect actual user load for I/O intensive applications

#### Memory-based Scaling
- **Metric**: Memory Percentage
- **Use Case**: Applications with high memory requirements or memory leaks
- **Threshold Example**: Scale out when Memory > 80%
- **Advantages**: Prevents out-of-memory errors
- **Considerations**: Memory cleanup may not immediately trigger scale-in

#### Request-based Scaling
- **Metric**: HTTP Queue Length
- **Use Case**: Applications with varying request patterns
- **Threshold Example**: Scale out when queue length > 100 requests
- **Advantages**: Directly correlates with user experience
- **Considerations**: May cause frequent scaling for bursty traffic

#### Custom Metrics
- **Examples**: Application-specific metrics via Application Insights
- **Use Case**: Business-specific scaling requirements
- **Implementation**: Custom telemetry collection and threshold definition

## Question 2: Event-Driven Architecture with Azure Event Hubs

### Compare Azure Event Hubs with Azure Service Bus for real-time data processing scenarios.

**Answer:**

| Aspect | Azure Event Hubs | Azure Service Bus |
|--------|------------------|-------------------|
| **Purpose** | High-throughput event streaming | Enterprise messaging |
| **Message Size** | Up to 1 MB | Up to 256 KB (Standard), 1 MB (Premium) |
| **Throughput** | Very high (millions of events/sec) | Moderate (thousands of messages/sec) |
| **Ordering** | Partition-level ordering | Session-based ordering |
| **Delivery** | At-least-once | At-least-once, Exactly-once |
| **Retention** | Time-based (1-7 days) | Message-based until consumed |
| **Use Cases** | IoT telemetry, logs, analytics | Request/response, workflows |

**For E-Commerce Real-Time Processing:**
Event Hubs is preferred because:
- High volume of user interactions
- Need for real-time analytics
- Partition-based scaling
- Cost-effective for streaming scenarios

## Question 3: Cosmos DB Scaling and Performance

### Discuss the different scaling options in Azure Cosmos DB and their impact on performance and cost.

**Answer:**

#### Provisioned Throughput
- **Configuration**: Fixed Request Units (RU/s)
- **Performance**: Predictable, guaranteed throughput
- **Cost**: Fixed cost regardless of usage
- **Use Case**: Steady, predictable workloads
- **Scaling**: Manual or autoscale between min/max RU/s

#### Serverless
- **Configuration**: Pay-per-request consumption
- **Performance**: Variable based on demand
- **Cost**: Only pay for consumed RU/s
- **Use Case**: Intermittent or unpredictable workloads
- **Limitations**: 5,000 RU/s maximum, single region

#### Autoscale
- **Configuration**: Dynamic scaling between min/max RU/s
- **Performance**: Automatic adjustment to demand
- **Cost**: Balance between provisioned and serverless
- **Use Case**: Variable workloads with some predictability
- **Benefits**: Automatic scaling without performance degradation

**For E-Commerce Application:**
Serverless mode is chosen because:
- Variable traffic patterns during sales events
- Cost optimization during low-traffic periods
- Automatic scaling without management overhead

## Question 4: Azure Functions Scaling Behavior

### Explain how Azure Functions scaling works in different hosting plans and its implications for real-time processing.

**Answer:**

#### Consumption Plan
- **Scaling**: Event-driven, automatic
- **Cold Start**: 5-10 seconds for first request
- **Maximum Instances**: 200 (default)
- **Timeout**: 5 minutes maximum
- **Best For**: Event processing, short-running tasks

#### Premium Plan
- **Scaling**: Pre-warmed instances + dynamic scaling
- **Cold Start**: Eliminated with always-ready instances
- **Maximum Instances**: 100 (default)
- **Timeout**: 30 minutes (or unlimited)
- **Best For**: Long-running processes, predictable load

#### Dedicated Plan
- **Scaling**: Manual or autoscale rules
- **Cold Start**: None (always running)
- **Maximum Instances**: Based on App Service Plan
- **Timeout**: No limit
- **Best For**: Consistent load, existing App Service integration

**For Event Hub Processing:**
Consumption Plan is optimal because:
- Automatic scaling based on Event Hub message backlog
- Cost-effective for variable event loads
- Built-in integration with Event Hub triggers
- No infrastructure management required

## Question 5: Performance Optimization Strategies

### Describe key performance optimization strategies for a real-time data processing system in Azure.

**Answer:**

#### Application Level Optimizations
1. **Batch Processing**: Process multiple events together to reduce overhead
2. **Async/Await Pattern**: Use asynchronous programming for I/O operations
3. **Connection Pooling**: Reuse database and service connections
4. **Caching**: Implement in-memory caching for frequently accessed data

#### Database Optimizations
1. **Partitioning Strategy**: Design optimal partition keys for Cosmos DB
2. **Indexing**: Create appropriate indexes for query patterns
3. **Bulk Operations**: Use bulk insert/upsert for high throughput
4. **Connection Settings**: Optimize connection mode and consistency levels

#### Infrastructure Optimizations
1. **Resource Colocation**: Deploy resources in same region/availability zone
2. **Scaling Configuration**: Set appropriate scaling thresholds and rules
3. **Resource Sizing**: Right-size compute resources based on workload
4. **Network Optimization**: Use private endpoints and service endpoints

#### Monitoring and Alerting
1. **Application Insights**: Monitor application performance and dependencies
2. **Custom Metrics**: Track business-specific performance indicators
3. **Alerting Rules**: Set up proactive alerts for performance degradation
4. **Dashboard Creation**: Create real-time monitoring dashboards

## Question 6: Cost Optimization in Azure

### Discuss strategies for optimizing costs while maintaining performance in an Azure-based real-time processing system.

**Answer:**

#### Right-Sizing Resources
- **App Service Plans**: Use appropriate SKUs based on requirements
- **Function Apps**: Choose optimal hosting plans (Consumption vs Premium)
- **Cosmos DB**: Select appropriate throughput models (Serverless vs Provisioned)

#### Scaling Strategies
- **Horizontal Scaling**: Scale out rather than up when possible
- **Scheduled Scaling**: Pre-scale for known traffic patterns
- **Aggressive Scale-In**: Quick scale-down during low traffic periods

#### Reserved Capacity
- **App Service Reserved Instances**: 1-3 year commitments for predictable workloads
- **Cosmos DB Reserved Capacity**: Significant savings for steady throughput requirements

#### Monitoring and Optimization
- **Cost Management**: Regular review of resource utilization and costs
- **Unused Resources**: Identify and remove unused or oversized resources
- **Dev/Test Pricing**: Use development subscriptions for non-production environments

#### Architecture Optimizations
- **Serverless First**: Use serverless services where appropriate
- **Managed Services**: Prefer PaaS over IaaS to reduce operational overhead
- **Data Lifecycle**: Implement data retention and archival policies

These strategies ensure cost-effectiveness while maintaining the performance and scalability requirements of the real-time data processing system.
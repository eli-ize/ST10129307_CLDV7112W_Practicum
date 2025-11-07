using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace ECommerceApp.Services
{
    /// <summary>
    /// Health check for Azure SQL Database service
    /// </summary>
    public class SqlDatabaseHealthCheck : IHealthCheck
    {
        private readonly ISqlDatabaseService _sqlDatabaseService;

        public SqlDatabaseHealthCheck(ISqlDatabaseService sqlDatabaseService)
        {
            _sqlDatabaseService = sqlDatabaseService;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Test real SQL Database connection
                var isConnected = await _sqlDatabaseService.TestConnectionAsync();
                
                return isConnected 
                    ? HealthCheckResult.Healthy("SQL Database is responsive") 
                    : HealthCheckResult.Degraded("SQL Database connection test failed");
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy("SQL Database is not responsive", ex);
            }
        }
    }

    /// <summary>
    /// Health check for Event Hub service
    /// </summary>
    public class EventHubHealthCheck : IHealthCheck
    {
        private readonly IEventHubService _eventHubService;

        public EventHubHealthCheck(IEventHubService eventHubService)
        {
            _eventHubService = eventHubService;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Test real Event Hub connection
                var isConnected = await _eventHubService.TestConnectionAsync();
                
                return isConnected 
                    ? HealthCheckResult.Healthy("Event Hub is responsive") 
                    : HealthCheckResult.Degraded("Event Hub connection test failed");
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy("Event Hub is not responsive", ex);
            }
        }
    }
}
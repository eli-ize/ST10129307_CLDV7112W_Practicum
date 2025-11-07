using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using System.Text.Json;
using Microsoft.Data.SqlClient;

namespace ECommerceDataProcessor
{
    /// <summary>
    /// Azure Function triggered by Event Hub events
    /// Processes e-commerce events and stores them in SQL Database
    /// </summary>
    public class EventProcessor
    {
        private readonly ILogger<EventProcessor> _logger;
        private readonly string _sqlConnectionString;

        public EventProcessor(ILogger<EventProcessor> logger, IConfiguration configuration)
        {
            _logger = logger;
            _sqlConnectionString = configuration.GetConnectionString("SqlDatabase") 
                ?? throw new InvalidOperationException("SqlDatabase connection string not configured");
        }

        /// <summary>
        /// Process events from Event Hub
        /// Triggered automatically when events arrive
        /// </summary>
        [Function("ProcessECommerceEvents")]
        public async Task Run(
            [EventHubTrigger("ecommerce-events", Connection = "EventHubConnection")] string[] events)
        {
            _logger.LogInformation($"Processing {events.Length} events from Event Hub");

            foreach (var eventData in events)
            {
                try
                {
                    // Log the event
                    _logger.LogInformation($"Processing event: {eventData}");

                    // Parse the event
                    var eventObj = JsonSerializer.Deserialize<JsonElement>(eventData);
                    
                    // Save to SQL Database
                    await SaveToSqlDatabaseAsync(eventData, eventObj);
                    
                    _logger.LogInformation($"Event processed successfully");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error processing event: {eventData}");
                    // Continue processing other events even if one fails
                }
            }
        }

        /// <summary>
        /// Save processed event to SQL Database
        /// </summary>
        private async Task SaveToSqlDatabaseAsync(string rawEvent, JsonElement eventObj)
        {
            try
            {
                using var connection = new SqlConnection(_sqlConnectionString);
                await connection.OpenAsync();

                // Ensure table exists
                await EnsureTableExistsAsync(connection);

                // Extract event properties
                var eventType = eventObj.TryGetProperty("eventType", out var type) 
                    ? type.GetString() ?? "Unknown" 
                    : "Unknown";
                
                var timestamp = eventObj.TryGetProperty("timestamp", out var ts) 
                    ? ts.GetString() ?? DateTime.UtcNow.ToString("o")
                    : DateTime.UtcNow.ToString("o");

                // Insert into database
                var insertSql = @"
                    INSERT INTO ProcessedEvents (EventType, EventData, ProcessedAt, RawData)
                    VALUES (@EventType, @EventData, @ProcessedAt, @RawData)";

                using var command = new SqlCommand(insertSql, connection);
                command.Parameters.AddWithValue("@EventType", eventType);
                command.Parameters.AddWithValue("@EventData", rawEvent);
                command.Parameters.AddWithValue("@ProcessedAt", DateTime.UtcNow);
                command.Parameters.AddWithValue("@RawData", rawEvent);

                await command.ExecuteNonQueryAsync();
                
                _logger.LogInformation($"Saved event to SQL Database: {eventType}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving to SQL Database");
                throw;
            }
        }

        /// <summary>
        /// Create ProcessedEvents table if it doesn't exist
        /// </summary>
        private async Task EnsureTableExistsAsync(SqlConnection connection)
        {
            var createTableSql = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProcessedEvents')
                BEGIN
                    CREATE TABLE ProcessedEvents (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        EventType NVARCHAR(100),
                        EventData NVARCHAR(MAX),
                        ProcessedAt DATETIME2 DEFAULT GETDATE(),
                        RawData NVARCHAR(MAX),
                        INDEX IX_EventType (EventType),
                        INDEX IX_ProcessedAt (ProcessedAt)
                    )
                END";

            using var command = new SqlCommand(createTableSql, connection);
            await command.ExecuteNonQueryAsync();
        }
    }
}

using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using System.Text;
using System.Text.Json;

namespace ECommerceApp.Services
{
    /// <summary>
    /// Service for sending events to Azure Event Hub
    /// </summary>
    public interface IEventHubService
    {
        Task SendEventAsync(object eventData);
        Task<bool> TestConnectionAsync();
    }

    /// <summary>
    /// Real Event Hub Service implementation
    /// Connects to Azure Event Hubs for real-time data ingestion
    /// </summary>
    public class EventHubService : IEventHubService
    {
        private readonly EventHubProducerClient? _producerClient;
        private readonly ILogger<EventHubService> _logger;
        private readonly bool _isConfigured;

        public EventHubService(IConfiguration configuration, ILogger<EventHubService> logger)
        {
            _logger = logger;
            _isConfigured = false;
            
            try
            {
                var connectionString = configuration["EventHubs:ConnectionString"];
                var eventHubName = configuration["EventHubs:EventHubName"];
                
                if (string.IsNullOrEmpty(connectionString) || string.IsNullOrEmpty(eventHubName))
                {
                    _logger.LogWarning("Event Hubs not configured. Service will run in degraded mode.");
                    return;
                }
                
                _producerClient = new EventHubProducerClient(connectionString, eventHubName);
                _isConfigured = true;
                _logger.LogInformation("Event Hub Producer Client initialized for: {EventHubName}", eventHubName);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to initialize Event Hub Producer Client at startup. Service will run in degraded mode.");
            }
        }

        public async Task SendEventAsync(object eventData)
        {
            if (!_isConfigured || _producerClient == null)
            {
                _logger.LogWarning("Event Hub not configured. Event not sent.");
                return;
            }
            
            try
            {
                using EventDataBatch eventBatch = await _producerClient.CreateBatchAsync();
                
                var eventDataJson = JsonSerializer.Serialize(eventData);
                var eventBody = new EventData(Encoding.UTF8.GetBytes(eventDataJson));
                
                if (!eventBatch.TryAdd(eventBody))
                {
                    throw new Exception("Event is too large for the batch");
                }
                
                await _producerClient.SendAsync(eventBatch);
                _logger.LogInformation("Event sent to Event Hub successfully: {DataSize} bytes", 
                    eventDataJson.Length);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending event to Event Hub");
                throw;
            }
        }

        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                var properties = await _producerClient.GetEventHubPropertiesAsync();
                _logger.LogInformation("Event Hub connection successful. Name: {Name}, PartitionCount: {Count}", 
                    properties.Name, properties.PartitionIds.Length);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Event Hub connection failed");
                return false;
            }
        }
    }
}
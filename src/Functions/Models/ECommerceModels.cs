using System.Text.Json;

namespace ECommerceDataProcessor.Models
{
    /// <summary>
    /// Represents raw e-commerce event data received from Event Hubs
    /// </summary>
    public class ECommerceEvent
    {
        public string EventId { get; set; } = string.Empty;
        public string EventType { get; set; } = string.Empty; // PageView, Purchase, AddToCart, etc.
        public string UserId { get; set; } = string.Empty;
        public string SessionId { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
        public string ProductId { get; set; } = string.Empty;
        public string CategoryId { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string Currency { get; set; } = "USD";
        public string Source { get; set; } = string.Empty; // Web, Mobile, API
        public Dictionary<string, object> Metadata { get; set; } = new();
    }

    /// <summary>
    /// Represents processed data to be stored in Cosmos DB
    /// </summary>
    public class ProcessedECommerceData
    {
        public string id { get; set; } = Guid.NewGuid().ToString();
        public string PartitionKey { get; set; } = string.Empty;
        public string EventId { get; set; } = string.Empty;
        public string EventType { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string SessionId { get; set; } = string.Empty;
        public DateTime ProcessedTimestamp { get; set; } = DateTime.UtcNow;
        public DateTime OriginalTimestamp { get; set; }
        public ProductInfo Product { get; set; } = new();
        public UserSession Session { get; set; } = new();
        public PerformanceMetrics Metrics { get; set; } = new();
        public string ProcessingStatus { get; set; } = "Processed";
    }

    /// <summary>
    /// Product information extracted and enriched from the event
    /// </summary>
    public class ProductInfo
    {
        public string ProductId { get; set; } = string.Empty;
        public string CategoryId { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string Currency { get; set; } = "USD";
        public decimal TotalValue { get; set; }
    }

    /// <summary>
    /// User session information for analytics
    /// </summary>
    public class UserSession
    {
        public string SessionId { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string Source { get; set; } = string.Empty;
        public int EventCount { get; set; }
        public TimeSpan SessionDuration { get; set; }
    }

    /// <summary>
    /// Performance metrics for monitoring and optimization
    /// </summary>
    public class PerformanceMetrics
    {
        public double ProcessingTimeMs { get; set; }
        public string FunctionInstanceId { get; set; } = Environment.MachineName;
        public int BatchSize { get; set; }
        public DateTime ProcessingStartTime { get; set; }
        public DateTime ProcessingEndTime { get; set; }
    }
}
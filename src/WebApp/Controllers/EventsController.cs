using Microsoft.AspNetCore.Mvc;

namespace ECommerceApp.Controllers
{
    /// <summary>
    /// API Controller for e-commerce events and data generation
    /// Demonstrates real-time data processing for the CLDV7112w practicum
    /// </summary>
    [ApiController]
    [Route("api")]
    public class EventsController : ControllerBase
    {
        private readonly ILogger<EventsController> _logger;
        private static int _requestCount = 0;
        private static readonly Random _random = new();

        public EventsController(ILogger<EventsController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Health check endpoint for monitoring
        /// </summary>
        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                service = "E-Commerce Real-Time Processing System",
                student = "ST10129307",
                module = "CLDV7112w",
                requestsProcessed = _requestCount
            });
        }

        /// <summary>
        /// Generate load for autoscaling testing
        /// This endpoint performs CPU-intensive operations to trigger autoscaling
        /// </summary>
        [HttpGet("generate-load")]
        public IActionResult GenerateLoad([FromQuery] int intensity = 5)
        {
            _logger.LogInformation("Generating load with intensity: {Intensity}", intensity);
            
            var startTime = DateTime.UtcNow;
            
            // CPU-intensive operation to trigger autoscaling
            double result = 0;
            for (int i = 0; i < intensity * 1000000; i++)
            {
                result += Math.Sqrt(i) * Math.Sin(i) * Math.Cos(i);
            }
            
            var endTime = DateTime.UtcNow;
            var duration = (endTime - startTime).TotalMilliseconds;

            Interlocked.Increment(ref _requestCount);

            return Ok(new
            {
                message = "Load generated successfully",
                intensity,
                durationMs = duration,
                result = result.ToString("F2"),
                timestamp = DateTime.UtcNow,
                requestNumber = _requestCount
            });
        }

        /// <summary>
        /// Receive e-commerce events for processing
        /// </summary>
        [HttpPost("events")]
        public IActionResult PostEvent([FromBody] ECommerceEvent eventData)
        {
            _logger.LogInformation("Received event: {EventType} from user {UserId}", 
                eventData.EventType, eventData.UserId);

            Interlocked.Increment(ref _requestCount);

            // Simulate processing
            var processedData = new
            {
                eventId = eventData.EventId,
                eventType = eventData.EventType,
                userId = eventData.UserId,
                processedAt = DateTime.UtcNow,
                status = "Processed",
                requestNumber = _requestCount
            };

            return Ok(processedData);
        }

        /// <summary>
        /// Get system statistics
        /// </summary>
        [HttpGet("stats")]
        public IActionResult GetStats()
        {
            return Ok(new
            {
                totalRequests = _requestCount,
                uptime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss"),
                systemInfo = new
                {
                    processorCount = Environment.ProcessorCount,
                    osVersion = Environment.OSVersion.ToString(),
                    machineName = Environment.MachineName,
                    workingSet = Environment.WorkingSet / 1024 / 1024 + " MB"
                }
            });
        }

        /// <summary>
        /// Simulate page view events
        /// </summary>
        [HttpGet("simulate/pageview")]
        public IActionResult SimulatePageView()
        {
            var eventData = new
            {
                eventId = Guid.NewGuid().ToString(),
                eventType = "PageView",
                userId = $"user_{_random.Next(1, 1000)}",
                productId = $"product_{_random.Next(1, 100)}",
                timestamp = DateTime.UtcNow,
                sessionId = Guid.NewGuid().ToString()
            };

            Interlocked.Increment(ref _requestCount);
            _logger.LogInformation("Simulated PageView event");

            return Ok(eventData);
        }

        /// <summary>
        /// Stress test endpoint - for testing autoscaling
        /// </summary>
        [HttpGet("stress-test")]
        public async Task<IActionResult> StressTest([FromQuery] int duration = 10)
        {
            _logger.LogInformation("Starting stress test for {Duration} seconds", duration);
            
            var startTime = DateTime.UtcNow;
            var iterations = 0;
            
            while ((DateTime.UtcNow - startTime).TotalSeconds < duration)
            {
                // CPU-intensive operations
                double result = 0;
                for (int i = 0; i < 100000; i++)
                {
                    result += Math.Sqrt(i) * Math.Log(i + 1);
                }
                iterations++;
                await Task.Delay(10); // Small delay to prevent complete lockup
            }

            Interlocked.Increment(ref _requestCount);

            return Ok(new
            {
                message = "Stress test completed",
                durationSeconds = duration,
                iterations,
                timestamp = DateTime.UtcNow
            });
        }
    }

    /// <summary>
    /// E-Commerce event model
    /// </summary>
    public class ECommerceEvent
    {
        public string EventId { get; set; } = Guid.NewGuid().ToString();
        public string EventType { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string SessionId { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
        public string ProductId { get; set; } = string.Empty;
        public string CategoryId { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string Currency { get; set; } = "USD";
        public string Source { get; set; } = string.Empty;
    }
}
namespace ECommerceApp.Services
{
    /// <summary>
    /// Service for generating test data for load testing
    /// </summary>
    public interface IDataGeneratorService
    {
        object GenerateECommerceEvent();
        IEnumerable<object> GenerateBulkEvents(int count);
    }

    /// <summary>
    /// Data generator for creating realistic e-commerce events
    /// </summary>
    public class DataGeneratorService : IDataGeneratorService
    {
        private static readonly Random _random = new();
        private static readonly string[] _eventTypes = { "PageView", "AddToCart", "Purchase", "Search", "Review" };
        private static readonly string[] _categories = { "Electronics", "Clothing", "Books", "Home", "Sports" };

        public object GenerateECommerceEvent()
        {
            return new
            {
                eventId = Guid.NewGuid().ToString(),
                eventType = _eventTypes[_random.Next(_eventTypes.Length)],
                userId = $"user_{_random.Next(1, 1000)}",
                sessionId = Guid.NewGuid().ToString(),
                timestamp = DateTime.UtcNow,
                productId = $"product_{_random.Next(1, 500)}",
                categoryId = _categories[_random.Next(_categories.Length)],
                price = Math.Round((decimal)(_random.NextDouble() * 500 + 10), 2),
                quantity = _random.Next(1, 5),
                currency = "USD",
                source = _random.Next(3) switch
                {
                    0 => "Web",
                    1 => "Mobile",
                    _ => "API"
                }
            };
        }

        public IEnumerable<object> GenerateBulkEvents(int count)
        {
            for (int i = 0; i < count; i++)
            {
                yield return GenerateECommerceEvent();
            }
        }
    }
}
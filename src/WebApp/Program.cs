using ECommerceApp.Services;

namespace ECommerceApp
{
    /// <summary>
    /// Main entry point for the E-Commerce web application
    /// Configured for Azure App Service deployment with autoscaling capabilities
    /// </summary>
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            
            // Add local configuration file for development/testing
            if (File.Exists("appsettings.Local.json"))
            {
                builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: true);
            }

            // Add services to the container
            ConfigureServices(builder.Services, builder.Configuration);

            var app = builder.Build();

            // Configure the HTTP request pipeline
            ConfigurePipeline(app);

            app.Run();
        }

        /// <summary>
        /// Configure application services and dependencies
        /// </summary>
        private static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
        {
            // Add controllers and API endpoints
            services.AddControllers();
            services.AddEndpointsApiExplorer();
            services.AddSwaggerGen();

            // Add custom services
            services.AddSingleton<IEventHubService, EventHubService>();
            services.AddSingleton<ISqlDatabaseService, SqlDatabaseService>();
            services.AddScoped<IDataGeneratorService, DataGeneratorService>();

            // Add health checks for monitoring (temporarily disabled for testing)
            services.AddHealthChecks();
                // .AddCheck<SqlDatabaseHealthCheck>("sqldatabase")
                // .AddCheck<EventHubHealthCheck>("eventhub");

            // Add CORS for frontend integration
            services.AddCors(options =>
            {
                options.AddDefaultPolicy(policy =>
                {
                    policy.AllowAnyOrigin()
                          .AllowAnyHeader()
                          .AllowAnyMethod();
                });
            });

            // Add memory cache for performance optimization
            services.AddMemoryCache();

            // Add HTTP client for external API calls
            services.AddHttpClient();
        }

        /// <summary>
        /// Configure the HTTP request pipeline
        /// </summary>
        private static void ConfigurePipeline(WebApplication app)
        {
            // Configure the HTTP request pipeline
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            // Enable default files BEFORE static files (middleware order matters!)
            app.UseDefaultFiles();
            
            // Enable static files (for UI)
            app.UseStaticFiles();

            app.UseRouting();
            app.UseCors();
            app.UseAuthorization();

            // Add health check endpoints
            app.MapHealthChecks("/health");
            app.MapHealthChecks("/health/ready");
            app.MapHealthChecks("/health/live");

            // Map controllers
            app.MapControllers();

            // API info endpoint (accessible via /api/info)
            app.MapGet("/api/info", () => Results.Ok(new
            {
                message = "E-Commerce Real-Time Data Processing System - CLDV7112w Practicum",
                student = "ST10129307",
                timestamp = DateTime.UtcNow,
                endpoints = new
                {
                    ui = "/index.html (or just /)",
                    health = "/api/health",
                    healthCheck = "/health",
                    generateLoad = "/api/generate-load",
                    events = "/api/events",
                    stats = "/api/stats",
                    simulate = "/api/simulate/pageview",
                    stressTest = "/api/stress-test",
                    swagger = "/swagger"
                }
            }));
        }
    }
}
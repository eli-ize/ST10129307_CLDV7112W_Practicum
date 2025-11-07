using Microsoft.Data.SqlClient;
using System.Text.Json;

namespace ECommerceApp.Services
{
    /// <summary>
    /// Service for interacting with Azure SQL Database
    /// </summary>
    public interface ISqlDatabaseService
    {
        Task<bool> SaveDataAsync(object data);
        Task<IEnumerable<object>> GetDataAsync();
        Task<bool> TestConnectionAsync();
    }

    /// <summary>
    /// Azure SQL Database Service implementation
    /// Connects to Azure SQL Database for data persistence
    /// </summary>
    public class SqlDatabaseService : ISqlDatabaseService
    {
        private readonly string _connectionString;
        private readonly ILogger<SqlDatabaseService> _logger;

        public SqlDatabaseService(IConfiguration configuration, ILogger<SqlDatabaseService> logger)
        {
            _logger = logger;
            _connectionString = configuration.GetConnectionString("SqlDatabase") 
                ?? configuration["ConnectionStrings:SqlDatabase"]
                ?? string.Empty;
            
            if (string.IsNullOrEmpty(_connectionString))
            {
                _logger.LogWarning("SQL Database connection string not configured. Service will run in degraded mode.");
                return;
            }
            
            // Don't initialize table during startup to avoid blocking
            _logger.LogInformation("SQL Database service initialized. Table will be created on first use.");
        }

        private async Task EnsureTableExists()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                
                var createTableSql = @"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProcessedData')
                    BEGIN
                        CREATE TABLE ProcessedData (
                            Id INT IDENTITY(1,1) PRIMARY KEY,
                            Data NVARCHAR(MAX),
                            Timestamp DATETIME2 DEFAULT GETDATE()
                        )
                    END";
                
                using var command = new SqlCommand(createTableSql, connection);
                await command.ExecuteNonQueryAsync();
                _logger.LogInformation("SQL Database table ensured");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating database table");
            }
        }

        public async Task<bool> SaveDataAsync(object data)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                
                var insertSql = "INSERT INTO ProcessedData (Data) VALUES (@Data)";
                using var command = new SqlCommand(insertSql, connection);
                command.Parameters.AddWithValue("@Data", JsonSerializer.Serialize(data));
                
                await command.ExecuteNonQueryAsync();
                _logger.LogInformation("Data saved to SQL Database successfully");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving data to SQL Database");
                return false;
            }
        }

        public async Task<IEnumerable<object>> GetDataAsync()
        {
            var results = new List<object>();
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                
                var selectSql = "SELECT TOP 10 * FROM ProcessedData ORDER BY Timestamp DESC";
                using var command = new SqlCommand(selectSql, connection);
                
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    results.Add(new
                    {
                        Id = reader["Id"],
                        Data = reader["Data"].ToString(),
                        Timestamp = reader["Timestamp"]
                    });
                }
                
                _logger.LogInformation("Retrieved {Count} records from SQL Database", results.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving data from SQL Database");
            }
            
            return results;
        }

        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                _logger.LogInformation("SQL Database connection successful");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SQL Database connection failed");
                return false;
            }
        }
    }
}
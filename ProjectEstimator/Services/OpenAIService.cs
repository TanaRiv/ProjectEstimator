using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class OpenAIService : IOpenAIService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly IConfiguration _configuration;
        private readonly ILogger<OpenAIService> _logger;

        public OpenAIService(HttpClient httpClient, IConfiguration configuration, ILogger<OpenAIService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
            _apiKey = configuration["OpenAI:ApiKey"] ?? "";
            
            // Log para depuración
            _logger.LogInformation($"OpenAI Service inicializado. API Key configurada: {IsConfigured()}");
        }

        public bool IsConfigured()
        {
            var configured = !string.IsNullOrEmpty(_apiKey);
            
            if (!configured)
            {
                _logger.LogWarning("OpenAI API Key no está configurada correctamente");
            }
            
            return configured;
        }

        public async Task<string> GetCompletionAsync(string systemPrompt, string userPrompt)
        {
            if (!IsConfigured())
            {
                var errorMsg = "OpenAI API Key no está configurada. Por favor, configura tu API Key en wwwroot/appsettings.json";
                _logger.LogError(errorMsg);
                throw new InvalidOperationException(errorMsg);
            }

            _logger.LogInformation("Enviando solicitud a OpenAI GPT-4...");
            
            var request = new
            {
                model = _configuration["OpenAI:Model"] ?? "gpt-4",
                messages = new[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = userPrompt }
                },
                temperature = double.Parse(_configuration["OpenAI:Temperature"] ?? "0.7"),
                max_tokens = int.Parse(_configuration["OpenAI:MaxTokens"] ?? "2000")
            };

            var json = JsonSerializer.Serialize(request, new JsonSerializerOptions { WriteIndented = true });
            
            // Log del request (sin el contenido completo por ser muy largo)
            _logger.LogDebug($"Request a OpenAI - Model: {request.model}, Tokens: {request.max_tokens}");
            
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            
            var httpRequest = new HttpRequestMessage(HttpMethod.Post, "https://api.openai.com/v1/chat/completions");
            httpRequest.Headers.Add("Authorization", $"Bearer {_apiKey}");
            httpRequest.Content = content;

            try
            {
                var response = await _httpClient.SendAsync(httpRequest);
                var responseContent = await response.Content.ReadAsStringAsync();
                
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError($"Error de OpenAI: {response.StatusCode}");
                    _logger.LogError($"Respuesta: {responseContent}");
                    
                    // Parsear error de OpenAI
                    try
                    {
                        var errorObj = JsonSerializer.Deserialize<JsonElement>(responseContent);
                        var errorMessage = errorObj.GetProperty("error").GetProperty("message").GetString();
                        throw new Exception($"Error de OpenAI: {errorMessage}");
                    }
                    catch
                    {
                        throw new Exception($"Error de OpenAI: {response.StatusCode} - {responseContent}");
                    }
                }
                
                var responseObj = JsonSerializer.Deserialize<JsonElement>(responseContent);
                var result = responseObj.GetProperty("choices")[0]
                    .GetProperty("message")
                    .GetProperty("content")
                    .GetString() ?? "";
                
                _logger.LogInformation($"Respuesta recibida de OpenAI: {result.Length} caracteres");
                
                return result;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Error de red al comunicarse con OpenAI");
                throw new Exception($"Error de red al comunicarse con OpenAI: {ex.Message}", ex);
            }
            catch (TaskCanceledException ex)
            {
                _logger.LogError(ex, "Timeout al comunicarse con OpenAI");
                throw new Exception("La solicitud a OpenAI tardó demasiado tiempo. Intenta de nuevo.", ex);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al comunicarse con OpenAI");
                throw;
            }
        }
    }
}

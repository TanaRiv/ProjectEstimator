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
            _logger.LogInformation($"🚀 OpenAI Service inicializado");
            _logger.LogInformation($"📌 Modelo configurado: {configuration["OpenAI:Model"] ?? "gpt-5"}");
            _logger.LogInformation($"🔑 API Key presente: {IsConfigured()}");
        }

        public bool IsConfigured()
        {
            var configured = !string.IsNullOrEmpty(_apiKey);

            if (!configured)
            {
                _logger.LogWarning("⚠️ OpenAI API Key no está configurada correctamente");
            }

            return configured;
        }

        //public async Task<string> GetCompletionAsync(string systemPrompt, string userPrompt)
        //{
        //    if (!IsConfigured())
        //    {
        //        var errorMsg = "OpenAI API Key no está configurada. Por favor, configura tu API Key en wwwroot/appsettings.json";
        //        _logger.LogError(errorMsg);
        //        throw new InvalidOperationException(errorMsg);
        //    }

        //    _logger.LogInformation("📤 Enviando solicitud a GPT-5...");

        //    var model = _configuration["OpenAI:Model"] ?? "gpt-5";
        //    var maxTokens = int.Parse(_configuration["OpenAI:MaxTokens"] ?? "8192");
        //    var temperature = double.Parse(_configuration["OpenAI:Temperature"] ?? "0.7");

        //    var request = new
        //    {
        //        model = model,
        //        messages = new[]
        //        {
        //            new { role = "system", content = systemPrompt },
        //            new { role = "user", content = userPrompt }
        //        },
        //        temperature = temperature,
        //        max_completion_tokens = maxTokens, // GPT-5 usa max_completion_tokens en lugar de max_tokens
        //        response_format = new { type = "json_object" } // Forzar respuesta JSON
        //    };

        //    var json = JsonSerializer.Serialize(request, new JsonSerializerOptions { WriteIndented = true });

        //    // Log del request (sin el contenido completo por ser muy largo)
        //    _logger.LogDebug($"📋 Request a OpenAI - Model: {model}, MaxTokens: {maxTokens}, Temp: {temperature}");

        //    var content = new StringContent(json, Encoding.UTF8, "application/json");

        //    var httpRequest = new HttpRequestMessage(HttpMethod.Post, "https://api.openai.com/v1/chat/completions");
        //    httpRequest.Headers.Add("Authorization", $"Bearer {_apiKey}");
        //    httpRequest.Content = content;

        //    try
        //    {
        //        var response = await _httpClient.SendAsync(httpRequest);
        //        var responseContent = await response.Content.ReadAsStringAsync();

        //        if (!response.IsSuccessStatusCode)
        //        {
        //            _logger.LogError($"❌ Error de OpenAI: {response.StatusCode}");
        //            _logger.LogError($"📄 Respuesta: {responseContent}");

        //            // Parsear error de OpenAI
        //            try
        //            {
        //                var errorObj = JsonSerializer.Deserialize<JsonElement>(responseContent);
        //                var errorMessage = errorObj.GetProperty("error").GetProperty("message").GetString();
        //                throw new Exception($"Error de OpenAI: {errorMessage}");
        //            }
        //            catch
        //            {
        //                throw new Exception($"Error de OpenAI: {response.StatusCode} - {responseContent}");
        //            }
        //        }

        //        var responseObj = JsonSerializer.Deserialize<JsonElement>(responseContent);
        //        var result = responseObj.GetProperty("choices")[0]
        //            .GetProperty("message")
        //            .GetProperty("content")
        //            .GetString() ?? "";

        //        // Log de tokens usados (útil para controlar costos)
        //        if (responseObj.TryGetProperty("usage", out var usage))
        //        {
        //            var promptTokens = usage.GetProperty("prompt_tokens").GetInt32();
        //            var completionTokens = usage.GetProperty("completion_tokens").GetInt32();
        //            var totalTokens = usage.GetProperty("total_tokens").GetInt32();

        //            _logger.LogInformation($"📊 Tokens usados - Prompt: {promptTokens}, Completion: {completionTokens}, Total: {totalTokens}");

        //            // Calcular costo aproximado (GPT-5 pricing)
        //            var inputCost = (promptTokens / 1000000.0) * 1.25; // $1.25 per 1M input tokens
        //            var outputCost = (completionTokens / 1000000.0) * 10.0; // $10 per 1M output tokens
        //            var totalCost = inputCost + outputCost;

        //            _logger.LogInformation($"💰 Costo aproximado: ${totalCost:F4} (Input: ${inputCost:F4}, Output: ${outputCost:F4})");
        //        }

        //        _logger.LogInformation($"✅ Respuesta recibida de GPT-5: {result.Length} caracteres");

        //        return result;
        //    }
        //    catch (HttpRequestException ex)
        //    {
        //        _logger.LogError(ex, "❌ Error de red al comunicarse con OpenAI");
        //        throw new Exception($"Error de red al comunicarse con OpenAI: {ex.Message}", ex);
        //    }
        //    catch (TaskCanceledException ex)
        //    {
        //        _logger.LogError(ex, "⏱️ Timeout al comunicarse con OpenAI");
        //        throw new Exception("La solicitud a OpenAI tardó demasiado tiempo. Intenta de nuevo.", ex);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "❌ Error inesperado al comunicarse con OpenAI");
        //        throw;
        //    }
        //}
        public async Task<string> GetCompletionAsync(string systemPrompt, string userPrompt)
        {
            if (!IsConfigured())
                throw new InvalidOperationException("OpenAI API Key no está configurada.");

            var model = _configuration["OpenAI:Model"] ?? "gpt-5";
            var maxTokens = int.Parse(_configuration["OpenAI:MaxTokens"] ?? "1000");
            //var temperature = double.Parse(_configuration["OpenAI:Temperature"] ?? "0.1");

            _httpClient.Timeout = TimeSpan.FromMinutes(10);
            var request = new
            {
                model,
                input = new object[]
                {
        new {
            role = "system",
            content = new object[] { new { type = "input_text", text = systemPrompt } }
        },
        new {
            role = "user",
            content = new object[] { new { type = "input_text", text = userPrompt } }
        }
                },
                //temperature,
                max_output_tokens = maxTokens, // 👈 este es el parámetro correcto
                text = new
                {
                    format = new { type = "json_object" }   // "text", "json" o "markdown"
                }
            };



            var json = JsonSerializer.Serialize(request);
            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, "https://api.openai.com/v1/responses");
            httpRequest.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _apiKey);
            httpRequest.Content = new StringContent(json, Encoding.UTF8, "application/json");

            var resp = await _httpClient.SendAsync(httpRequest, HttpCompletionOption.ResponseHeadersRead);
            var body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new Exception(ParseOpenAIError(body) ?? $"Error de OpenAI: {resp.StatusCode} - {body}");

            using var doc = JsonDocument.Parse(body);
            var root = doc.RootElement;

            // Texto: output[0].content[0].text
            var text = root.GetProperty("output")[1].GetProperty("content")[0].GetProperty("text").GetString() ?? "";

            if (root.TryGetProperty("usage", out var usage))
            {
                var inTok = usage.GetProperty("input_tokens").GetInt32();
                var outTok = usage.GetProperty("output_tokens").GetInt32();
                var totTok = usage.GetProperty("total_tokens").GetInt32();
                _logger.LogInformation($"📊 Tokens - input:{inTok} output:{outTok} total:{totTok}");
            }

            return text;
        }

        // Aux: intenta extraer "error.message"
        private static string? ParseOpenAIError(string responseContent)
        {
            try
            {
                using var doc = JsonDocument.Parse(responseContent);
                return doc.RootElement.GetProperty("error").GetProperty("message").GetString();
            }
            catch { return null; }
        }
    }
}
# FixOpenAIIntegration.ps1
# Script para asegurar que se use OpenAI realmente

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🔧 Corrigiendo integración con OpenAI GPT-4..." -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Set-Location $projectPath

# ============================================
# PASO 1: Verificar configuración
# ============================================
Write-Host "`n📋 Verificando configuración..." -ForegroundColor Yellow

$appsettingsPath = "$projectPath\wwwroot\appsettings.json"
if (Test-Path $appsettingsPath) {
    $config = Get-Content $appsettingsPath | ConvertFrom-Json
    if ($config.OpenAI.ApiKey -eq "YOUR_OPENAI_API_KEY_HERE") {
        Write-Host "⚠️  API Key no configurada" -ForegroundColor Yellow
        Write-Host "Por favor, edita wwwroot\appsettings.json y agrega tu API Key" -ForegroundColor Yellow
    } else {
        Write-Host "✅ API Key detectada" -ForegroundColor Green
    }
}

# ============================================
# PASO 2: Corregir OpenAIService
# ============================================
Write-Host "`n📦 Actualizando OpenAIService para depuración..." -ForegroundColor Yellow

@'
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
            var configured = !string.IsNullOrEmpty(_apiKey) && 
                           !_apiKey.Contains("YOUR_OPENAI_API_KEY");
            
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
'@ | Out-File -FilePath "$projectPath\Services\OpenAIService.cs" -Encoding UTF8

Write-Host "  ✓ OpenAIService actualizado con mejor manejo de errores" -ForegroundColor Gray

# ============================================
# PASO 3: Corregir EstimationService para asegurar uso de OpenAI
# ============================================
Write-Host "`n📦 Actualizando EstimationService para usar OpenAI realmente..." -ForegroundColor Yellow

@'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using ProjectEstimatorApp.Models;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class EstimationService : IEstimationService
    {
        private readonly IOpenAIService _openAIService;
        private readonly ILogger<EstimationService> _logger;

        public EstimationService(IOpenAIService openAIService, ILogger<EstimationService> logger)
        {
            _openAIService = openAIService;
            _logger = logger;
        }
        
        public async Task<ProjectEstimation> EstimateProjectAsync(EstimationRequest request)
        {
            _logger.LogInformation($"Iniciando estimación para proyecto: {request.ProjectName}");
            
            var estimation = new ProjectEstimation
            {
                ProjectName = request.ProjectName,
                InitialPrompt = request.InitialPrompt,
                DocumentContent = request.DocumentContent,
                Status = EstimationStatus.Processing
            };

            try
            {
                if (_openAIService.IsConfigured())
                {
                    _logger.LogInformation("OpenAI configurado, usando GPT-4 para estimación real");
                    estimation = await ExtractTasksWithOpenAI(request.DocumentContent, request.InitialPrompt, request.ProjectName);
                    
                    if (estimation.Tasks.Any())
                    {
                        estimation.Status = EstimationStatus.Completed;
                        _logger.LogInformation($"Estimación completada: {estimation.Tasks.Count} tareas, {estimation.TotalEstimatedHours} horas totales");
                    }
                    else
                    {
                        _logger.LogWarning("OpenAI no devolvió tareas, usando estimación local");
                        estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                    }
                }
                else
                {
                    _logger.LogWarning("OpenAI no configurado, usando estimación local");
                    await Task.Delay(2000); // Simular procesamiento
                    estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error durante la estimación");
                estimation.Status = EstimationStatus.Failed;
                estimation.AnalysisResult = $"Error: {ex.Message}";
                
                // Si falla OpenAI, usar estimación local
                _logger.LogInformation("Fallback a estimación local debido a error");
                estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                estimation.AnalysisResult = $"Nota: Se usó estimación local debido a: {ex.Message}";
            }

            return estimation;
        }

        private async Task<ProjectEstimation> ExtractTasksWithOpenAI(string documentContent, string additionalContext, string projectName)
        {
            _logger.LogInformation("Preparando prompt para OpenAI...");
            
            var systemPrompt = @"Eres un experto analista de proyectos con más de 20 años de experiencia en desarrollo empresarial.
Especializado en el stack Microsoft: .NET 8, C#, Blazor, SQL Server.

IMPORTANTE: Debes analizar el documento/descripción proporcionado y generar una estimación REALISTA y DETALLADA.

Para cada tarea identificada en el proyecto, proporciona:
- taskId: Identificador único (ej: TASK-001, TASK-002)
- name: Nombre descriptivo de la tarea
- description: Descripción detallada
- category: Una de estas: Backend, Frontend, Database, Infrastructure, Testing, Documentation, DevOps, Architecture
- complexity: Una de estas: Simple, Medium, Complex, VeryComplex
- estimatedHours: Número de horas (entero)
- requiredProfile: Junior, Middle o Senior
- dependencies: Array de taskIds de los que depende
- acceptanceCriteria: Array de criterios de aceptación
- taskRisks: Array de riesgos identificados

REGLAS DE ESTIMACIÓN:
- Máximo 8 horas por tarea individual
- Incluir SIEMPRE tareas de testing (mínimo 25% del desarrollo)
- Incluir SIEMPRE documentación (mínimo 10% del desarrollo)
- Incluir configuración inicial, CI/CD, despliegue
- Considerar factores de ajuste:
  * Investigación técnica: +15%
  * Debugging esperado: +20%
  * Code review: +10%
  * Reuniones: +15%

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido con esta estructura exacta:
{
  ""projectName"": ""nombre del proyecto"",
  ""complexity"": ""Low|Medium|High|VeryHigh"",
  ""confidence"": ""High|Medium|Low"",
  ""totalHours"": 0,
  ""contingencyHours"": 0,
  ""tasks"": [
    {
      ""taskId"": ""TASK-001"",
      ""name"": ""nombre"",
      ""description"": ""descripción"",
      ""category"": ""categoria"",
      ""complexity"": ""complejidad"",
      ""estimatedHours"": 0,
      ""requiredProfile"": ""perfil"",
      ""dependencies"": [],
      ""acceptanceCriteria"": [""criterio1""],
      ""taskRisks"": [""riesgo1""]
    }
  ],
  ""summary"": {
    ""developmentHours"": 0,
    ""testingHours"": 0,
    ""documentationHours"": 0,
    ""infrastructureHours"": 0,
    ""managementHours"": 0
  },
  ""assumptions"": [""asunción1""],
  ""risks"": [""riesgo1""],
  ""recommendations"": [""recomendación1""]
}";

            var userPrompt = $@"PROYECTO: {projectName}

CONTEXTO ADICIONAL:
{additionalContext}

DOCUMENTO/DESCRIPCIÓN DEL PROYECTO:
{documentContent}

Por favor, analiza este proyecto y genera una estimación completa y detallada con todas las tareas necesarias para su desarrollo.
Recuerda incluir configuración, desarrollo, testing, documentación y despliegue.
Responde SOLO con el JSON, sin texto adicional.";

            try
            {
                _logger.LogInformation("Enviando solicitud a OpenAI...");
                var response = await _openAIService.GetCompletionAsync(systemPrompt, userPrompt);
                
                _logger.LogInformation($"Respuesta recibida, procesando JSON...");
                
                // Intentar extraer JSON de la respuesta
                var jsonStart = response.IndexOf("{");
                var jsonEnd = response.LastIndexOf("}") + 1;
                
                if (jsonStart >= 0 && jsonEnd > jsonStart)
                {
                    var jsonResponse = response.Substring(jsonStart, jsonEnd - jsonStart);
                    
                    _logger.LogDebug($"JSON extraído: {jsonResponse.Substring(0, Math.Min(500, jsonResponse.Length))}...");
                    
                    var options = new JsonSerializerOptions 
                    { 
                        PropertyNameCaseInsensitive = true,
                        AllowTrailingCommas = true,
                        ReadCommentHandling = JsonCommentHandling.Skip
                    };
                    
                    var result = JsonSerializer.Deserialize<OpenAIEstimationResponse>(jsonResponse, options);
                    
                    if (result != null && result.Tasks != null && result.Tasks.Any())
                    {
                        _logger.LogInformation($"JSON parseado exitosamente: {result.Tasks.Count} tareas");
                        return ConvertToEstimation(result);
                    }
                    else
                    {
                        _logger.LogWarning("El JSON no contiene tareas válidas");
                    }
                }
                else
                {
                    _logger.LogWarning("No se encontró JSON válido en la respuesta de OpenAI");
                    _logger.LogDebug($"Respuesta completa: {response}");
                }
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Error al parsear JSON de OpenAI");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al procesar respuesta de OpenAI");
                throw;
            }

            // Si llegamos aquí, algo falló, devolver estimación vacía
            return new ProjectEstimation
            {
                ProjectName = projectName,
                Status = EstimationStatus.Failed,
                Tasks = new List<DevelopmentTask>(),
                AnalysisResult = "No se pudo procesar la respuesta de OpenAI"
            };
        }

        private ProjectEstimation ConvertToEstimation(OpenAIEstimationResponse result)
        {
            var estimation = new ProjectEstimation
            {
                ProjectName = result.ProjectName ?? "Proyecto",
                Complexity = Enum.TryParse<ProjectComplexity>(result.Complexity, true, out var comp) 
                    ? comp : ProjectComplexity.Medium,
                Confidence = Enum.TryParse<ConfidenceLevel>(result.Confidence, true, out var conf) 
                    ? conf : ConfidenceLevel.Medium,
                TotalEstimatedHours = result.TotalHours,
                ContingencyHours = result.ContingencyHours > 0 ? result.ContingencyHours : result.TotalHours * 0.15,
                Tasks = ConvertTasks(result.Tasks),
                Summary = result.Summary ?? new EstimationSummary(),
                Assumptions = result.Assumptions ?? new List<string>(),
                Risks = result.Risks ?? new List<string>(),
                Recommendations = result.Recommendations ?? new List<string>(),
                Status = EstimationStatus.Completed
            };

            // Recalcular totales si es necesario
            if (estimation.TotalEstimatedHours == 0)
            {
                estimation.TotalEstimatedHours = estimation.Tasks.Sum(t => t.EstimatedHours);
            }

            if (estimation.ContingencyHours == 0)
            {
                estimation.ContingencyHours = estimation.TotalEstimatedHours * 0.15;
            }

            return estimation;
        }

        private List<DevelopmentTask> ConvertTasks(List<OpenAITask> tasks)
        {
            if (tasks == null || !tasks.Any()) 
            {
                _logger.LogWarning("No hay tareas para convertir");
                return new List<DevelopmentTask>();
            }

            var convertedTasks = new List<DevelopmentTask>();
            
            foreach (var task in tasks)
            {
                try
                {
                    var convertedTask = new DevelopmentTask
                    {
                        TaskId = task.TaskId ?? $"TASK-{convertedTasks.Count + 1:D3}",
                        Name = task.Name ?? "Tarea sin nombre",
                        Description = task.Description ?? "",
                        Category = Enum.TryParse<TaskCategory>(task.Category, true, out var cat) 
                            ? cat : TaskCategory.Backend,
                        Complexity = Enum.TryParse<ComplexityLevel>(task.Complexity, true, out var comp) 
                            ? comp : ComplexityLevel.Medium,
                        EstimatedHours = task.EstimatedHours > 0 ? task.EstimatedHours : 8,
                        RequiredProfile = Enum.TryParse<ProfileLevel>(task.RequiredProfile, true, out var prof) 
                            ? prof : ProfileLevel.Middle,
                        Dependencies = task.Dependencies ?? new List<string>(),
                        AcceptanceCriteria = task.AcceptanceCriteria ?? new List<string>(),
                        TaskRisks = task.TaskRisks ?? new List<string>()
                    };
                    
                    convertedTasks.Add(convertedTask);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error convirtiendo tarea: {task.Name}");
                }
            }

            _logger.LogInformation($"Convertidas {convertedTasks.Count} tareas exitosamente");
            return convertedTasks;
        }

        public ProjectEstimation GetSampleEstimation(string projectName, string prompt)
        {
            _logger.LogInformation("Generando estimación local de ejemplo");
            
            var tasks = new List<DevelopmentTask>
            {
                new DevelopmentTask
                {
                    TaskId = "LOCAL-001",
                    Name = "Configuración inicial (Estimación Local)",
                    Description = "Esta es una estimación de ejemplo. Configure su API Key de OpenAI para obtener estimaciones reales.",
                    Category = TaskCategory.Architecture,
                    Complexity = ComplexityLevel.Simple,
                    EstimatedHours = 8,
                    RequiredProfile = ProfileLevel.Middle,
                    AcceptanceCriteria = new List<string> { "Proyecto configurado" }
                }
            };

            // Agregar más tareas de ejemplo basadas en palabras clave
            var promptLower = prompt.ToLower();
            
            if (promptLower.Contains("database") || promptLower.Contains("sql"))
            {
                tasks.Add(new DevelopmentTask
                {
                    TaskId = "LOCAL-002",
                    Name = "Base de datos (Estimación Local)",
                    Description = "Estimación local básica",
                    Category = TaskCategory.Database,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 24,
                    RequiredProfile = ProfileLevel.Middle
                });
            }

            return new ProjectEstimation
            {
                ProjectName = projectName + " (ESTIMACIÓN LOCAL)",
                Status = EstimationStatus.Completed,
                Tasks = tasks,
                TotalEstimatedHours = tasks.Sum(t => t.EstimatedHours),
                ContingencyHours = tasks.Sum(t => t.EstimatedHours) * 0.15,
                Complexity = ProjectComplexity.Medium,
                Confidence = ConfidenceLevel.Low,
                Summary = new EstimationSummary
                {
                    DevelopmentHours = tasks.Sum(t => t.EstimatedHours),
                    TestingHours = 0,
                    DocumentationHours = 0,
                    InfrastructureHours = 0,
                    ManagementHours = 0
                },
                Assumptions = new List<string> { "NOTA: Esta es una estimación local. Configure OpenAI para estimaciones reales." },
                Risks = new List<string> { "Estimación no basada en análisis real del proyecto" },
                Recommendations = new List<string> { "Configure su API Key de OpenAI en appsettings.json" }
            };
        }

        // Clases para deserialización
        private class OpenAIEstimationResponse
        {
            public string ProjectName { get; set; }
            public string Complexity { get; set; }
            public string Confidence { get; set; }
            public double TotalHours { get; set; }
            public double ContingencyHours { get; set; }
            public List<OpenAITask> Tasks { get; set; }
            public EstimationSummary Summary { get; set; }
            public List<string> Assumptions { get; set; }
            public List<string> Risks { get; set; }
            public List<string> Recommendations { get; set; }
        }
        
        private class OpenAITask
        {
            public string TaskId { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public string Category { get; set; }
            public string Complexity { get; set; }
            public double EstimatedHours { get; set; }
            public string RequiredProfile { get; set; }
            public List<string> Dependencies { get; set; }
            public List<string> AcceptanceCriteria { get; set; }
            public List<string> TaskRisks { get; set; }
        }
    }
}
'@ | Out-File -FilePath "$projectPath\Services\EstimationService.cs" -Encoding UTF8

Write-Host "  ✓ EstimationService actualizado para usar OpenAI realmente" -ForegroundColor Gray

# ============================================
# PASO 4: Actualizar Program.cs con logging
# ============================================
Write-Host "`n📦 Actualizando Program.cs con logging..." -ForegroundColor Yellow

@"
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.Logging;
using ProjectEstimatorApp;
using ProjectEstimatorApp.Services;
using ProjectEstimatorApp.Services.Interfaces;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

// Configurar logging
builder.Logging.SetMinimumLevel(LogLevel.Debug);

// Configurar HttpClient para OpenAI
builder.Services.AddScoped(sp => {
    var client = new HttpClient();
    client.BaseAddress = new Uri("https://api.openai.com/");
    client.Timeout = TimeSpan.FromSeconds(60); // Timeout de 60 segundos para OpenAI
    return client;
});

// Registrar servicios
builder.Services.AddScoped<IProjectService, ProjectService>();
builder.Services.AddScoped<IOpenAIService, OpenAIService>();
builder.Services.AddScoped<IPdfService, PdfService>();
builder.Services.AddScoped<IEstimationService, EstimationService>();

// Cargar configuración
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

await builder.Build().RunAsync();
"@ | Out-File -FilePath "$projectPath\Program.cs" -Encoding UTF8

Write-Host "  ✓ Program.cs actualizado" -ForegroundColor Gray

# ============================================
# PASO 5: Verificar/crear appsettings.json
# ============================================
Write-Host "`n📦 Verificando appsettings.json..." -ForegroundColor Yellow

if (!(Test-Path "$projectPath\wwwroot\appsettings.json")) {
    @"
{
  "OpenAI": {
    "ApiKey": "YOUR_OPENAI_API_KEY_HERE",
    "Model": "gpt-4",
    "MaxTokens": 2000,
    "Temperature": 0.7
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
"@ | Out-File -FilePath "$projectPath\wwwroot\appsettings.json" -Encoding UTF8
    Write-Host "  ✓ appsettings.json creado - CONFIGURA TU API KEY" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ appsettings.json existe" -ForegroundColor Gray
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ INTEGRACIÓN CON OPENAI CORREGIDA" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n🔍 DEPURACIÓN ACTIVADA:" -ForegroundColor Cyan
Write-Host "  ✓ Logs detallados en consola del navegador (F12)" -ForegroundColor White
Write-Host "  ✓ Mensajes de estado durante el proceso" -ForegroundColor White
Write-Host "  ✓ Errores específicos de OpenAI" -ForegroundColor White
Write-Host "  ✓ Validación de respuestas JSON" -ForegroundColor White

Write-Host "`n⚠️  IMPORTANTE:" -ForegroundColor Yellow
Write-Host "  1. Asegúrate de tener tu API Key en:" -ForegroundColor White
Write-Host "     $projectPath\wwwroot\appsettings.json" -ForegroundColor Gray
Write-Host "  2. La API Key debe ser válida y con créditos" -ForegroundColor White
Write-Host "  3. Abre la consola del navegador (F12) para ver logs" -ForegroundColor White

Write-Host "`n🎯 CÓMO VERIFICAR QUE FUNCIONA:" -ForegroundColor Yellow
Write-Host "  1. Si dice '(ESTIMACIÓN LOCAL)' → No está usando OpenAI" -ForegroundColor White
Write-Host "  2. Si genera múltiples tareas detalladas → Está usando OpenAI" -ForegroundColor White
Write-Host "  3. Revisa la consola del navegador para ver el proceso" -ForegroundColor White

Write-Host "`n🚀 Compilando proyecto..." -ForegroundColor Yellow

dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡Compilación exitosa!" -ForegroundColor Green
    Write-Host "`n▶️  Ejecutando aplicación..." -ForegroundColor Cyan
    Write-Host "Abre la consola del navegador (F12) para ver los logs" -ForegroundColor Yellow
    dotnet run
} else {
    Write-Host "`n❌ Error en compilación" -ForegroundColor Red
}
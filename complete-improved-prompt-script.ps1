# ImplementImprovedPrompt.ps1
# Script completo para implementar el prompt profesional mejorado

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🚀 Implementando prompt profesional mejorado para estimaciones..." -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Set-Location $projectPath

# ============================================
# PASO 1: Actualizar modelos de datos
# ============================================
Write-Host "`n📦 Actualizando modelos de datos..." -ForegroundColor Yellow

@'
using System;
using System.Collections.Generic;

namespace ProjectEstimatorApp.Models
{
    public class ProjectEstimation
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string ProjectName { get; set; } = string.Empty;
        public string DocumentContent { get; set; } = string.Empty;
        public string InitialPrompt { get; set; } = string.Empty;
        public List<DevelopmentTask> Tasks { get; set; } = new();
        public double TotalEstimatedHours { get; set; }
        public double ContingencyHours { get; set; }
        public EstimationStatus Status { get; set; }
        public string? AnalysisResult { get; set; }
        public ProjectComplexity Complexity { get; set; }
        public ConfidenceLevel Confidence { get; set; }
        public EstimationSummary Summary { get; set; } = new();
        public List<string> Assumptions { get; set; } = new();
        public List<string> Risks { get; set; } = new();
        public List<string> Recommendations { get; set; } = new();
    }

    public class DevelopmentTask
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string TaskId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TaskCategory Category { get; set; }
        public double EstimatedHours { get; set; }
        public ComplexityLevel Complexity { get; set; }
        public ProfileLevel RequiredProfile { get; set; }
        public List<string> Dependencies { get; set; } = new();
        public List<string> AcceptanceCriteria { get; set; } = new();
        public List<string> TaskRisks { get; set; } = new();
    }

    public class EstimationSummary
    {
        public double DevelopmentHours { get; set; }
        public double TestingHours { get; set; }
        public double DocumentationHours { get; set; }
        public double InfrastructureHours { get; set; }
        public double ManagementHours { get; set; }
    }

    public enum TaskCategory
    {
        Backend,
        Frontend,
        Database,
        Infrastructure,
        Testing,
        Documentation,
        DevOps,
        Architecture
    }

    public enum ComplexityLevel
    {
        Simple = 1,
        Medium = 2,
        Complex = 3,
        VeryComplex = 4
    }

    public enum ProjectComplexity
    {
        Low,
        Medium,
        High,
        VeryHigh
    }

    public enum ConfidenceLevel
    {
        High,   // ±10% margen
        Medium, // ±25% margen
        Low     // ±40% margen
    }

    public enum ProfileLevel
    {
        Junior,
        Middle,
        Senior
    }

    public enum EstimationStatus
    {
        Pending,
        Processing,
        Completed,
        Failed
    }

    public class EstimationRequest
    {
        public string DocumentContent { get; set; } = string.Empty;
        public string InitialPrompt { get; set; } = string.Empty;
        public string ProjectName { get; set; } = string.Empty;
    }
}
'@ | Out-File -FilePath "$projectPath\Models\ProjectEstimation.cs" -Encoding UTF8

Write-Host "  ✓ Modelos actualizados" -ForegroundColor Gray

# ============================================
# PASO 2: Crear EstimationService.cs (Parte 1)
# ============================================
Write-Host "`n📦 Creando EstimationService con prompt mejorado (Parte 1)..." -ForegroundColor Yellow

$estimationServicePart1 = @'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using ProjectEstimatorApp.Models;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class EstimationService : IEstimationService
    {
        private readonly IOpenAIService _openAIService;

        public EstimationService(IOpenAIService openAIService)
        {
            _openAIService = openAIService;
        }
        
        public async Task<ProjectEstimation> EstimateProjectAsync(EstimationRequest request)
        {
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
                    var result = await ExtractTasksWithOpenAI(request.DocumentContent, request.InitialPrompt);
                    estimation = result;
                    estimation.Status = EstimationStatus.Completed;
                }
                else
                {
                    await Task.Delay(2000);
                    estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                }
            }
            catch (Exception ex)
            {
                estimation.Status = EstimationStatus.Failed;
                estimation.AnalysisResult = ex.Message;
            }

            return estimation;
        }
'@

$estimationServicePart1 | Out-File -FilePath "$projectPath\Services\EstimationService.cs" -Encoding UTF8

# ============================================
# PASO 3: Agregar el prompt mejorado al servicio
# ============================================
Write-Host "`n📦 Agregando prompt profesional..." -ForegroundColor Yellow

$estimationServicePart2 = @'

        private async Task<ProjectEstimation> ExtractTasksWithOpenAI(string documentContent, string additionalContext)
        {
            var systemPrompt = @"# ROL Y CONTEXTO
Eres un experto analista de proyectos con más de 20 años de experiencia en desarrollo empresarial.
Especializado en el stack Microsoft: .NET 8, C#, Blazor, SQL Server.

# OBJETIVO
Analizar documentos de diseño y generar estimaciones detalladas y realistas.

# PROCESO DE ANÁLISIS

## FASE 1: COMPRENSIÓN
Identificar del documento:
- Contexto general y objetivos
- Requerimientos funcionales
- Requerimientos no funcionales
- Integraciones necesarias

## FASE 2: IDENTIFICACIÓN DE RIESGOS
- Ambigüedades en requisitos
- Dependencias externas
- Riesgos técnicos
- Suposiciones necesarias

## FASE 3: DESCOMPOSICIÓN
- Máximo 8 horas por tarea
- Incluir: desarrollo, testing (25% mínimo), documentación (10% mínimo)
- Cada tarea debe ser verificable

## FASE 4: ESTIMACIÓN REALISTA
Base: Desarrollador nivel medio
Factores de ajuste:
- Investigación: +15%
- Debugging: +20%
- Code review: +10%
- Reuniones: +15%
- Primera vez con tecnología: x1.3
- Integraciones: x1.2

# FORMATO JSON
{
  ""projectName"": ""string"",
  ""complexity"": ""Low|Medium|High|VeryHigh"",
  ""confidence"": ""High|Medium|Low"",
  ""totalHours"": number,
  ""contingencyHours"": number,
  ""tasks"": [{
    ""taskId"": ""string"",
    ""name"": ""string"",
    ""description"": ""string"",
    ""category"": ""Backend|Frontend|Database|Infrastructure|Testing|Documentation|DevOps|Architecture"",
    ""complexity"": ""Simple|Medium|Complex|VeryComplex"",
    ""estimatedHours"": number,
    ""requiredProfile"": ""Junior|Middle|Senior"",
    ""dependencies"": [],
    ""acceptanceCriteria"": [],
    ""taskRisks"": []
  }],
  ""summary"": {
    ""developmentHours"": number,
    ""testingHours"": number,
    ""documentationHours"": number,
    ""infrastructureHours"": number,
    ""managementHours"": number
  },
  ""assumptions"": [],
  ""risks"": [],
  ""recommendations"": []
}";

            var userPrompt = $@"CONTEXTO: {additionalContext}

DOCUMENTO: {documentContent}

Genera estimación completa en JSON con todas las tareas necesarias.";

            try
            {
                var response = await _openAIService.GetCompletionAsync(systemPrompt, userPrompt);
                var jsonStart = response.IndexOf("{");
                var jsonEnd = response.LastIndexOf("}") + 1;
                
                if (jsonStart >= 0 && jsonEnd > jsonStart)
                {
                    var jsonResponse = response.Substring(jsonStart, jsonEnd - jsonStart);
                    var result = JsonSerializer.Deserialize<OpenAIResponse>(jsonResponse, 
                        new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                    
                    if (result != null)
                    {
                        return ConvertToEstimation(result);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }

            return GetSampleEstimation("Proyecto", documentContent);
        }

        private ProjectEstimation ConvertToEstimation(OpenAIResponse result)
        {
            return new ProjectEstimation
            {
                ProjectName = result.ProjectName ?? "Proyecto",
                Complexity = Enum.TryParse<ProjectComplexity>(result.Complexity, true, out var comp) 
                    ? comp : ProjectComplexity.Medium,
                Confidence = Enum.TryParse<ConfidenceLevel>(result.Confidence, true, out var conf) 
                    ? conf : ConfidenceLevel.Medium,
                TotalEstimatedHours = result.TotalHours,
                ContingencyHours = result.ContingencyHours,
                Tasks = ConvertTasks(result.Tasks),
                Summary = result.Summary ?? new EstimationSummary(),
                Assumptions = result.Assumptions ?? new List<string>(),
                Risks = result.Risks ?? new List<string>(),
                Recommendations = result.Recommendations ?? new List<string>(),
                Status = EstimationStatus.Completed
            };
        }

        private List<DevelopmentTask> ConvertTasks(List<OpenAITask> tasks)
        {
            if (tasks == null) return new List<DevelopmentTask>();
            
            return tasks.Select(t => new DevelopmentTask
            {
                TaskId = t.TaskId ?? Guid.NewGuid().ToString().Substring(0, 8),
                Name = t.Name ?? "Tarea",
                Description = t.Description ?? "",
                Category = Enum.TryParse<TaskCategory>(t.Category, true, out var cat) 
                    ? cat : TaskCategory.Backend,
                Complexity = Enum.TryParse<ComplexityLevel>(t.Complexity, true, out var comp) 
                    ? comp : ComplexityLevel.Medium,
                EstimatedHours = t.EstimatedHours,
                RequiredProfile = Enum.TryParse<ProfileLevel>(t.RequiredProfile, true, out var prof) 
                    ? prof : ProfileLevel.Middle,
                Dependencies = t.Dependencies ?? new List<string>(),
                AcceptanceCriteria = t.AcceptanceCriteria ?? new List<string>(),
                TaskRisks = t.TaskRisks ?? new List<string>()
            }).ToList();
        }
'@

Add-Content -Path "$projectPath\Services\EstimationService.cs" -Value $estimationServicePart2

# ============================================
# PASO 4: Agregar método de estimación local mejorado
# ============================================
Write-Host "`n📦 Agregando estimación local mejorada..." -ForegroundColor Yellow

$estimationServicePart3 = @'

        public ProjectEstimation GetSampleEstimation(string projectName, string prompt)
        {
            var tasks = GenerateDetailedTasks(prompt);
            var total = tasks.Sum(t => t.EstimatedHours);
            
            return new ProjectEstimation
            {
                ProjectName = projectName,
                Status = EstimationStatus.Completed,
                Tasks = tasks,
                TotalEstimatedHours = total,
                ContingencyHours = total * 0.15,
                Complexity = ProjectComplexity.Medium,
                Confidence = ConfidenceLevel.Medium,
                Summary = CalculateSummary(tasks),
                Assumptions = new List<string> 
                { 
                    "Equipo con experiencia en .NET/Blazor",
                    "Infraestructura disponible",
                    "Requisitos estables"
                },
                Risks = new List<string>
                {
                    "Cambios en requisitos",
                    "Dependencias externas",
                    "Curva de aprendizaje"
                },
                Recommendations = new List<string>
                {
                    "Implementar CI/CD desde inicio",
                    "Revisiones semanales",
                    "Documentación continua"
                }
            };
        }

        private EstimationSummary CalculateSummary(List<DevelopmentTask> tasks)
        {
            return new EstimationSummary
            {
                DevelopmentHours = tasks.Where(t => t.Category == TaskCategory.Backend || 
                    t.Category == TaskCategory.Frontend).Sum(t => t.EstimatedHours),
                TestingHours = tasks.Where(t => t.Category == TaskCategory.Testing).Sum(t => t.EstimatedHours),
                DocumentationHours = tasks.Where(t => t.Category == TaskCategory.Documentation).Sum(t => t.EstimatedHours),
                InfrastructureHours = tasks.Where(t => t.Category == TaskCategory.Infrastructure || 
                    t.Category == TaskCategory.DevOps).Sum(t => t.EstimatedHours),
                ManagementHours = tasks.Sum(t => t.EstimatedHours) * 0.15
            };
        }

        private List<DevelopmentTask> GenerateDetailedTasks(string prompt)
        {
            var tasks = new List<DevelopmentTask>();
            var promptLower = prompt.ToLower();
            
            // Setup inicial
            tasks.Add(new DevelopmentTask
            {
                TaskId = "SETUP-001",
                Name = "Configuración inicial",
                Description = "Setup proyecto, Git, estructura",
                Category = TaskCategory.Architecture,
                Complexity = ComplexityLevel.Simple,
                EstimatedHours = 8,
                RequiredProfile = ProfileLevel.Middle,
                AcceptanceCriteria = new List<string> { "Proyecto configurado", "Git listo" }
            });
            
            // Si tiene base de datos
            if (promptLower.Contains("database") || promptLower.Contains("sql"))
            {
                tasks.Add(new DevelopmentTask
                {
                    TaskId = "DB-001",
                    Name = "Diseño de base de datos",
                    Description = "Esquema, tablas, relaciones",
                    Category = TaskCategory.Database,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 24,
                    RequiredProfile = ProfileLevel.Middle,
                    Dependencies = new List<string> { "SETUP-001" }
                });
            }
            
            // Si tiene API
            if (promptLower.Contains("api") || promptLower.Contains("backend"))
            {
                tasks.Add(new DevelopmentTask
                {
                    TaskId = "API-001",
                    Name = "Desarrollo API REST",
                    Description = "Endpoints, validaciones, seguridad",
                    Category = TaskCategory.Backend,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 40,
                    RequiredProfile = ProfileLevel.Senior
                });
            }
            
            // Testing siempre
            tasks.Add(new DevelopmentTask
            {
                TaskId = "TEST-001",
                Name = "Pruebas unitarias",
                Description = "Cobertura 70% mínimo",
                Category = TaskCategory.Testing,
                Complexity = ComplexityLevel.Medium,
                EstimatedHours = 24,
                RequiredProfile = ProfileLevel.Middle
            });
            
            // Documentación siempre
            tasks.Add(new DevelopmentTask
            {
                TaskId = "DOC-001",
                Name = "Documentación técnica",
                Description = "Arquitectura, APIs, despliegue",
                Category = TaskCategory.Documentation,
                Complexity = ComplexityLevel.Simple,
                EstimatedHours = 12,
                RequiredProfile = ProfileLevel.Middle
            });
            
            return tasks;
        }

        // Clases para deserialización
        private class OpenAIResponse
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
'@

Add-Content -Path "$projectPath\Services\EstimationService.cs" -Value $estimationServicePart3

Write-Host "  ✓ EstimationService completado" -ForegroundColor Gray

# ============================================
# PASO 5: Verificar/Actualizar IEstimationService
# ============================================
Write-Host "`n📦 Verificando interfaz IEstimationService..." -ForegroundColor Yellow

if (!(Test-Path "$projectPath\Services\Interfaces\IEstimationService.cs")) {
    @"
using System.Threading.Tasks;
using ProjectEstimatorApp.Models;

namespace ProjectEstimatorApp.Services.Interfaces
{
    public interface IEstimationService
    {
        Task<ProjectEstimation> EstimateProjectAsync(EstimationRequest request);
        ProjectEstimation GetSampleEstimation(string projectName, string prompt);
    }
}
"@ | Out-File -FilePath "$projectPath\Services\Interfaces\IEstimationService.cs" -Encoding UTF8
    Write-Host "  ✓ IEstimationService creado" -ForegroundColor Gray
}

# ============================================
# COMPILAR Y EJECUTAR
# ============================================
Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ PROMPT PROFESIONAL IMPLEMENTADO" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n📋 CARACTERÍSTICAS DEL NUEVO PROMPT:" -ForegroundColor Cyan
Write-Host "  ✅ 20+ años experiencia simulada" -ForegroundColor White
Write-Host "  ✅ Stack Microsoft (.NET 8, C#, Blazor, SQL Server)" -ForegroundColor White
Write-Host "  ✅ Tareas máximo 8 horas" -ForegroundColor White
Write-Host "  ✅ Testing mínimo 25%" -ForegroundColor White
Write-Host "  ✅ Documentación mínimo 10%" -ForegroundColor White
Write-Host "  ✅ Buffer contingencia 15%" -ForegroundColor White
Write-Host "  ✅ Factores de ajuste realistas" -ForegroundColor White
Write-Host "  ✅ Niveles de confianza" -ForegroundColor White
Write-Host "  ✅ Identificación de riesgos" -ForegroundColor White
Write-Host "  ✅ Recomendaciones profesionales" -ForegroundColor White

Write-Host "`n🚀 Compilando proyecto..." -ForegroundColor Yellow

dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡Compilación exitosa!" -ForegroundColor Green
    Write-Host "`n▶️  Ejecutando aplicación..." -ForegroundColor Cyan
    Write-Host "Navega a: https://localhost:5001/estimator" -ForegroundColor Yellow
    dotnet run
} else {
    Write-Host "`n❌ Error en compilación" -ForegroundColor Red
}
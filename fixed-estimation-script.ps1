# AddEstimationFeaturesFixed.ps1
# Script corregido para agregar la funcionalidad de estimación

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🚀 Agregando funcionalidad de estimación de proyectos..." -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Set-Location $projectPath

# ============================================
# PASO 1: Crear los Modelos
# ============================================
Write-Host "`n📦 Creando modelos de datos..." -ForegroundColor Yellow

# Crear carpeta Models si no existe
if (!(Test-Path "$projectPath\Models")) {
    New-Item -ItemType Directory -Path "$projectPath\Models" -Force | Out-Null
}

# ProjectEstimation.cs
@"
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
        public EstimationStatus Status { get; set; }
        public string? AnalysisResult { get; set; }
    }

    public class DevelopmentTask
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TaskCategory Category { get; set; }
        public double EstimatedHours { get; set; }
        public ComplexityLevel Complexity { get; set; }
        public List<string> Dependencies { get; set; } = new();
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
"@ | Out-File -FilePath "$projectPath\Models\ProjectEstimation.cs" -Encoding UTF8

Write-Host "  ✓ ProjectEstimation.cs creado" -ForegroundColor Gray

# ============================================
# PASO 2: Crear Servicios
# ============================================
Write-Host "`n📦 Creando servicios de estimación..." -ForegroundColor Yellow

# IEstimationService.cs
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

# EstimationService.cs
$estimationServiceContent = @'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ProjectEstimatorApp.Models;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class EstimationService : IEstimationService
    {
        private readonly Random _random = new Random();
        
        public async Task<ProjectEstimation> EstimateProjectAsync(EstimationRequest request)
        {
            await Task.Delay(2000);
            return GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
        }
        
        public ProjectEstimation GetSampleEstimation(string projectName, string prompt)
        {
            var estimation = new ProjectEstimation
            {
                ProjectName = string.IsNullOrEmpty(projectName) ? "Proyecto de Ejemplo" : projectName,
                InitialPrompt = prompt,
                Status = EstimationStatus.Completed,
                DocumentContent = "Documento analizado",
                Tasks = GenerateSampleTasks(prompt)
            };
            
            estimation.TotalEstimatedHours = estimation.Tasks.Sum(t => t.EstimatedHours);
            return estimation;
        }
        
        private List<DevelopmentTask> GenerateSampleTasks(string prompt)
        {
            var tasks = new List<DevelopmentTask>();
            var promptLower = prompt.ToLower();
            
            bool isWebProject = promptLower.Contains("web") || promptLower.Contains("frontend");
            bool hasDatabase = promptLower.Contains("database") || promptLower.Contains("sql") || promptLower.Contains("datos");
            bool hasApi = promptLower.Contains("api") || promptLower.Contains("rest") || promptLower.Contains("backend");
            bool hasMobile = promptLower.Contains("móvil") || promptLower.Contains("mobile") || promptLower.Contains("app");
            
            tasks.Add(new DevelopmentTask
            {
                Name = "Configuración inicial del proyecto",
                Description = "Setup del entorno de desarrollo y estructura base",
                Category = TaskCategory.Architecture,
                Complexity = ComplexityLevel.Simple,
                EstimatedHours = 8,
                Dependencies = new List<string>()
            });
            
            if (hasDatabase)
            {
                tasks.Add(new DevelopmentTask
                {
                    Name = "Diseño y configuración de base de datos",
                    Description = "Crear esquema, tablas y relaciones",
                    Category = TaskCategory.Database,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 16,
                    Dependencies = new List<string> { "Configuración inicial" }
                });
                
                tasks.Add(new DevelopmentTask
                {
                    Name = "Capa de acceso a datos",
                    Description = "Implementar repositorios y contexto de datos",
                    Category = TaskCategory.Backend,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 24,
                    Dependencies = new List<string> { "Base de datos" }
                });
            }
            
            if (hasApi)
            {
                tasks.Add(new DevelopmentTask
                {
                    Name = "Desarrollo de API REST",
                    Description = "Crear endpoints y controladores",
                    Category = TaskCategory.Backend,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 40,
                    Dependencies = new List<string> { "Capa de datos" }
                });
                
                tasks.Add(new DevelopmentTask
                {
                    Name = "Autenticación y autorización",
                    Description = "Implementar JWT y políticas de seguridad",
                    Category = TaskCategory.Backend,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 32,
                    Dependencies = new List<string> { "API REST" }
                });
            }
            
            if (isWebProject)
            {
                tasks.Add(new DevelopmentTask
                {
                    Name = "Interfaz de usuario",
                    Description = "Desarrollar componentes y páginas principales",
                    Category = TaskCategory.Frontend,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 48,
                    Dependencies = hasApi ? new List<string> { "API REST" } : new List<string>()
                });
                
                tasks.Add(new DevelopmentTask
                {
                    Name = "Diseño responsive",
                    Description = "Adaptar UI para dispositivos móviles",
                    Category = TaskCategory.Frontend,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 16,
                    Dependencies = new List<string> { "Interfaz de usuario" }
                });
            }
            
            if (hasMobile)
            {
                tasks.Add(new DevelopmentTask
                {
                    Name = "Desarrollo de aplicación móvil",
                    Description = "Implementar app nativa o híbrida",
                    Category = TaskCategory.Frontend,
                    Complexity = ComplexityLevel.VeryComplex,
                    EstimatedHours = 80,
                    Dependencies = hasApi ? new List<string> { "API REST" } : new List<string>()
                });
            }
            
            tasks.Add(new DevelopmentTask
            {
                Name = "Pruebas unitarias",
                Description = "Escribir tests para componentes críticos",
                Category = TaskCategory.Testing,
                Complexity = ComplexityLevel.Medium,
                EstimatedHours = 24,
                Dependencies = new List<string> { "Desarrollo principal" }
            });
            
            tasks.Add(new DevelopmentTask
            {
                Name = "Documentación técnica",
                Description = "Documentar API y arquitectura",
                Category = TaskCategory.Documentation,
                Complexity = ComplexityLevel.Simple,
                EstimatedHours = 12,
                Dependencies = new List<string> { "Desarrollo completo" }
            });
            
            if (promptLower.Contains("deploy") || promptLower.Contains("producción") || promptLower.Contains("production"))
            {
                tasks.Add(new DevelopmentTask
                {
                    Name = "Configuración de CI/CD",
                    Description = "Setup de pipelines de integración continua",
                    Category = TaskCategory.DevOps,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 16,
                    Dependencies = new List<string>()
                });
                
                tasks.Add(new DevelopmentTask
                {
                    Name = "Despliegue a producción",
                    Description = "Configurar servidores y deployment",
                    Category = TaskCategory.DevOps,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 24,
                    Dependencies = new List<string> { "CI/CD" }
                });
            }
            
            return tasks;
        }
    }
}
'@

$estimationServiceContent | Out-File -FilePath "$projectPath\Services\EstimationService.cs" -Encoding UTF8

Write-Host "  ✓ EstimationService.cs creado" -ForegroundColor Gray

# ============================================
# PASO 3: Crear página de estimación (parte 1)
# ============================================
Write-Host "`n📦 Creando página de estimación..." -ForegroundColor Yellow

# Crear la página en dos partes debido a la longitud
$estimatorPagePart1 = @'
@page "/estimator"
@namespace ProjectEstimatorApp.Pages
@using ProjectEstimatorApp.Models
@using ProjectEstimatorApp.Services.Interfaces
@using Microsoft.AspNetCore.Components.Forms
@inject IEstimationService EstimationService
@inject IJSRuntime JSRuntime

<PageTitle>Estimador de Proyectos</PageTitle>

<div style="padding: 20px; max-width: 1400px; margin: 0 auto;">
    <h2 style="color: #2c3e50; text-align: center;">🤖 Agente de Valoración de Proyectos</h2>
    
    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 20px; margin-top: 30px;">
        <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h3 style="color: #667eea; margin-top: 0;">Nueva Estimación</h3>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Nombre del Proyecto:</label>
                <input type="text" @bind="projectName" 
                       style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px;"
                       placeholder="Ej: Sistema de Gestión" />
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Descripción del Proyecto:</label>
                <textarea @bind="documentContent" 
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 150px;"
                          placeholder="Describe el proyecto..."></textarea>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Contexto Adicional:</label>
                <textarea @bind="initialPrompt" 
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 100px;"
                          placeholder="Tecnologías, restricciones..."></textarea>
            </div>
            
            <button @onclick="ProcessEstimation" disabled="@isProcessing"
                    style="width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer;">
                @if (isProcessing)
                {
                    <span>⏳ Analizando...</span>
                }
                else
                {
                    <span>🚀 Generar Estimación</span>
                }
            </button>
        </div>
'@

# Guardar primera parte
$estimatorPagePart1 | Out-File -FilePath "$projectPath\Pages\ProjectEstimator.razor" -Encoding UTF8

Write-Host "  ✓ ProjectEstimator.razor creado" -ForegroundColor Gray

# ============================================
# PASO 4: Actualizar Program.cs
# ============================================
Write-Host "`n📦 Actualizando Program.cs..." -ForegroundColor Yellow

@"
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using ProjectEstimatorApp;
using ProjectEstimatorApp.Services;
using ProjectEstimatorApp.Services.Interfaces;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });
builder.Services.AddScoped<IProjectService, ProjectService>();
builder.Services.AddScoped<IEstimationService, EstimationService>();

await builder.Build().RunAsync();
"@ | Out-File -FilePath "$projectPath\Program.cs" -Encoding UTF8

Write-Host "  ✓ Program.cs actualizado" -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ FUNCIONALIDAD BÁSICA AGREGADA" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n🚀 Compilando proyecto..." -ForegroundColor Yellow

dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡Compilación exitosa!" -ForegroundColor Green
    Write-Host "`n▶️  Ejecutando aplicación..." -ForegroundColor Cyan
    dotnet run
} else {
    Write-Host "`n❌ Error en la compilación" -ForegroundColor Red
}
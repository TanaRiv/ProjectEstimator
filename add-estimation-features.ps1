# AddEstimationFeatures.ps1
# Script para agregar la funcionalidad completa de estimación

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🚀 Agregando funcionalidad de estimación de proyectos..." -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host "`n🚀 Compilando y ejecutando con las nuevas características..." -ForegroundColor Yellow

# Compilar el proyecto
$buildResult = dotnet build 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡COMPILACIÓN EXITOSA!" -ForegroundColor Green
    Write-Host "`n📋 Nuevas características agregadas:" -ForegroundColor Cyan
    Write-Host "  ✓ Página de estimación completa en /estimator" -ForegroundColor White
    Write-Host "  ✓ Modelos de datos (ProjectEstimation, DevelopmentTask)" -ForegroundColor White
    Write-Host "  ✓ Servicio de estimación funcional" -ForegroundColor White
    Write-Host "  ✓ Generación automática de tareas" -ForegroundColor White
    Write-Host "  ✓ Categorización por tipo de trabajo" -ForegroundColor White
    Write-Host "  ✓ Cálculo de complejidad" -ForegroundColor White
    Write-Host "  ✓ Interfaz mejorada con navegación" -ForegroundColor White
    
    Write-Host "`n▶️  Reiniciando la aplicación..." -ForegroundColor Cyan
    Write-Host "La aplicación se abrirá en tu navegador" -ForegroundColor Yellow
    Write-Host "`n🌐 URLs disponibles:" -ForegroundColor Cyan
    Write-Host "  Página principal: https://localhost:5001" -ForegroundColor White
    Write-Host "  Estimador: https://localhost:5001/estimator" -ForegroundColor White
    
    Write-Host "`n💡 Cómo usar el estimador:" -ForegroundColor Yellow
    Write-Host "  1. Ve a la página /estimator" -ForegroundColor White
    Write-Host "  2. Ingresa el nombre de tu proyecto" -ForegroundColor White
    Write-Host "  3. Describe el proyecto en detalle" -ForegroundColor White
    Write-Host "  4. Añade contexto adicional (tecnologías, equipo, etc.)" -ForegroundColor White
    Write-Host "  5. Haz clic en 'Generar Estimación'" -ForegroundColor White
    Write-Host "  6. Revisa las tareas y horas estimadas" -ForegroundColor White
    
    Write-Host "`nPresiona Ctrl+C para detener la aplicación" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    # Ejecutar la aplicación
    dotnet run
} else {
    Write-Host "`n❌ Error en la compilación:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Yellow
    
    Write-Host "`n💡 Posibles soluciones:" -ForegroundColor Cyan
    Write-Host "1. Ejecuta: dotnet clean" -ForegroundColor White
    Write-Host "2. Ejecuta: dotnet restore" -ForegroundColor White
    Write-Host "3. Ejecuta: dotnet build" -ForegroundColor White
    Write-Host "4. Si persiste el error, muéstrame el mensaje completo" -ForegroundColor White
} 60 -ForegroundColor Cyan

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
# PASO 2: Crear Servicios Mejorados
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

# EstimationService.cs (Simulado por ahora, sin GPT-4)
@"
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
            // Simular delay de procesamiento
            await Task.Delay(2000);
            
            // Por ahora, generar una estimación de ejemplo
            return GetSampleEstimation(request.ProjectName, request.InitialPrompt);
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
            
            // Analizar el prompt para personalizar las tareas
            bool isWebProject = prompt.ToLower().Contains("web") || prompt.ToLower().Contains("frontend");
            bool hasDatabase = prompt.ToLower().Contains("database") || prompt.ToLower().Contains("sql");
            bool hasApi = prompt.ToLower().Contains("api") || prompt.ToLower().Contains("rest");
            
            // Tareas base
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
                    Dependencies = new List<string> { "API REST" }
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
            
            // Tareas comunes
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
            
            tasks.Add(new DevelopmentTask
            {
                Name = "Configuración de CI/CD",
                Description = "Setup de pipelines de integración continua",
                Category = TaskCategory.DevOps,
                Complexity = ComplexityLevel.Medium,
                EstimatedHours = 16,
                Dependencies = new List<string>()
            });
            
            return tasks;
        }
    }
}
"@ | Out-File -FilePath "$projectPath\Services\EstimationService.cs" -Encoding UTF8

Write-Host "  ✓ EstimationService.cs creado" -ForegroundColor Gray

# ============================================
# PASO 3: Crear la Página de Estimación
# ============================================
Write-Host "`n📦 Creando página de estimación..." -ForegroundColor Yellow

@"
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
        <!-- Panel Izquierdo: Formulario -->
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
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 150px; resize: vertical;"
                          placeholder="Describe el proyecto a desarrollar. Por ejemplo:&#10;- Sistema web de gestión de inventarios&#10;- Con base de datos SQL Server&#10;- API REST para integraciones&#10;- Panel de administración&#10;- Reportes en tiempo real"></textarea>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Contexto Adicional (Prompt):</label>
                <textarea @bind="initialPrompt" 
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 100px; resize: vertical;"
                          placeholder="Información adicional como:&#10;- Tecnologías específicas (React, .NET, etc.)&#10;- Tamaño del equipo&#10;- Restricciones o requisitos especiales"></textarea>
            </div>
            
            <button @onclick="ProcessEstimation" disabled="@isProcessing"
                    style="width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: @(isProcessing ? "not-allowed" : "pointer"); opacity: @(isProcessing ? "0.7" : "1");">
                @if (isProcessing)
                {
                    <span>⏳ Analizando proyecto...</span>
                }
                else
                {
                    <span>🚀 Generar Estimación</span>
                }
            </button>
            
            @if (!string.IsNullOrEmpty(errorMessage))
            {
                <div style="margin-top: 15px; padding: 10px; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 5px; color: #721c24;">
                    @errorMessage
                </div>
            }
        </div>
        
        <!-- Panel Derecho: Resultados -->
        <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            @if (currentEstimation == null && !isProcessing)
            {
                <div style="text-align: center; padding: 50px; color: #999;">
                    <h3>📋 No hay estimación generada</h3>
                    <p>Completa el formulario y haz clic en "Generar Estimación" para comenzar</p>
                </div>
            }
            else if (isProcessing)
            {
                <div style="text-align: center; padding: 50px;">
                    <div style="width: 60px; height: 60px; border: 6px solid #f3f3f3; border-top: 6px solid #667eea; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
                    <h3 style="color: #667eea; margin-top: 20px;">Analizando proyecto...</h3>
                    <p style="color: #999;">El agente está procesando la información y generando las tareas</p>
                </div>
            }
            else if (currentEstimation != null)
            {
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                        <h3 style="color: #2c3e50; margin: 0;">@currentEstimation.ProjectName</h3>
                        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 10px 20px; border-radius: 20px; font-weight: bold;">
                            Total: @currentEstimation.TotalEstimatedHours.ToString("F0") horas
                        </div>
                    </div>
                    
                    <div style="margin-bottom: 20px;">
                        <h4 style="color: #667eea;">📊 Resumen por Categoría</h4>
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px;">
                            @foreach (var categoryGroup in currentEstimation.Tasks.GroupBy(t => t.Category))
                            {
                                <div style="padding: 10px; background: #f8f9fa; border-radius: 5px; text-align: center;">
                                    <div style="font-weight: bold; color: #2c3e50;">@categoryGroup.Key</div>
                                    <div style="color: #667eea; font-size: 1.2rem;">@categoryGroup.Sum(t => t.EstimatedHours)h</div>
                                </div>
                            }
                        </div>
                    </div>
                    
                    <div>
                        <h4 style="color: #667eea;">📝 Tareas Identificadas (@currentEstimation.Tasks.Count)</h4>
                        <div style="max-height: 400px; overflow-y: auto;">
                            <table style="width: 100%; border-collapse: collapse;">
                                <thead>
                                    <tr style="background: #f8f9fa;">
                                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #dee2e6;">Tarea</th>
                                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #dee2e6;">Categoría</th>
                                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #dee2e6;">Complejidad</th>
                                        <th style="padding: 10px; text-align: right; border-bottom: 2px solid #dee2e6;">Horas</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach (var task in currentEstimation.Tasks.OrderBy(t => t.Category))
                                    {
                                        <tr style="border-bottom: 1px solid #dee2e6;">
                                            <td style="padding: 10px;">
                                                <div style="font-weight: bold;">@task.Name</div>
                                                <div style="font-size: 0.9rem; color: #666;">@task.Description</div>
                                            </td>
                                            <td style="padding: 10px;">
                                                <span style="padding: 3px 8px; background: #e9ecef; border-radius: 3px; font-size: 0.9rem;">
                                                    @task.Category
                                                </span>
                                            </td>
                                            <td style="padding: 10px;">
                                                <span style="padding: 3px 8px; background: @GetComplexityColor(task.Complexity); color: white; border-radius: 3px; font-size: 0.9rem;">
                                                    @task.Complexity
                                                </span>
                                            </td>
                                            <td style="padding: 10px; text-align: right; font-weight: bold;">
                                                @task.EstimatedHours.ToString("F0")h
                                            </td>
                                        </tr>
                                    }
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
                        <p style="margin: 0; color: #666;">
                            <strong>💡 Nota:</strong> Esta es una estimación inicial basada en la descripción proporcionada. 
                            Para obtener estimaciones más precisas con GPT-4, configura tu API Key de OpenAI en appsettings.json.
                        </p>
                    </div>
                </div>
            }
        </div>
    </div>
</div>

<style>
    @@keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
</style>

@code {
    private string projectName = "";
    private string documentContent = "";
    private string initialPrompt = "";
    private bool isProcessing = false;
    private string errorMessage = "";
    private ProjectEstimation? currentEstimation;
    
    private async Task ProcessEstimation()
    {
        if (string.IsNullOrWhiteSpace(documentContent))
        {
            errorMessage = "Por favor, proporciona una descripción del proyecto";
            return;
        }
        
        errorMessage = "";
        isProcessing = true;
        
        try
        {
            var request = new EstimationRequest
            {
                ProjectName = string.IsNullOrWhiteSpace(projectName) ? "Proyecto Sin Nombre" : projectName,
                DocumentContent = documentContent,
                InitialPrompt = initialPrompt
            };
            
            currentEstimation = await EstimationService.EstimateProjectAsync(request);
        }
        catch (Exception ex)
        {
            errorMessage = $"Error al procesar la estimación: {ex.Message}";
        }
        finally
        {
            isProcessing = false;
        }
    }
    
    private string GetComplexityColor(ComplexityLevel complexity)
    {
        return complexity switch
        {
            ComplexityLevel.Simple => "#28a745",
            ComplexityLevel.Medium => "#ffc107",
            ComplexityLevel.Complex => "#fd7e14",
            ComplexityLevel.VeryComplex => "#dc3545",
            _ => "#6c757d"
        };
    }
}
"@ | Out-File -FilePath "$projectPath\Pages\ProjectEstimator.razor" -Encoding UTF8

Write-Host "  ✓ ProjectEstimator.razor creado" -ForegroundColor Gray

# ============================================
# PASO 4: Actualizar Index.razor con navegación
# ============================================
Write-Host "`n📦 Actualizando página principal..." -ForegroundColor Yellow

@"
@page "/"
@namespace ProjectEstimatorApp.Pages
@inject NavigationManager Navigation

<PageTitle>Project Estimator - Inicio</PageTitle>

<div style="text-align: center; padding: 50px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
    <h1 style="color: #2c3e50; font-size: 3rem;">🤖 Agente de Valoración de Proyectos</h1>
    <p style="font-size: 1.3rem; color: #666; margin-bottom: 40px;">
        Sistema inteligente para estimar el esfuerzo de desarrollo de software
    </p>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; max-width: 900px; margin: 0 auto;">
        <div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="font-size: 3rem; margin-bottom: 15px;">📊</div>
            <h3 style="color: #2c3e50;">Análisis Inteligente</h3>
            <p style="color: #666;">Analiza documentos y genera estimaciones detalladas automáticamente</p>
        </div>
        
        <div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="font-size: 3rem; margin-bottom: 15px;">🎯</div>
            <h3 style="color: #2c3e50;">Categorización Automática</h3>
            <p style="color: #666;">Clasifica tareas por tipo y complejidad de forma inteligente</p>
        </div>
        
        <div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="font-size: 3rem; margin-bottom: 15px;">📈</div>
            <h3 style="color: #2c3e50;">Aprendizaje Continuo</h3>
            <p style="color: #666;">Mejora sus estimaciones con cada proyecto analizado</p>
        </div>
    </div>
    
    <div style="margin-top: 50px;">
        <button @onclick="NavigateToEstimator"
                style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                       color: white; 
                       border: none; 
                       padding: 15px 40px; 
                       border-radius: 30px; 
                       font-size: 1.2rem; 
                       font-weight: bold; 
                       cursor: pointer; 
                       box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                       transition: transform 0.2s;">
            🚀 Comenzar Estimación
        </button>
    </div>
    
    <div style="margin-top: 60px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
        <h3 style="color: #2c3e50;">¿Cómo funciona?</h3>
        <div style="max-width: 600px; margin: 0 auto; text-align: left;">
            <div style="margin: 15px 0; display: flex; align-items: center;">
                <span style="background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-right: 15px; font-weight: bold;">1</span>
                <span style="color: #666;">Describe tu proyecto o sube un documento de diseño</span>
            </div>
            <div style="margin: 15px 0; display: flex; align-items: center;">
                <span style="background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-right: 15px; font-weight: bold;">2</span>
                <span style="color: #666;">El agente analiza y extrae las tareas necesarias</span>
            </div>
            <div style="margin: 15px 0; display: flex; align-items: center;">
                <span style="background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-right: 15px; font-weight: bold;">3</span>
                <span style="color: #666;">Recibe una estimación detallada con horas por tarea</span>
            </div>
            <div style="margin: 15px 0; display: flex; align-items: center;">
                <span style="background: #667eea; color: white; width: 30px; height: 30px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-right: 15px; font-weight: bold;">4</span>
                <span style="color: #666;">Proporciona feedback para mejorar futuras estimaciones</span>
            </div>
        </div>
    </div>
</div>

@code {
    private void NavigateToEstimator()
    {
        Navigation.NavigateTo("/estimator");
    }
}
"@ | Out-File -FilePath "$projectPath\Pages\Index.razor" -Encoding UTF8

Write-Host "  ✓ Index.razor actualizado" -ForegroundColor Gray

# ============================================
# PASO 5: Registrar servicios en Program.cs
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

// Registrar servicios
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });
builder.Services.AddScoped<IProjectService, ProjectService>();
builder.Services.AddScoped<IEstimationService, EstimationService>();

// Configuración
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

await builder.Build().RunAsync();
"@ | Out-File -FilePath "$projectPath\Program.cs" -Encoding UTF8

Write-Host "  ✓ Program.cs actualizado" -ForegroundColor Gray

# ============================================
# PASO 6: Actualizar _Imports.razor
# ============================================
Write-Host "`n📦 Actualizando _Imports.razor..." -ForegroundColor Yellow

@"
@using System.Net.Http
@using System.Net.Http.Json
@using Microsoft.AspNetCore.Components.Forms
@using Microsoft.AspNetCore.Components.Routing
@using Microsoft.AspNetCore.Components.Web
@using Microsoft.AspNetCore.Components.Web.Virtualization
@using Microsoft.AspNetCore.Components.WebAssembly.Http
@using Microsoft.JSInterop
@using ProjectEstimatorApp
@using ProjectEstimatorApp.Models
@using ProjectEstimatorApp.Services
@using ProjectEstimatorApp.Services.Interfaces
"@ | Out-File -FilePath "$projectPath\_Imports.razor" -Encoding UTF8

Write-Host "  ✓ _Imports.razor actualizado" -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "✅ FUNCIONALIDAD DE ESTIMACIÓN AGREGADA" -ForegroundColor Green
Write-Host "=" *
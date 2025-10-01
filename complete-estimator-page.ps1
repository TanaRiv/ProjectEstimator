# CompleteEstimatorPage.ps1
# Script para crear la página completa del estimador

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🔧 Completando página del estimador..." -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Set-Location $projectPath

# ============================================
# Eliminar archivos problemáticos primero
# ============================================
Write-Host "`n🧹 Limpiando archivos anteriores..." -ForegroundColor Yellow

# Renombrar el archivo problemático de IProjectEstimationAgent si existe
$problemFile = "$projectPath\Services\Interfaces\IProjectEstimationAgent.cs"
if (Test-Path $problemFile) {
    Remove-Item $problemFile -Force
    Write-Host "  ✓ Archivo problemático eliminado" -ForegroundColor Gray
}

# ============================================
# Crear la página completa del estimador
# ============================================
Write-Host "`n📦 Creando página completa del estimador..." -ForegroundColor Yellow

@'
@page "/estimator"
@namespace ProjectEstimatorApp.Pages
@using ProjectEstimatorApp.Models
@using ProjectEstimatorApp.Services.Interfaces
@inject IEstimationService EstimationService

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
                          placeholder="Describe el proyecto. Ej: Sistema web con base de datos, API REST, autenticación..."></textarea>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Contexto Adicional:</label>
                <textarea @bind="initialPrompt" 
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 100px; resize: vertical;"
                          placeholder="Tecnologías específicas, tamaño del equipo, restricciones..."></textarea>
            </div>
            
            <button @onclick="ProcessEstimation" disabled="@isProcessing"
                    style="width: 100%; padding: 12px; background: @(isProcessing ? "#999" : "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"); color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: @(isProcessing ? "not-allowed" : "pointer");">
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
                    <div style="font-size: 4rem;">📋</div>
                    <h3>No hay estimación generada</h3>
                    <p>Completa el formulario y haz clic en "Generar Estimación"</p>
                    
                    <div style="margin-top: 30px; text-align: left; background: #f8f9fa; padding: 20px; border-radius: 5px;">
                        <h4 style="color: #2c3e50;">💡 Ejemplos de descripción:</h4>
                        <p style="color: #666;"><strong>Ejemplo 1:</strong> "Sistema web de gestión de inventarios con base de datos SQL, API REST, panel de administración y reportes"</p>
                        <p style="color: #666;"><strong>Ejemplo 2:</strong> "Aplicación móvil con backend en la nube, autenticación, notificaciones push y pagos en línea"</p>
                        <p style="color: #666;"><strong>Ejemplo 3:</strong> "API REST para integración con sistemas externos, con autenticación JWT y documentación Swagger"</p>
                    </div>
                </div>
            }
            else if (isProcessing)
            {
                <div style="text-align: center; padding: 50px;">
                    <div class="spinner"></div>
                    <h3 style="color: #667eea; margin-top: 20px;">Analizando proyecto...</h3>
                    <p style="color: #999;">El agente está procesando la información</p>
                </div>
            }
            else if (currentEstimation != null)
            {
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #e9ecef;">
                        <h3 style="color: #2c3e50; margin: 0;">📁 @currentEstimation.ProjectName</h3>
                        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 10px 20px; border-radius: 20px; font-weight: bold; font-size: 1.2rem;">
                            @currentEstimation.TotalEstimatedHours.ToString("F0") horas
                        </div>
                    </div>
                    
                    @if (currentEstimation.Tasks.Any())
                    {
                        <div style="margin-bottom: 20px;">
                            <h4 style="color: #667eea;">📊 Resumen por Categoría</h4>
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 10px;">
                                @foreach (var group in currentEstimation.Tasks.GroupBy(t => t.Category))
                                {
                                    <div style="padding: 10px; background: #f8f9fa; border-radius: 5px; text-align: center; border: 1px solid #dee2e6;">
                                        <div style="font-size: 0.9rem; color: #6c757d;">@group.Key</div>
                                        <div style="color: #667eea; font-size: 1.5rem; font-weight: bold;">@group.Sum(t => t.EstimatedHours)h</div>
                                    </div>
                                }
                            </div>
                        </div>
                        
                        <div>
                            <h4 style="color: #667eea;">📝 Tareas Detalladas</h4>
                            <div style="max-height: 400px; overflow-y: auto;">
                                @foreach (var task in currentEstimation.Tasks.OrderBy(t => t.Category))
                                {
                                    <div style="padding: 15px; margin-bottom: 10px; background: #f8f9fa; border-radius: 5px; border-left: 4px solid @GetCategoryColor(task.Category);">
                                        <div style="display: flex; justify-content: space-between; align-items: start;">
                                            <div style="flex: 1;">
                                                <h5 style="margin: 0 0 5px 0; color: #2c3e50;">@task.Name</h5>
                                                <p style="margin: 0 0 10px 0; color: #6c757d; font-size: 0.9rem;">@task.Description</p>
                                                <div style="display: flex; gap: 10px;">
                                                    <span style="padding: 2px 8px; background: white; border-radius: 3px; font-size: 0.85rem; color: #495057;">
                                                        @task.Category
                                                    </span>
                                                    <span style="padding: 2px 8px; background: @GetComplexityColor(task.Complexity); color: white; border-radius: 3px; font-size: 0.85rem;">
                                                        @task.Complexity
                                                    </span>
                                                </div>
                                            </div>
                                            <div style="text-align: right;">
                                                <div style="font-size: 1.5rem; font-weight: bold; color: #667eea;">@task.EstimatedHours.ToString("F0")h</div>
                                            </div>
                                        </div>
                                    </div>
                                }
                            </div>
                        </div>
                        
                        <div style="margin-top: 20px; padding: 15px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 5px;">
                            <p style="margin: 0; color: #495057;">
                                <strong>📌 Nota:</strong> Esta estimación se basa en el análisis de la descripción proporcionada. 
                                Los tiempos pueden variar según la experiencia del equipo y los requisitos específicos del proyecto.
                            </p>
                        </div>
                    }
                </div>
            }
        </div>
    </div>
</div>

<style>
    .spinner {
        width: 60px;
        height: 60px;
        border: 6px solid #f3f3f3;
        border-top: 6px solid #667eea;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin: 0 auto;
    }
    
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
        errorMessage = "";
        
        if (string.IsNullOrWhiteSpace(documentContent))
        {
            errorMessage = "Por favor, proporciona una descripción del proyecto";
            return;
        }
        
        isProcessing = true;
        StateHasChanged();
        
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
            errorMessage = $"Error: {ex.Message}";
        }
        finally
        {
            isProcessing = false;
            StateHasChanged();
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
    
    private string GetCategoryColor(TaskCategory category)
    {
        return category switch
        {
            TaskCategory.Backend => "#667eea",
            TaskCategory.Frontend => "#764ba2",
            TaskCategory.Database => "#17a2b8",
            TaskCategory.Testing => "#28a745",
            TaskCategory.Documentation => "#6c757d",
            TaskCategory.DevOps => "#fd7e14",
            TaskCategory.Architecture => "#dc3545",
            TaskCategory.Infrastructure => "#ffc107",
            _ => "#6c757d"
        };
    }
}
'@ | Out-File -FilePath "$projectPath\Pages\ProjectEstimator.razor" -Encoding UTF8

Write-Host "  ✓ ProjectEstimator.razor completado" -ForegroundColor Gray

# ============================================
# Actualizar la página Index con navegación
# ============================================
Write-Host "`n📦 Actualizando página Index..." -ForegroundColor Yellow

@'
@page "/"
@namespace ProjectEstimatorApp.Pages
@inject NavigationManager Navigation

<PageTitle>Project Estimator - Inicio</PageTitle>

<div style="text-align: center; padding: 50px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
    <h1 style="color: #2c3e50; font-size: 3rem;">🤖 Agente de Valoración de Proyectos</h1>
    <p style="font-size: 1.3rem; color: #666; margin-bottom: 40px;">
        Sistema inteligente para estimar el esfuerzo de desarrollo
    </p>
    
    <div style="margin-top: 50px;">
        <button @onclick="GoToEstimator"
                style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                       color: white; 
                       border: none; 
                       padding: 15px 40px; 
                       border-radius: 30px; 
                       font-size: 1.2rem; 
                       font-weight: bold; 
                       cursor: pointer; 
                       box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);">
            🚀 Ir al Estimador
        </button>
    </div>
    
    <div style="margin-top: 60px;">
        <h3 style="color: #2c3e50;">Características</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; max-width: 800px; margin: 0 auto;">
            <div style="padding: 20px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <div style="font-size: 2rem;">📊</div>
                <h4>Análisis Inteligente</h4>
                <p style="color: #666;">Genera estimaciones basadas en la descripción del proyecto</p>
            </div>
            <div style="padding: 20px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <div style="font-size: 2rem;">🎯</div>
                <h4>Categorización</h4>
                <p style="color: #666;">Organiza tareas por tipo y complejidad automáticamente</p>
            </div>
            <div style="padding: 20px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <div style="font-size: 2rem;">⏱️</div>
                <h4>Estimación Precisa</h4>
                <p style="color: #666;">Calcula horas basándose en mejores prácticas</p>
            </div>
        </div>
    </div>
</div>

@code {
    private void GoToEstimator()
    {
        Navigation.NavigateTo("/estimator");
    }
}
'@ | Out-File -FilePath "$projectPath\Pages\Index.razor" -Encoding UTF8

Write-Host "  ✓ Index.razor actualizado" -ForegroundColor Gray

# ============================================
# Actualizar _Imports.razor
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
@using Microsoft.AspNetCore.Components.Authorization
@using Microsoft.JSInterop
@using ProjectEstimatorApp
@using ProjectEstimatorApp.Models
@using ProjectEstimatorApp.Services
@using ProjectEstimatorApp.Services.Interfaces
"@ | Out-File -FilePath "$projectPath\_Imports.razor" -Encoding UTF8

Write-Host "  ✓ _Imports.razor actualizado" -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ PÁGINA DEL ESTIMADOR COMPLETADA" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n🚀 Compilando proyecto..." -ForegroundColor Yellow

# Limpiar y compilar
dotnet clean | Out-Null
dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡Compilación exitosa!" -ForegroundColor Green
    Write-Host "`n📋 Funcionalidades disponibles:" -ForegroundColor Cyan
    Write-Host "  ✓ Página principal con navegación" -ForegroundColor White
    Write-Host "  ✓ Estimador completo en /estimator" -ForegroundColor White
    Write-Host "  ✓ Generación automática de tareas" -ForegroundColor White
    Write-Host "  ✓ Categorización y cálculo de horas" -ForegroundColor White
    Write-Host "  ✓ Interfaz visual atractiva" -ForegroundColor White
    
    Write-Host "`n▶️  Ejecutando aplicación..." -ForegroundColor Cyan
    Write-Host "Navega a: https://localhost:5001/estimator" -ForegroundColor Yellow
    
    dotnet run
} else {
    Write-Host "`n❌ Error en la compilación" -ForegroundColor Red
    Write-Host "Intenta ejecutar manualmente:" -ForegroundColor Yellow
    Write-Host "dotnet clean" -ForegroundColor White
    Write-Host "dotnet restore" -ForegroundColor White
    Write-Host "dotnet build" -ForegroundColor White
}

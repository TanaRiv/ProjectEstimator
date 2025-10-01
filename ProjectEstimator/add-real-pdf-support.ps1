# AddRealPdfSupport.ps1
# Script para agregar soporte real de lectura de PDFs

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "📄 Agregando soporte real para PDFs con iText7..." -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Set-Location $projectPath

# ============================================
# PASO 1: Instalar paquete iText7
# ============================================
Write-Host "`n📦 Instalando iText7..." -ForegroundColor Yellow

dotnet add package itext7 --version 8.0.2
dotnet add package itext7.bouncy-castle-adapter --version 8.0.2

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ iText7 instalado correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error instalando iText7" -ForegroundColor Red
    exit
}

# ============================================
# PASO 2: Crear servicio de lectura de PDF
# ============================================
Write-Host "`n📦 Creando servicio de lectura de PDF..." -ForegroundColor Yellow

# Interfaz IPdfService
@"
using System.Threading.Tasks;

namespace ProjectEstimatorApp.Services.Interfaces
{
    public interface IPdfService
    {
        Task<string> ExtractTextFromPdfAsync(byte[] pdfBytes);
        string ExtractTextFromPdf(byte[] pdfBytes);
    }
}
"@ | Out-File -FilePath "$projectPath\Services\Interfaces\IPdfService.cs" -Encoding UTF8

# Implementación PdfService
@'
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas.Parser;
using iText.Kernel.Pdf.Canvas.Parser.Listener;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class PdfService : IPdfService
    {
        public async Task<string> ExtractTextFromPdfAsync(byte[] pdfBytes)
        {
            return await Task.Run(() => ExtractTextFromPdf(pdfBytes));
        }

        public string ExtractTextFromPdf(byte[] pdfBytes)
        {
            try
            {
                using (var stream = new MemoryStream(pdfBytes))
                {
                    using (var pdfReader = new PdfReader(stream))
                    {
                        using (var pdfDoc = new PdfDocument(pdfReader))
                        {
                            var strategy = new SimpleTextExtractionStrategy();
                            var extractedText = new StringBuilder();
                            
                            // Extraer texto de todas las páginas
                            for (int pageNum = 1; pageNum <= pdfDoc.GetNumberOfPages(); pageNum++)
                            {
                                var page = pdfDoc.GetPage(pageNum);
                                var text = PdfTextExtractor.GetTextFromPage(page, strategy);
                                
                                if (!string.IsNullOrWhiteSpace(text))
                                {
                                    extractedText.AppendLine($"--- Página {pageNum} ---");
                                    extractedText.AppendLine(text);
                                    extractedText.AppendLine();
                                }
                            }
                            
                            var result = extractedText.ToString();
                            
                            if (string.IsNullOrWhiteSpace(result))
                            {
                                return "No se pudo extraer texto del PDF. El archivo podría estar vacío o contener solo imágenes.";
                            }
                            
                            return result;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return $"Error al procesar el PDF: {ex.Message}";
            }
        }
    }
}
'@ | Out-File -FilePath "$projectPath\Services\PdfService.cs" -Encoding UTF8

Write-Host "  ✓ PdfService.cs creado" -ForegroundColor Gray

# ============================================
# PASO 3: Actualizar página del estimador
# ============================================
Write-Host "`n📦 Actualizando página del estimador con lectura real de PDF..." -ForegroundColor Yellow

@'
@page "/estimator"
@namespace ProjectEstimatorApp.Pages
@using ProjectEstimatorApp.Models
@using ProjectEstimatorApp.Services.Interfaces
@using Microsoft.AspNetCore.Components.Forms
@inject IEstimationService EstimationService
@inject IOpenAIService OpenAIService
@inject IPdfService PdfService

<PageTitle>Estimador de Proyectos</PageTitle>

<div style="padding: 20px; max-width: 1400px; margin: 0 auto;">
    <h2 style="color: #2c3e50; text-align: center;">🤖 Agente de Valoración de Proyectos</h2>
    
    <!-- Alerta sobre OpenAI -->
    @if (!OpenAIService.IsConfigured())
    {
        <div style="margin: 20px 0; padding: 15px; background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 5px;">
            <strong>⚠️ OpenAI no configurado:</strong> El sistema está usando estimaciones locales. 
            Para usar GPT-4, configura tu API Key en wwwroot/appsettings.json
        </div>
    }
    else
    {
        <div style="margin: 20px 0; padding: 15px; background-color: #d4edda; border: 1px solid #28a745; border-radius: 5px;">
            <strong>✅ OpenAI configurado:</strong> Usando GPT-4 para estimaciones inteligentes
        </div>
    }
    
    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 20px; margin-top: 30px;">
        <!-- Panel Izquierdo: Formulario -->
        <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h3 style="color: #667eea; margin-top: 0;">Nueva Estimación</h3>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">📁 Cargar PDF con Especificaciones:</label>
                <InputFile OnChange="@LoadPdfFile" accept=".pdf" style="width: 100%;" />
                @if (!string.IsNullOrEmpty(uploadedFileName))
                {
                    <div style="margin-top: 5px; padding: 5px; background: #d4edda; border-radius: 3px;">
                        <span style="color: green;">✓ @uploadedFileName cargado</span>
                        @if (pdfPageCount > 0)
                        {
                            <span style="color: #666;"> (@pdfPageCount páginas, @pdfTextLength caracteres)</span>
                        }
                    </div>
                }
                @if (isProcessingPdf)
                {
                    <div style="margin-top: 5px; color: #007bff;">
                        ⏳ Procesando PDF...
                    </div>
                }
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Nombre del Proyecto:</label>
                <input type="text" @bind="projectName" 
                       style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px;"
                       placeholder="Ej: Sistema de Gestión" />
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">
                    Descripción del Proyecto: 
                    @if (!string.IsNullOrEmpty(documentContent))
                    {
                        <span style="color: green; font-weight: normal;">(PDF cargado)</span>
                    }
                </label>
                <textarea @bind="documentContent" 
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 150px; resize: vertical; font-family: monospace; font-size: 0.9rem;"
                          placeholder="El contenido del PDF aparecerá aquí, o puedes escribir/pegar directamente..."></textarea>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">Contexto Adicional:</label>
                <textarea @bind="initialPrompt" 
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 5px; min-height: 100px; resize: vertical;"
                          placeholder="Ej: Equipo de 3 desarrolladores, stack .NET y React, 3 meses de plazo..."></textarea>
            </div>
            
            <button @onclick="ProcessEstimation" disabled="@(isProcessing || isProcessingPdf)"
                    style="width: 100%; padding: 12px; background: @(isProcessing || isProcessingPdf ? "#999" : "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"); color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: @(isProcessing || isProcessingPdf ? "not-allowed" : "pointer");">
                @if (isProcessing)
                {
                    <span>⏳ Analizando con @(OpenAIService.IsConfigured() ? "GPT-4" : "Motor Local")...</span>
                }
                else if (isProcessingPdf)
                {
                    <span>⏳ Procesando PDF...</span>
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
            
            @if (!string.IsNullOrEmpty(successMessage))
            {
                <div style="margin-top: 15px; padding: 10px; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 5px; color: #155724;">
                    @successMessage
                </div>
            }
        </div>
        
        <!-- Panel Derecho: Resultados -->
        <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-height: 80vh; overflow-y: auto;">
            @if (currentEstimation == null && !isProcessing)
            {
                <div style="text-align: center; padding: 50px; color: #999;">
                    <div style="font-size: 4rem;">📋</div>
                    <h3>No hay estimación generada</h3>
                    <p>Sube un PDF o completa el formulario y haz clic en "Generar Estimación"</p>
                    
                    <div style="margin-top: 30px; text-align: left; background: #f8f9fa; padding: 20px; border-radius: 5px;">
                        <h4 style="color: #2c3e50;">💡 Cómo usar:</h4>
                        <ol style="color: #666; text-align: left;">
                            <li><strong>Opción 1 - Con PDF:</strong> Carga un PDF con las especificaciones del proyecto</li>
                            <li><strong>Opción 2 - Manual:</strong> Escribe o pega la descripción del proyecto</li>
                            <li>Añade contexto adicional (tecnologías, equipo, plazos)</li>
                            <li>Haz clic en "Generar Estimación"</li>
                        </ol>
                        
                        <h5 style="color: #2c3e50; margin-top: 15px;">📄 Formatos de PDF soportados:</h5>
                        <ul style="color: #666;">
                            <li>Documentos de Word exportados a PDF</li>
                            <li>Especificaciones técnicas</li>
                            <li>Propuestas de proyecto</li>
                            <li>Documentos de requisitos</li>
                        </ul>
                    </div>
                </div>
            }
            else if (isProcessing)
            {
                <div style="text-align: center; padding: 50px;">
                    <div class="spinner"></div>
                    <h3 style="color: #667eea; margin-top: 20px;">
                        @if (OpenAIService.IsConfigured())
                        {
                            <span>Analizando con GPT-4...</span>
                        }
                        else
                        {
                            <span>Analizando proyecto...</span>
                        }
                    </h3>
                    <p style="color: #999;">Esto puede tomar unos segundos</p>
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
                            <h4 style="color: #667eea;">📝 Tareas Identificadas (@currentEstimation.Tasks.Count)</h4>
                            @foreach (var task in currentEstimation.Tasks.OrderBy(t => t.Category))
                            {
                                <div style="padding: 15px; margin-bottom: 10px; background: #f8f9fa; border-radius: 5px; border-left: 4px solid @GetCategoryColor(task.Category);">
                                    <div style="display: flex; justify-content: space-between;">
                                        <div style="flex: 1;">
                                            <h5 style="margin: 0 0 5px 0; color: #2c3e50;">@task.Name</h5>
                                            <p style="margin: 0 0 10px 0; color: #6c757d; font-size: 0.9rem;">@task.Description</p>
                                            <div style="display: flex; gap: 10px;">
                                                <span style="padding: 2px 8px; background: white; border-radius: 3px; font-size: 0.85rem;">
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
    private string uploadedFileName = "";
    private int pdfPageCount = 0;
    private int pdfTextLength = 0;
    private bool isProcessing = false;
    private bool isProcessingPdf = false;
    private string errorMessage = "";
    private string successMessage = "";
    private ProjectEstimation? currentEstimation;
    
    private async Task LoadPdfFile(InputFileChangeEventArgs e)
    {
        errorMessage = "";
        successMessage = "";
        isProcessingPdf = true;
        StateHasChanged();
        
        try
        {
            var file = e.File;
            uploadedFileName = file.Name;
            
            // Leer el archivo PDF (máximo 10MB)
            using var stream = file.OpenReadStream(maxAllowedSize: 10 * 1024 * 1024);
            using var memoryStream = new MemoryStream();
            await stream.CopyToAsync(memoryStream);
            var pdfBytes = memoryStream.ToArray();
            
            // Extraer texto del PDF usando iText7
            var extractedText = await PdfService.ExtractTextFromPdfAsync(pdfBytes);
            
            if (!string.IsNullOrWhiteSpace(extractedText) && !extractedText.StartsWith("Error"))
            {
                documentContent = extractedText;
                pdfTextLength = extractedText.Length;
                pdfPageCount = extractedText.Split("--- Página").Length - 1;
                
                successMessage = $"✅ PDF procesado exitosamente: {pdfPageCount} páginas, {pdfTextLength:N0} caracteres extraídos";
                
                // Intentar extraer el nombre del proyecto del contenido
                if (string.IsNullOrWhiteSpace(projectName))
                {
                    var lines = extractedText.Split('\n');
                    var possibleTitle = lines.FirstOrDefault(l => l.Length > 5 && l.Length < 100);
                    if (!string.IsNullOrWhiteSpace(possibleTitle))
                    {
                        projectName = possibleTitle.Trim();
                    }
                }
            }
            else
            {
                errorMessage = extractedText.StartsWith("Error") ? extractedText : "No se pudo extraer texto del PDF";
            }
        }
        catch (Exception ex)
        {
            errorMessage = $"Error al procesar el PDF: {ex.Message}";
        }
        finally
        {
            isProcessingPdf = false;
            StateHasChanged();
        }
    }
    
    private async Task ProcessEstimation()
    {
        errorMessage = "";
        successMessage = "";
        
        if (string.IsNullOrWhiteSpace(documentContent))
        {
            errorMessage = "Por favor, proporciona una descripción del proyecto o carga un PDF";
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
            
            if (currentEstimation.Status == EstimationStatus.Failed)
            {
                errorMessage = currentEstimation.AnalysisResult ?? "Error al procesar la estimación";
            }
            else
            {
                successMessage = "✅ Estimación generada exitosamente";
            }
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

Write-Host "  ✓ ProjectEstimator.razor actualizado" -ForegroundColor Gray

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

// Configurar HttpClient para OpenAI
builder.Services.AddScoped(sp => {
    var client = new HttpClient();
    client.BaseAddress = new Uri("https://api.openai.com/");
    return client;
});

// Registrar servicios
builder.Services.AddScoped<IProjectService, ProjectService>();
builder.Services.AddScoped<IOpenAIService, OpenAIService>();
builder.Services.AddScoped<IPdfService, PdfService>();
builder.Services.AddScoped<IEstimationService, EstimationService>();

// Configuración
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

await builder.Build().RunAsync();
"@ | Out-File -FilePath "$projectPath\Program.cs" -Encoding UTF8

Write-Host "  ✓ Program.cs actualizado" -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ SOPORTE REAL DE PDF IMPLEMENTADO" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n📋 CARACTERÍSTICAS AGREGADAS:" -ForegroundColor Cyan
Write-Host "  ✓ Lectura real de PDFs con iText7" -ForegroundColor White
Write-Host "  ✓ Extracción de texto de todas las páginas" -ForegroundColor White
Write-Host "  ✓ Contador de páginas y caracteres" -ForegroundColor White
Write-Host "  ✓ Detección automática del nombre del proyecto" -ForegroundColor White
Write-Host "  ✓ Manejo de errores mejorado" -ForegroundColor White

Write-Host "`n🚀 Compilando proyecto..." -ForegroundColor Yellow

dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡Compilación exitosa!" -ForegroundColor Green
    
    Write-Host "`n📄 AHORA PUEDES:" -ForegroundColor Cyan
    Write-Host "  1. Cargar PDFs reales con especificaciones" -ForegroundColor White
    Write-Host "  2. El texto se extraerá automáticamente" -ForegroundColor White
    Write-Host "  3. Ver el número de páginas y caracteres" -ForegroundColor White
    Write-Host "  4. Generar estimaciones basadas en el contenido" -ForegroundColor White
    
    Write-Host "`n💡 TIPOS DE PDF SOPORTADOS:" -ForegroundColor Yellow
    Write-Host "  ✓ Documentos de Word exportados a PDF" -ForegroundColor White
    Write-Host "  ✓ Especificaciones técnicas" -ForegroundColor White
    Write-Host "  ✓ Propuestas de proyecto" -ForegroundColor White
    Write-Host "  ✓ Documentos de requisitos" -ForegroundColor White
    Write-Host "  ⚠️ PDFs escaneados (imágenes) NO funcionarán" -ForegroundColor Yellow
    
    Write-Host "`n▶️  Ejecutando aplicación..." -ForegroundColor Cyan
    dotnet run
} else {
    Write-Host "`n❌ Error en la compilación" -ForegroundColor Red
}
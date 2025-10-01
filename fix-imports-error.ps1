# FixImportsError.ps1
# Script rápido para corregir el error de _Imports.razor

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🔧 Corrigiendo _Imports.razor..." -ForegroundColor Green

# Corregir _Imports.razor - quitar la línea problemática
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

Write-Host "✅ _Imports.razor corregido" -ForegroundColor Green

Write-Host "`n🚀 Compilando..." -ForegroundColor Yellow

Set-Location $projectPath
dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡Compilación exitosa!" -ForegroundColor Green
    Write-Host "`n▶️  Ejecutando aplicación..." -ForegroundColor Cyan
    Write-Host "`n📋 Para usar el estimador:" -ForegroundColor Yellow
    Write-Host "  1. La aplicación se abrirá en tu navegador" -ForegroundColor White
    Write-Host "  2. Haz clic en 'Ir al Estimador' o navega a /estimator" -ForegroundColor White
    Write-Host "  3. Ingresa una descripción del proyecto" -ForegroundColor White
    Write-Host "  4. Haz clic en 'Generar Estimación'" -ForegroundColor White
    Write-Host "`nPresiona Ctrl+C para detener" -ForegroundColor Yellow
    
    dotnet run
} else {
    Write-Host "`n❌ Aún hay errores" -ForegroundColor Red
}
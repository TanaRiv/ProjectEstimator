# FinalFix.ps1
# Script para crear App.razor y ejecutar el proyecto

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🔧 Aplicando corrección final..." -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

Set-Location $projectPath

# Crear App.razor con el namespace correcto
Write-Host "`n📝 Creando App.razor..." -ForegroundColor Yellow

@"
@namespace ProjectEstimatorApp

<Router AppAssembly="@typeof(Program).Assembly">
    <Found Context="routeData">
        <RouteView RouteData="@routeData" DefaultLayout="@typeof(MainLayout)" />
    </Found>
    <NotFound>
        <PageTitle>Not found</PageTitle>
        <LayoutView Layout="@typeof(MainLayout)">
            <p role="alert">Sorry, there's nothing at this address.</p>
        </LayoutView>
    </NotFound>
</Router>
"@ | Out-File -FilePath "$projectPath\App.razor" -Encoding UTF8

Write-Host "✅ App.razor creado" -ForegroundColor Green

# Crear MainLayout.razor
Write-Host "`n📝 Creando MainLayout.razor..." -ForegroundColor Yellow

@"
@namespace ProjectEstimatorApp
@inherits LayoutComponentBase

<div class="page">
    <main>
        <div class="top-row px-4">
            <a href="https://github.com" target="_blank">About</a>
        </div>

        <article class="content px-4">
            @Body
        </article>
    </main>
</div>

<style>
    .page {
        position: relative;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    main {
        flex: 1;
    }

    .top-row {
        background-color: #f7f7f7;
        border-bottom: 1px solid #d6d5d5;
        justify-content: flex-end;
        height: 3.5rem;
        display: flex;
        align-items: center;
    }

    .top-row a {
        margin-left: 1.5rem;
        text-decoration: none;
        color: #333;
    }

    .top-row a:hover {
        text-decoration: underline;
    }

    .content {
        padding-top: 1.1rem;
    }
</style>
"@ | Out-File -FilePath "$projectPath\MainLayout.razor" -Encoding UTF8

Write-Host "✅ MainLayout.razor creado" -ForegroundColor Green

# Actualizar Program.cs para asegurar que usa el namespace correcto
Write-Host "`n📝 Actualizando Program.cs..." -ForegroundColor Yellow

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

await builder.Build().RunAsync();
"@ | Out-File -FilePath "$projectPath\Program.cs" -Encoding UTF8

Write-Host "✅ Program.cs actualizado" -ForegroundColor Green

# Actualizar Index.razor para agregar el namespace
Write-Host "`n📝 Actualizando Index.razor..." -ForegroundColor Yellow

@"
@page "/"
@namespace ProjectEstimatorApp.Pages
@inject ProjectEstimatorApp.Services.Interfaces.IProjectService ProjectService

<PageTitle>Project Estimator</PageTitle>

<div style="text-align: center; padding: 50px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
    <h1 style="color: #2c3e50; font-size: 2.5rem;">🤖 @ProjectService.GetProjectName()</h1>
    <p style="font-size: 1.2rem; color: #666;">Sistema inteligente para estimar el esfuerzo de desarrollo</p>
    
    <div style="margin-top: 30px; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; color: white; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <h3>✅ Estado del Sistema</h3>
        <p style="font-weight: bold; font-size: 1.1rem;">¡Aplicación funcionando correctamente!</p>
        <p>Blazor WebAssembly | .NET 8.0 | Version 1.0.0</p>
    </div>
    
    <div style="margin-top: 40px;">
        <h4 style="color: #2c3e50;">📋 Características del Proyecto:</h4>
        <div style="display: flex; justify-content: center;">
            <ul style="list-style: none; padding: 0; text-align: left;">
                <li style="margin: 15px 0; font-size: 1.1rem;">
                    <span style="color: #27ae60; font-weight: bold;">✅</span> Blazor WebAssembly configurado
                </li>
                <li style="margin: 15px 0; font-size: 1.1rem;">
                    <span style="color: #27ae60; font-weight: bold;">✅</span> Inyección de dependencias funcionando
                </li>
                <li style="margin: 15px 0; font-size: 1.1rem;">
                    <span style="color: #27ae60; font-weight: bold;">✅</span> Estructura de proyecto organizada
                </li>
                <li style="margin: 15px 0; font-size: 1.1rem;">
                    <span style="color: #f39c12; font-weight: bold;">⏳</span> Integración con GPT-4 (próximamente)
                </li>
                <li style="margin: 15px 0; font-size: 1.1rem;">
                    <span style="color: #f39c12; font-weight: bold;">⏳</span> Análisis de documentos PDF (próximamente)
                </li>
                <li style="margin: 15px 0; font-size: 1.1rem;">
                    <span style="color: #f39c12; font-weight: bold;">⏳</span> Sistema de aprendizaje continuo (próximamente)
                </li>
            </ul>
        </div>
    </div>
    
    <div style="margin-top: 40px;">
        <button style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 12px 30px; border-radius: 25px; cursor: pointer; font-size: 16px; font-weight: bold; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: transform 0.2s;" 
                @onclick="TestService"
                @onmouseover="@(() => hover = true)"
                @onmouseout="@(() => hover = false)">
            🚀 Probar Servicio
        </button>
        
        @if (!string.IsNullOrEmpty(message))
        {
            <div style="margin-top: 20px; padding: 15px; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 5px; color: #155724;">
                <strong>✓</strong> @message
            </div>
        }
    </div>
    
    <div style="margin-top: 50px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
        <p style="color: #999; font-size: 0.9rem;">
            Desarrollado con ❤️ usando Blazor WebAssembly y .NET 8.0
        </p>
    </div>
</div>

@code {
    private string message = "";
    private bool hover = false;
    
    private void TestService()
    {
        message = $"¡Servicio funcionando perfectamente! Proyecto: {ProjectService.GetProjectName()} - Hora: {DateTime.Now:HH:mm:ss}";
    }
}
"@ | Out-File -FilePath "$projectPath\Pages\Index.razor" -Encoding UTF8

Write-Host "✅ Index.razor actualizado" -ForegroundColor Green

# Asegurar que wwwroot/index.html existe y es correcto
Write-Host "`n📝 Verificando index.html..." -ForegroundColor Yellow

if (!(Test-Path "$projectPath\wwwroot")) {
    New-Item -ItemType Directory -Path "$projectPath\wwwroot" -Force | Out-Null
}

@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <title>Project Estimator</title>
    <base href="/" />
    <link href="css/app.css" rel="stylesheet" />
</head>
<body>
    <div id="app">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;">
            <div style="width: 50px; height: 50px; border: 5px solid #f3f3f3; border-top: 5px solid #667eea; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
            <h3 style="color: #667eea; margin-top: 20px; font-family: 'Segoe UI', sans-serif;">Cargando Project Estimator...</h3>
        </div>
    </div>

    <style>
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>

    <script src="_framework/blazor.webassembly.js"></script>
</body>
</html>
"@ | Out-File -FilePath "$projectPath\wwwroot\index.html" -Encoding UTF8

Write-Host "✅ index.html verificado" -ForegroundColor Green

# Crear/actualizar app.css
if (!(Test-Path "$projectPath\wwwroot\css")) {
    New-Item -ItemType Directory -Path "$projectPath\wwwroot\css" -Force | Out-Null
}

@"
html, body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
    height: 100%;
}

#app {
    min-height: 100vh;
    background: linear-gradient(to bottom, #ffffff, #f8f9fa);
}

* {
    box-sizing: border-box;
}
"@ | Out-File -FilePath "$projectPath\wwwroot\css\app.css" -Encoding UTF8

Write-Host "✅ app.css actualizado" -ForegroundColor Green

Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "🎉 CORRECCIÓN COMPLETA APLICADA" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host "`n🚀 Compilando proyecto..." -ForegroundColor Yellow

# Limpiar y compilar
dotnet clean | Out-Null
$buildResult = dotnet build 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ ¡COMPILACIÓN EXITOSA!" -ForegroundColor Green
    Write-Host "`n▶️  Iniciando aplicación..." -ForegroundColor Cyan
    Write-Host "La aplicación se abrirá en tu navegador en unos segundos..." -ForegroundColor Yellow
    Write-Host "Si no se abre automáticamente, navega a: " -NoNewline
    Write-Host "https://localhost:5001" -ForegroundColor Cyan
    Write-Host "`nPresiona Ctrl+C para detener la aplicación" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    # Ejecutar la aplicación
    dotnet run
} else {
    Write-Host "`n❌ Error en la compilación:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Yellow
    
    Write-Host "`n💡 Intenta ejecutar estos comandos manualmente:" -ForegroundColor Cyan
    Write-Host "cd $projectPath" -ForegroundColor White
    Write-Host "dotnet clean" -ForegroundColor White
    Write-Host "dotnet restore" -ForegroundColor White
    Write-Host "dotnet build" -ForegroundColor White
    Write-Host "dotnet run" -ForegroundColor White
}
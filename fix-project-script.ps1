# FixProject.ps1
# Script para corregir los errores del proyecto

$projectPath = "C:\Users\hp\Downloads\ProjectEstimatorComplete\ProjectEstimator"

Write-Host "🔧 Corrigiendo proyecto..." -ForegroundColor Yellow

# Corregir _Imports.razor
Write-Host "Actualizando _Imports.razor..." -ForegroundColor Cyan
@"
@using System.Net.Http
@using System.Net.Http.Json
@using Microsoft.AspNetCore.Components.Forms
@using Microsoft.AspNetCore.Components.Routing
@using Microsoft.AspNetCore.Components.Web
@using Microsoft.AspNetCore.Components.Web.Virtualization
@using Microsoft.AspNetCore.Components.WebAssembly.Http
@using Microsoft.JSInterop
"@ | Out-File -FilePath "$projectPath\_Imports.razor" -Encoding UTF8

# Crear Program.cs funcional
Write-Host "Creando Program.cs..." -ForegroundColor Cyan
@"
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

await builder.Build().RunAsync();
"@ | Out-File -FilePath "$projectPath\Program.cs" -Encoding UTF8

# Crear App.razor
Write-Host "Creando App.razor..." -ForegroundColor Cyan
@"
<Router AppAssembly="@typeof(Program).Assembly">
    <Found Context="routeData">
        <RouteView RouteData="@routeData" />
    </Found>
    <NotFound>
        <PageTitle>Not found</PageTitle>
        <p role="alert">Sorry, there's nothing at this address.</p>
    </NotFound>
</Router>
"@ | Out-File -FilePath "$projectPath\App.razor" -Encoding UTF8

# Crear carpeta Pages si no existe
if (!(Test-Path "$projectPath\Pages")) {
    New-Item -ItemType Directory -Path "$projectPath\Pages" -Force | Out-Null
}

# Crear Index.razor
Write-Host "Creando Index.razor..." -ForegroundColor Cyan
@"
@page "/"

<PageTitle>Project Estimator</PageTitle>

<div style="text-align: center; padding: 50px;">
    <h1>🤖 Agente de Valoración de Proyectos</h1>
    <p>Sistema inteligente para estimar el esfuerzo de desarrollo</p>
    
    <div style="margin-top: 30px;">
        <h3>Estado del Sistema</h3>
        <p style="color: green;">✅ Aplicación funcionando correctamente</p>
        <p>La funcionalidad completa se agregará próximamente.</p>
    </div>
    
    <div style="margin-top: 30px;">
        <h4>Características Planificadas:</h4>
        <ul style="list-style: none; padding: 0;">
            <li>📄 Análisis de documentos PDF</li>
            <li>🤖 Integración con GPT-4</li>
            <li>📊 Estimación automática de tareas</li>
            <li>📈 Sistema de aprendizaje continuo</li>
        </ul>
    </div>
</div>

<style>
    h1 {
        color: #2c3e50;
    }
    ul li {
        margin: 10px 0;
    }
</style>
"@ | Out-File -FilePath "$projectPath\Pages\Index.razor" -Encoding UTF8

# Crear carpeta wwwroot si no existe
if (!(Test-Path "$projectPath\wwwroot")) {
    New-Item -ItemType Directory -Path "$projectPath\wwwroot" -Force | Out-Null
}

# Crear index.html
Write-Host "Creando index.html..." -ForegroundColor Cyan
@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Project Estimator</title>
    <base href="/" />
    <link href="css/app.css" rel="stylesheet" />
</head>
<body>
    <div id="app">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);">
            <h3>Loading...</h3>
        </div>
    </div>

    <script src="_framework/blazor.webassembly.js"></script>
</body>
</html>
"@ | Out-File -FilePath "$projectPath\wwwroot\index.html" -Encoding UTF8

# Crear carpeta css si no existe
if (!(Test-Path "$projectPath\wwwroot\css")) {
    New-Item -ItemType Directory -Path "$projectPath\wwwroot\css" -Force | Out-Null
}

# Crear app.css básico
Write-Host "Creando app.css..." -ForegroundColor Cyan
@"
html, body {
    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
    margin: 0;
    padding: 0;
}

#app {
    min-height: 100vh;
}

h1 {
    font-weight: 300;
}
"@ | Out-File -FilePath "$projectPath\wwwroot\css\app.css" -Encoding UTF8

# Actualizar el .csproj para asegurarse de que sea correcto
Write-Host "Actualizando ProjectEstimator.csproj..." -ForegroundColor Cyan
@"
<Project Sdk="Microsoft.NET.Sdk.BlazorWebAssembly">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <RootNamespace>ProjectEstimatorApp</RootNamespace>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly" Version="8.0.0" />
    <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly.DevServer" Version="8.0.0" PrivateAssets="all" />
  </ItemGroup>

</Project>
"@ | Out-File -FilePath "$projectPath\ProjectEstimator.csproj" -Encoding UTF8

Write-Host "`n✅ Correcciones aplicadas" -ForegroundColor Green
Write-Host "`nEjecutando el proyecto..." -ForegroundColor Cyan

Set-Location $projectPath
dotnet clean
dotnet restore
dotnet run
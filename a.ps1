# VerifyAndFix.ps1
$basePath = "C:\Users\hp\Downloads\ProjectEstimatorComplete"

Write-Host "Verificando estructura del proyecto..." -ForegroundColor Yellow

# Verificar si existe la carpeta ProjectEstimator
if (!(Test-Path "$basePath\ProjectEstimator")) {
    Write-Host "❌ No se encuentra la carpeta ProjectEstimator" -ForegroundColor Red
    Write-Host "Creando estructura..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "$basePath\ProjectEstimator" -Force
}

# Verificar si existe el archivo .csproj
if (!(Test-Path "$basePath\ProjectEstimator\ProjectEstimator.csproj")) {
    Write-Host "❌ No se encuentra ProjectEstimator.csproj" -ForegroundColor Red
    Write-Host "Creando archivo .csproj..." -ForegroundColor Yellow
    
    $csprojContent = @'
<Project Sdk="Microsoft.NET.Sdk.BlazorWebAssembly">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly" Version="8.0.0" />
    <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly.DevServer" Version="8.0.0" PrivateAssets="all" />
  </ItemGroup>

</Project>
'@
    $csprojContent | Out-File -FilePath "$basePath\ProjectEstimator\ProjectEstimator.csproj" -Encoding UTF8
}

# Verificar Program.cs
if (!(Test-Path "$basePath\ProjectEstimator\Program.cs")) {
    Write-Host "❌ No se encuentra Program.cs" -ForegroundColor Red
    Write-Host "Creando Program.cs mínimo..." -ForegroundColor Yellow
    
    $programContent = @'
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

await builder.Build().RunAsync();
'@
    $programContent | Out-File -FilePath "$basePath\ProjectEstimator\Program.cs" -Encoding UTF8
}

Write-Host "✅ Estructura verificada" -ForegroundColor Green
Write-Host ""
Write-Host "Ejecutando el proyecto..." -ForegroundColor Cyan
Set-Location "$basePath\ProjectEstimator"
dotnet restore
dotnet run
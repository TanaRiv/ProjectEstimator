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

// Configurar HttpClient para OpenAI con timeout extendido para GPT-5
builder.Services.AddScoped(sp => {
    var client = new HttpClient();
    client.BaseAddress = new Uri("https://api.openai.com/");
    client.Timeout = TimeSpan.FromSeconds(180); // GPT-5 con reasoning puede tardar más
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
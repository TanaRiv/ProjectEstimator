# 🤖 Agente de Valoración de Proyectos

Sistema inteligente basado en IA para estimar el esfuerzo de desarrollo de proyectos de software.

## 🚀 Inicio Rápido

### Requisitos Previos
- .NET 8.0 SDK o superior
- Visual Studio 2022 o VS Code
- Cuenta de OpenAI con acceso a API

### Instalación

1. **Abrir el proyecto en Visual Studio**
   - Abre el archivo ProjectEstimator.sln

2. **Configurar API Key de OpenAI**
   - Abre ProjectEstimator/appsettings.json
   - Reemplaza YOUR_OPENAI_API_KEY_HERE con tu clave API

3. **Restaurar paquetes NuGet**
   En la terminal de Visual Studio o PowerShell:
   `ash
   dotnet restore
   `

4. **Ejecutar la aplicación**
   `ash
   dotnet run --project ProjectEstimator
   `

5. **Abrir en el navegador**
   - La aplicación se abrirá automáticamente
   - Si no, navega a: https://localhost:5001

## 📋 Características

- ✅ Análisis automático de documentos PDF
- ✅ Estimación inteligente usando GPT-4
- ✅ Categorización automática de tareas
- ✅ Sistema de aprendizaje continuo
- ✅ Visualización con gráficos interactivos
- ✅ Exportación en múltiples formatos

## 🏗️ Estructura del Proyecto

`
ProjectEstimator/
├── Models/              # Modelos de datos
├── Services/            # Lógica de negocio
│   └── Interfaces/      # Contratos de servicios
├── Pages/               # Páginas Blazor
├── Data/                # Contexto de base de datos
└── wwwroot/            # Recursos estáticos
`

## 🔧 Configuración

Ajusta los parámetros en ppsettings.json:

`json
{
  ""OpenAI"": {
    ""ApiKey"": ""tu-api-key"",
    ""Model"": ""gpt-4"",
    ""MaxTokens"": 2000,
    ""Temperature"": 0.7
  },
  ""EstimationSettings"": {
    ""DefaultComplexityMultipliers"": {
      ""Simple"": 1.0,
      ""Medium"": 2.5,
      ""Complex"": 5.0,
      ""VeryComplex"": 10.0
    }
  }
}
`

## 📊 Uso

1. **Cargar Documento**: Selecciona un PDF con el diseño del proyecto
2. **Proporcionar Contexto**: Añade información adicional en el prompt
3. **Analizar**: El sistema procesará y generará estimaciones
4. **Revisar**: Examina las tareas y tiempos estimados
5. **Feedback**: Proporciona horas reales para mejorar el modelo

## 🐛 Solución de Problemas

### Error: ""API Key no válida""
- Verifica que tu API key de OpenAI esté correctamente configurada en ppsettings.json

### Error: ""No se puede leer el PDF""
- Asegúrate de que el archivo PDF no esté corrupto
- Verifica que el tamaño del archivo sea menor a 10MB

### La aplicación no se ejecuta
- Verifica que tengas .NET 8.0 SDK instalado: dotnet --version
- Restaura los paquetes NuGet: dotnet restore

## 📝 Licencia

MIT License - Libre para uso personal y comercial

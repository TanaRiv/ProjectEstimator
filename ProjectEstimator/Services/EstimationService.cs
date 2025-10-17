using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using ProjectEstimatorApp.Models;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class EstimationService : IEstimationService
    {
        private readonly IOpenAIService _openAIService;
        private readonly ILogger<EstimationService> _logger;

        public EstimationService(IOpenAIService openAIService, ILogger<EstimationService> logger)
        {
            _openAIService = openAIService;
            _logger = logger;
        }

        public async Task<ProjectEstimation> EstimateProjectAsync(EstimationRequest request)
        {
            _logger.LogInformation($"🚀 Iniciando estimación para proyecto: {request.ProjectName}");

            var estimation = new ProjectEstimation
            {
                ProjectName = request.ProjectName,
                InitialPrompt = request.InitialPrompt,
                DocumentContent = request.DocumentContent,
                Status = EstimationStatus.Processing
            };

            try
            {
                if (_openAIService.IsConfigured())
                {
                    _logger.LogInformation("✅ OpenAI configurado, usando GPT-5 para estimación");
                    estimation = await ExtractTasksWithGPT5(request.DocumentContent, request.InitialPrompt, request.ProjectName);

                    if (estimation.Tasks.Any())
                    {
                        estimation.Status = EstimationStatus.Completed;
                        _logger.LogInformation($"✅ Estimación completada: {estimation.Tasks.Count} tareas, {estimation.TotalEstimatedHours} horas totales");
                    }
                    else
                    {
                        _logger.LogWarning("⚠️ GPT-5 no devolvió tareas, usando estimación local");
                        estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                    }
                }
                else
                {
                    _logger.LogWarning("⚠️ OpenAI no configurado, usando estimación local");
                    await Task.Delay(2000); // Simular procesamiento
                    estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error durante la estimación");
                estimation.Status = EstimationStatus.Failed;
                estimation.AnalysisResult = $"Error: {ex.Message}";

                // Si falla OpenAI, usar estimación local
                _logger.LogInformation("🔄 Fallback a estimación local debido a error");
                estimation = GetSampleEstimation(request.ProjectName, request.InitialPrompt + " " + request.DocumentContent);
                estimation.AnalysisResult = $"Nota: Se usó estimación local debido a: {ex.Message}";
            }

            return estimation;
        }

        private async Task<ProjectEstimation> ExtractTasksWithGPT5(string documentContent, string additionalContext, string projectName)
        {
            _logger.LogInformation("📝 Preparando prompt optimizado para GPT-5...");

            var systemPrompt = @"# ROL Y CONTEXTO
Eres un experto analista de proyectos con más de 20 años de experiencia en desarrollo empresarial.
Especializado en el stack Microsoft: .NET 8, C#, Blazor, SQL Server.
Especializado también en el uso y desarrollo para A3erp
Tu precisión y profesionalismo son fundamentales para el éxito de los proyectos.

# OBJETIVO PRINCIPAL
Analizar documentos de diseño funcional/técnico y generar estimaciones detalladas, realistas y accionables para proyectos de desarrollo de software.

# PROCESO DE ANÁLISIS ESTRUCTURADO

## FASE 1: EXTRACCIÓN Y COMPRENSIÓN
Del documento proporcionado, identificar sistemáticamente:
- Sección 1: Introducción → Contexto general y visión del proyecto
- Sección 2: Objetivos de negocio → Alcance, prioridades y KPIs esperados
- Sección 3: Requerimientos funcionales → Funcionalidades específicas a desarrollar
- Sección 4: Requerimientos no funcionales → Restricciones técnicas, rendimiento, seguridad
- Arquitectura propuesta → Componentes, integraciones, infraestructura
- Restricciones → Tiempo, presupuesto, recursos disponibles

## FASE 2: IDENTIFICACIÓN DE RIESGOS Y AMBIGÜEDADES
Antes de proceder con la estimación, identificar y listar:
- ❗ Información faltante crítica
- ⚠️ Ambigüedades que afectan la estimación
- 🔄 Dependencias externas no clarificadas
- 🚨 Riesgos técnicos identificados
- 💡 Suposiciones realizadas para la estimación

## FASE 3: DESCOMPOSICIÓN DE TAREAS
Principios de descomposición:
- Máximo 8 horas por tarea individual (idealmente 2-4 horas)
- Cada tarea debe ser verificable y entregable
- **PRINCIPIO DE EFICIENCIA**: Antes de desglosar, evaluar si las subtareas pueden: 
* Ejecutarse de forma paralela o integrada (análisis + desarrollo)
 * Reutilizar código, templates o componentes existentes 
* Beneficiarse de herramientas automatizadas o experiencia previa 
- **REGLA DE GRANULARIDAD ADAPTATIVA**: 
* Si el total estimado < 100 horas: Agrupar tareas relacionadas (ej: ""Desarrollo completo del módulo X"" en vez de separar análisis+lógica+UI) 
* Si el total estimado > 150 horas: Mantener desglose granular para mejor control
- Incluir TODAS las actividades del ciclo de desarrollo:
  
  * PREPARACIÓN:
    - Configuración del entorno de desarrollo
    - Setup de proyecto y arquitectura base
    - Configuración de base de datos
    - Configuración de CI/CD pipelines
  
  * DESARROLLO CORE:
    - Modelado de datos y creación de esquemas
    - Desarrollo de capa de acceso a datos
    - Lógica de negocio y servicios
    - APIs y endpoints
    - Interfaces de usuario
    - Integraciones con sistemas externos
  
  * CALIDAD:
    - Pruebas unitarias (mínimo 70% cobertura)
    - Pruebas de integración
    - Pruebas de rendimiento
    - Pruebas de seguridad
    - Pruebas de aceptación de usuario
  
  * DOCUMENTACIÓN:
    - Documentación técnica
    - Documentación de API
    - Manual de usuario
    - Guía de despliegue
    - Documentación de mantenimiento
  
  * DESPLIEGUE Y ESTABILIZACIÓN:
    - Preparación de ambientes
    - Migración de datos
    - Despliegue a producción
    - Monitoreo post-despliegue
    - Soporte post-producción inicial

## FASE 4: ESTIMACIÓN REALISTA Y AJUSTADA

### Base de cálculo:
- Desarrollador de nivel MEDIO (3-5 años de experiencia)
- Jornada efectiva de 6 horas productivas (no 8)
- Velocidad estándar, no heroica

### Factores de ajuste obligatorios:
- Investigación técnica: +5% del tiempo de desarrollo
- Inicio de proyecto y crear entorno: +2% del tiempo de desarrollo
- Debugging y resolución de issues: +10% del tiempo de desarrollo
- Code review y refactoring: +10% del tiempo de desarrollo
- Reuniones y comunicación: +10% del tiempo total
- Retrabajos y cambios menores: +10% del tiempo total
- Formación de los usuarios: +5% del tiempo de desarrollo
-Instalación: +1% del tiempo de desarrollo

### Multiplicadores contextuales:
- Primera vez con una tecnología: x1.3
- Integraciones con sistemas externos: x1.2
- Requisitos de alta disponibilidad (99.9%+): x1.15
- Múltiples idiomas/localización: x1.1
- Requisitos regulatorios (GDPR, etc.): x1.2
- Proyecto legacy/código existente: x1.25

### Factores de equipo (si se especifica):
- Equipo junior (< 2 años exp): x1.5
- Equipo medio (2-5 años exp): x1.0
- Equipo senior (> 5 años exp): x0.8
- Equipo distribuido/remoto: x1.1
**FACTOR DE EFICIENCIA POR SIMPLICIDAD:**
 - Si estimación base < 100 horas: Aplicar descuento del 15% por eficiencias de coordinación y reutilización

# CALIBRACIÓN AUTOMÁTICA POR COMPLEJIDAD
 ## Evaluación inicial de complejidad: Antes de la estimación final, evaluar:
 - ¿Requiere más de 5 módulos independientes? → Proyecto Grande
 - ¿Involucra más de 3 integraciones externas? → Proyecto Grande 
- ¿Estimación base > 120 horas? → Proyecto Grande 
- ¿Menos de 10 funcionalidades principales? → Proyecto Pequeño
 ## Ajustes por tipo de proyecto: ### PROYECTOS PEQUEÑOS (criterios anteriores no cumplidos):
 - **Documentación**: Máximo 5% del desarrollo (no 10%) 
- **Testing**: 15% del desarrollo (enfoque pragmático, no exhaustivo) 
- **Gestión**: Máximo 8 horas totales 
- **RQNF mínimos**: Instalación (1-2h), Formación (2-4h), Soporte inicial (4-6h)
 - **Reutilización**: Asumir 20% de eficiencia por componentes/código existente 
### PROYECTOS GRANDES: 
- Mantener porcentajes estándar del sistema original - Aplicar todos los factores de contingencia
# FORMATO DE SALIDA ESTRUCTURADO

## 📋 RESUMEN EJECUTIVO
- Nombre del proyecto: [Nombre]
- Complejidad general: [Baja/Media/Alta/Muy Alta]
- Riesgos principales: [Lista de 3-7 riesgos críticos]
- Confianza en la estimación: [Alta ±5% / Media ±15% / Baja ±25%]

## 🎯 [MÓDULO/ÉPICA/FUNCIONALIDAD]

### Contexto del módulo
[Breve descripción del objetivo y valor de negocio]

### Tareas detalladas:

#### ✅ [Nombre específico de la tarea]
📝 **Descripción**: [Qué se debe hacer exactamente]
🔧 **Tipo**: [Backend/Frontend/Database/Testing/Documentation/DevOps/Infrastructure]
👤 **Perfil requerido**: [Junior/Middle/Senior] - [Habilidades específicas]
⏱️ **Tiempo estimado**: [X horas]
⚠️ **Dependencias**: [Tareas previas requeridas]
🎯 **Criterios de aceptación**: [Cómo validar que está completa]
📊 **Complejidad**: [Simple/Media/Compleja/Muy Compleja]

### 📊 Subtotal módulo: 
- Desarrollo: XX horas
- Testing: XX horas
- Documentación: XX horas
- **Total módulo: XX horas**

## 💰 RESUMEN FINAL DE ESTIMACIÓN

### Desglose por tipo de actividad:
- **Desarrollo core**: XX horas (X%)
- **Testing y QA**: XX horas (X%)
- **Documentación**: XX horas (X%)
- **DevOps/Infraestructura**: XX horas (X%)
- **Gestión y comunicación**: XX horas (X%)

### Desglose por tecnología:
- **Backend (.NET/C#)**: XX horas
- **Frontend (Blazor)**: XX horas
- **Base de datos (SQL Server)**: XX horas
- **Integraciones**: XX horas

### Cálculo final:
- **Subtotal tareas**: XX horas
- **Buffer contingencia (15%)**: XX horas
- **Margen de error (±X%)**: XX-XX horas

### 🎯 **TOTAL PROYECTO: XXX horas**

### Conversión a tiempo calendario:
- **En días laborables**: XX días
- **En semanas (1 desarrollador)**: XX semanas
- **En semanas (equipo de X)**: XX semanas

## 📈 CRONOGRAMA SUGERIDO

### Sprint 1-2: Fundación (X horas)
- [Lista de tareas prioritarias]

### Sprint 3-4: Desarrollo Core (X horas)
- [Lista de funcionalidades principales]

### Sprint 5-6: Integraciones y Polish (X horas)
- [Lista de tareas de integración y mejora]

### Sprint 7: Testing y Estabilización (X horas)
- [Lista de actividades de QA]

### Sprint 8: Despliegue y Documentación (X horas)
- [Lista de tareas finales]

## ⚠️ NOTAS Y CONSIDERACIONES IMPORTANTES
- [Supuestos realizados]
- [Riesgos no mitigados]
- [Recomendaciones técnicas]
- [Dependencias externas críticas]

# REGLAS DE NEGOCIO PARA LA ESTIMACIÓN

1. NUNCA subestimar tareas de infraestructura y configuración
2. SIEMPRE incluir tiempo para pruebas (mínimo 25% del desarrollo)
3. SIEMPRE incluir documentación (mínimo 10% del desarrollo)
4. NUNCA asumir que las integraciones funcionarán a la primera
5. SIEMPRE considerar tiempo de aprendizaje para tecnologías nuevas
6. INCLUIR tiempo para corrección de bugs post-despliegue en tareas individuales
7. CONSIDERAR la deuda técnica en proyectos existentes
8. NUNCA sobreestimes tareas relacionadas con A3erp. La estructura de A3ERP es bien conocida y las tareas relacionadas se hacen rápido
9. **REGLA DE PROPORCIONALIDAD**: En funcionalidades similares, la segunda y subsecuentes toman 60-70% del tiempo de la primera (efecto aprendizaje) 
10. **REGLA DE CONTEXTO A3ERP**: Reconocer patrones estándar de A3ERP para reducir estimaciones en módulos típicos 
11. **REGLA DE SIMPLICIDAD**: Si una tarea toma menos de 1 hora, considerar integrarla con tareas relacionadas 
12. **REGLA DE REALISMO**: Cuestionar estimaciones que resulten en más de 20 horas por funcionalidad simple (CRUD básico, formularios estándar)

# ESTRUCTURA JSON DE RESPUESTA

Devuelve SIEMPRE un JSON con esta estructura exacta:

{
  ""projectName"": ""string"",
  ""complexity"": ""Low|Medium|High|VeryHigh"",
  ""confidence"": ""High|Medium|Low"",
  ""totalHours"": number,
  ""contingencyHours"": number,
  ""tasks"": [
    {
      ""id"": ""string"",
      ""name"": ""string"",
      ""description"": ""string"",
      ""category"": ""Backend|Frontend|Database|Infrastructure|Testing|Documentation|DevOps|Architecture"",
      ""complexity"": ""Simple|Medium|Complex|VeryComplex"",
      ""estimatedHours"": number,
      ""requiredProfile"": ""Junior|Middle|Senior"",
      ""dependencies"": [""taskId""],
      ""acceptanceCriteria"": [""string""],
      ""risks"": [""string""]
    }
  ],
  ""summary"": {
    ""developmentHours"": number,
    ""testingHours"": number,
    ""documentationHours"": number,
    ""infrastructureHours"": number,
    ""managementHours"": number
  },
  ""assumptions"": [""string""],
  ""risks"": [""string""],
  ""recommendations"": [""string""]
}";

            var userPrompt = $@"INFORMACIÓN DEL CONTEXTO DEL PROYECTO:
El desarrollo se hará por parte de un solo desarrollador. No se van a hacer pruebas unitarias.

DOCUMENTO DE DISEÑO A ANALIZAR:
{documentContent}

CONTEXTO ADICIONAL DEL USUARIO:
{additionalContext}

NOMBRE DEL PROYECTO:
{projectName}

INSTRUCCIONES ESPECÍFICAS:
1. Analiza el documento completo identificando todos los requisitos
2. Identifica cualquier ambigüedad o información faltante
3. Genera una estimación detallada siguiendo la estructura definida
4. Incluye todos los tipos de tareas necesarias (desarrollo, testing, documentación, etc.)
5. Aplica los factores de ajuste apropiados según el contexto
6. Proporciona un cronograma realista
7. Lista todos los riesgos y suposiciones

Por favor, genera una estimación completa y profesional para este proyecto.";

            try
            {
                _logger.LogInformation("📤 Enviando solicitud a GPT-5...");
                var response = await _openAIService.GetCompletionAsync(systemPrompt, userPrompt);

                _logger.LogInformation($"📥 Respuesta recibida, procesando JSON...");

                // Intentar extraer JSON de la respuesta
                var jsonStart = response.IndexOf("{");
                var jsonEnd = response.LastIndexOf("}") + 1;

                if (jsonStart >= 0 && jsonEnd > jsonStart)
                {
                    var jsonResponse = response.Substring(jsonStart, jsonEnd - jsonStart);

                    _logger.LogDebug($"🔍 JSON extraído: {jsonResponse.Substring(0, Math.Min(500, jsonResponse.Length))}...");

                    var options = new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true,
                        AllowTrailingCommas = true,
                        ReadCommentHandling = JsonCommentHandling.Skip
                    };

                    var result = JsonSerializer.Deserialize<OpenAIEstimationResponse>(jsonResponse, options);

                    if (result != null && result.Tasks != null && result.Tasks.Any())
                    {
                        _logger.LogInformation($"✅ JSON parseado exitosamente: {result.Tasks.Count} tareas");
                        return ConvertToEstimation(result);
                    }
                    else
                    {
                        _logger.LogWarning("⚠️ El JSON no contiene tareas válidas");
                    }
                }
                else
                {
                    _logger.LogWarning("⚠️ No se encontró JSON válido en la respuesta de GPT-5");
                    _logger.LogDebug($"Respuesta completa: {response}");
                }
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "❌ Error al parsear JSON de GPT-5");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error al procesar respuesta de GPT-5");
                throw;
            }

            // Si llegamos aquí, algo falló
            return new ProjectEstimation
            {
                ProjectName = projectName,
                Status = EstimationStatus.Failed,
                Tasks = new List<DevelopmentTask>(),
                AnalysisResult = "No se pudo procesar la respuesta de GPT-5"
            };
        }

        private ProjectEstimation ConvertToEstimation(OpenAIEstimationResponse result)
        {
            var estimation = new ProjectEstimation
            {
                ProjectName = result.ProjectName ?? "Proyecto",
                Complexity = Enum.TryParse<ProjectComplexity>(result.Complexity, true, out var comp)
                    ? comp : ProjectComplexity.Medium,
                Confidence = Enum.TryParse<ConfidenceLevel>(result.Confidence, true, out var conf)
                    ? conf : ConfidenceLevel.Medium,
                TotalEstimatedHours = result.TotalHours,
                ContingencyHours = result.ContingencyHours > 0 ? result.ContingencyHours : result.TotalHours * 0.15,
                Tasks = ConvertTasks(result.Tasks),
                Summary = result.Summary ?? new EstimationSummary(),
                Assumptions = result.Assumptions ?? new List<string>(),
                Risks = result.Risks ?? new List<string>(),
                Recommendations = result.Recommendations ?? new List<string>(),
                Status = EstimationStatus.Completed
            };

            // Recalcular totales si es necesario
            if (estimation.TotalEstimatedHours == 0)
            {
                estimation.TotalEstimatedHours = estimation.Tasks.Sum(t => t.EstimatedHours);
            }

            if (estimation.ContingencyHours == 0)
            {
                estimation.ContingencyHours = estimation.TotalEstimatedHours * 0.15;
            }

            return estimation;
        }

        private List<DevelopmentTask> ConvertTasks(List<OpenAITask> tasks)
        {
            if (tasks == null || !tasks.Any())
            {
                _logger.LogWarning("⚠️ No hay tareas para convertir");
                return new List<DevelopmentTask>();
            }

            var convertedTasks = new List<DevelopmentTask>();

            foreach (var task in tasks)
            {
                try
                {
                    var convertedTask = new DevelopmentTask
                    {
                        TaskId = task.Id ?? $"TASK-{convertedTasks.Count + 1:D3}",
                        Name = task.Name ?? "Tarea sin nombre",
                        Description = task.Description ?? "",
                        Category = Enum.TryParse<TaskCategory>(task.Category, true, out var cat)
                            ? cat : TaskCategory.Backend,
                        Complexity = Enum.TryParse<ComplexityLevel>(task.Complexity, true, out var comp)
                            ? comp : ComplexityLevel.Medium,
                        EstimatedHours = task.EstimatedHours > 0 ? task.EstimatedHours : 8,
                        RequiredProfile = Enum.TryParse<ProfileLevel>(task.RequiredProfile, true, out var prof)
                            ? prof : ProfileLevel.Middle,
                        Dependencies = task.Dependencies ?? new List<string>(),
                        AcceptanceCriteria = task.AcceptanceCriteria ?? new List<string>(),
                        TaskRisks = task.Risks ?? new List<string>()
                    };

                    convertedTasks.Add(convertedTask);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"❌ Error convirtiendo tarea: {task.Name}");
                }
            }

            _logger.LogInformation($"✅ Convertidas {convertedTasks.Count} tareas exitosamente");
            return convertedTasks;
        }

        public ProjectEstimation GetSampleEstimation(string projectName, string prompt)
        {
            _logger.LogInformation("🔄 Generando estimación local de ejemplo");

            var tasks = new List<DevelopmentTask>
            {
                new DevelopmentTask
                {
                    TaskId = "LOCAL-001",
                    Name = "Configuración inicial (Estimación Local)",
                    Description = "Esta es una estimación de ejemplo. Configure su API Key de OpenAI para obtener estimaciones reales con GPT-5.",
                    Category = TaskCategory.Architecture,
                    Complexity = ComplexityLevel.Simple,
                    EstimatedHours = 8,
                    RequiredProfile = ProfileLevel.Middle,
                    AcceptanceCriteria = new List<string> { "Proyecto configurado", "Dependencias instaladas" }
                }
            };

            // Agregar más tareas basadas en palabras clave
            var promptLower = prompt.ToLower();

            if (promptLower.Contains("database") || promptLower.Contains("sql") || promptLower.Contains("datos"))
            {
                tasks.Add(new DevelopmentTask
                {
                    TaskId = "LOCAL-002",
                    Name = "Diseño de base de datos (Estimación Local)",
                    Description = "Estimación local básica para base de datos",
                    Category = TaskCategory.Database,
                    Complexity = ComplexityLevel.Medium,
                    EstimatedHours = 24,
                    RequiredProfile = ProfileLevel.Middle
                });
            }

            if (promptLower.Contains("api") || promptLower.Contains("rest") || promptLower.Contains("backend"))
            {
                tasks.Add(new DevelopmentTask
                {
                    TaskId = "LOCAL-003",
                    Name = "API REST (Estimación Local)",
                    Description = "Estimación local básica para API",
                    Category = TaskCategory.Backend,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 40,
                    RequiredProfile = ProfileLevel.Senior
                });
            }

            if (promptLower.Contains("frontend") || promptLower.Contains("ui") || promptLower.Contains("interfaz"))
            {
                tasks.Add(new DevelopmentTask
                {
                    TaskId = "LOCAL-004",
                    Name = "Interfaz de Usuario (Estimación Local)",
                    Description = "Estimación local básica para frontend",
                    Category = TaskCategory.Frontend,
                    Complexity = ComplexityLevel.Complex,
                    EstimatedHours = 48,
                    RequiredProfile = ProfileLevel.Middle
                });
            }

            // Siempre agregar testing
            tasks.Add(new DevelopmentTask
            {
                TaskId = "LOCAL-TEST",
                Name = "Testing (Estimación Local)",
                Description = "Pruebas unitarias e integración",
                Category = TaskCategory.Testing,
                Complexity = ComplexityLevel.Medium,
                EstimatedHours = 16,
                RequiredProfile = ProfileLevel.Middle
            });

            // Siempre agregar documentación
            tasks.Add(new DevelopmentTask
            {
                TaskId = "LOCAL-DOC",
                Name = "Documentación (Estimación Local)",
                Description = "Documentación técnica y de usuario",
                Category = TaskCategory.Documentation,
                Complexity = ComplexityLevel.Simple,
                EstimatedHours = 8,
                RequiredProfile = ProfileLevel.Middle
            });

            return new ProjectEstimation
            {
                ProjectName = projectName + " (ESTIMACIÓN LOCAL)",
                Status = EstimationStatus.Completed,
                Tasks = tasks,
                TotalEstimatedHours = tasks.Sum(t => t.EstimatedHours),
                ContingencyHours = tasks.Sum(t => t.EstimatedHours) * 0.15,
                Complexity = ProjectComplexity.Medium,
                Confidence = ConfidenceLevel.Low,
                Summary = new EstimationSummary
                {
                    DevelopmentHours = tasks.Where(t => t.Category == TaskCategory.Backend ||
                                                       t.Category == TaskCategory.Frontend ||
                                                       t.Category == TaskCategory.Database).Sum(t => t.EstimatedHours),
                    TestingHours = tasks.Where(t => t.Category == TaskCategory.Testing).Sum(t => t.EstimatedHours),
                    DocumentationHours = tasks.Where(t => t.Category == TaskCategory.Documentation).Sum(t => t.EstimatedHours),
                    InfrastructureHours = tasks.Where(t => t.Category == TaskCategory.Infrastructure ||
                                                          t.Category == TaskCategory.DevOps).Sum(t => t.EstimatedHours),
                    ManagementHours = tasks.Sum(t => t.EstimatedHours) * 0.15
                },
                Assumptions = new List<string>
                {
                    "⚠️ NOTA: Esta es una estimación local de ejemplo",
                    "Configure OpenAI GPT-5 para estimaciones reales y detalladas",
                    "GPT-5 proporciona análisis mucho más profundo y preciso",
                    "Equipo con experiencia en las tecnologías requeridas",
                    "Requisitos estables y bien definidos"
                },
                Risks = new List<string>
                {
                    "Estimación no basada en análisis real del proyecto",
                    "Sin validación de IA avanzada",
                    "Posibles cambios en requisitos",
                    "Dependencias externas no identificadas"
                },
                Recommendations = new List<string>
                {
                    "Configure su API Key de OpenAI en appsettings.json",
                    "Use GPT-5 para obtener estimaciones de nivel profesional",
                    "GPT-5 identifica riesgos y dependencias automáticamente",
                    "Revisar estimaciones con el equipo técnico",
                    "Considerar buffer adicional para imprevistos"
                }
            };
        }

        // Clases para deserialización de respuesta de GPT-5
        private class OpenAIEstimationResponse
        {
            public string ProjectName { get; set; }
            public string Complexity { get; set; }
            public string Confidence { get; set; }
            public double TotalHours { get; set; }
            public double ContingencyHours { get; set; }
            public List<OpenAITask> Tasks { get; set; }
            public EstimationSummary Summary { get; set; }
            public List<string> Assumptions { get; set; }
            public List<string> Risks { get; set; }
            public List<string> Recommendations { get; set; }
        }

        private class OpenAITask
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public string Category { get; set; }
            public string Complexity { get; set; }
            public double EstimatedHours { get; set; }
            public string RequiredProfile { get; set; }
            public List<string> Dependencies { get; set; }
            public List<string> AcceptanceCriteria { get; set; }
            public List<string> Risks { get; set; }
        }
    }
}
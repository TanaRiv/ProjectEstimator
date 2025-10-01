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
        public double ContingencyHours { get; set; }
        public EstimationStatus Status { get; set; }
        public string? AnalysisResult { get; set; }
        public ProjectComplexity Complexity { get; set; }
        public ConfidenceLevel Confidence { get; set; }
        public EstimationSummary Summary { get; set; } = new();
        public List<string> Assumptions { get; set; } = new();
        public List<string> Risks { get; set; } = new();
        public List<string> Recommendations { get; set; } = new();
    }

    public class DevelopmentTask
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string TaskId { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TaskCategory Category { get; set; }
        public double EstimatedHours { get; set; }
        public ComplexityLevel Complexity { get; set; }
        public ProfileLevel RequiredProfile { get; set; }
        public List<string> Dependencies { get; set; } = new();
        public List<string> AcceptanceCriteria { get; set; } = new();
        public List<string> TaskRisks { get; set; } = new();
    }

    public class EstimationSummary
    {
        public double DevelopmentHours { get; set; }
        public double TestingHours { get; set; }
        public double DocumentationHours { get; set; }
        public double InfrastructureHours { get; set; }
        public double ManagementHours { get; set; }
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

    public enum ProjectComplexity
    {
        Low,
        Medium,
        High,
        VeryHigh
    }

    public enum ConfidenceLevel
    {
        High,   // ±10% margen
        Medium, // ±25% margen
        Low     // ±40% margen
    }

    public enum ProfileLevel
    {
        Junior,
        Middle,
        Senior
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

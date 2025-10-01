using System;
using System.Collections.Generic;

namespace ProjectEstimator.Models
{
    public class DevelopmentTask
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public TaskCategory Category { get; set; }
        public double EstimatedHours { get; set; }
        public ComplexityLevel Complexity { get; set; }
        public List<string> Dependencies { get; set; } = new();
        public List<string> RequiredSkills { get; set; } = new();
    }
}

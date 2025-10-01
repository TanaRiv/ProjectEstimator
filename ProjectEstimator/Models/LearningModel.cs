using System;
using System.Collections.Generic;

namespace ProjectEstimator.Models
{
    public class LearningModel
    {
        public Dictionary<TaskCategory, double> CategoryAdjustmentFactors { get; set; } = new();
        public Dictionary<ComplexityLevel, double> ComplexityMultipliers { get; set; } = new();
        public double GlobalAdjustmentFactor { get; set; } = 1.0;
        public int TotalEstimations { get; set; }
        public double AverageAccuracy { get; set; }
        public DateTime LastUpdated { get; set; }
    }
}

using System;
using System.Collections.Generic;

namespace ProjectEstimator.Models
{
    public class EstimationFeedback
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid EstimationId { get; set; }
        public DateTime FeedbackDate { get; set; } = DateTime.UtcNow;
        public double ActualHours { get; set; }
        public double EstimatedHours { get; set; }
        public double AccuracyPercentage => (1 - Math.Abs(ActualHours - EstimatedHours) / ActualHours) * 100;
        public string Comments { get; set; } = string.Empty;
        public List<TaskFeedback> TaskFeedbacks { get; set; } = new();
    }

    public class TaskFeedback
    {
        public Guid TaskId { get; set; }
        public double ActualHours { get; set; }
        public double EstimatedHours { get; set; }
        public string Deviation { get; set; } = string.Empty;
    }
}

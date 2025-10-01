namespace ProjectEstimator.Models
{
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

    public enum EstimationStatus
    {
        Pending,
        Processing,
        Completed,
        Failed
    }
}

namespace ProjectEstimatorApp.Services
{
    using ProjectEstimatorApp.Services.Interfaces;
    
    public class ProjectService : IProjectService
    {
        public string GetProjectName()
        {
            return "Project Estimator";
        }
    }
}

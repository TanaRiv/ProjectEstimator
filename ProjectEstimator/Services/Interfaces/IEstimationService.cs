using System.Threading.Tasks;
using ProjectEstimatorApp.Models;

namespace ProjectEstimatorApp.Services.Interfaces
{
    public interface IEstimationService
    {
        Task<ProjectEstimation> EstimateProjectAsync(EstimationRequest request);
        ProjectEstimation GetSampleEstimation(string projectName, string prompt);
    }
}

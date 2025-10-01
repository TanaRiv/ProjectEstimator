using System.Threading.Tasks;
using ProjectEstimator.Models;

namespace ProjectEstimator.Services.Interfaces
{
    public interface ILearningService
    {
        Task<LearningModel> GetCurrentModelAsync();
        Task ProcessFeedbackAsync(EstimationFeedback feedback);
        Task SaveModelAsync(LearningModel model);
    }
}

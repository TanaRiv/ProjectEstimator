using System.Threading.Tasks;

namespace ProjectEstimatorApp.Services.Interfaces
{
    public interface IOpenAIService
    {
        Task<string> GetCompletionAsync(string systemPrompt, string userPrompt);
        bool IsConfigured();
    }
}

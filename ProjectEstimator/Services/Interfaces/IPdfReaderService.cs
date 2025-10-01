using System.Threading.Tasks;

namespace ProjectEstimator.Services.Interfaces
{
    public interface IPdfReaderService
    {
        Task<string> ReadPdfAsync(string filePath);
    }
}

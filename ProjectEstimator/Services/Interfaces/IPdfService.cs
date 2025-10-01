using System.Threading.Tasks;

namespace ProjectEstimatorApp.Services.Interfaces
{
    public interface IPdfService
    {
        Task<string> ExtractTextFromPdfAsync(byte[] pdfBytes);
        string ExtractTextFromPdf(byte[] pdfBytes);
    }
}

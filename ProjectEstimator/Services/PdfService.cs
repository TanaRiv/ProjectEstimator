using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas.Parser;
using iText.Kernel.Pdf.Canvas.Parser.Listener;
using ProjectEstimatorApp.Services.Interfaces;

namespace ProjectEstimatorApp.Services
{
    public class PdfService : IPdfService
    {
        public async Task<string> ExtractTextFromPdfAsync(byte[] pdfBytes)
        {
            return await Task.Run(() => ExtractTextFromPdf(pdfBytes));
        }

        public string ExtractTextFromPdf(byte[] pdfBytes)
        {
            try
            {
                using (var stream = new MemoryStream(pdfBytes))
                {
                    using (var pdfReader = new PdfReader(stream))
                    {
                        using (var pdfDoc = new PdfDocument(pdfReader))
                        {
                            var strategy = new SimpleTextExtractionStrategy();
                            var extractedText = new StringBuilder();
                            
                            // Extraer texto de todas las páginas
                            for (int pageNum = 1; pageNum <= pdfDoc.GetNumberOfPages(); pageNum++)
                            {
                                var page = pdfDoc.GetPage(pageNum);
                                var text = PdfTextExtractor.GetTextFromPage(page, strategy);
                                
                                if (!string.IsNullOrWhiteSpace(text))
                                {
                                    extractedText.AppendLine($"--- Página {pageNum} ---");
                                    extractedText.AppendLine(text);
                                    extractedText.AppendLine();
                                }
                            }
                            
                            var result = extractedText.ToString();
                            
                            if (string.IsNullOrWhiteSpace(result))
                            {
                                return "No se pudo extraer texto del PDF. El archivo podría estar vacío o contener solo imágenes.";
                            }
                            
                            return result;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return $"Error al procesar el PDF: {ex.Message}";
            }
        }
    }
}

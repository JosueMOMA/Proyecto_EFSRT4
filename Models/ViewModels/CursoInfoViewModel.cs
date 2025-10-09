namespace EducaEFRT.Models.ViewModels
{
    public class CursoInfoViewModel
    {
        public int IdCurso { get; set; }
        public string NombreCurso { get; set; }
        public int DuracionHoras { get; set; }
        public string Nivel { get; set; }
        public bool Certificacion { get; set; }
        public string ImagenUrl { get; set; }
        public decimal Precio { get; set; }
    }
}
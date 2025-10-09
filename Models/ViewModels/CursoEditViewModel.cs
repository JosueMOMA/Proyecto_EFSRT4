using System.Collections.Generic;
using System.Web.Mvc;

namespace EducaEFRT.Models.ViewModels
{
    public class CursoEditViewModel
    {
        public int Id { get; set; }
        public string NombreCurso { get; set; }
        public int DuracionHoras { get; set; }
        public int NivelId { get; set; }
        public IEnumerable<SelectListItem> NivelesDisponibles { get; set; }
        public bool Certificacion { get; set; }
        public string ImagenUrl { get; set; }
        public decimal Precio { get; set; }
    }
}
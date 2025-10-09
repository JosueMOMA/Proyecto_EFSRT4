using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web;
using System.Web.Mvc;

namespace EducaEFRT.Models.ViewModels
{
    public class NuevoCursoViewModel
    {
        [Required(ErrorMessage = "El nombre del curso es obligatorio.")]
        [Display(Name = "Nombre del curso")]
        public string NombreCurso { get; set; }

        [Required(ErrorMessage = "La duración es obligatoria.")]
        [Range(1, 1000, ErrorMessage = "Ingrese una duración válida (en horas).")]
        [Display(Name = "Duración (horas)")]
        public int DuracionHoras { get; set; }

        [Required(ErrorMessage = "Debe seleccionar un nivel.")]
        [Display(Name = "Nivel")]
        public int NivelId { get; set; }

        public IEnumerable<SelectListItem> NivelesDisponibles { get; set; }

        [Display(Name = "Certificación")]
        public bool Certificacion { get; set; }

        [Display(Name = "Imagen URL")]
        public string ImagenUrl { get; set; }

        [Display(Name = "Subir imagen")]
        public HttpPostedFileBase ImagenFile { get; set; }

        [Required(ErrorMessage = "El precio es obligatorio.")]
        [Range(0, 10000, ErrorMessage = "Ingrese un precio válido.")]
        [Display(Name = "Precio (S/.)")]
        public decimal Precio { get; set; }

        public NuevoCursoViewModel()
        {
            // Valores predeterminados
            DuracionHoras = 40;
            Precio = 200;
            NivelesDisponibles = new List<SelectListItem>
            {
                new SelectListItem { Value = "1", Text = "Basico" },
                new SelectListItem { Value = "2", Text = "Intermedio" },
                new SelectListItem { Value = "3", Text = "Avanzado" }
            };
        }
    }
}

using System;

namespace EducaEFRT.Models.ViewModels
{
    public class NotasViewModel
    {
        public int IdMatricula { get; set; }               // Necesario para registrar o actualizar
        public string CodigoEstudiante { get; set; }       // Solo para mostrar
        public string Apellidos { get; set; }              // Solo para mostrar
        public string Nombres { get; set; }                // Solo para mostrar

        public decimal NotaT1 { get; set; }                // Capturado en el formulario
        public decimal NotaT2 { get; set; }                // Capturado en el formulario
        public decimal NotaEF { get; set; }                // Capturado en el formulario
        public decimal? Promedio { get; set; }             // Calculado (puede omitirse si lo calculas en la vista)
        public string Estado { get; set; }                 // Mostrado en la tabla
    }


}

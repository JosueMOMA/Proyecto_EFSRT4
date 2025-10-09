using System;

namespace EducaEFRT.Models.ViewModels
{
    public class ReporteAsistenciaViewModel
    {
        public string Docente { get; set; }
        public string Curso { get; set; }
        public string Seccion { get; set; }
        public string Turno { get; set; }
        public int TotalClases { get; set; }
        public int Asistencias { get; set; }
        public int Inasistencias { get; set; }
        public int Tardanzas { get; set; }
    }
}
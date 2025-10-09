using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EducaEFRT.Models.ViewModels
{
    public class CursoGestionViewModel
    {
        public int IdAsignacion { get; set; }
        public int IdCurso { get; set; }

        // Curso
        public string NombreCurso { get; set; }
        public string ImagenUrl { get; set; }

        // Datos relacionados
        public string NombreSeccion { get; set; }
        public string NombreTurno { get; set; }
        public string NombreDocente { get; set; }

        // Fechas
        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }

        // Total de estudiantes matriculados
        public int CantidadMatriculados { get; set; }
    }
}

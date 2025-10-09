using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EducaEFRT.Models.ViewModels
{
    public class AsignacionViewModel
    {
        public int IdAsignacion { get; set; }
        public string CursoNombre { get; set; }
        public string SeccionNombre { get; set; }
        public string TurnoNombre { get; set; }

        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }

    }
}

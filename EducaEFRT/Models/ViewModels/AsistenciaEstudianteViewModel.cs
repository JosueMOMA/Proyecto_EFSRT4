using System;

namespace EducaEFRT.Models.ViewModels
{
    public class AsistenciaEstudianteViewModel
    {
        public int IdMatricula { get; set; }
        public DateTime Fecha { get; set; }
        public string EstadoAsistencia { get; set; }
    }

}

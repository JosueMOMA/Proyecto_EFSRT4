using System.Collections.Generic;

namespace EducaEFRT.Models.ViewModels
{
    public class DocenteEditViewModel
    {
        public int Id { get; set; }
        public string Dni { get; set; }
        public string Nombres { get; set; }
        public string Apellidos { get; set; }
        public string Correo { get; set; }
        public string Celular { get; set; }
        public string Direccion { get; set; }
        public string Profesion { get; set; }
        public string GradoAcademico { get; set; }
        public string FotoUrl { get; set; }
        public List<CursoAsignadoViewModel> CursosAsignados { get; set; }

        public DocenteEditViewModel()
        {
            CursosAsignados = new List<CursoAsignadoViewModel>();
        }
    }

    public class CursoAsignadoViewModel
    {
        public int Id { get; set; }
        public string Curso { get; set; }
        public string Seccion { get; set; }
        public string Turno { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
    }
}
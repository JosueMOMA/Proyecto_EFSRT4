// EducaEFRT/Models/DB/Repositories/AsignacionCursoRepository.cs
using System;
using System.Collections.Generic;
using System.Linq;

namespace EducaEFRT.Models.DB.Repositories
{
    public class AsignacionCursoRepository : IDisposable
    {
        private readonly EduControlDB _db;

        public AsignacionCursoRepository()
        {
            _db = new EduControlDB();
        }

        public List<AsignacionCursoViewModel> ObtenerCursosPorUsuario(int idUsuario)
        {
            // TEMP: Verifica el idUsuario recibido
            System.Diagnostics.Debug.WriteLine("idUsuario recibido: " + idUsuario);

            var docente = _db.Docentes.FirstOrDefault(d => d.IdUsuario == idUsuario);
            if (docente == null)
            {
                System.Diagnostics.Debug.WriteLine("No se encontró docente para idUsuario: " + idUsuario);
                return new List<AsignacionCursoViewModel>();
            }

            int idDocente = docente.IdDocente;
            System.Diagnostics.Debug.WriteLine("idDocente encontrado: " + idDocente);

            var cursos = (from ac in _db.AsignacionesCurso
                          join c in _db.Cursos on ac.IdCurso equals c.IdCurso
                          join s in _db.Secciones on ac.IdSeccion equals s.IdSeccion
                          join t in _db.Turnos on ac.IdTurno equals t.IdTurno
                          where ac.IdDocente == idDocente
                          select new AsignacionCursoViewModel
                          {
                              IdAsignacion = ac.IdAsignacion, // Agregado
                              NombreCurso = c.NombreCurso,
                              NombreSeccion = s.NombreSeccion,
                              NombreTurno = t.NombreTurno,
                              ImagenUrl = c.ImagenUrl
                          }).ToList();

            System.Diagnostics.Debug.WriteLine("Cursos encontrados: " + cursos.Count);

            return cursos;
        }


        public void Dispose()
        {
            _db.Dispose();
        }
    }

    public class AsignacionCursoViewModel
    {
        public int IdAsignacion { get; set; }
        public string NombreCurso { get; set; }
        public string NombreSeccion { get; set; }
        public string NombreTurno { get; set; }
        public string ImagenUrl { get; set; }

    }
}
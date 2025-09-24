using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using EducaEFRT.Filters;
using EducaEFRT.Models;
using EducaEFRT.Models.DB;
using EducaEFRT.Models.DB.Repositories;
using EducaEFRT.Models.ViewModels;

namespace EducaEFRT.Controllers
{
    [Authorize]
    public class DocenteController : Controller
    {
        public ActionResult CursosAsignados()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            int idUsuario = (int)Session["IdUsuario"];
            System.Diagnostics.Debug.WriteLine("idUsuario en sesión: " + idUsuario);

            using (var repo = new AsignacionCursoRepository())
            {
                var cursos = repo.ObtenerCursosPorUsuario(idUsuario);

                //Obtener nombre completo del docente
                using (var db = new EduControlDB())
                {
                    var docente = db.Docentes.FirstOrDefault(d => d.IdUsuario == idUsuario);
                    if (docente != null)
                    {
                        ViewBag.NombreUsuario = docente.Nombres + " " + docente.Apellidos;
                    }
                    else
                    {
                        ViewBag.NombreUsuario = "Usuario";
                    }
                }

                return View(cursos);
            }
        }
        public ActionResult RegistrarAsistencia(int idAsignacion)
        {
            using (var db = new EduControlDB())
            {
                var asignacion = db.AsignacionesCurso
                    .Include("Curso")
                    .Include("Seccion")
                    .Include("Turno")
                    .FirstOrDefault(a => a.IdAsignacion == idAsignacion);

                if (asignacion == null)
                    return HttpNotFound();

                var model = new RegistrarAsistenciaDocenteViewModel
                {
                    IdAsignacion = asignacion.IdAsignacion,
                    Curso = asignacion.Curso.NombreCurso,
                    Seccion = asignacion.Seccion.NombreSeccion,
                    Turno = asignacion.Turno.NombreTurno
                };

                return View(model);
            }
        }

        [HttpPost]
        public ActionResult RegistrarAsistencia(RegistrarAsistenciaDocenteViewModel model)
        {
            if (ModelState.IsValid)
            {
                bool exito;
                using (var repo = new AsistenciaDocenteRepository())
                {
                    exito = repo.RegistrarAsistencia(model.IdAsignacion);
                }

                if (exito)
                {
                    TempData["Mensaje"] = "✅ Asistencia registrada correctamente.";
                }
                else
                {
                    TempData["Mensaje"] = "⚠️ Ya registraste tu asistencia para este curso hoy.";
                }

                return RedirectToAction("CursosAsignados");
            }

            return View(model);
        }
        //
        [HttpGet]
        public JsonResult ObtenerEstudiantesPorAsignacion(int idAsignacion)
        {
            using (var db = new EduControlDB())
            {
                var fechaHoy = DateTime.Today;

                var lista = (from m in db.Matriculas
                             join e in db.Estudiantes on m.IdEstudiante equals e.IdEstudiante
                             where m.IdAsignacion == idAsignacion
                             select new
                             {
                                 m.IdMatricula,
                                 e.CodigoEstudiante,
                                 e.Apellidos,
                                 e.Nombres,
                                 EstadoAsistencia = db.AsistenciasEstudiante
                                     .Where(a => a.IdMatricula == m.IdMatricula && a.Fecha == fechaHoy)
                                     .Select(a => a.EstadoAsistencia)
                                     .FirstOrDefault() ?? "Falto" // Si no hay asistencia registrada, marcar "Faltó"
                             })
                             .OrderBy(x => x.Apellidos) // 👈 Aquí se hace el ordenamiento por apellido
                             .ThenBy(x => x.Nombres)    // 👈 Opcional: ordenar por nombre si hay mismos apellidos
                             .ToList();

                return Json(lista, JsonRequestBehavior.AllowGet);
            }
        }

        //
        [HttpPost]
        public ActionResult RegistrarAsistenciaEstudiantes(FormCollection form)
        {
            var matriculas = form.GetValues("matriculas[]");
            int registrosInsertados = 0;
            int registrosActualizados = 0;

            if (matriculas != null)
            {
                using (var db = new EduControlDB())
                {
                    foreach (var idStr in matriculas)
                    {
                        int idMatricula = int.Parse(idStr);
                        string key = $"asistencia_{idMatricula}";
                        string estado = form[key];

                        var asistenciaExistente = db.AsistenciasEstudiante.FirstOrDefault(a =>
                            a.IdMatricula == idMatricula && a.Fecha == DateTime.Today);

                        if (asistenciaExistente != null)
                        {
                            // Actualizar si cambió el estado
                            if (asistenciaExistente.EstadoAsistencia != estado)
                            {
                                asistenciaExistente.EstadoAsistencia = estado;
                                asistenciaExistente.Hora = DateTime.Now.TimeOfDay;
                                registrosActualizados++;
                            }
                        }
                        else
                        {
                            // Insertar nuevo registro
                            var nuevaAsistencia = new AsistenciaEstudiante
                            {
                                IdMatricula = idMatricula,
                                Fecha = DateTime.Today,
                                Hora = DateTime.Now.TimeOfDay,
                                EstadoAsistencia = estado
                            };
                            db.AsistenciasEstudiante.Add(nuevaAsistencia);
                            registrosInsertados++;
                        }
                    }

                    db.SaveChanges();
                }

                TempData["Mensaje"] = $"✅ Asistencia de estudiantes actualizada correctamente. " +
                    $"({registrosInsertados} nuevas, {registrosActualizados} actualizadas)";
            }
            else
            {
                TempData["Mensaje"] = "⚠️ No se seleccionó ningún estudiante.";
            }

            return RedirectToAction("CursosAsignados");
        }

        //
        [HttpGet]
        public JsonResult BuscarEstudiantePorCodigo(int idAsignacion, string codigo)
        {
            if (string.IsNullOrEmpty(codigo))
                return Json(new List<object>(), JsonRequestBehavior.AllowGet);

            using (var db = new EduControlDB())
            {
                var fechaHoy = DateTime.Today;

                var resultado = (from m in db.Matriculas
                                 join e in db.Estudiantes on m.IdEstudiante equals e.IdEstudiante
                                 where m.IdAsignacion == idAsignacion && e.CodigoEstudiante == codigo
                                 select new
                                 {
                                     m.IdMatricula,
                                     e.CodigoEstudiante,
                                     e.Apellidos,
                                     e.Nombres,
                                     EstadoAsistencia = db.AsistenciasEstudiante
                                         .Where(a => a.IdMatricula == m.IdMatricula && a.Fecha == fechaHoy)
                                         .Select(a => a.EstadoAsistencia)
                                         .FirstOrDefault() ?? "Falto"
                                 }).ToList();

                return Json(resultado, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public ActionResult RegistrarNotasEstudiantes(FormCollection form)
        {
            var matriculas = form.GetValues("matriculas[]");
            int registrosInsertados = 0;
            int registrosActualizados = 0;

            if (matriculas != null)
            {
                using (var db = new EduControlDB())
                {
                    foreach (var idStr in matriculas)
                    {
                        int idMatricula = int.Parse(idStr);

                        string keyT1 = $"notaT1_{idMatricula}";
                        string keyT2 = $"notaT2_{idMatricula}";
                        string keyEF = $"notaEF_{idMatricula}";

                        bool hayAlgunaNota = !string.IsNullOrWhiteSpace(form[keyT1]) ||
                                             !string.IsNullOrWhiteSpace(form[keyT2]) ||
                                             !string.IsNullOrWhiteSpace(form[keyEF]);

                        if (!hayAlgunaNota)
                            continue; // Ignorar si no hay ninguna nota

                        // Notas individuales (pueden ser nullables)
                        decimal? notaT1 = decimal.TryParse(form[keyT1], out var t1) ? t1 : (decimal?)null;
                        decimal? notaT2 = decimal.TryParse(form[keyT2], out var t2) ? t2 : (decimal?)null;
                        decimal? notaEF = decimal.TryParse(form[keyEF], out var ef) ? ef : (decimal?)null;

                        var notaExistente = db.Notas.FirstOrDefault(n => n.IdMatricula == idMatricula);

                        if (notaExistente != null)
                        {
                            // Solo actualizar si algo cambió
                            if (notaExistente.NotaT1 != notaT1 ||
                                notaExistente.NotaT2 != notaT2 ||
                                notaExistente.NotaEF != notaEF)
                            {
                                notaExistente.NotaT1 = notaT1;
                                notaExistente.NotaT2 = notaT2;
                                notaExistente.NotaEF = notaEF;
                                registrosActualizados++;
                            }
                        }
                        else
                        {
                            var nuevaNota = new Notas
                            {
                                IdMatricula = idMatricula,
                                NotaT1 = notaT1,
                                NotaT2 = notaT2,
                                NotaEF = notaEF,
                                Estado = "Pendiente" // se actualizará luego
                            };
                            db.Notas.Add(nuevaNota);
                            registrosInsertados++;
                        }
                    }

                    db.SaveChanges();
                }

                TempData["Mensaje"] = $"✅ Registro de notas completado. ({registrosInsertados} nuevas, {registrosActualizados} actualizadas)";
            }
            else
            {
                TempData["Mensaje"] = "⚠️ No se seleccionó ningún estudiante para registrar notas.";
            }

            return RedirectToAction("CursosAsignados");
        }


        [HttpGet]
        public JsonResult ObtenerNotasPorAsignacion(int idAsignacion)
        {
            using (var db = new EduControlDB())
            {
                var lista = (from m in db.Matriculas
                             join e in db.Estudiantes on m.IdEstudiante equals e.IdEstudiante
                             where m.IdAsignacion == idAsignacion
                             join n in db.Notas on m.IdMatricula equals n.IdMatricula into notasGroup
                             from n in notasGroup.DefaultIfEmpty() // left join para mostrar incluso si no hay notas aún
                             select new
                             {
                                 m.IdMatricula,
                                 e.CodigoEstudiante,
                                 e.Apellidos,
                                 e.Nombres,
                                 NotaT1 = n != null ? n.NotaT1 : (decimal?)null,
                                 NotaT2 = n != null ? n.NotaT2 : (decimal?)null,
                                 NotaEF = n != null ? n.NotaEF : (decimal?)null,
                                 Promedio = n != null ? n.Promedio : (decimal?)null,
                                 Estado = n != null ? n.Estado : "Pendiente"
                             })
                             .OrderBy(x => x.Apellidos)
                             .ThenBy(x => x.Nombres)
                             .ToList();

                return Json(lista, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult BuscarEstudiantePorCodigoNotas(int idAsignacion, string codigo)
        {
            if (string.IsNullOrEmpty(codigo))
                return Json(new List<object>(), JsonRequestBehavior.AllowGet);

            using (var db = new EduControlDB())
            {
                var resultado = (from m in db.Matriculas
                                 join e in db.Estudiantes on m.IdEstudiante equals e.IdEstudiante
                                 where m.IdAsignacion == idAsignacion && e.CodigoEstudiante == codigo
                                 join n in db.Notas on m.IdMatricula equals n.IdMatricula into notaJoin
                                 from n in notaJoin.DefaultIfEmpty()
                                 select new
                                 {
                                     m.IdMatricula,
                                     e.CodigoEstudiante,
                                     e.Apellidos,
                                     e.Nombres,
                                     T1 = n != null ? n.NotaT1 : (decimal?)null,
                                     T2 = n != null ? n.NotaT2 : (decimal?)null,
                                     EF = n != null ? n.NotaEF : (decimal?)null,
                                     Promedio = n != null ? n.Promedio : (decimal?)null,
                                     EstadoNota = n != null ? n.Estado : "Pendiente"
                                 }).ToList();

                return Json(resultado, JsonRequestBehavior.AllowGet);
            }
        }





    }
}

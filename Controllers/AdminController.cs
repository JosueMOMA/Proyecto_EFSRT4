using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using EducaEFRT.Filters;
using EducaEFRT.Models;
using EducaEFRT.Models.DB;
using EducaEFRT.Models.DB.Repositories;
using System.Data.Entity;
using EducaEFRT.Models.ViewModels;
using System.IO;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Text.RegularExpressions;

namespace EducaEFRT.Controllers
{
    [Authorize]
    public class AdminController : Controller
    {
        public ActionResult PanelAdmin()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            int idUsuario = (int)Session["IdUsuario"];
            System.Diagnostics.Debug.WriteLine("idUsuario en sesión: " + idUsuario);

            using (var db = new EduControlDB())
            {
                var admin = db.AdministradoresSistema.FirstOrDefault(d => d.IdUsuario == idUsuario);
                if (admin != null)
                {
                    ViewBag.NombreUsuario = admin.Nombres + " " + admin.Apellidos;
                }
                else
                {
                    ViewBag.NombreUsuario = "Usuario";
                }
            }
            return View();
        }
        // ==================== GESTIÓN DE CURSOS ====================
        // Listar cursos
        public ActionResult GestionCurso()
        {
            // Verificar sesión
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var cursos = (from c in db.Cursos
                             join a in db.AsignacionesCurso on c.IdCurso equals a.IdCurso into asignaciones
                             from asig in asignaciones.DefaultIfEmpty()
                             select new CursoGestionViewModel
                             {
                                 IdCurso = c.IdCurso,
                                 IdAsignacion = asig != null ? asig.IdAsignacion : 0,
                                 NombreCurso = c.NombreCurso,
                                 ImagenUrl = c.ImagenUrl,
                                 NombreSeccion = asig != null ? asig.Seccion.NombreSeccion : "Sin asignar",
                                 NombreTurno = asig != null ? asig.Turno.NombreTurno : "Sin asignar",
                                 NombreDocente = asig != null ? asig.Docente.Nombres + " " + asig.Docente.Apellidos : "Sin asignar",
                                 FechaInicio = asig != null ? asig.FechaInicio : DateTime.MinValue,
                                 FechaFin = asig != null ? asig.FechaFin : DateTime.MinValue,
                                 CantidadMatriculados = asig != null ? db.Matriculas.Count(m => m.IdAsignacion == asig.IdAsignacion) : 0
                             })
                             .ToList();

                return View("~/Views/Admin/GestionCurso/IndexCurso.cshtml", cursos);
            }
        }
        // ==================== GESTIÓN DE DOCENTES ====================

        // Listar docentes
        public ActionResult GestionDocente()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docentes = db.Docentes.ToList();
                return View("~/Views/Admin/GestionDocente/Index.cshtml", docentes);
            }
        }

        // GET: Crear Docente
        public ActionResult CrearDocente()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            return View("~/Views/Admin/GestionDocente/Crear.cshtml");
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CrearDocente(CrearDocenteViewModel model)
        {
            if (!ModelState.IsValid)
                return View(model);

            try
            {
                using (var db = new EduControlDB())
                {
                    if (db.Usuarios.Any(u => u.Username == model.Username))
                    {
                        ModelState.AddModelError("Username", "El nombre de usuario ya existe.");
                        return View(model);
                    }

                    // Crear Usuario
                    var usuario = new Usuario
                    {
                        Username = model.Username,
                        Password = model.Password,
                        Rol = "Docente"
                    };
                    db.Usuarios.Add(usuario);
                    db.SaveChanges();

                    // Crear Docente
                    var docente = new Docente
                    {
                        Dni = model.Dni,
                        Nombres = model.Nombres,
                        Apellidos = model.Apellidos,
                        Correo = model.Correo,
                        Celular = model.Celular,
                        Direccion = model.Direccion,
                        Profesion = model.Profesion,
                        GradoAcademico = model.GradoAcademico,
                        IdUsuario = usuario.IdUsuario
                    };

                    // Guardar foto si se subió
                    if (model.FotoFile != null && model.FotoFile.ContentLength > 0)
                    {
                        string fileExtension = Path.GetExtension(model.FotoFile.FileName);
                        string fileName = $"{model.Dni}{fileExtension}"; // Renombrar con el DNI
                        string folderPath = Server.MapPath("~/Content/Images/Docentes/");

                        if (!Directory.Exists(folderPath))
                            Directory.CreateDirectory(folderPath);

                        string fullPath = Path.Combine(folderPath, fileName);
                        model.FotoFile.SaveAs(fullPath);

                        // Guardamos la ruta relativa para usarla en la vista
                        docente.Foto = "/Content/Images/Docentes/" + fileName;
                    }

                    db.Docentes.Add(docente);
                    db.SaveChanges();
                }

                TempData["Success"] = "Usuario docente creado correctamente.";
                return RedirectToAction("GestionDocente");
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Error al crear usuario: " + ex.Message);
                return View(model);
            }
        }




        // GET: Detalle docente
        public ActionResult DetalleDocente(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.FirstOrDefault(d => d.IdDocente == id);
                if (docente == null)
                    return HttpNotFound();

                var asignacionesVm = db.AsignacionesCurso
                    .Where(a => a.IdDocente == id)
                    .Select(a => new EducaEFRT.Models.ViewModels.AsignacionViewModel
                    {
                        IdAsignacion = a.IdAsignacion,
                        CursoNombre = a.Curso != null ? a.Curso.NombreCurso : null,
                        SeccionNombre = a.Seccion != null ? a.Seccion.NombreSeccion : null,
                        TurnoNombre = a.Turno != null ? a.Turno.NombreTurno : null,
                        FechaInicio = a.FechaInicio,
                        FechaFin = a.FechaFin
                    })
                    .ToList();

                ViewBag.CursosAsignados = asignacionesVm;

                return View("~/Views/Admin/GestionDocente/Detalle.cshtml", docente);
            }
        }

        // ===========================================================
        // GET: Editar Docente
        // ===========================================================
        public ActionResult EditarDocente(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                // 1️⃣ Buscar docente
                var docente = db.Docentes.FirstOrDefault(d => d.IdDocente == id);
                if (docente == null)
                    return HttpNotFound();

                // 2️⃣ Cargar solo las asignaciones de este docente
                var asignacionesVm = db.AsignacionesCurso
                    .Include("Curso")
                    .Include("Seccion")
                    .Include("Turno")
                    .Where(a => a.IdDocente == id)
                    .Select(a => new AsignacionViewModel
                    {
                        IdAsignacion = a.IdAsignacion,
                        CursoNombre = a.Curso.NombreCurso,
                        SeccionNombre = a.Seccion.NombreSeccion,
                        TurnoNombre = a.Turno.NombreTurno,
                        FechaInicio = a.FechaInicio,
                        FechaFin = a.FechaFin
                    })
                    .ToList();

                // 3️⃣ Crear ViewModel
                var viewModel = new EditarDocenteViewModel
                {
                    Docente = docente,
                    CursosAsignados = asignacionesVm
                };

                return View("~/Views/Admin/GestionDocente/Editar.cshtml", viewModel);
            }
        }

        // ===========================================================
        // POST: Editar Docente
        // ===========================================================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditarDocente(EditarDocenteViewModel model)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            if (!ModelState.IsValid)
                return View("~/Views/Admin/GestionDocente/Editar.cshtml", model);

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.FirstOrDefault(d => d.IdDocente == model.Docente.IdDocente);
                if (docente == null)
                    return HttpNotFound();

                // 🧾 Actualizar datos básicos
                docente.Dni = model.Docente.Dni;
                docente.Nombres = model.Docente.Nombres;
                docente.Apellidos = model.Docente.Apellidos;
                docente.Correo = model.Docente.Correo;
                docente.Celular = model.Docente.Celular;
                docente.Direccion = model.Docente.Direccion;
                docente.Profesion = model.Docente.Profesion;
                docente.GradoAcademico = model.Docente.GradoAcademico;

                // 🖼️ Si se subió una nueva foto
                if (model.FotoFile != null && model.FotoFile.ContentLength > 0)
                {
                    string extension = Path.GetExtension(model.FotoFile.FileName);
                    string fileName = $"{model.Docente.Dni}{extension}";
                    string folderPath = Server.MapPath("~/Content/Images/Docentes/");

                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);

                    string fullPath = Path.Combine(folderPath, fileName);
                    model.FotoFile.SaveAs(fullPath);

                    docente.Foto = "/Content/Images/Docentes/" + fileName;
                }

                db.Entry(docente).State = EntityState.Modified;
                db.SaveChanges();
            }

            TempData["SuccessMessage"] = "Los datos del docente se actualizaron correctamente.";
            return RedirectToAction("GestionDocente");
        }

        // GET: Eliminar docente
        public ActionResult EliminarDocente(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.Find(id);
                if (docente == null)
                    return HttpNotFound();

                return View("~/Views/Admin/GestionDocente/Eliminar.cshtml", docente);
            }
        }

        // POST: Confirmar eliminación
        [HttpPost, ActionName("EliminarDocente")]
        [ValidateAntiForgeryToken]
        public ActionResult EliminarDocenteConfirmado(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.Find(id);
                if (docente != null)
                {
                    db.Docentes.Remove(docente);
                    db.SaveChanges();
                }
            }
            return RedirectToAction("GestionDocente");
        }

        // ===========================================================
        // MÉTODOS PARA GESTIÓN DE ASIGNACIONES
        // ===========================================================
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditarAsignacion(int IdAsignacion, int IdTurno, DateTime FechaInicio, DateTime FechaFin)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var asignacion = db.AsignacionesCurso.Find(IdAsignacion);
                if (asignacion != null)
                {
                    asignacion.IdTurno = IdTurno;
                    asignacion.FechaInicio = FechaInicio;
                    asignacion.FechaFin = FechaFin;
                    
                    db.Entry(asignacion).State = EntityState.Modified;
                    db.SaveChanges();
                    
                    TempData["SuccessMessage"] = "Asignación actualizada correctamente.";
                }
            }
            
            return RedirectToAction("EditarDocente", new { id = Request.Form["IdDocente"] });
        }
        
        [HttpGet]
        public JsonResult ObtenerTurnos()
        {
            using (var db = new EduControlDB())
            {
                var turnos = db.Turnos.Select(t => new { 
                    IdTurno = t.IdTurno, 
                    NombreTurno = t.NombreTurno 
                }).ToList();
                
                return Json(turnos, JsonRequestBehavior.AllowGet);
            }
        }
        
        // ===========================================================
        // CREAR NUEVO CURSO
        // ===========================================================
        
        public ActionResult CrearCurso()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            var model = new NuevoCursoViewModel();
            model.NivelesDisponibles = new List<SelectListItem>
            {
                new SelectListItem { Value = "1", Text = "Básico" },
                new SelectListItem { Value = "2", Text = "Intermedio" },
                new SelectListItem { Value = "3", Text = "Avanzado" }
            };

            return View("~/Views/Admin/GestionCurso/CrearCurso.cshtml", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RegistrarCurso(NuevoCursoViewModel model)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            if (!ModelState.IsValid)
            {
                // Recargar niveles disponibles si hay error de validación
                model.NivelesDisponibles = new List<SelectListItem>
        {
            new SelectListItem { Value = "1", Text = "Básico" },
            new SelectListItem { Value = "2", Text = "Intermedio" },
            new SelectListItem { Value = "3", Text = "Avanzado" }
        };
                return View("~/Views/Admin/GestionCurso/CrearCurso.cshtml", model);
            }

            try
            {
                using (var db = new EduControlDB())
                {
                    // Determinar nivel textual según el Id seleccionado
                    string nivelTexto = "Desconocido";
                    if (model.NivelId == 1)
                        nivelTexto = "Básico";
                    else if (model.NivelId == 2)
                        nivelTexto = "Intermedio";
                    else if (model.NivelId == 3)
                        nivelTexto = "Avanzado";

                    // Crear instancia del curso
                    var curso = new Curso
                    {
                        NombreCurso = model.NombreCurso,
                        DuracionHoras = model.DuracionHoras,
                        Nivel = nivelTexto,
                        Certificacion = model.Certificacion,
                        Precio = model.Precio
                    };

                    // Manejo de imagen (opcional)
                    if (model.ImagenFile != null && model.ImagenFile.ContentLength > 0)
                    {
                        string fileExtension = Path.GetExtension(model.ImagenFile.FileName);
                        string safeName = model.NombreCurso
                            .Replace(" ", "_")
                            .Replace("/", "_")
                            .Replace("\\", "_");

                        string fileName = safeName + fileExtension;
                        string folderPath = Server.MapPath("~/Content/Images/Cursos/");

                        if (!Directory.Exists(folderPath))
                            Directory.CreateDirectory(folderPath);

                        string fullPath = Path.Combine(folderPath, fileName);
                        model.ImagenFile.SaveAs(fullPath);

                        // Guardar ruta relativa para usar en la vista
                        curso.ImagenUrl = "/Content/Images/Cursos/" + fileName;
                    }
                    else
                    {
                        curso.ImagenUrl = null;
                    }

                    db.Cursos.Add(curso);
                    db.SaveChanges();
                }

                TempData["Success"] = "Curso registrado correctamente.";
                return RedirectToAction("GestionCurso");
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Error al registrar curso: " + ex.Message);

                // Recargar niveles para mantener el combo en caso de error
                model.NivelesDisponibles = new List<SelectListItem>
        {
            new SelectListItem { Value = "1", Text = "Básico" },
            new SelectListItem { Value = "2", Text = "Intermedio" },
            new SelectListItem { Value = "3", Text = "Avanzado" }
        };

                return View("~/Views/Admin/GestionCurso/CrearCurso.cshtml", model);
            }
        }


        public ActionResult DetalleCurso(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var curso = db.Cursos.FirstOrDefault(c => c.IdCurso == id);
                if (curso == null)
                    return HttpNotFound();

                var model = new CursoInfoViewModel
                {
                    NombreCurso = curso.NombreCurso,
                    DuracionHoras = curso.DuracionHoras,
                    Nivel = curso.Nivel,
                    Certificacion = curso.Certificacion,
                    ImagenUrl = curso.ImagenUrl,
                    Precio = curso.Precio
                };

                return View("~/Views/Admin/GestionCurso/DetalleCurso.cshtml", model);
            }
        }








        // =====================================
        // MÉTODO GET: EditarCurso
        // =====================================
        public ActionResult EditarCurso(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                // Buscar el curso directamente (no la asignación)
                var curso = db.Cursos.FirstOrDefault(c => c.IdCurso == id);

                if (curso == null)
                    return HttpNotFound();

                // Mapeamos al ViewModel
                var model = new CursoInfoViewModel
                {
                    IdCurso = curso.IdCurso,
                    NombreCurso = curso.NombreCurso,
                    DuracionHoras = curso.DuracionHoras,
                    Nivel = curso.Nivel,
                    Certificacion = curso.Certificacion,
                    Precio = curso.Precio,
                    ImagenUrl = curso.ImagenUrl
                };

                return View("~/Views/Admin/GestionCurso/EditarCurso.cshtml", model);
            }
        }


        // =====================================
        // MÉTODO POST: EditarCurso (Guardar cambios)
        // =====================================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditarCurso(CursoInfoViewModel model, HttpPostedFileBase ImagenFile)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            if (!ModelState.IsValid)
                return View("~/Views/Admin/GestionCurso/EditarCurso.cshtml", model);

            try
            {
                using (var db = new EduControlDB())
                {
                    var curso = db.Cursos.FirstOrDefault(c => c.IdCurso == model.IdCurso);

                    if (curso == null)
                        return HttpNotFound();

                    // Actualizar campos básicos
                    curso.NombreCurso = model.NombreCurso;
                    curso.DuracionHoras = model.DuracionHoras;
                    curso.Nivel = model.Nivel;
                    curso.Certificacion = model.Certificacion;
                    curso.Precio = model.Precio;

                    // Manejo de imagen
                    if (ImagenFile != null && ImagenFile.ContentLength > 0)
                    {
                        try
                        {
                            string carpetaDestino = Server.MapPath("~/Content/Images/Cursos/");
                            if (!Directory.Exists(carpetaDestino))
                                Directory.CreateDirectory(carpetaDestino);

                            // Eliminar imagen anterior si existe
                            if (!string.IsNullOrEmpty(curso.ImagenUrl))
                            {
                                string rutaAnterior = Server.MapPath(curso.ImagenUrl);
                                if (System.IO.File.Exists(rutaAnterior))
                                    System.IO.File.Delete(rutaAnterior);
                            }

                            // Guardar la nueva imagen
                            string extension = Path.GetExtension(ImagenFile.FileName);
                            string nuevoNombre = $"curso_{curso.IdCurso}_{DateTime.Now.Ticks}{extension}";
                            string rutaCompleta = Path.Combine(carpetaDestino, nuevoNombre);
                            ImagenFile.SaveAs(rutaCompleta);

                            // Guardar la ruta relativa
                            curso.ImagenUrl = $"/Content/Images/Cursos/{nuevoNombre}";
                        }
                        catch (Exception ex)
                        {
                            ModelState.AddModelError("", "Error al guardar la imagen: " + ex.Message);
                            return View("~/Views/Admin/GestionCurso/EditarCurso.cshtml", model);
                        }
                    }

                    db.Entry(curso).State = EntityState.Modified;
                    db.SaveChanges();

                    TempData["SuccessMessage"] = "El curso se actualizó correctamente.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error al actualizar curso: {ex.Message}");
                TempData["ErrorMessage"] = "Ocurrió un error al actualizar el curso.";
            }

            return RedirectToAction("GestionCurso");
        }


        [HttpGet]
        public JsonResult ObtenerCursos()
        {
            using (var db = new EduControlDB())
            {
                var cursos = db.Cursos.Select(c => new { 
                    IdCurso = c.IdCurso, 
                    NombreCurso = c.NombreCurso 
                }).ToList();
                
                return Json(cursos, JsonRequestBehavior.AllowGet);
            }
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AgregarAsignacion(FormCollection form)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            try
            {
                int idDocente = int.Parse(form["Docente.IdDocente"]);
                int idCurso = int.Parse(form["IdCurso"]);
                int idSeccion = int.Parse(form["IdSeccion"]);
                int idTurno = int.Parse(form["IdTurno"]);
                DateTime fechaInicio = DateTime.Parse(form["FechaInicio"]);
                DateTime fechaFin = DateTime.Parse(form["FechaFin"]);

                using (var db = new EduControlDB())
                {
                    var asignacion = new AsignacionCurso
                    {
                        IdDocente = idDocente,
                        IdCurso = idCurso,
                        IdSeccion = idSeccion,
                        IdTurno = idTurno,
                        FechaInicio = fechaInicio,
                        FechaFin = fechaFin
                    };
                    
                    db.AsignacionesCurso.Add(asignacion);
                    db.SaveChanges();
                    
                    System.Diagnostics.Debug.WriteLine($"Asignación creada: Docente {idDocente}, Curso {idCurso}");
                }
                
                TempData["SuccessMessage"] = "Asignación agregada correctamente.";
                return RedirectToAction("EditarDocente", new { id = idDocente });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
                TempData["ErrorMessage"] = "Error al agregar asignación.";
                return RedirectToAction("GestionDocente");
            }
        }
        
        public ActionResult EliminarAsignacion(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var asignacion = db.AsignacionesCurso.Find(id);
                if (asignacion != null)
                {
                    int idDocente = asignacion.IdDocente;
                    int idCurso = asignacion.IdCurso;
                    
                    // Eliminar TODAS las asignaciones de este curso
                    var todasAsignaciones = db.AsignacionesCurso.Where(a => a.IdCurso == idCurso).ToList();
                    db.AsignacionesCurso.RemoveRange(todasAsignaciones);
                    db.SaveChanges();
                    
                    System.Diagnostics.Debug.WriteLine($"Eliminadas {todasAsignaciones.Count} asignaciones del curso {idCurso}");
                    TempData["SuccessMessage"] = $"Eliminadas todas las asignaciones del curso ({todasAsignaciones.Count} asignaciones).";
                    return RedirectToAction("EditarDocente", new { id = idDocente });
                }
            }
            
            return RedirectToAction("GestionDocente");
        }

        // ==================== REPORTES ====================
        public ActionResult Reportes(int? docente = null, int? curso = null, int? seccion = null, int? turno = null)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            // Debug de parámetros recibidos
            System.Diagnostics.Debug.WriteLine($"=== PARÁMETROS RECIBIDOS ===");
            System.Diagnostics.Debug.WriteLine($"docente: {docente}");
            System.Diagnostics.Debug.WriteLine($"curso: {curso}");
            System.Diagnostics.Debug.WriteLine($"seccion: {seccion}");
            System.Diagnostics.Debug.WriteLine($"turno: {turno}");
            System.Diagnostics.Debug.WriteLine($"QueryString completo: {Request.QueryString}");

            using (var db = new EduControlDB())
            {
                try
                {
                    System.Diagnostics.Debug.WriteLine($"Ejecutando consulta con filtros: docente={docente}, curso={curso}, seccion={seccion}, turno={turno}");
                    
                    var reportes = db.Database.SqlQuery<ReporteAsistenciaViewModel>(
                        "EXEC sp_ReporteAsistenciaDocente @id_docente, @id_curso, @id_seccion, @id_turno",
                        new SqlParameter("@id_docente", (object)docente ?? DBNull.Value),
                        new SqlParameter("@id_curso", (object)curso ?? DBNull.Value),
                        new SqlParameter("@id_seccion", (object)seccion ?? DBNull.Value),
                        new SqlParameter("@id_turno", (object)turno ?? DBNull.Value)
                    ).ToList();
                    
                    System.Diagnostics.Debug.WriteLine($"Registros obtenidos después del filtro: {reportes.Count}");
                    
                    // Cargar datos para los selectores
                    ViewBag.Docentes = db.Docentes.Select(d => new SelectListItem
                    {
                        Value = d.IdDocente.ToString(),
                        Text = d.Nombres + " " + d.Apellidos,
                        Selected = d.IdDocente == docente
                    }).ToList();
                    
                    ViewBag.Cursos = db.Cursos.Select(c => new SelectListItem
                    {
                        Value = c.IdCurso.ToString(),
                        Text = c.NombreCurso,
                        Selected = c.IdCurso == curso
                    }).ToList();
                    
                    ViewBag.Secciones = db.Secciones.Select(s => new SelectListItem
                    {
                        Value = s.IdSeccion.ToString(),
                        Text = s.NombreSeccion,
                        Selected = s.IdSeccion == seccion
                    }).ToList();
                    
                    ViewBag.Turnos = db.Turnos.Select(t => new SelectListItem
                    {
                        Value = t.IdTurno.ToString(),
                        Text = t.NombreTurno,
                        Selected = t.IdTurno == turno
                    }).ToList();
                    
                    System.Diagnostics.Debug.WriteLine($"Reportes encontrados: {reportes.Count}");
                    
                    return View("~/Views/Admin/Reportes/Reportes.cshtml", reportes);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error completo: {ex.ToString()}");
                    ViewBag.Error = ex.Message;
                    return View("~/Views/Admin/Reportes/Reportes.cshtml", new List<ReporteAsistenciaViewModel>());
                }
            }
        }
    }
}

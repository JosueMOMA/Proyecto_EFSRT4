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
    public class AdminController : Controller
    {
        public ActionResult PanelAdmin()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            int idUsuario = (int)Session["IdUsuario"];
            System.Diagnostics.Debug.WriteLine("idUsuario en sesión: " + idUsuario);
            //Obtener nombre completo del admin
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

        // Gestión de Docentes
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

        public ActionResult CrearDocente()
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            return View("~/Views/Admin/GestionDocente/Crear.cshtml");
        }

        public ActionResult DetalleDocente(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.FirstOrDefault(d => d.IdDocente == id);
                if (docente == null)
                    return HttpNotFound();

                var viewModel = new DocenteEditViewModel
                {
                    Id = docente.IdDocente,
                    Nombres = docente.Nombres ?? "",
                    Apellidos = docente.Apellidos ?? "",
                    Dni = docente.Dni ?? "",
                    Correo = docente.Correo ?? "",
                    Celular = docente.Celular ?? "",
                    Direccion = docente.Direccion ?? "",
                    Profesion = docente.Profesion ?? "",
                    GradoAcademico = docente.GradoAcademico ?? "",
                    FotoUrl = docente.FotoUrl ?? "",
                    CursosAsignados = new List<CursoAsignadoViewModel>()
                };

                return View("~/Views/Admin/GestionDocente/Detalle.cshtml", viewModel);
            }
        }

        public ActionResult EditarDocente(int id)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.FirstOrDefault(d => d.IdDocente == id);
                if (docente == null)
                    return HttpNotFound();

                // Cargar datos reales de la base de datos
                var viewModel = new DocenteEditViewModel
                {
                    Id = docente.IdDocente,
                    Nombres = docente.Nombres ?? "",
                    Apellidos = docente.Apellidos ?? "",
                    Dni = docente.Dni ?? "",
                    Correo = docente.Correo ?? "",
                    Celular = docente.Celular ?? "",
                    Direccion = docente.Direccion ?? "",
                    Profesion = docente.Profesion ?? "",
                    GradoAcademico = docente.GradoAcademico ?? "",
                    FotoUrl = docente.FotoUrl ?? "",
                    CursosAsignados = new List<CursoAsignadoViewModel>()
                };

                return View("~/Views/Admin/GestionDocente/Editar.cshtml", viewModel);
            }
        }

        [HttpPost]
        public ActionResult Guardar(DocenteEditViewModel model)
        {
            if (Session["IdUsuario"] == null)
                return RedirectToAction("Login", "Account");

            using (var db = new EduControlDB())
            {
                var docente = db.Docentes.FirstOrDefault(d => d.IdDocente == model.Id);
                if (docente != null)
                {
                    // Actualizar todos los campos
                    docente.Nombres = model.Nombres;
                    docente.Apellidos = model.Apellidos;
                    docente.Dni = model.Dni;
                    docente.Correo = model.Correo;
                    docente.Celular = model.Celular;
                    docente.Direccion = model.Direccion;
                    docente.Profesion = model.Profesion;
                    docente.GradoAcademico = model.GradoAcademico;
                    docente.FotoUrl = model.FotoUrl;
                    
                    db.SaveChanges();
                    return RedirectToAction("GestionDocente");
                }
            }

            return View("~/Views/Admin/GestionDocente/Editar.cshtml", model);
        }
    }
}

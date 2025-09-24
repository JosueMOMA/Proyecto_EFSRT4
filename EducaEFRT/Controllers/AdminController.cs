using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using EducaEFRT.Filters;
using EducaEFRT.Models;
using EducaEFRT.Models.DB;
using EducaEFRT.Models.DB.Repositories;

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
    }
}

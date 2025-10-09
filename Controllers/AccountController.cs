using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using EducaEFRT.Models.DB.Repositories;
using EducaEFRT.Models;
using System.Web.Security;

namespace EducaEFRT.Controllers
{
    public class AccountController : Controller
    {
        [AllowAnonymous]
        public ActionResult Login(string returnUrl)
        {
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginViewModel model, string returnUrl)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                using (var repo = new UsuarioRepository())
                {
                    var usuario = repo.ValidarUsuario(model.Username, model.Password);

                    if (usuario != null)
                    {
                        FormsAuthentication.SetAuthCookie(model.Username, model.RememberMe);
                        Session["IdUsuario"] = usuario.IdUsuario;
                        Session["NombreUsuario"] = usuario.Username;
                        Session["Rol"] = usuario.Rol;

                        if (usuario.Rol == "Docente")
                        {
                            return RedirectToAction("CursosAsignados", "Docente");
                        }
                        else if (usuario.Rol == "Administrador")
                        {
                            return RedirectToAction("PanelAdmin", "Admin");
                        }
                        else
                        {
                            ModelState.AddModelError("", "Rol no reconocido.");
                            return View(model);
                        }
                    }

                }

                ModelState.AddModelError("", "Nombre de usuario o contraseña incorrectos.");
            }
            catch (Exception ex)
            {
                string mensajeError = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                ModelState.AddModelError("", "Error técnico: " + mensajeError);
                System.Diagnostics.Debug.WriteLine("ERROR LOGIN: " + ex.ToString());
            }

            return View(model);
        }

        private ActionResult RedirectToLocal(string returnUrl)
        {
            if (Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }
            return RedirectToAction("Login", "Account");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            System.Web.Security.FormsAuthentication.SignOut();

            return RedirectToAction("Login", "Account");
        }
    }
}
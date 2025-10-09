using System;
using System.ComponentModel.DataAnnotations;
using System.Web;

namespace EducaEFRT.Models.ViewModels
{
    public class CrearDocenteViewModel
    {
        // =================== USUARIO ===================
        [Required(ErrorMessage = "El nombre de usuario es obligatorio.")]
        [StringLength(50, ErrorMessage = "El nombre de usuario no puede tener más de 50 caracteres.")]
        public string Username { get; set; }

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [DataType(DataType.Password)]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres.")]
        [RegularExpression(@"^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\-=/\\|]).{8,}$",
            ErrorMessage = "La contraseña debe tener al menos 8 caracteres, una letra mayúscula, un número y un carácter especial.")]
        public string Password { get; set; }

        public string Rol { get; set; } = "Docente";

        // =================== DOCENTE ===================
        [Required(ErrorMessage = "El DNI es obligatorio.")]
        [StringLength(8, MinimumLength = 8, ErrorMessage = "El DNI debe tener 8 dígitos.")]
        [RegularExpression(@"^\d{8}$", ErrorMessage = "El DNI debe contener solo números.")]
        public string Dni { get; set; }

        [Required(ErrorMessage = "Los nombres son obligatorios.")]
        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "Los nombres solo pueden contener letras.")]
        public string Nombres { get; set; }

        [Required(ErrorMessage = "Los apellidos son obligatorios.")]
        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "Los apellidos solo pueden contener letras.")]
        public string Apellidos { get; set; }

        [EmailAddress(ErrorMessage = "Ingrese un correo válido.")]
        public string Correo { get; set; }

        [RegularExpression(@"^\d{9}$", ErrorMessage = "El celular debe tener 9 números y solo contener dígitos.")]
        public string Celular { get; set; }

        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "La profesión solo puede contener letras.")]
        public string Profesion { get; set; }

        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "El grado académico solo puede contener letras.")]
        public string GradoAcademico { get; set; }

        public string Direccion { get; set; }

        // =================== IMAGEN ===================
        public HttpPostedFileBase FotoFile { get; set; }
    }
}

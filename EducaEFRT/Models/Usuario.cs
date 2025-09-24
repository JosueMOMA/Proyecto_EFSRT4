using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace EducaEFRT.Models
{
    [Table("Usuario")] // Asegura que mapea a la tabla correcta
    public class Usuario
    {
        [Key] // Esto define la propiedad como clave primaria
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)] // Autoincremental
        [Column("id_usuario")] // Mapea al nombre de columna correcto
        public int IdUsuario { get; set; }

        [Required]
        [Column("Username")]
        public string Username { get; set; }

        [Required]
        [Column("Password")]
        public string Password { get; set; }

        [Required]
        [Column("Rol")]
        public string Rol { get; set; }
    }
}
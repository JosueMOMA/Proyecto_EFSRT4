using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("AdministradorSistema")]
    public class AdministradorSistema
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_admin")]
        public int IdAdmin { get; set; }

        [Required]
        [Column("nombres")]
        public string Nombres { get; set; }

        [Required]
        [Column("apellidos")]
        public string Apellidos { get; set; }

        [Required]
        [Column("id_usuario")]
        public int IdUsuario { get; set; }
    }
}

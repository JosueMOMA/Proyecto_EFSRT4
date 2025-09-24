using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Docente")]
    public class Docente
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_docente")]
        public int IdDocente { get; set; }

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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Estudiante")]
    public class Estudiante
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_estudiante")]
        public int IdEstudiante { get; set; }

        [Required]
        [Column("codigo_estudiante")]
        public string CodigoEstudiante { get; set; }

        [Required]
        [Column("apellidos")]
        public string Apellidos { get; set; }

        [Required]
        [Column("nombres")]
        public string Nombres { get; set; }
    }
}

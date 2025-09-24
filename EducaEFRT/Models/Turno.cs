using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Turno")]
    public class Turno
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_turno")]
        public int IdTurno { get; set; }

        [Required]
        [Column("nombre_turno")]
        public string NombreTurno { get; set; }
    }
}

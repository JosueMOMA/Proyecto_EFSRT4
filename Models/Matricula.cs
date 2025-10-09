using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Matricula")]
    public class Matricula
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_matricula")]
        public int IdMatricula { get; set; }

        [Required]
        [Column("id_estudiante")]
        public int IdEstudiante { get; set; }

        [Required]
        [Column("id_asignacion")]
        public int IdAsignacion { get; set; }
        public virtual Estudiante Estudiante { get; set; }
    }
}
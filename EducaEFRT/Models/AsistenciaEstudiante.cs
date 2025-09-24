using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("AsistenciaEstudiante")]
    public class AsistenciaEstudiante
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_asistencia_estudiante")]
        public int IdAsistenciaEstudiante { get; set; }

        [Required]
        [Column("id_matricula")]
        public int IdMatricula { get; set; }

        [Required]
        [Column("fecha")]
        public DateTime Fecha { get; set; }

        [Required]
        [Column("hora")]
        public TimeSpan Hora { get; set; }

        [Required]
        [Column("estado_asistencia")]
        public string EstadoAsistencia { get; set; }
    }
}

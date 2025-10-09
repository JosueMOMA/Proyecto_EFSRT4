using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("AsistenciaDocente")]
    public class AsistenciaDocente
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_asistencia_docente")]
        public int IdAsistenciaDocente { get; set; }

        [Required]
        [Column("id_asignacion")]
        public int IdAsignacion { get; set; }

        [Required]
        [Column("fecha")]
        public DateTime Fecha { get; set; }

        [Required]
        [Column("hora")]
        public TimeSpan Hora { get; set; }

        [Required]
        [Column("estado_asistencia")]
        public String EstadoAsistencia { get; set; }

    }
}

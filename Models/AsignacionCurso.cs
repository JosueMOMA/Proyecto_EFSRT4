using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("AsignacionCurso")]
    public class AsignacionCurso
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_asignacion")]
        public int IdAsignacion { get; set; }

        [Required]
        [Column("id_docente")]
        public int IdDocente { get; set; }

        [Required]
        [Column("id_curso")]
        public int IdCurso { get; set; }

        [Required]
        [Column("id_seccion")]
        public int IdSeccion { get; set; }

        [Required]
        [Column("id_turno")]
        public int IdTurno { get; set; }

        // ✅ NUEVAS COLUMNAS DE FECHAS
        [Required]
        [Column("fecha_inicio")]
        public DateTime FechaInicio { get; set; }

        [Required]
        [Column("fecha_fin")]
        public DateTime FechaFin { get; set; }

        // Relaciones de navegación
        [ForeignKey("IdCurso")]
        public virtual Curso Curso { get; set; }

        [ForeignKey("IdSeccion")]
        public virtual Seccion Seccion { get; set; }

        [ForeignKey("IdTurno")]
        public virtual Turno Turno { get; set; }

        [ForeignKey("IdDocente")]
        public virtual Docente Docente { get; set; }
    }
}

using System;
using System.Collections.Generic;
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
        [StringLength(8)]
        [Column("dni")]
        public string Dni { get; set; }

        [Required]
        [Column("nombres")]
        public string Nombres { get; set; }

        [Required]
        [Column("apellidos")]
        public string Apellidos { get; set; }

        [Column("correo")]
        [EmailAddress]
        public string Correo { get; set; }

        [Column("celular")]
        [Phone]
        public string Celular { get; set; }

        [Column("direccion")]
        public string Direccion { get; set; }

        [Column("profesion")]
        public string Profesion { get; set; }

        [Column("grado_academico")]
        public string GradoAcademico { get; set; }

        [Column("foto")]
        public string Foto { get; set; }

        [Required]
        [Column("id_usuario")]
        public int IdUsuario { get; set; }
        public virtual ICollection<AsignacionCurso> AsignacionesCurso { get; set; }

    }
}

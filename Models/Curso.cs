using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Curso")]
    public class Curso
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_curso")]
        public int IdCurso { get; set; }

        [Required]
        [Column("nombre_curso")]
        public string NombreCurso { get; set; }

        [Column("imagen_url")]
        public string ImagenUrl { get; set; }

        //NUEVOS CAMPOS
        [Required]
        [Column("duracion_horas")]
        public int DuracionHoras { get; set; }

        [Required]
        [Column("nivel")]
        public string Nivel { get; set; }

        [Required]
        [Column("certificacion")]
        public bool Certificacion { get; set; }

        [Required]
        [Column("precio")]
        public decimal Precio { get; set; }

    }
}
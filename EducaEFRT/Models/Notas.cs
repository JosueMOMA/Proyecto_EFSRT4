using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Notas")]
    public class Notas
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_nota")]
        public int IdNota { get; set; }

        [Required]
        [Column("id_matricula")]
        public int IdMatricula { get; set; }

        [Column("nota_T1")]
        public decimal? NotaT1 { get; set; }

        [Column("nota_T2")]
        public decimal? NotaT2 { get; set; }

        [Column("nota_EF")]
        public decimal? NotaEF { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        [Column("promedio")]
        public decimal? Promedio { get; set; }

        [Required]
        [Column("estado")]
        public string Estado { get; set; }
    }
}

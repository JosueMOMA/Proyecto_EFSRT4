using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducaEFRT.Models
{
    [Table("Seccion")]
    public class Seccion
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id_seccion")]
        public int IdSeccion { get; set; }

        [Required]
        [Column("nombre_seccion")]
        public string NombreSeccion { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace EducaEFRT.Models.ViewModels
{
    public class EditarDocenteViewModel
    {
        public Docente Docente { get; set; }
        public List<AsignacionViewModel> CursosAsignados { get; set; }
        public HttpPostedFileBase FotoFile { get; set; } // 👈 Agregar esta línea

        public EditarDocenteViewModel()
        {
            CursosAsignados = new List<AsignacionViewModel>();
        }
    }
}

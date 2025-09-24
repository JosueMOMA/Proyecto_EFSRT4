using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using EducaEFRT.Models;


namespace EducaEFRT.Models.DB
{
    public class EduControlDB : DbContext
    {
        public EduControlDB() : base("name=EduControlDB")
        {
            // Configuración adicional para evitar problemas
            Configuration.ProxyCreationEnabled = false;
            Configuration.LazyLoadingEnabled = false;
        }

        public virtual DbSet<Usuario> Usuarios { get; set; }
        public virtual DbSet<Docente> Docentes { get; set; }
        public virtual DbSet<AdministradorSistema> AdministradoresSistema { get; set; }
        public virtual DbSet<Curso> Cursos { get; set; }
        public virtual DbSet<Seccion> Secciones { get; set; }
        public virtual DbSet<Turno> Turnos { get; set; }
        public virtual DbSet<Estudiante> Estudiantes { get; set; }
        public virtual DbSet<AsignacionCurso> AsignacionesCurso { get; set; }
        public virtual DbSet<AsistenciaDocente> AsistenciasDocente { get; set; }
        public virtual DbSet<Matricula> Matriculas { get; set; }
        public virtual DbSet<AsistenciaEstudiante> AsistenciasEstudiante { get; set; }
        public virtual DbSet<Notas> Notas { get; set; }
        public IEnumerable<object> AsignacionCurso { get; internal set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            // Elimina esta línea si estás usando atributos en la clase
            // modelBuilder.Entity<Usuario>().ToTable("Usuario");

            base.OnModelCreating(modelBuilder);
        }
    }
}
using EducaEFRT.Models.DB;
using EducaEFRT.Models;
using System;
using System.Linq;

public class AsistenciaDocenteRepository : IDisposable
{
    private EduControlDB db = new EduControlDB();

    // Nuevo método que valida y retorna true/false según éxito
    public bool RegistrarAsistencia(int idAsignacion)
    {
        var hoy = DateTime.Now.Date;

        // Validar si ya existe asistencia hoy para esa asignación
        bool yaRegistrada = db.AsistenciasDocente
            .Any(a => a.IdAsignacion == idAsignacion && a.Fecha == hoy);

        if (yaRegistrada)
            return false; // Ya registrada

        // Si no existe, registrar nueva asistencia
        var asistencia = new AsistenciaDocente
        {
            IdAsignacion = idAsignacion,
            Fecha = hoy,
            Hora = DateTime.Now.TimeOfDay,
            EstadoAsistencia = "Asistio"
        };

        db.AsistenciasDocente.Add(asistencia);
        db.SaveChanges();

        return true; // Registrado exitosamente
    }

    public void Dispose()
    {
        db.Dispose();
    }
}

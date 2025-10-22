# 📚 Sistema de Gestión Educativa - EduControl

Sistema web para la gestión integral de docentes, cursos, estudiantes y asistencias en instituciones educativas.

## 🚀 Características Principales

### 👨‍🏫 Gestión de Docentes
- ✅ Crear, editar y visualizar docentes
- ✅ Eliminar docentes (solo si no tienen cursos asignados)
- ✅ Asignar cursos a docentes
- ✅ Gestionar asignaciones de cursos
- ✅ Subir foto de perfil

### 📖 Gestión de Cursos
- ✅ Crear, editar y eliminar cursos
- ✅ Asignar docentes, secciones y turnos
- ✅ Control de estudiantes matriculados
- ✅ Gestión de imágenes de cursos

### 👥 Gestión de Estudiantes
- ✅ Registro de estudiantes
- ✅ Matrícula en cursos
- ✅ Control de asistencias
- ✅ Registro de notas (T1, T2, EF)
- ✅ Cálculo automático de promedios

### 📊 Reportes
- ✅ Reporte de asistencia de docentes
- ✅ Filtros por docente, curso, sección y turno
- ✅ Exportación a PDF y Excel

## 🛠️ Tecnologías

- **Backend:** ASP.NET MVC 5 (.NET Framework 4.8)
- **Frontend:** Razor Views, Tailwind CSS
- **Base de Datos:** SQL Server
- **ORM:** Entity Framework 6
- **Librerías:**
  - iTextSharp (Generación de PDF)
  - EPPlus (Exportación a Excel)

## 📋 Requisitos Previos

- Visual Studio 2019 o superior
- SQL Server 2016 o superior
- .NET Framework 4.8
- IIS Express (incluido en Visual Studio)

## ⚙️ Instalación

### 1. Clonar el Repositorio
```bash
git clone <url-del-repositorio>
cd Proyecto_EFSRT4
```

### 2. Configurar Base de Datos

#### a) Crear la Base de Datos
Ejecutar el script principal en SQL Server Management Studio:
```sql
-- Archivo: DB_EDUCA_EFSRT4_Final.sql
```

#### b) Ejecutar Procedimientos Almacenados
```sql
-- 1. Procedimiento para eliminar docentes
-- Archivo: sp_EliminarDocente.sql

-- 2. Procedimiento para eliminar asignaciones
-- Archivo: sp_EliminarAsignacion.sql
```

### 3. Configurar Cadena de Conexión

Editar `Web.config`:
```xml
<connectionStrings>
  <add name="EduControlDB" 
       connectionString="Data Source=TU_SERVIDOR;Initial Catalog=DB_EDUCA;Integrated Security=True" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

### 4. Restaurar Paquetes NuGet
```bash
# En Visual Studio:
Tools > NuGet Package Manager > Restore NuGet Packages
```

### 5. Compilar y Ejecutar
```bash
# Presionar F5 en Visual Studio
# O usar:
dotnet build
```

## 👤 Usuarios por Defecto

### Administrador
- **Usuario:** `admin`
- **Contraseña:** `Admin2025@`

### Docentes
| Usuario | Contraseña | Nombre |
|---------|-----------|--------|
| aJara | AbraJar123@ | Abraham Jara |
| mrodriguez | MariaR123@ | Maria Rodriguez |
| jvaldez | JoseVal123@ | Jose Valdez |

## 📁 Estructura del Proyecto

```
Proyecto_EFSRT4/
├── Controllers/
│   ├── AccountController.cs      # Autenticación
│   ├── AdminController.cs        # Gestión administrativa
│   ├── DocenteController.cs      # Funciones de docentes
│   └── HomeController.cs         # Página principal
├── Models/
│   ├── DB/
│   │   ├── EduControlDB.cs       # Contexto de Entity Framework
│   │   └── Repositories/         # Repositorios
│   ├── ViewModels/               # ViewModels
│   ├── Usuario.cs
│   ├── Docente.cs
│   ├── Curso.cs
│   ├── Estudiante.cs
│   └── ...
├── Views/
│   ├── Admin/
│   │   ├── GestionDocente/
│   │   ├── GestionCurso/
│   │   └── Reportes/
│   ├── Docente/
│   └── Shared/
├── Content/
│   ├── Images/
│   │   ├── Docentes/            # Fotos de docentes
│   │   └── Cursos/              # Imágenes de cursos
│   └── Site.css
├── Scripts/
└── Web.config
```

## 🔐 Procedimientos Almacenados

### sp_EliminarDocente
Elimina un docente y todas sus relaciones.

**Validaciones:**
- ❌ No permite eliminar si tiene cursos asignados

**Elimina:**
- Usuario asociado
- Registro del docente

```sql
EXEC sp_EliminarDocente @id_docente = 1
```

### sp_EliminarAsignacion
Elimina una asignación de curso.

**Validaciones:**
- ❌ No permite eliminar si tiene estudiantes matriculados

**Elimina:**
- Asistencias del docente
- Asignación del curso

```sql
EXEC sp_EliminarAsignacion @id_asignacion = 1
```

### sp_ReporteAsistenciaDocente
Genera reporte de asistencia de docentes con filtros opcionales.

```sql
EXEC sp_ReporteAsistenciaDocente 
    @id_docente = NULL,
    @id_curso = NULL,
    @id_seccion = NULL,
    @id_turno = NULL
```

## 🎯 Funcionalidades Clave

### Eliminación Inteligente

#### Docentes
- ✅ **Habilitado:** Docentes sin cursos asignados
- ❌ **Deshabilitado:** Docentes con cursos asignados
- 💡 **Tooltip:** "No se puede eliminar porque tiene cursos asignados"

#### Asignaciones de Cursos
- ✅ **Habilitado:** Asignaciones sin estudiantes matriculados
- ❌ **Deshabilitado:** Asignaciones con estudiantes
- 💡 **Tooltip:** "No se puede eliminar porque tiene estudiantes matriculados"

### Sistema de Notas
- **T1:** 25% del promedio
- **T2:** 25% del promedio
- **EF:** 50% del promedio
- **Aprobado:** Promedio ≥ 13
- **Estado:** Calculado automáticamente por trigger

### Control de Asistencias
- **Estados:** Asistió, Faltó, Tardanza
- **Registro:** Por fecha y hora
- **Reportes:** Filtros múltiples

## 📊 Base de Datos

### Tablas Principales
- `Usuario` - Credenciales de acceso
- `Docente` - Información de docentes
- `Estudiante` - Información de estudiantes
- `Curso` - Catálogo de cursos
- `AsignacionCurso` - Relación docente-curso-sección-turno
- `Matricula` - Inscripción de estudiantes
- `AsistenciaDocente` - Registro de asistencias de docentes
- `AsistenciaEstudiante` - Registro de asistencias de estudiantes
- `Notas` - Calificaciones de estudiantes

### Triggers
- `trg_ActualizarEstadoNota` - Calcula estado (Aprobado/Desaprobado/Pendiente)

## 🔧 Configuración Adicional

### Permisos de Carpetas
Asegurar permisos de escritura en:
```
Content/Images/Docentes/
Content/Images/Cursos/
```

### Configuración de IIS
```xml
<system.webServer>
  <security>
    <requestFiltering>
      <requestLimits maxAllowedContentLength="10485760" />
    </requestFiltering>
  </security>
</system.webServer>
```

## 🐛 Solución de Problemas

### Error: "No se encuentra la vista"
```bash
# Verificar que las rutas en los controladores sean correctas
return View("~/Views/Admin/GestionDocente/Index.cshtml", model);
```

### Error: "Invalid object name 'sp_EliminarDocente'"
```sql
-- Ejecutar los procedimientos almacenados en SQL Server
USE DB_EDUCA
GO
-- Ejecutar sp_EliminarDocente.sql
-- Ejecutar sp_EliminarAsignacion.sql
```

### Error: "Unable to create a constant value"
```csharp
// Extraer IDs a lista antes de usar en consulta LINQ
var ids = lista.Select(x => x.Id).ToList();
var resultado = db.Tabla.Where(t => ids.Contains(t.Id));
```

## 📝 Notas de Desarrollo

### Convenciones de Código
- Nombres de tablas en singular
- Prefijo `sp_` para procedimientos almacenados
- ViewModels en carpeta `Models/ViewModels/`
- Repositorios en `Models/DB/Repositories/`

### Seguridad
- ✅ Tokens antifalsificación en formularios
- ✅ Validación de sesión en todos los controladores
- ✅ Contraseñas con validación de complejidad
- ✅ Protección contra SQL Injection (Entity Framework)

## 📄 Licencia

Este proyecto es de uso educativo.

## 👥 Autores

- Equipo de Desarrollo EFSRT4

## 📞 Soporte

Para reportar problemas o sugerencias, crear un issue en el repositorio.

---

**Versión:** 1.0  
**Última actualización:** Enero 2025

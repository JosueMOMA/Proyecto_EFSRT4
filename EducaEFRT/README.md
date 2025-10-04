# Solución de Errores de Compilación - Proyecto EducaEFRT

## Errores Encontrados y Soluciones Aplicadas

### 1. Error: "No se pudo cargar el tipo 'EducaEFRT.MvcApplication'"

**Causa:** El proyecto no se estaba compilando correctamente debido a referencias incorrectas de paquetes NuGet.

**Solución:**
1. Eliminar carpetas temporales:
   ```cmd
   rmdir /s /q bin
   rmdir /s /q obj
   ```

2. Restaurar paquetes NuGet en la Consola del Administrador de Paquetes:
   ```
   Update-Package -reinstall
   ```

3. Instalar paquete específico:
   ```
   Install-Package Microsoft.CodeDom.Providers.DotNetCompilerPlatform -Version 2.0.1
   ```

### 2. Error: Referencias de paquetes NuGet incorrectas

**Causa:** El archivo `.csproj` tenía referencias a versiones incorrectas de paquetes NuGet.

**Solución:**
1. Actualizar `Views\Web.config` con las versiones correctas:
   - Cambiar `System.Web.Mvc` de versión `5.2.9.0` a `5.3.0.0`

2. Recrear el archivo `EducaEFRT.csproj` con referencias correctas:
   - Eliminar referencias problemáticas de `Microsoft.CodeDom.Providers.DotNetCompilerPlatform.4.1.0`
   - Usar únicamente la versión `2.0.1`
   - Corregir rutas de paquetes de `..\\packages` a `packages`

### 3. Error: "No se puede encontrar una parte de la ruta 'bin\roslyn\csc.exe'"

**Causa:** Faltaban los archivos del compilador Roslyn en la carpeta `bin\roslyn`.

**Solución:**
1. Crear carpeta roslyn:
   ```cmd
   mkdir bin\roslyn
   ```

2. Copiar archivos del compilador:
   ```cmd
   xcopy packages\Microsoft.CodeDom.Providers.DotNetCompilerPlatform.2.0.1\tools\Roslyn45\* bin\roslyn\ /E /Y
   ```

## Pasos de Compilación Final

1. **Compilar** → **Limpiar solución**
2. **Compilar** → **Recompilar solución**
3. Verificar que no hay errores en la Lista de errores
4. Ejecutar la aplicación con **F5**

## Configuración de Base de Datos

- **Nombre de BD:** DB_EDUCA
- **Cadena de conexión:** `server=.; database=DB_EDUCA; Integrated Security=True;`
- **Tipo:** Entity Framework Code First (se crea automáticamente)

## URLs del Proyecto

- **Aplicación:** https://localhost:44383/
- **Login:** https://localhost:44383/Account/Login

## Comando Alternativo para Errores de Compilación

Si aparecen errores de compilación en el futuro, ejecutar en la Consola del Administrador de Paquetes:
```
Update-Package Microsoft.CodeDom.Providers.DotNetCompilerPlatform -Reinstall
```
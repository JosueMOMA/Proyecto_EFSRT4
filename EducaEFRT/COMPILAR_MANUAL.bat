@echo off
echo Compilando proyecto manualmente...

REM Cambiar al directorio del proyecto
cd /d "c:\Users\Maeve\Desktop\REPOs\EducaEFRT"

REM Compilar con dotnet (si está disponible)
dotnet build

REM Si dotnet no funciona, usar MSBuild
if %ERRORLEVEL% NEQ 0 (
    echo Intentando con MSBuild...
    "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" EducaEFRT.csproj /p:Configuration=Debug
)

echo Verificando archivos generados...
dir bin\

pause
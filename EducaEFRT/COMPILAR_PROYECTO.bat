@echo off
echo Compilando proyecto EducaEFRT...

REM Restaurar paquetes NuGet
nuget restore

REM Compilar con MSBuild
"%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" EducaEFRT.csproj /p:Configuration=Debug /p:Platform="Any CPU"

if %ERRORLEVEL% NEQ 0 (
    echo Error en la compilacion
    pause
    exit /b 1
)

echo Compilacion exitosa
pause
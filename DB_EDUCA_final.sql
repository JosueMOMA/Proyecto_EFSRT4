IF DB_ID('DB_EDUCA') IS NOT NULL
DROP DATABASE DB_EDUCA;

CREATE DATABASE DB_EDUCA;
GO

USE DB_EDUCA
GO

-- Tabla Usuario
CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    Rol VARCHAR(50) NOT NULL
);

-- Tabla Docente
CREATE TABLE Docente (
    id_docente INT PRIMARY KEY IDENTITY(1,1),
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    id_usuario INT NOT NULL FOREIGN KEY REFERENCES Usuario(id_usuario)
);

-- Tabla AdministradorSistema
CREATE TABLE AdministradorSistema (
    id_admin INT PRIMARY KEY IDENTITY(1,1),
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    id_usuario INT NOT NULL FOREIGN KEY REFERENCES Usuario(id_usuario)
);

-- Tabla Curso
CREATE TABLE Curso (
    id_curso INT PRIMARY KEY IDENTITY(1,1),
    nombre_curso VARCHAR(100) NOT NULL,
	imagen_url VARCHAR(255) NULL
);

-- Tabla Seccion
CREATE TABLE Seccion (
    id_seccion INT PRIMARY KEY IDENTITY(1,1),
    nombre_seccion VARCHAR(50) NOT NULL
);

-- Tabla Turno
CREATE TABLE Turno (
    id_turno INT PRIMARY KEY IDENTITY(1,1),
    nombre_turno VARCHAR(50) NOT NULL
);

-- Tabla Estudiante
CREATE TABLE Estudiante (
    id_estudiante INT PRIMARY KEY IDENTITY(1,1),
    codigo_estudiante VARCHAR(20) NOT NULL UNIQUE,
    apellidos VARCHAR(50) NOT NULL,
    nombres VARCHAR(50) NOT NULL
);

-- Tabla AsignacionCurso
CREATE TABLE AsignacionCurso (
    id_asignacion INT PRIMARY KEY IDENTITY(1,1),
    id_docente INT NOT NULL FOREIGN KEY REFERENCES Docente(id_docente),
    id_curso INT NOT NULL FOREIGN KEY REFERENCES Curso(id_curso),
    id_seccion INT NOT NULL FOREIGN KEY REFERENCES Seccion(id_seccion),
    id_turno INT NOT NULL FOREIGN KEY REFERENCES Turno(id_turno)
);

-- Tabla AsistenciaDocente
CREATE TABLE AsistenciaDocente (
    id_asistencia_docente INT PRIMARY KEY IDENTITY(1,1),
    id_asignacion INT NOT NULL FOREIGN KEY REFERENCES AsignacionCurso(id_asignacion),
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado_asistencia VARCHAR(10) CHECK (estado_asistencia IN ('Asistio','Falto','Tardanza')) NOT NULL -- Asistió, Falta, Tardanza
);

-- Tabla Matricula
CREATE TABLE Matricula (
    id_matricula INT PRIMARY KEY IDENTITY(1,1),
    id_estudiante INT NOT NULL FOREIGN KEY REFERENCES Estudiante(id_estudiante),
    id_asignacion INT NOT NULL FOREIGN KEY REFERENCES AsignacionCurso(id_asignacion),
	UNIQUE (id_estudiante, id_asignacion) -- No puede repetir misma asignación
);

-- Tabla AsistenciaEstudiante
CREATE TABLE AsistenciaEstudiante (
    id_asistencia_estudiante INT PRIMARY KEY IDENTITY(1,1),
    id_matricula INT NOT NULL FOREIGN KEY REFERENCES Matricula(id_matricula),
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado_asistencia VARCHAR(10) CHECK (estado_asistencia IN ('Asistio','Falto','Tardanza')) NOT NULL -- Asistió, Falta, Tardanza
);

-- Tabla Notas
CREATE TABLE Notas (
    id_nota INT PRIMARY KEY IDENTITY(1,1),
    id_matricula INT NOT NULL FOREIGN KEY REFERENCES Matricula(id_matricula),
    nota_T1 DECIMAL(5,2) CHECK (nota_T1 BETWEEN 0 AND 20),
    nota_T2 DECIMAL(5,2) CHECK (nota_T2 BETWEEN 0 AND 20),
    nota_EF DECIMAL(5,2) CHECK (nota_EF BETWEEN 0 AND 20),
	promedio AS (
    (ISNULL(nota_T1, 0) * 0.25) + 
    (ISNULL(nota_T2, 0) * 0.25) + 
    (ISNULL(nota_EF, 0) * 0.50)) PERSISTED,
    estado VARCHAR(20) NULL
);
GO
/*TRIGGER PARA VALIDAR CONTRASEÑA*/
CREATE TRIGGER trg_ValidarPasswordUsuario
ON Usuario
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar todas las filas afectadas
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LEN(Password) < 8
           OR Password NOT LIKE '%[A-Z]%'     -- No contiene mayúscula
           OR Password NOT LIKE '%[a-z]%'     -- No contiene minúscula
           OR Password NOT LIKE '%[0-9]%'     -- No contiene número
           OR Password NOT LIKE '%[^a-zA-Z0-9]%' -- No contiene carácter especial
    )
    BEGIN
        RAISERROR('La contraseña debe tener al menos 8 caracteres, incluyendo una mayúscula, una minúscula, un número y un carácter especial.', 16, 1);
        RETURN;
    END

    -- Si la validación pasa, realizar INSERT o UPDATE
    MERGE Usuario AS target
    USING inserted AS source
    ON target.id_usuario = source.id_usuario
    WHEN MATCHED THEN
        UPDATE SET
            Username = source.Username,
            Password = source.Password,
            Rol = source.Rol
    WHEN NOT MATCHED THEN
        INSERT (Username, Password, Rol)
        VALUES (source.Username, source.Password, source.Rol);
END;
GO
/*EJEMPLO DE CONTRASEÑA
INSERT INTO Usuario (Username, Password, Rol)
VALUES ('admin', 'Admin123@', 'Administrador');*/
/*TRIGGER PARA EL ESTADO (APROBADO/DESAPROBADO)*/
CREATE OR ALTER TRIGGER trg_ActualizarEstadoNota
ON Notas
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE N
    SET estado = 
        CASE 
            WHEN i.nota_T1 IS NULL OR i.nota_T2 IS NULL OR i.nota_EF IS NULL THEN 'Pendiente'
            WHEN i.promedio >= 13 THEN 'Aprobado'
            ELSE 'Desaprobado'
        END
    FROM Notas N
    INNER JOIN inserted i ON N.id_nota = i.id_nota;
END;
GO

/*INSERTAR DATOS*/
-- Tabla: Turno
INSERT INTO Turno (nombre_turno) VALUES
('Mañana'),
('Tarde'),
('Noche');

-- Tabla: Seccion
INSERT INTO Seccion (nombre_seccion) VALUES
('A1'),
('B1'),
('C1'),
('D1'),
('A2'),
('B2');

-- Tabla: Usuario (Administrador y Docentes)
INSERT INTO Usuario (Username, Password, Rol) VALUES
('admin', 'Admin2025@', 'Administrador'),
('dcastañeda', 'DaniC123@', 'Docente'),
('mrodriguez', 'MariaR123@', 'Docente'),
('jvaldez', 'JoseVal123@', 'Docente'),
('rsanchez', 'RosaS123@', 'Docente'),
('fchavez', 'FernandoCh@2023', 'Docente'),
('bvasquez', 'BeatrizV2023@', 'Docente');

-- Tabla: AdministradorSistema
INSERT INTO AdministradorSistema (nombres, apellidos, id_usuario) VALUES
('Carlos Eduardo', 'Mendoza Diaz', 1);

-- Tabla: Docente
INSERT INTO Docente (nombres, apellidos, id_usuario) VALUES
('Daniel Alexis', 'Ramos Castañeda', 2),
('Maria Ruth', 'Rodríguez Ordoñez', 3),
('Jose Valerio', 'Valdez Montes', 4),
('Rosa Ana', 'Sanchez Savedra', 5),
('Fernando Dean', 'Chávez Parker', 6),
('Beatriz Marta', 'Vasquez Coronel', 7);

-- Tabla: Curso
INSERT INTO Curso (nombre_curso) VALUES
('Programación Web'),
('Bases de Datos'),
('Power BI Básico'),
('Desarrollo Web'),
('Inteligencia Artificial'),
('Ciberseguridad'),
('Cloud Computing'),
('Big Data'),
('Machine Learning'),
('Desarrollo Móvil'),
('Fundamentos de Algoritmos');

-- Tabla: AsignacionCurso
INSERT INTO AsignacionCurso (id_docente, id_curso, id_seccion, id_turno) VALUES
(1, 1, 1, 1), 
(2, 2, 2, 2), 
(1, 3, 6, 3), 
(1, 4, 3, 1), 
(4, 5, 4, 2), 
(5, 6, 5, 3), 
(6, 7, 6, 2), 
(1, 8, 2, 2), 
(2, 9, 2, 3), 
(3, 10, 3, 1), 
(4, 11, 4, 2); 

-- Tabla: Estudiante
INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU001', 'Gonzales Navarro', 'Ana Cristel'),
('EDU002', 'Torres Mendoza', 'Carlos Augusto'),
('EDU003', 'Ruiz Suarez', 'María Lucero'),
('EDU004', 'Castro Sanchez', 'Sergio Valentino'),
('EDU005', 'Ramirez Roque', 'Laura Maria'),
('EDU006', 'Fernandez Bazan', 'Jorge Miguel'),
('EDU007', 'Chavez Montes', 'Brenda Carolina'),
('EDU008', 'Perez Martinez', 'Luis Miguel'),
('EDU009', 'Garcia Perez', 'Diana Angelica'),
('EDU010', 'Suarez Uriarte', 'Valeria Abigail'),
('EDU011', 'Salazar Solorzano', 'Mario Adam'),
('EDU012', 'Lopez Arista', 'Karina Paola'),
('EDU013', 'Medina Cueva', 'Pedro Leonardo');

-- Tabla: Matricula
INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 1),
(10, 2),
(11, 3),
(12, 9),
(13, 10);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU014', 'Mendoza Torres', 'Luis Alberto'),
('EDU015', 'Ramírez Castillo', 'María Fernanda'),
('EDU016', 'González Pérez', 'Jorge Luis'),
('EDU017', 'Fernández Rojas', 'Ana Sofía'),
('EDU018', 'Sánchez Morales', 'Carlos Eduardo'),
('EDU019', 'López Vargas', 'Valeria Isabel'),
('EDU020', 'Pérez Flores', 'Miguel Ángel'),
('EDU021', 'Rodríguez Jiménez', 'Lucía Carolina'),
('EDU022', 'Torres Martínez', 'Diego Andrés'),
('EDU023', 'Castillo Medina', 'Camila Patricia');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(14, 1),
(15, 1),
(16, 1),
(17, 1),
(18, 1),
(19, 1),
(20, 1),
(21, 1),
(22, 1),
(23, 1);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU024', 'Vásquez Herrera', 'Julio César'),
('EDU025', 'Morales Delgado', 'Natalia Beatriz'),
('EDU026', 'Reyes Campos', 'Alonso Javier'),
('EDU027', 'Chávez Luján', 'Melanie Rocío'),
('EDU028', 'Silva Benavides', 'Daniel Alejandro'),
('EDU029', 'Flores Zúñiga', 'Mónica Alejandra'),
('EDU030', 'Ortega Meza', 'Esteban Raúl'),
('EDU031', 'Carranza Soto', 'Andrea Marisol'),
('EDU032', 'Córdova Pinedo', 'Santiago Emiliano'),
('EDU033', 'Ríos Galvez', 'Valentina María');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(24, 2),
(25, 2),
(26, 2),
(27, 2),
(28, 2),
(29, 2),
(30, 2),
(31, 2),
(32, 2),
(33, 2);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU034', 'Mendoza Salas', 'Alessandro Javier'),
('EDU035', 'Ramos Quispe', 'Camila Fernanda'),
('EDU036', 'Delgado Infante', 'Samuel Andrés'),
('EDU037', 'López Miranda', 'Isabella Ruth'),
('EDU038', 'Valverde León', 'Joaquín Esteban'),
('EDU039', 'Espinoza Barreto', 'Martina Carolina'),
('EDU040', 'Paredes Tello', 'Matías Emanuel'),
('EDU041', 'Gómez Ruiz', 'Luciana Belén'),
('EDU042', 'Quinteros Vargas', 'Adrián Rafael'),
('EDU043', 'Rosales Guevara', 'Emilia Antonia');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(34, 3),
(35, 3),
(36, 3),
(37, 3),
(38, 3),
(39, 3),
(40, 3),
(41, 3),
(42, 3),
(43, 3);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU044', 'Gutiérrez Méndez', 'Thiago Emmanuel'),
('EDU045', 'Campos Rivas', 'Samantha Abigail'),
('EDU046', 'Navarro Zegarra', 'Gabriel Matías'),
('EDU047', 'Peralta Sánchez', 'Renata Milagros'),
('EDU048', 'Cornejo Paredes', 'Benjamín Alejandro'),
('EDU049', 'Silva Robles', 'Valentina Nicole'),
('EDU050', 'Aguilar Tapia', 'Dylan Sebastián'),
('EDU051', 'Cruz Huamán', 'Antonella Sofía'),
('EDU052', 'Reyes Palacios', 'Diego Armando'),
('EDU053', 'Morales Cárdenas', 'Julieta Celeste');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(44, 4),
(45, 4),
(46, 4),
(47, 4),
(48, 4),
(49, 4),
(50, 4),
(51, 4),
(52, 4),
(53, 4);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU054', 'Valverde Cuéllar', 'Luciana Camila'),
('EDU055', 'Ríos Luján', 'Joaquín Ignacio'),
('EDU056', 'Sánchez Bravo', 'Emily Adriana'),
('EDU057', 'Mendoza Romero', 'Santiago Andrés'),
('EDU058', 'Velásquez Ocampo', 'Camila Fernanda'),
('EDU059', 'Ramírez Bernal', 'Mateo Alonso'),
('EDU060', 'Castañeda Vela', 'Ariana Belén'),
('EDU061', 'Ponce Loayza', 'Gael Joaquín'),
('EDU062', 'Salas Reynoso', 'Isabella Antonella'),
('EDU063', 'Cárdenas Torres', 'Matías Emmanuel');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(54, 5),
(55, 5),
(56, 5),
(57, 5),
(58, 5),
(59, 5),
(60, 5),
(61, 5),
(62, 5),
(63, 5);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU064', 'Reátegui Delgado', 'Thiago Daniel'),
('EDU065', 'Silva Córdova', 'Mía Valentina'),
('EDU066', 'Zamora Gutiérrez', 'Gabriel Esteban'),
('EDU067', 'Oré Quispe', 'Sofía Isabella'),
('EDU068', 'Rosales Aguirre', 'Liam Mateo'),
('EDU069', 'Pizarro Castañeda', 'Emily Victoria'),
('EDU070', 'Guerra Tapia', 'Benjamín Aarón'),
('EDU071', 'Cabello Gonzales', 'Valeria Alejandra'),
('EDU072', 'Arévalo Meza', 'Derek Santiago'),
('EDU073', 'Vásquez Córdova', 'Zoe Camila');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(64, 6),
(65, 6),
(66, 6),
(67, 6),
(68, 6),
(69, 6),
(70, 6),
(71, 6),
(72, 6),
(73, 6);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU074', 'Campos Leiva', 'Renato Adrián'),
('EDU075', 'Barboza Díaz', 'Julieta Romina'),
('EDU076', 'Moreno Córdova', 'Matías Emmanuel'),
('EDU077', 'Calderón Vega', 'Victoria Paz'),
('EDU078', 'Urbina Romero', 'Diego Alonso'),
('EDU079', 'Alfaro Espinoza', 'Luciana Rafaela'),
('EDU080', 'Ramírez Loayza', 'Ian Alessandro'),
('EDU081', 'Guevara Rojas', 'Camila Antonella'),
('EDU082', 'Valverde Olivares', 'Sebastián Joaquín'),
('EDU083', 'Espejo Farfán', 'Daniela Rebeca');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(74, 7),
(75, 7),
(76, 7),
(77, 7),
(78, 7),
(79, 7),
(80, 7),
(81, 7),
(82, 7),
(83, 7);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU084', 'Ríos Gallardo', 'Thiago Emanuel'),
('EDU085', 'Carranza Paredes', 'Sofía Elizabeth'),
('EDU086', 'Mejía Rivas', 'Álvaro Ignacio'),
('EDU087', 'Mendoza Vargas', 'Isabella Antonia'),
('EDU088', 'Zambrano Campos', 'Samuel Josué'),
('EDU089', 'Figueroa Aguirre', 'Antonella Fiorella'),
('EDU090', 'Acosta Guzmán', 'Valentino Nicolás'),
('EDU091', 'Aguilar Neyra', 'Martina Jazmín'),
('EDU092', 'Rosales Díaz', 'Joaquín Gabriel'),
('EDU093', 'Sánchez Marquina', 'Emma Nicole');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(84, 8),
(85, 8),
(86, 8),
(87, 8),
(88, 8),
(89, 8),
(90, 8),
(91, 8),
(92, 8),
(93, 8);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU094', 'Silva Gamarra', 'Luciana Isabella'),
('EDU095', 'Ortega Chávez', 'Mateo Alejandro'),
('EDU096', 'Delgado Núñez', 'Camila Valeria'),
('EDU097', 'Guevara Herrera', 'Diego Alonso'),
('EDU098', 'Córdova Mejía', 'Alejandra Milagros'),
('EDU099', 'Pizarro Alvarado', 'Sebastián Andrés'),
('EDU100', 'Morales Benavente', 'Valeria Antonella'),
('EDU101', 'Ramos Loyola', 'Gael Esteban'),
('EDU102', 'Campos Lévano', 'Emma Sofía'),
('EDU103', 'Villanueva Barrios', 'Liam Santiago');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(94, 9),
(95, 9),
(96, 9),
(97, 9),
(98, 9),
(99, 9),
(100, 9),
(101, 9),
(102, 9),
(103, 9);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU104', 'Salinas Ríos', 'Gabriela Alessandra'),
('EDU105', 'Luna Huamán', 'Thiago Alexander'),
('EDU106', 'Aguilar Ponce', 'Isabela Ariana'),
('EDU107', 'Escobar Tello', 'Emilio Leonardo'),
('EDU108', 'Carrillo Galindo', 'Victoria Fernanda'),
('EDU109', 'Reyna Zegarra', 'Matías Emmanuel'),
('EDU110', 'Loayza Carranza', 'Renata Ivanna'),
('EDU111', 'Bustamante Aguirre', 'Martín Enrique'),
('EDU112', 'Bravo Monzón', 'Alessia Michelle'),
('EDU113', 'Pacheco Canales', 'Julián Mateo');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(104, 10),
(105, 10),
(106, 10),
(107, 10),
(108, 10),
(109, 10),
(110, 10),
(111, 10),
(112, 10),
(113, 10);

INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU114', 'Ortega Valdez', 'Camila Julieta'),
('EDU115', 'Velarde León', 'Sebastián Andrés'),
('EDU116', 'Arévalo Cuéllar', 'Valentina Rosario'),
('EDU117', 'Sotomayor Prado', 'Diego Alonso'),
('EDU118', 'Guillén Rivas', 'Mía Antonella'),
('EDU119', 'Portilla Álvarez', 'Benjamín Josué'),
('EDU120', 'Yupanqui Matos', 'Luciana Nicole'),
('EDU121', 'Chávez Huerta', 'Gael Rodrigo'),
('EDU122', 'Esquivel Melgar', 'Zoe Daniela'),
('EDU123', 'Manrique Paucar', 'Tomás Elías');

INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(114, 11),
(115, 11),
(116, 11),
(117, 11),
(118, 11),
(119, 11),
(120, 11),
(121, 11),
(122, 11),
(123, 11);

UPDATE Curso SET imagen_url = 'https://teclab.edu.ar/wp-content/uploads/2023/12/Que-es-la-programacion-web.webp' WHERE nombre_curso = 'Programación Web';
UPDATE Curso SET imagen_url = 'https://revistabyte.es/wp-content/uploads/2019/02/Comparativa-Bases-de-Datos-2019.jpg.webp' WHERE nombre_curso = 'Bases de Datos';
UPDATE Curso SET imagen_url = 'https://learn.microsoft.com/es-es/power-bi/fundamentals/media/service-basic-concepts/power-bi-app-dashboard.png' WHERE nombre_curso = 'Power BI Básico';
UPDATE Curso SET imagen_url = 'https://www.comunicare.es/wp-content/uploads/2021/11/desarrollo-web-3.jpg' WHERE nombre_curso = 'Desarrollo Web';
UPDATE Curso SET imagen_url = 'https://www.seguritecnia.es/wp-content/uploads/2022/03/inteligencia-artificial.jpg' WHERE nombre_curso = 'Inteligencia Artificial';
UPDATE Curso SET imagen_url = 'https://universidadeuropea.com/resources/media/images/analista-ciberseguridad-1200x630.original.jpg' WHERE nombre_curso = 'Ciberseguridad';
UPDATE Curso SET imagen_url = 'https://img.computing.es/wp-content/uploads/2024/03/19095219/Cloud-Computing-1.jpg' WHERE nombre_curso = 'Cloud Computing';
UPDATE Curso SET imagen_url = 'https://incae.edu/wp-content/uploads/2023/10/big_data_01.jpg' WHERE nombre_curso = 'Big Data';
UPDATE Curso SET imagen_url = 'https://kodigowebstorage.blob.core.windows.net/kodigowebsite/2024/02/Machine-learning.jpg' WHERE nombre_curso = 'Machine Learning';
UPDATE Curso SET imagen_url = 'https://www.qualitydevs.com/wp-content/uploads/2021/03/Desarrollo-apps-moviles.jpg' WHERE nombre_curso = 'Desarrollo Móvil';
UPDATE Curso SET imagen_url = 'https://cdn.lynda.com/course/2838139/2838139-1613993931720-16x9.jpg' WHERE nombre_curso = 'Fundamentos de Algoritmos';

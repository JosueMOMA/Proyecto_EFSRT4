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
    Password VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CS_AS�NOT�NULL,
    Rol VARCHAR(50) NOT NULL
);

-- Tabla Docente
CREATE TABLE Docente (
    id_docente INT PRIMARY KEY IDENTITY(1,1),
    dni CHAR(8) NOT NULL CHECK (dni LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    correo VARCHAR(100),
    celular VARCHAR(15),
    direccion VARCHAR(150),
    profesion VARCHAR(100),
    grado_academico VARCHAR(100),
    foto VARCHAR(255),
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
	imagen_url VARCHAR(255) NULL,
	duracion_horas INT NOT NULL DEFAULT 0,
    nivel VARCHAR(20) NOT NULL DEFAULT 'Basico',
    certificacion BIT NOT NULL DEFAULT 0,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00
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
    id_turno INT NOT NULL FOREIGN KEY REFERENCES Turno(id_turno),
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL
);


-- Tabla AsistenciaDocente
CREATE TABLE AsistenciaDocente (
    id_asistencia_docente INT PRIMARY KEY IDENTITY(1,1),
    id_asignacion INT NOT NULL FOREIGN KEY REFERENCES AsignacionCurso(id_asignacion),
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado_asistencia VARCHAR(10) CHECK (estado_asistencia IN ('Asistio','Falto','Tardanza')) NOT NULL -- Asisti�, Falta, Tardanza
);

-- Tabla Matricula
CREATE TABLE Matricula (
    id_matricula INT PRIMARY KEY IDENTITY(1,1),
    id_estudiante INT NOT NULL FOREIGN KEY REFERENCES Estudiante(id_estudiante),
    id_asignacion INT NOT NULL FOREIGN KEY REFERENCES AsignacionCurso(id_asignacion),
	UNIQUE (id_estudiante, id_asignacion) -- No puede repetir misma asignaci�n
);

-- Tabla AsistenciaEstudiante
CREATE TABLE AsistenciaEstudiante (
    id_asistencia_estudiante INT PRIMARY KEY IDENTITY(1,1),
    id_matricula INT NOT NULL FOREIGN KEY REFERENCES Matricula(id_matricula),
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado_asistencia VARCHAR(10) CHECK (estado_asistencia IN ('Asistio','Falto','Tardanza')) NOT NULL -- Asisti�, Falta, Tardanza
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

/*EJEMPLO DE CONTRASE�A
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
('Ma�ana'),
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
('dcasta�eda', 'DaniC123@', 'Docente'),
('mrodriguez', 'MariaR123@', 'Docente'),
('jvaldez', 'JoseVal123@', 'Docente'),
('rsanchez', 'RosaS123@', 'Docente'),
('fchavez', 'FernandoCh@2023', 'Docente'),
('bvasquez', 'BeatrizV2023@', 'Docente');

-- Tabla: AdministradorSistema
INSERT INTO AdministradorSistema (nombres, apellidos, id_usuario) VALUES
('Carlos Eduardo', 'Mendoza Diaz', 1);

-- Tabla: Docente
INSERT INTO Docente (
    dni, nombres, apellidos, correo, celular, direccion, profesion, grado_academico, foto, id_usuario
)
VALUES
('12345678', 'Daniel Alexis', 'Ramos Casta�eda', 'daniel.ramos@example.com', '987654321', 'Av. Los Olivos 123', 'Ingeniero de Sistemas', 'Maestr�a en Educaci�n', NULL, 2),
('23456789', 'Maria Ruth', 'Rodr�guez Ordo�ez', 'maria.rodriguez@example.com', '976543210', 'Calle Primavera 456', 'Licenciada en Matem�ticas', 'Doctorado en Ciencias', NULL, 3),
('34567890', 'Jose Valerio', 'Valdez Montes', 'jose.valdez@example.com', '965432109', 'Jr. Lima 789', 'Ingeniero Inform�tico', 'Maestr�a en Tecnolog�a', NULL, 4),
('45678901', 'Rosa Ana', 'Sanchez Savedra', 'rosa.sanchez@example.com', '954321098', 'Av. Brasil 101', 'Licenciada en F�sica', 'Maestr�a en Educaci�n', NULL, 5),
('56789012', 'Fernando Dean', 'Ch�vez Parker', 'fernando.chavez@example.com', '943210987', 'Pasaje La Paz 202', 'Ingeniero de Software', 'Maestr�a en Ingenier�a', NULL, 6),
('67890123', 'Beatriz Marta', 'Vasquez Coronel', 'beatriz.vasquez@example.com', '932109876', 'Calle Sol 303', 'Licenciada en Computaci�n', 'Doctorado en Ciencias de la Computaci�n', NULL, 7);

-- Tabla: Curso
INSERT INTO Curso (nombre_curso, imagen_url, duracion_horas, nivel, certificacion, precio) VALUES
('Programaci�n Web', 'https://teclab.edu.ar/wp-content/uploads/2023/12/Que-es-la-programacion-web.webp', 80, 'Intermedio', 1, 250.00),
('Bases de Datos', 'https://revistabyte.es/wp-content/uploads/2019/02/Comparativa-Bases-de-Datos-2019.jpg.webp', 60, 'B�sico', 1, 200.00),
('Power BI B�sico', 'https://learn.microsoft.com/es-es/power-bi/fundamentals/media/service-basic-concepts/power-bi-app-dashboard.png', 40, 'B�sico', 1, 180.00),
('Desarrollo Web', 'https://www.comunicare.es/wp-content/uploads/2021/11/desarrollo-web-3.jpg', 100, 'Avanzado', 1, 300.00),
('Inteligencia Artificial', 'https://www.seguritecnia.es/wp-content/uploads/2022/03/inteligencia-artificial.jpg', 120, 'Avanzado', 1, 350.00),
('Ciberseguridad', 'https://universidadeuropea.com/resources/media/images/analista-ciberseguridad-1200x630.original.jpg', 90, 'Intermedio', 1, 320.00),
('Cloud Computing', 'https://img.computing.es/wp-content/uploads/2024/03/19095219/Cloud-Computing-1.jpg', 70, 'Intermedio', 1, 280.00),
('Big Data', 'https://incae.edu/wp-content/uploads/2023/10/big_data_01.jpg', 110, 'Avanzado', 1, 330.00),
('Machine Learning', 'https://kodigowebstorage.blob.core.windows.net/kodigowebsite/2024/02/Machine-learning.jpg', 100, 'Avanzado', 1, 340.00),
('Desarrollo M�vil', 'https://www.qualitydevs.com/wp-content/uploads/2021/03/Desarrollo-apps-moviles.jpg', 80, 'Intermedio', 1, 290.00),
('Fundamentos de Algoritmos', 'https://cdn.lynda.com/course/2838139/2838139-1613993931720-16x9.jpg', 50, 'B�sico', 1, 150.00);

-- Tabla: AsignacionCurso
INSERT INTO AsignacionCurso (id_docente, id_curso, id_seccion, id_turno, fecha_inicio, fecha_fin) VALUES
(1, 1, 1, 1, '2025-03-01', '2025-06-30'), 
(2, 2, 2, 2, '2025-03-01', '2025-06-30'), 
(1, 3, 6, 3, '2025-03-01', '2025-06-30'), 
(1, 4, 3, 1, '2025-03-01', '2025-06-30'), 
(4, 5, 4, 2, '2025-03-01', '2025-06-30'), 
(5, 6, 5, 3, '2025-03-01', '2025-06-30'), 
(6, 7, 6, 2, '2025-03-01', '2025-06-30'), 
(1, 8, 2, 2, '2025-03-01', '2025-06-30'), 
(2, 9, 2, 3, '2025-03-01', '2025-06-30'), 
(3, 10, 3, 1, '2025-03-01', '2025-06-30'), 
(4, 11, 4, 2, '2025-03-01', '2025-06-30');


-- Tabla: Estudiante
INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU001', 'Gonzales Navarro', 'Ana Cristel'),
('EDU002', 'Torres Mendoza', 'Carlos Augusto'),
('EDU003', 'Ruiz Suarez', 'Mar�a Lucero'),
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
('EDU015', 'Ram�rez Castillo', 'Mar�a Fernanda'),
('EDU016', 'Gonz�lez P�rez', 'Jorge Luis'),
('EDU017', 'Fern�ndez Rojas', 'Ana Sof�a'),
('EDU018', 'S�nchez Morales', 'Carlos Eduardo'),
('EDU019', 'L�pez Vargas', 'Valeria Isabel'),
('EDU020', 'P�rez Flores', 'Miguel �ngel'),
('EDU021', 'Rodr�guez Jim�nez', 'Luc�a Carolina'),
('EDU022', 'Torres Mart�nez', 'Diego Andr�s'),
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
('EDU024', 'V�squez Herrera', 'Julio C�sar'),
('EDU025', 'Morales Delgado', 'Natalia Beatriz'),
('EDU026', 'Reyes Campos', 'Alonso Javier'),
('EDU027', 'Ch�vez Luj�n', 'Melanie Roc�o'),
('EDU028', 'Silva Benavides', 'Daniel Alejandro'),
('EDU029', 'Flores Z��iga', 'M�nica Alejandra'),
('EDU030', 'Ortega Meza', 'Esteban Ra�l'),
('EDU031', 'Carranza Soto', 'Andrea Marisol'),
('EDU032', 'C�rdova Pinedo', 'Santiago Emiliano'),
('EDU033', 'R�os Galvez', 'Valentina Mar�a');

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
('EDU036', 'Delgado Infante', 'Samuel Andr�s'),
('EDU037', 'L�pez Miranda', 'Isabella Ruth'),
('EDU038', 'Valverde Le�n', 'Joaqu�n Esteban'),
('EDU039', 'Espinoza Barreto', 'Martina Carolina'),
('EDU040', 'Paredes Tello', 'Mat�as Emanuel'),
('EDU041', 'G�mez Ruiz', 'Luciana Bel�n'),
('EDU042', 'Quinteros Vargas', 'Adri�n Rafael'),
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
('EDU044', 'Guti�rrez M�ndez', 'Thiago Emmanuel'),
('EDU045', 'Campos Rivas', 'Samantha Abigail'),
('EDU046', 'Navarro Zegarra', 'Gabriel Mat�as'),
('EDU047', 'Peralta S�nchez', 'Renata Milagros'),
('EDU048', 'Cornejo Paredes', 'Benjam�n Alejandro'),
('EDU049', 'Silva Robles', 'Valentina Nicole'),
('EDU050', 'Aguilar Tapia', 'Dylan Sebasti�n'),
('EDU051', 'Cruz Huam�n', 'Antonella Sof�a'),
('EDU052', 'Reyes Palacios', 'Diego Armando'),
('EDU053', 'Morales C�rdenas', 'Julieta Celeste');

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
('EDU054', 'Valverde Cu�llar', 'Luciana Camila'),
('EDU055', 'R�os Luj�n', 'Joaqu�n Ignacio'),
('EDU056', 'S�nchez Bravo', 'Emily Adriana'),
('EDU057', 'Mendoza Romero', 'Santiago Andr�s'),
('EDU058', 'Vel�squez Ocampo', 'Camila Fernanda'),
('EDU059', 'Ram�rez Bernal', 'Mateo Alonso'),
('EDU060', 'Casta�eda Vela', 'Ariana Bel�n'),
('EDU061', 'Ponce Loayza', 'Gael Joaqu�n'),
('EDU062', 'Salas Reynoso', 'Isabella Antonella'),
('EDU063', 'C�rdenas Torres', 'Mat�as Emmanuel');

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
('EDU064', 'Re�tegui Delgado', 'Thiago Daniel'),
('EDU065', 'Silva C�rdova', 'M�a Valentina'),
('EDU066', 'Zamora Guti�rrez', 'Gabriel Esteban'),
('EDU067', 'Or� Quispe', 'Sof�a Isabella'),
('EDU068', 'Rosales Aguirre', 'Liam Mateo'),
('EDU069', 'Pizarro Casta�eda', 'Emily Victoria'),
('EDU070', 'Guerra Tapia', 'Benjam�n Aar�n'),
('EDU071', 'Cabello Gonzales', 'Valeria Alejandra'),
('EDU072', 'Ar�valo Meza', 'Derek Santiago'),
('EDU073', 'V�squez C�rdova', 'Zoe Camila');

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
('EDU074', 'Campos Leiva', 'Renato Adri�n'),
('EDU075', 'Barboza D�az', 'Julieta Romina'),
('EDU076', 'Moreno C�rdova', 'Mat�as Emmanuel'),
('EDU077', 'Calder�n Vega', 'Victoria Paz'),
('EDU078', 'Urbina Romero', 'Diego Alonso'),
('EDU079', 'Alfaro Espinoza', 'Luciana Rafaela'),
('EDU080', 'Ram�rez Loayza', 'Ian Alessandro'),
('EDU081', 'Guevara Rojas', 'Camila Antonella'),
('EDU082', 'Valverde Olivares', 'Sebasti�n Joaqu�n'),
('EDU083', 'Espejo Farf�n', 'Daniela Rebeca');

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
('EDU084', 'R�os Gallardo', 'Thiago Emanuel'),
('EDU085', 'Carranza Paredes', 'Sof�a Elizabeth'),
('EDU086', 'Mej�a Rivas', '�lvaro Ignacio'),
('EDU087', 'Mendoza Vargas', 'Isabella Antonia'),
('EDU088', 'Zambrano Campos', 'Samuel Josu�'),
('EDU089', 'Figueroa Aguirre', 'Antonella Fiorella'),
('EDU090', 'Acosta Guzm�n', 'Valentino Nicol�s'),
('EDU091', 'Aguilar Neyra', 'Martina Jazm�n'),
('EDU092', 'Rosales D�az', 'Joaqu�n Gabriel'),
('EDU093', 'S�nchez Marquina', 'Emma Nicole');

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
('EDU095', 'Ortega Ch�vez', 'Mateo Alejandro'),
('EDU096', 'Delgado N��ez', 'Camila Valeria'),
('EDU097', 'Guevara Herrera', 'Diego Alonso'),
('EDU098', 'C�rdova Mej�a', 'Alejandra Milagros'),
('EDU099', 'Pizarro Alvarado', 'Sebasti�n Andr�s'),
('EDU100', 'Morales Benavente', 'Valeria Antonella'),
('EDU101', 'Ramos Loyola', 'Gael Esteban'),
('EDU102', 'Campos L�vano', 'Emma Sof�a'),
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
('EDU104', 'Salinas R�os', 'Gabriela Alessandra'),
('EDU105', 'Luna Huam�n', 'Thiago Alexander'),
('EDU106', 'Aguilar Ponce', 'Isabela Ariana'),
('EDU107', 'Escobar Tello', 'Emilio Leonardo'),
('EDU108', 'Carrillo Galindo', 'Victoria Fernanda'),
('EDU109', 'Reyna Zegarra', 'Mat�as Emmanuel'),
('EDU110', 'Loayza Carranza', 'Renata Ivanna'),
('EDU111', 'Bustamante Aguirre', 'Mart�n Enrique'),
('EDU112', 'Bravo Monz�n', 'Alessia Michelle'),
('EDU113', 'Pacheco Canales', 'Juli�n Mateo');

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
('EDU115', 'Velarde Le�n', 'Sebasti�n Andr�s'),
('EDU116', 'Ar�valo Cu�llar', 'Valentina Rosario'),
('EDU117', 'Sotomayor Prado', 'Diego Alonso'),
('EDU118', 'Guill�n Rivas', 'M�a Antonella'),
('EDU119', 'Portilla �lvarez', 'Benjam�n Josu�'),
('EDU120', 'Yupanqui Matos', 'Luciana Nicole'),
('EDU121', 'Ch�vez Huerta', 'Gael Rodrigo'),
('EDU122', 'Esquivel Melgar', 'Zoe Daniela'),
('EDU123', 'Manrique Paucar', 'Tom�s El�as');

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

CREATE OR ALTER PROCEDURE sp_ReporteAsistenciaDocente
    @id_docente INT = NULL,
    @id_curso INT = NULL,
    @id_seccion INT = NULL,
    @id_turno INT = NULL
AS
BEGIN
    SELECT 
        CONCAT(d.nombres, ' ', d.apellidos) AS Docente,
        c.nombre_curso AS Curso,
        s.nombre_seccion AS Seccion,
        t.nombre_turno AS Turno,
        COUNT(ad.id_asistencia_docente) AS TotalClases,
        SUM(CASE WHEN ad.estado_asistencia = 'Asistio' THEN 1 ELSE 0 END) AS Asistencias,
        SUM(CASE WHEN ad.estado_asistencia = 'Falto' THEN 1 ELSE 0 END) AS Inasistencias,
        SUM(CASE WHEN ad.estado_asistencia = 'Tardanza' THEN 1 ELSE 0 END) AS Tardanzas
    FROM AsignacionCurso ac
    INNER JOIN Docente d ON ac.id_docente = d.id_docente
    INNER JOIN Curso c ON ac.id_curso = c.id_curso
    INNER JOIN Seccion s ON ac.id_seccion = s.id_seccion
    INNER JOIN Turno t ON ac.id_turno = t.id_turno
    LEFT JOIN AsistenciaDocente ad ON ac.id_asignacion = ad.id_asignacion
    WHERE (@id_docente IS NULL OR ac.id_docente = @id_docente)
      AND (@id_curso IS NULL OR ac.id_curso = @id_curso)
      AND (@id_seccion IS NULL OR ac.id_seccion = @id_seccion)
      AND (@id_turno IS NULL OR ac.id_turno = @id_turno)
    GROUP BY 
        d.nombres, d.apellidos, c.nombre_curso, 
        s.nombre_seccion, t.nombre_turno
    ORDER BY d.apellidos, d.nombres;
END;
GO

-- Listar todos los reportes
EXEC sp_ReporteAsistenciaDocente;

-- Filtrar por docente espec�fico
EXEC sp_ReporteAsistenciaDocente @id_docente = 1;

-- Filtrar por curso y turno
EXEC sp_ReporteAsistenciaDocente @id_curso = 1, @id_turno = 1;

INSERT INTO AsistenciaDocente (id_asignacion, fecha, hora, estado_asistencia) VALUES
(1, '2025-01-15', '08:00:00', 'Asistio'),
(1, '2025-01-16', '08:05:00', 'Tardanza'),
(1, '2025-01-17', '08:00:00', 'Asistio'),
(2, '2025-01-15', '14:00:00', 'Asistio'),
(2, '2025-01-16', '14:00:00', 'Asistio'),
(3, '2025-01-15', '19:00:00', 'Asistio'),
(3, '2025-01-16', '19:10:00', 'Tardanza'),
(4, '2025-01-15', '08:00:00', 'Asistio'),
(4, '2025-01-17', '08:00:00', 'Falto'),
(5, '2025-01-15', '14:00:00', 'Asistio');

-- Verificar los datos
SELECT * FROM AsistenciaDocente;

-- Ejecutar el procedimiento para ver los resultados
EXEC sp_ReporteAsistenciaDocente;

-- Procedimiento almacenado actualizado con par�metros de filtro
CREATE OR ALTER PROCEDURE sp_ReporteAsistenciaDocente
    @id_docente INT = NULL,
    @id_curso INT = NULL,
    @id_seccion INT = NULL,
    @id_turno INT = NULL
AS
BEGIN
    SELECT 
        CONCAT(d.nombres, ' ', d.apellidos) AS Docente,
        c.nombre_curso AS Curso,
        s.nombre_seccion AS Seccion,
        t.nombre_turno AS Turno,
        COUNT(ad.id_asistencia_docente) AS TotalClases,
        SUM(CASE WHEN ad.estado_asistencia = 'Asistio' THEN 1 ELSE 0 END) AS Asistencias,
        SUM(CASE WHEN ad.estado_asistencia = 'Falto' THEN 1 ELSE 0 END) AS Inasistencias,
        SUM(CASE WHEN ad.estado_asistencia = 'Tardanza' THEN 1 ELSE 0 END) AS Tardanzas
    FROM AsignacionCurso ac
    INNER JOIN Docente d ON ac.id_docente = d.id_docente
    INNER JOIN Curso c ON ac.id_curso = c.id_curso
    INNER JOIN Seccion s ON ac.id_seccion = s.id_seccion
    INNER JOIN Turno t ON ac.id_turno = t.id_turno
    LEFT JOIN AsistenciaDocente ad ON ac.id_asignacion = ad.id_asignacion
    WHERE (@id_docente IS NULL OR ac.id_docente = @id_docente)
      AND (@id_curso IS NULL OR ac.id_curso = @id_curso)
      AND (@id_seccion IS NULL OR ac.id_seccion = @id_seccion)
      AND (@id_turno IS NULL OR ac.id_turno = @id_turno)
    GROUP BY 
        d.nombres, d.apellidos, c.nombre_curso, 
        s.nombre_seccion, t.nombre_turno
    ORDER BY d.apellidos, d.nombres;
END;
GO

-- Prueba del procedimiento
-- Sin filtros (todos los registros)
EXEC sp_ReporteAsistenciaDocente;

-- Con filtro de docente
EXEC sp_ReporteAsistenciaDocente @id_docente = 1;

-- Con filtro de curso
EXEC sp_ReporteAsistenciaDocente @id_curso = 1;

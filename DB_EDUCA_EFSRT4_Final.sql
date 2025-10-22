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
('aJara', 'AbraJar123@', 'Docente'),
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
('12345678', 'Abraham Oliver', 'Jara Miranda', 'abraham.jara@example.com', '987654321', 'Av. Los Olivos 123', 'Ingeniero de Sistemas', 'Maestría en Educación', NULL, 2),
('23456789', 'Maria Ruth', 'Rodríguez Ordoñez', 'maria.rodriguez@example.com', '976543210', 'Calle Primavera 456', 'Licenciada en Matemáticas', 'Doctorado en Ciencias', NULL, 3),
('34567890', 'Jose Valerio', 'Valdez Montes', 'jose.valdez@example.com', '965432109', 'Jr. Lima 789', 'Ingeniero Informático', 'Maestría en Tecnología', NULL, 4),
('45678901', 'Rosa Ana', 'Sanchez Savedra', 'rosa.sanchez@example.com', '954321098', 'Av. Brasil 101', 'Licenciada en Física', 'Maestría en Educación', NULL, 5),
('56789012', 'Fernando Dean', 'Chávez Parker', 'fernando.chavez@example.com', '943210987', 'Pasaje La Paz 202', 'Ingeniero de Software', 'Maestría en Ingeniería', NULL, 6),
('67890123', 'Beatriz Marta', 'Vasquez Coronel', 'beatriz.vasquez@example.com', '932109876', 'Calle Sol 303', 'Licenciada en Computación', 'Doctorado en Ciencias de la Computación', NULL, 7);

-- Tabla: Curso
INSERT INTO Curso (nombre_curso, imagen_url, duracion_horas, nivel, certificacion, precio) VALUES
('Programación Web', 'https://teclab.edu.ar/wp-content/uploads/2023/12/Que-es-la-programacion-web.webp', 80, 'Intermedio', 1, 250.00),
('Bases de Datos', 'https://revistabyte.es/wp-content/uploads/2019/02/Comparativa-Bases-de-Datos-2019.jpg.webp', 60, 'Básico', 1, 200.00),
('Power BI Básico', 'https://learn.microsoft.com/es-es/power-bi/fundamentals/media/service-basic-concepts/power-bi-app-dashboard.png', 40, 'Básico', 1, 180.00),
('Desarrollo Web', 'https://www.comunicare.es/wp-content/uploads/2021/11/desarrollo-web-3.jpg', 100, 'Avanzado', 1, 300.00),
('Inteligencia Artificial', 'https://www.seguritecnia.es/wp-content/uploads/2022/03/inteligencia-artificial.jpg', 120, 'Avanzado', 1, 350.00),
('Ciberseguridad', 'https://universidadeuropea.com/resources/media/images/analista-ciberseguridad-1200x630.original.jpg', 90, 'Intermedio', 1, 320.00),
('Cloud Computing', 'https://img.computing.es/wp-content/uploads/2024/03/19095219/Cloud-Computing-1.jpg', 70, 'Intermedio', 1, 280.00),
('Big Data', 'https://incae.edu/wp-content/uploads/2023/10/big_data_01.jpg', 110, 'Avanzado', 1, 330.00),
('Machine Learning', 'https://kodigowebstorage.blob.core.windows.net/kodigowebsite/2024/02/Machine-learning.jpg', 100, 'Avanzado', 1, 340.00),
('Desarrollo Móvil', 'https://www.qualitydevs.com/wp-content/uploads/2021/03/Desarrollo-apps-moviles.jpg', 80, 'Intermedio', 1, 290.00),
('Fundamentos de Algoritmos', 'https://cdn.lynda.com/course/2838139/2838139-1613993931720-16x9.jpg', 50, 'Básico', 1, 150.00);

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

USE DB_EDUCA
GO

-- Insertar más docentes
INSERT INTO Usuario (Username, Password, Rol) VALUES
('lgarcia', 'LuisG2025@', 'Docente'),
('cmartinez', 'CarlosM2025@', 'Docente'),
('aperez', 'AnaP2025@', 'Docente');

INSERT INTO Docente (dni, nombres, apellidos, correo, celular, direccion, profesion, grado_academico, foto, id_usuario)
VALUES
('78901234', 'Luis Alberto', 'García Mendoza', 'luis.garcia@example.com', '921098765', 'Av. Universitaria 404', 'Ingeniero de Datos', 'Maestría en Big Data', NULL, 8),
('89012345', 'Carlos Enrique', 'Martínez Silva', 'carlos.martinez@example.com', '910987654', 'Calle Tecnología 505', 'Especialista en IA', 'Doctorado en IA', NULL, 9),
('90123456', 'Ana Patricia', 'Pérez Rojas', 'ana.perez@example.com', '909876543', 'Jr. Innovación 606', 'Desarrolladora Full Stack', 'Maestría en Software', NULL, 10);

-- Insertar más cursos
INSERT INTO Curso (nombre_curso, imagen_url, duracion_horas, nivel, certificacion, precio) VALUES
('Python Avanzado', 'https://www.python.org/static/community_logos/python-logo-master-v3-TM.png', 90, 'Avanzado', 1, 310.00),
('React Native', 'https://reactnative.dev/img/header_logo.svg', 75, 'Intermedio', 1, 270.00),
('DevOps Fundamentals', 'https://miro.medium.com/max/1400/1*OlTmKBHN_6Pu3jqJKxXfYw.png', 85, 'Intermedio', 1, 295.00);

-- Insertar asignaciones sin estudiantes (para poder eliminar)
INSERT INTO AsignacionCurso (id_docente, id_curso, id_seccion, id_turno, fecha_inicio, fecha_fin) VALUES
(5, 12, 1, 1, '2025-04-01', '2025-07-30'),
(6, 13, 2, 2, '2025-04-01', '2025-07-30'),
(1, 14, 3, 3, '2025-04-01', '2025-07-30');

-- Insertar más estudiantes
INSERT INTO Estudiante (codigo_estudiante, apellidos, nombres) VALUES
('EDU124', 'Ramírez Soto', 'Andrés Felipe'),
('EDU125', 'Gutiérrez Luna', 'Sofía Valentina'),
('EDU126', 'Herrera Castro', 'Mateo Sebastián'),
('EDU127', 'Vargas Díaz', 'Isabella Lucía'),
('EDU128', 'Moreno Ríos', 'Nicolás Alejandro');

-- Insertar matrículas adicionales
INSERT INTO Matricula (id_estudiante, id_asignacion) VALUES
(124, 1),
(125, 1),
(126, 2),
(127, 2),
(128, 3);

-- Insertar asistencias de docentes
INSERT INTO AsistenciaDocente (id_asignacion, fecha, hora, estado_asistencia) VALUES
(6, '2025-01-20', '08:00:00', 'Asistio'),
(7, '2025-01-20', '14:00:00', 'Asistio'),
(8, '2025-01-20', '19:00:00', 'Tardanza'),
(9, '2025-01-21', '08:00:00', 'Asistio'),
(10, '2025-01-21', '14:00:00', 'Falto');

-- Insertar notas para algunos estudiantes
INSERT INTO Notas (id_matricula, nota_T1, nota_T2, nota_EF) VALUES
(1, 15.5, 16.0, 17.0),
(2, 14.0, 13.5, 15.0),
(3, 18.0, 17.5, 19.0),
(4, 12.0, 11.5, 13.0),
(5, 16.5, 17.0, 18.5);


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

-- Filtrar por docente específico
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

-- Procedimiento almacenado actualizado con parámetros de filtro
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

-- Procedimiento almacenado para eliminar curso con todas sus relacione

CREATE OR ALTER PROCEDURE sp_EliminarCursos
    @id_curso INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @cantidadMatriculados INT;
    
    SELECT @cantidadMatriculados = COUNT(*)
    FROM Matricula M
    INNER JOIN AsignacionCurso AC ON M.id_asignacion = AC.id_asignacion
    WHERE AC.id_curso = @id_curso;
    
    IF @cantidadMatriculados > 0
    BEGIN
        RAISERROR('No se puede eliminar el curso porque tiene estudiantes matriculados.', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM AsignacionCurso WHERE id_curso = @id_curso;
        DELETE FROM Curso WHERE id_curso = @id_curso;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Probar el procedimiento con DevOps (id_curso = 14)
EXEC sp_EliminarCursos @id_curso = 1004;

select * from Curso
go



SELECT * FROM sys.procedures WHERE name = 'sp_EliminarCursos';

SELECT name FROM sys.procedures WHERE name LIKE '%Eliminar%'

-- Procedimiento almacenado para eliminar docente con todas sus relaciones
CREATE OR ALTER PROCEDURE sp_EliminarDocente
    @id_docente INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @cantidadAsignaciones INT;
    DECLARE @id_usuario INT;
    
    -- Verificar si el docente tiene asignaciones con estudiantes matriculados
    SELECT @cantidadAsignaciones = COUNT(*)
    FROM Matricula M
    INNER JOIN AsignacionCurso AC ON M.id_asignacion = AC.id_asignacion
    WHERE AC.id_docente = @id_docente;
    
    IF @cantidadAsignaciones > 0
    BEGIN
        RAISERROR('No se puede eliminar el docente porque tiene estudiantes matriculados en sus cursos.', 16, 1);
        RETURN;
    END
    
    -- Obtener el id_usuario del docente
    SELECT @id_usuario = id_usuario FROM Docente WHERE id_docente = @id_docente;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Eliminar asistencias del docente
        DELETE FROM AsistenciaDocente 
        WHERE id_asignacion IN (SELECT id_asignacion FROM AsignacionCurso WHERE id_docente = @id_docente);
        
        -- Eliminar asignaciones del docente
        DELETE FROM AsignacionCurso WHERE id_docente = @id_docente;
        
        -- Eliminar el docente
        DELETE FROM Docente WHERE id_docente = @id_docente;
        
        -- Eliminar el usuario asociado
        IF @id_usuario IS NOT NULL
        BEGIN
            DELETE FROM Usuario WHERE id_usuario = @id_usuario;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================
-- SCRIPT DE PRUEBAS PARA ELIMINAR DOCENTE
-- ============================================

-- 1. Ver todos los docentes y sus asignaciones
SELECT 
    d.id_docente,
    CONCAT(d.nombres, ' ', d.apellidos) AS Docente,
    COUNT(DISTINCT ac.id_asignacion) AS TotalAsignaciones,
    COUNT(m.id_matricula) AS EstudiantesMatriculados
FROM Docente d
LEFT JOIN AsignacionCurso ac ON d.id_docente = ac.id_docente
LEFT JOIN Matricula m ON ac.id_asignacion = m.id_asignacion
GROUP BY d.id_docente, d.nombres, d.apellidos
ORDER BY d.id_docente;

-- 2. Identificar docentes que SÍ se pueden eliminar (sin estudiantes matriculados)
SELECT 
    d.id_docente,
    CONCAT(d.nombres, ' ', d.apellidos) AS Docente,
    'SE PUEDE ELIMINAR' AS Estado
FROM Docente d
WHERE NOT EXISTS (
    SELECT 1 
    FROM AsignacionCurso ac
    INNER JOIN Matricula m ON ac.id_asignacion = m.id_asignacion
    WHERE ac.id_docente = d.id_docente
);

-- 3. Identificar docentes que NO se pueden eliminar (tienen estudiantes)
SELECT 
    d.id_docente,
    CONCAT(d.nombres, ' ', d.apellidos) AS Docente,
    COUNT(m.id_matricula) AS EstudiantesMatriculados,
    'NO SE PUEDE ELIMINAR' AS Estado
FROM Docente d
INNER JOIN AsignacionCurso ac ON d.id_docente = ac.id_docente
INNER JOIN Matricula m ON ac.id_asignacion = m.id_asignacion
GROUP BY d.id_docente, d.nombres, d.apellidos;

-- ============================================
-- PRUEBA 1: Intentar eliminar docente CON estudiantes (debe fallar)
-- ============================================
PRINT '=== PRUEBA 1: Intentar eliminar docente con estudiantes ==='
BEGIN TRY
    EXEC sp_EliminarDocente @id_docente = 1; -- Abraham Jara tiene estudiantes
    PRINT 'ERROR: No debería haber eliminado el docente'
END TRY
BEGIN CATCH
    PRINT 'CORRECTO: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- PRUEBA 2: Crear un docente de prueba y eliminarlo
-- ============================================
PRINT '=== PRUEBA 2: Crear y eliminar docente de prueba ==='

-- Crear usuario de prueba
delete from Usuario
where id_usuario in (1002,1004,1009,1011)
go

select * 
from Usuario
go;

INSERT INTO Usuario (Username, Password, Rol) 
VALUES ('docente_prueba', 'Test123@', 'Docente');


DECLARE @id_usuario_prueba INT = SCOPE_IDENTITY();

PRINT 'usuario de prueba creado con ID: ' + CAST(@id_usuario_prueba AS VARCHAR);

-- Crear docente de prueba
INSERT INTO Docente (dni, nombres, apellidos, correo, celular, direccion, profesion, grado_academico, foto, id_usuario)
VALUES ('99999999', 'Docente', 'De Prueba', 'prueba@test.com', '999999999', 'Calle Test', 'Profesor', 'Licenciado', NULL, 1014);

DECLARE @id_docente_prueba INT = SCOPE_IDENTITY();

PRINT 'Docente de prueba creado con ID: ' + CAST(@id_docente_prueba AS VARCHAR);

-- Verificar que existe
SELECT * FROM Docente WHERE id_docente = 1014;
SELECT * FROM Usuario WHERE id_usuario = 1014;

-- Eliminar el docente de prueba
EXEC sp_EliminarDocente @id_docente = 1004;

-- Verificar que se eliminó
IF NOT EXISTS (SELECT 1 FROM Docente WHERE id_docente = 1004)
    PRINT 'CORRECTO: Docente eliminado exitosamente'
ELSE
    PRINT 'ERROR: El docente no se eliminó'

IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = 1004)
    PRINT 'CORRECTO: Usuario eliminado exitosamente'
ELSE
    PRINT 'ERROR: El usuario no se eliminó'
GO

-- ============================================
-- PRUEBA 3: Crear docente con asignación SIN estudiantes y eliminarlo
-- ============================================
PRINT '=== PRUEBA 3: Eliminar docente con asignación pero sin estudiantes ==='

-- Crear usuario
INSERT INTO Usuario (Username, Password, Rol) 
VALUES ('docente_prueba2', 'Test123@', 'Docente');

select * from Usuario
go;

DECLARE @id_usuario_prueba2 INT = SCOPE_IDENTITY();

-- Crear docente
INSERT INTO Docente (dni, nombres, apellidos, correo, celular, direccion, profesion, grado_academico, foto, id_usuario)
VALUES ('88888888', 'Docente2', 'De Prueba', 'prueba2@test.com', '888888888', 'Calle Test', 'Profesor', 'Licenciado', NULL, 1015);

DECLARE @id_docente_prueba2 INT = SCOPE_IDENTITY();

-- Crear asignación sin estudiantes
INSERT INTO AsignacionCurso (id_docente, id_curso, id_seccion, id_turno, fecha_inicio, fecha_fin)
VALUES (@id_docente_prueba2, 1, 1, 1, '2025-05-01', '2025-08-30');

DECLARE @id_asignacion_prueba INT = SCOPE_IDENTITY();

-- Crear asistencia del docente
INSERT INTO AsistenciaDocente (id_asignacion, fecha, hora, estado_asistencia)
VALUES (@id_asignacion_prueba, '2025-01-20', '08:00:00', 'Asistio');

PRINT 'Docente con asignación creado con ID: ' + CAST(@id_docente_prueba2 AS VARCHAR);

-- Eliminar el docente (debe funcionar porque no tiene estudiantes)
EXEC sp_EliminarDocente @id_docente = @id_docente_prueba2;

-- Verificar que se eliminó todo
IF NOT EXISTS (SELECT 1 FROM Docente WHERE id_docente = @id_docente_prueba2)
    PRINT 'CORRECTO: Docente eliminado'
ELSE
    PRINT 'ERROR: Docente no eliminado'

IF NOT EXISTS (SELECT 1 FROM AsignacionCurso WHERE id_asignacion = @id_asignacion_prueba)
    PRINT 'CORRECTO: Asignación eliminada'
ELSE
    PRINT 'ERROR: Asignación no eliminada'

IF NOT EXISTS (SELECT 1 FROM AsistenciaDocente WHERE id_asignacion = @id_asignacion_prueba)
    PRINT 'CORRECTO: Asistencias eliminadas'
ELSE
    PRINT 'ERROR: Asistencias no eliminadas'

IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario_prueba2)
    PRINT 'CORRECTO: Usuario eliminado'
ELSE
    PRINT 'ERROR: Usuario no eliminado'
GO

PRINT '=== PRUEBAS COMPLETADAS ==='


-- Procedimiento almacenado para eliminar asignación de curso
CREATE OR ALTER PROCEDURE sp_EliminarAsignacion
    @id_asignacion INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @cantidadEstudiantes INT;
    
    -- Verificar si la asignación tiene estudiantes matriculados
    SELECT @cantidadEstudiantes = COUNT(*)
    FROM Matricula
    WHERE id_asignacion = @id_asignacion;
    
    IF @cantidadEstudiantes > 0
    BEGIN
        RAISERROR('No se puede eliminar la asignación porque tiene estudiantes matriculados.', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Eliminar asistencias del docente en esta asignación
        DELETE FROM AsistenciaDocente WHERE id_asignacion = @id_asignacion;
        
        -- Eliminar la asignación
        DELETE FROM AsignacionCurso WHERE id_asignacion = @id_asignacion;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

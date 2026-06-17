-- =============================================
-- MediCita -- Script de base de datos
-- SQL Server
-- =============================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'MediCitaDB')
    DROP DATABASE MediCitaDB;
GO

CREATE DATABASE MediCitaDB;
GO

USE MediCitaDB;
GO

-- =============================================
-- TABLAS
-- =============================================

-- Usuarios (autenticacion y roles)
CREATE TABLE Usuarios (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    CodigoPublico UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID() UNIQUE,
    Nombre        NVARCHAR(100)  NOT NULL,
    Apellido      NVARCHAR(100)  NOT NULL,
    Email         NVARCHAR(200)  NOT NULL UNIQUE,
    PasswordHash  NVARCHAR(500)  NOT NULL,
    Rol           NVARCHAR(20)   NOT NULL CHECK (Rol IN ('Administrador', 'Medico', 'Paciente')),
    Activo        BIT            NOT NULL DEFAULT 1,
    CreadoEn      DATETIME2      NOT NULL DEFAULT GETDATE(),
    ActualizadoEn DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- Especialidades medicas
CREATE TABLE Especialidades (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      NVARCHAR(150)  NOT NULL UNIQUE,
    Descripcion NVARCHAR(500)  NULL,
    Activa      BIT            NOT NULL DEFAULT 1
);
GO

-- Pacientes (extiende Usuarios)
CREATE TABLE Pacientes (
    Id                  INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId           INT            NOT NULL UNIQUE,
    Cedula              NVARCHAR(20)   NOT NULL UNIQUE,
    Telefono            NVARCHAR(20)   NULL,
    FechaNacimiento     DATE           NULL,
    Genero              NVARCHAR(20)   NULL CHECK (Genero IN ('Masculino', 'Femenino', 'Otro')),
    Direccion           NVARCHAR(300)  NULL,
    ContactoEmergencia  NVARCHAR(200)  NULL,
    TelefonoEmergencia  NVARCHAR(20)   NULL,
    CONSTRAINT FK_Pacientes_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id) ON DELETE CASCADE
);
GO

-- Medicos (extiende Usuarios)
CREATE TABLE Medicos (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId       INT            NOT NULL UNIQUE,
    EspecialidadId  INT            NOT NULL,
    Cedula          NVARCHAR(20)   NOT NULL UNIQUE,
    Telefono        NVARCHAR(20)   NULL,
    NumLicencia     NVARCHAR(50)   NOT NULL UNIQUE,
    Biografia       NVARCHAR(1000) NULL,
    Activo          BIT            NOT NULL DEFAULT 1,
    CONSTRAINT FK_Medicos_Usuarios      FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Medicos_Especialidades FOREIGN KEY (EspecialidadId)
        REFERENCES Especialidades(Id)
);
GO

-- Horarios semanales del medico
CREATE TABLE HorariosMedico (
    Id                INT IDENTITY(1,1) PRIMARY KEY,
    MedicoId          INT   NOT NULL,
    DiaSemana         INT   NOT NULL CHECK (DiaSemana BETWEEN 1 AND 7), -- 1=Lunes ... 7=Domingo
    HoraInicio        TIME  NOT NULL,
    HoraFin           TIME  NOT NULL,
    DuracionCitaMin   INT   NOT NULL DEFAULT 30 CHECK (DuracionCitaMin > 0),
    Activo            BIT   NOT NULL DEFAULT 1,
    CONSTRAINT FK_Horarios_Medicos FOREIGN KEY (MedicoId)
        REFERENCES Medicos(Id) ON DELETE CASCADE,
    CONSTRAINT CHK_Horario_Horas CHECK (HoraFin > HoraInicio)
);
GO

-- Citas
CREATE TABLE Citas (
    Id                  INT IDENTITY(1,1) PRIMARY KEY,
    CodigoPublico       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID() UNIQUE,
    PacienteId          INT             NOT NULL,
    MedicoId            INT             NOT NULL,
    FechaHoraInicio     DATETIME2       NOT NULL,
    FechaHoraFin        DATETIME2       NOT NULL,
    Estado              NVARCHAR(20)    NOT NULL DEFAULT 'Pendiente'
                            CHECK (Estado IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada', 'NoAsistio')),
    Motivo              NVARCHAR(500)   NOT NULL,
    Observaciones       NVARCHAR(1000)  NULL,
    MotivoCancelacion   NVARCHAR(500)   NULL,
    CanceladaPor        NVARCHAR(20)    NULL CHECK (CanceladaPor IN ('Paciente', 'Medico', 'Administrador')),
    CreadaEn            DATETIME2       NOT NULL DEFAULT GETDATE(),
    ActualizadaEn       DATETIME2       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Citas_Pacientes FOREIGN KEY (PacienteId)
        REFERENCES Pacientes(Id),
    CONSTRAINT FK_Citas_Medicos FOREIGN KEY (MedicoId)
        REFERENCES Medicos(Id),
    CONSTRAINT CHK_Cita_Horas CHECK (FechaHoraFin > FechaHoraInicio)
);
GO

-- Notificaciones / cola de emails
CREATE TABLE Notificaciones (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    CitaId      INT             NOT NULL,
    UsuarioId   INT             NOT NULL,
    Tipo        NVARCHAR(30)    NOT NULL
                    CHECK (Tipo IN ('Confirmacion', 'Cancelacion', 'Recordatorio', 'NoAsistio', 'Completada')),
    Estado      NVARCHAR(20)    NOT NULL DEFAULT 'Pendiente'
                    CHECK (Estado IN ('Pendiente', 'Enviada', 'Error')),
    Asunto      NVARCHAR(300)   NOT NULL,
    MensajeHtml NVARCHAR(MAX)   NULL,
    Intentos    INT             NOT NULL DEFAULT 0,
    EnviadaEn   DATETIME2       NULL,
    ErrorDetalle NVARCHAR(500)  NULL,
    CreadaEn    DATETIME2       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Notificaciones_Citas    FOREIGN KEY (CitaId)
        REFERENCES Citas(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Notificaciones_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id)
);
GO

-- =============================================
-- INDICES
-- =============================================

-- Busqueda de citas por medico y fecha (consulta mas frecuente)
CREATE INDEX IX_Citas_MedicoId_Fecha
    ON Citas (MedicoId, FechaHoraInicio)
    INCLUDE (Estado, PacienteId);

-- Busqueda rapida por CodigoPublico (usado en endpoints de la API)
CREATE INDEX IX_Citas_CodigoPublico
    ON Citas (CodigoPublico);

CREATE INDEX IX_Usuarios_CodigoPublico
    ON Usuarios (CodigoPublico);

-- Busqueda de citas por paciente
CREATE INDEX IX_Citas_PacienteId
    ON Citas (PacienteId, FechaHoraInicio);

-- Busqueda de citas activas (validacion de solapamiento)
CREATE INDEX IX_Citas_Solapamiento
    ON Citas (MedicoId, FechaHoraInicio, FechaHoraFin, Estado);

-- Notificaciones pendientes de envio
CREATE INDEX IX_Notificaciones_Pendientes
    ON Notificaciones (Estado, CreadaEn)
    WHERE Estado = 'Pendiente';

-- Medicos por especialidad
CREATE INDEX IX_Medicos_EspecialidadId
    ON Medicos (EspecialidadId)
    WHERE Activo = 1;
GO

-- =============================================
-- DATOS DE PRUEBA
-- =============================================

-- Especialidades
INSERT INTO Especialidades (Nombre, Descripcion) VALUES
('Medicina General',    'Atención primaria y consulta general'),
('Pediatría',           'Atención médica a niños y adolescentes'),
('Cardiología',         'Diagnóstico y tratamiento de enfermedades del corazón'),
('Dermatología',        'Diagnóstico y tratamiento de enfermedades de la piel'),
('Ginecología',         'Salud reproductiva y atención a la mujer'),
('Traumatología',       'Lesiones del sistema musculoesquelético'),
('Neurología',          'Diagnóstico y tratamiento del sistema nervioso'),
('Oftalmología',        'Diagnóstico y tratamiento de enfermedades de los ojos');
GO

-- Usuarios: 1 Admin, 4 Medicos, 5 Pacientes
-- Nota: PasswordHash = PBKDF2 de 'Admin1234!' (reemplazar con hash real en produccion)
INSERT INTO Usuarios (Nombre, Apellido, Email, PasswordHash, Rol) VALUES
-- Administrador
('Carlos',   'Mendoza',   'admin@medicita.com',          'HASH_PLACEHOLDER', 'Administrador'),
-- Medicos
('Ana',      'Gutiérrez', 'ana.gutierrez@medicita.com',  'HASH_PLACEHOLDER', 'Medico'),
('Roberto',  'Sánchez',   'roberto.sanchez@medicita.com','HASH_PLACEHOLDER', 'Medico'),
('Valeria',  'Torres',    'valeria.torres@medicita.com', 'HASH_PLACEHOLDER', 'Medico'),
('Miguel',   'Reyes',     'miguel.reyes@medicita.com',   'HASH_PLACEHOLDER', 'Medico'),
-- Pacientes
('Jefferson','Veloz',     'jefferson@gmail.com',         'HASH_PLACEHOLDER', 'Paciente'),
('María',    'López',     'maria.lopez@gmail.com',       'HASH_PLACEHOLDER', 'Paciente'),
('Pedro',    'Castillo',  'pedro.castillo@gmail.com',    'HASH_PLACEHOLDER', 'Paciente'),
('Sofía',    'Herrera',   'sofia.herrera@gmail.com',     'HASH_PLACEHOLDER', 'Paciente'),
('Luis',     'Mora',      'luis.mora@gmail.com',         'HASH_PLACEHOLDER', 'Paciente');
GO

-- Medicos (UsuarioId 2-5 = medicos)
INSERT INTO Medicos (UsuarioId, EspecialidadId, Cedula, Telefono, NumLicencia, Biografia) VALUES
(2, 1, '0901234561', '0991000001', 'LIC-001', 'Médico general con 8 años de experiencia en atención primaria.'),
(3, 3, '0901234562', '0991000002', 'LIC-002', 'Cardiólogo especializado en enfermedades coronarias.'),
(4, 5, '0901234563', '0991000003', 'LIC-003', 'Ginecóloga con enfoque en salud reproductiva integral.'),
(5, 2, '0901234564', '0991000004', 'LIC-004', 'Pediatra con 5 años de experiencia en cuidado infantil.');
GO

-- Pacientes (UsuarioId 6-10 = pacientes)
INSERT INTO Pacientes (UsuarioId, Cedula, Telefono, FechaNacimiento, Genero) VALUES
(6,  '0951234561', '0981000001', '1998-05-15', 'Masculino'),
(7,  '0951234562', '0981000002', '1990-03-22', 'Femenino'),
(8,  '0951234563', '0981000003', '1985-11-08', 'Masculino'),
(9,  '0951234564', '0981000004', '2001-07-30', 'Femenino'),
(10, '0951234565', '0981000005', '1975-12-01', 'Masculino');
GO

-- Horarios (Lun-Vie para cada medico, 08:00-13:00, citas de 30 min)
INSERT INTO HorariosMedico (MedicoId, DiaSemana, HoraInicio, HoraFin, DuracionCitaMin) VALUES
-- Dra. Ana Gutierrez - Medicina General
(1, 1, '08:00', '13:00', 30), (1, 2, '08:00', '13:00', 30),
(1, 3, '08:00', '13:00', 30), (1, 4, '08:00', '13:00', 30),
(1, 5, '08:00', '12:00', 30),
-- Dr. Roberto Sanchez - Cardiologia
(2, 1, '09:00', '14:00', 45), (2, 3, '09:00', '14:00', 45),
(2, 5, '09:00', '12:00', 45),
-- Dra. Valeria Torres - Ginecologia
(3, 2, '08:00', '13:00', 30), (3, 4, '08:00', '13:00', 30),
(3, 5, '08:00', '11:00', 30),
-- Dr. Miguel Reyes - Pediatria
(4, 1, '07:00', '12:00', 20), (4, 2, '07:00', '12:00', 20),
(4, 3, '07:00', '12:00', 20), (4, 4, '07:00', '12:00', 20);
GO

-- Citas de prueba (estados variados)
-- Combinamos fecha + hora con DATEADD sobre CAST(fecha AS DATETIME2)
DECLARE @Hoy   DATETIME2 = CAST(CAST(GETDATE() AS DATE) AS DATETIME2);
DECLARE @Manana DATETIME2 = DATEADD(DAY,  1, @Hoy);
DECLARE @Pasado DATETIME2 = DATEADD(DAY,  2, @Hoy);
DECLARE @Ayer   DATETIME2 = DATEADD(DAY, -1, @Hoy);

INSERT INTO Citas (PacienteId, MedicoId, FechaHoraInicio, FechaHoraFin, Estado, Motivo) VALUES
-- Citas futuras - confirmadas
(1, 1, DATEADD(MINUTE, 480,  @Manana), DATEADD(MINUTE, 510,  @Manana), 'Confirmada', 'Consulta general por dolor de cabeza'),
(2, 1, DATEADD(MINUTE, 510,  @Manana), DATEADD(MINUTE, 540,  @Manana), 'Confirmada', 'Control de presion arterial'),
(3, 2, DATEADD(MINUTE, 540,  @Pasado), DATEADD(MINUTE, 585,  @Pasado), 'Confirmada', 'Evaluacion cardiologica de rutina'),
-- Citas pendientes
(4, 3, DATEADD(MINUTE, 480,  @Pasado), DATEADD(MINUTE, 510,  @Pasado), 'Pendiente',  'Consulta ginecologica'),
(5, 4, DATEADD(MINUTE, 420,  @Manana), DATEADD(MINUTE, 440,  @Manana), 'Pendiente',  'Control pediatrico mensual'),
-- Citas completadas (ayer)
(1, 4, DATEADD(MINUTE, 420,  @Ayer),   DATEADD(MINUTE, 440,  @Ayer),   'Completada', 'Control de rutina'),
(2, 1, DATEADD(MINUTE, 480,  @Ayer),   DATEADD(MINUTE, 510,  @Ayer),   'Completada', 'Gripe y malestar general'),
-- Cita cancelada
(3, 1, DATEADD(MINUTE, 540,  @Ayer),   DATEADD(MINUTE, 570,  @Ayer),   'Cancelada',  'Dolor abdominal');
GO

UPDATE Citas SET MotivoCancelacion = 'El paciente no pudo asistir', CanceladaPor = 'Paciente'
WHERE Estado = 'Cancelada';
GO

-- Notificaciones de prueba
-- Referencia de citas insertadas:
--   Id=1  PacienteId=1 (UsuarioId=6)  Confirmada  manana
--   Id=2  PacienteId=2 (UsuarioId=7)  Confirmada  manana
--   Id=3  PacienteId=3 (UsuarioId=8)  Confirmada  pasado
--   Id=4  PacienteId=4 (UsuarioId=9)  Pendiente   pasado
--   Id=5  PacienteId=5 (UsuarioId=10) Pendiente   manana
--   Id=6  PacienteId=1 (UsuarioId=6)  Completada  ayer
--   Id=7  PacienteId=2 (UsuarioId=7)  Completada  ayer
--   Id=8  PacienteId=3 (UsuarioId=8)  Cancelada   ayer
INSERT INTO Notificaciones (CitaId, UsuarioId, Tipo, Estado, Asunto, EnviadaEn) VALUES
(1,  6,  'Confirmacion', 'Enviada',   'Tu cita ha sido confirmada - MediCita',       GETDATE()),
(2,  7,  'Confirmacion', 'Enviada',   'Tu cita ha sido confirmada - MediCita',       GETDATE()),
(3,  8,  'Confirmacion', 'Enviada',   'Tu cita ha sido confirmada - MediCita',       GETDATE()),
(8,  8,  'Cancelacion',  'Enviada',   'Tu cita ha sido cancelada - MediCita',        GETDATE()),
(6,  6,  'Completada',   'Enviada',   'Resumen de tu consulta - MediCita',           GETDATE()),
(7,  7,  'Completada',   'Enviada',   'Resumen de tu consulta - MediCita',           GETDATE()),
(5,  10, 'Recordatorio', 'Pendiente', 'Recordatorio: tienes una cita mañana - MediCita', NULL),
(1,  6,  'Recordatorio', 'Pendiente', 'Recordatorio: tienes una cita mañana - MediCita', NULL);
GO

-- =============================================
-- STORED PROCEDURE: validar solapamiento
-- =============================================

CREATE OR ALTER PROCEDURE sp_ValidarDisponibilidad
    @MedicoId       INT,
    @FechaHoraInicio DATETIME2,
    @FechaHoraFin    DATETIME2,
    @CitaIdExcluir   INT = NULL   -- para ediciones: excluir la cita actual
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica si existe alguna cita activa que solape con el rango propuesto
    IF EXISTS (
        SELECT 1 FROM Citas
        WHERE  MedicoId       = @MedicoId
          AND  Estado         NOT IN ('Cancelada', 'NoAsistio')
          AND  (@CitaIdExcluir IS NULL OR Id <> @CitaIdExcluir)
          AND  FechaHoraInicio < @FechaHoraFin
          AND  FechaHoraFin   > @FechaHoraInicio
    )
        SELECT 0 AS Disponible, 'El médico ya tiene una cita en ese horario.' AS Mensaje;
    ELSE
        SELECT 1 AS Disponible, 'Horario disponible.' AS Mensaje;
END;
GO

-- =============================================
-- VIEW: agenda del dia por medico
-- =============================================

CREATE OR ALTER VIEW vw_AgendaDiaria AS
SELECT
    c.Id                AS CitaId,
    c.CodigoPublico     AS CitaCodigo,
    c.FechaHoraInicio,
    c.FechaHoraFin,
    c.Estado,
    c.Motivo,
    m.Id                AS MedicoId,
    um.Nombre + ' ' + um.Apellido  AS NombreMedico,
    e.Nombre            AS Especialidad,
    pat.Id              AS PacienteId,
    up.Nombre + ' ' + up.Apellido  AS NombrePaciente,
    up.Email            AS EmailPaciente,
    pat.Telefono        AS TelefonoPaciente,
    pat.Cedula          AS CedulaPaciente
FROM  Citas c
JOIN  Medicos        m   ON m.Id   = c.MedicoId
JOIN  Usuarios       um  ON um.Id  = m.UsuarioId
JOIN  Especialidades e   ON e.Id   = m.EspecialidadId
JOIN  Pacientes      pat ON pat.Id = c.PacienteId
JOIN  Usuarios       up  ON up.Id  = pat.UsuarioId;
GO

PRINT 'MediCitaDB creada exitosamente.';
GO
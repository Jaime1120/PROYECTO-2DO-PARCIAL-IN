-- ============================================================
-- Creación de la base de datos
-- ============================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'dw_servicios')
BEGIN
    CREATE DATABASE [dw_servicios];
END;
GO

USE [dw_servicios];
GO

-- ============================================================
-- Tabla de dimensión: dim_fecha
-- ============================================================
CREATE TABLE dim_fecha (
    fecha_id DATE NOT NULL PRIMARY KEY,
    dia INT NOT NULL,
    mes INT NOT NULL,
    anio INT NOT NULL,
    nombre_mes VARCHAR(10) NOT NULL,
    trimestre INT NOT NULL,
    semestre INT NOT NULL,
    semana_anio INT NOT NULL,
    dia_semana VARCHAR(10) NOT NULL,
    es_fin_semana BIT NOT NULL,
    es_feriado BIT NOT NULL CONSTRAINT DF_dim_fecha_es_feriado DEFAULT 0,
    periodo_academico VARCHAR(20) NULL
);
GO

CREATE INDEX idx_anio ON dim_fecha(anio);
CREATE INDEX idx_mes ON dim_fecha(mes);
CREATE INDEX idx_trimestre ON dim_fecha(trimestre);
GO

-- ============================================================
-- Tabla de dimensión: dim_tiempo
-- ============================================================
CREATE TABLE dim_tiempo (
    tiempo_id TIME NOT NULL PRIMARY KEY,
    hora INT NOT NULL,
    minuto INT NOT NULL,
    segundo INT NOT NULL CONSTRAINT DF_dim_tiempo_segundo DEFAULT 0,
    hora_24 INT NOT NULL,
    hora_12 INT NOT NULL,
    am_pm VARCHAR(2) NOT NULL CONSTRAINT CHK_dim_tiempo_am_pm CHECK (am_pm IN ('AM','PM')),
    periodo_dia VARCHAR(20) NOT NULL,
    bloque_horario VARCHAR(30) NULL
);
GO

CREATE INDEX idx_hora ON dim_tiempo(hora);
CREATE INDEX idx_periodo ON dim_tiempo(periodo_dia);
GO

-- ============================================================
-- Tabla de dimensión: dim_carrera
-- ============================================================
CREATE TABLE dim_carrera (
    carrera_id INT NOT NULL PRIMARY KEY,
    codigo_carrera VARCHAR(10) NOT NULL,
    nombre_carrera VARCHAR(50) NOT NULL,
    area_conocimiento VARCHAR(50) NULL,
    departamento VARCHAR(50) NULL,
    creditos_totales INT NULL,
    duracion_semestres INT NULL,
    nivel_academico VARCHAR(30) NULL,
    CONSTRAINT uk_codigo_carrera UNIQUE (codigo_carrera)
);
GO

-- ============================================================
-- Tabla de dimensión: dim_usuario
-- ============================================================
CREATE TABLE dim_usuario (
    usuario_id VARCHAR(15) NOT NULL PRIMARY KEY,
    matricula VARCHAR(15) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    sexo CHAR(1) NOT NULL CONSTRAINT CHK_dim_usuario_sexo CHECK (sexo IN ('H','M')),
    correo_electronico VARCHAR(100) NOT NULL,
    direccion VARCHAR(MAX) NULL,
    telefono VARCHAR(20) NULL,
    tipo_usuario VARCHAR(20) NULL CONSTRAINT CHK_dim_usuario_tipo CHECK (tipo_usuario IN ('Estudiante','Docente','Administrativo','Externo')),
    carrera_id INT NULL,
    semestre_actual INT NULL,
    edad INT NULL,
    fecha_registro DATE NULL,
    activo BIT NOT NULL CONSTRAINT DF_dim_usuario_activo DEFAULT 1
);
GO

CREATE INDEX idx_carrera ON dim_usuario(carrera_id);
CREATE INDEX idx_tipo_usuario ON dim_usuario(tipo_usuario);
GO

ALTER TABLE dim_usuario
ADD CONSTRAINT FK_dim_usuario_carrera FOREIGN KEY (carrera_id) REFERENCES dim_carrera(carrera_id);
GO

-- ============================================================
-- Tabla de dimensión: dim_tipo_equipo
-- ============================================================
CREATE TABLE dim_tipo_equipo (
    tipo_equipo_id INT NOT NULL PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    categoria_equipo VARCHAR(30) NULL,
    familia_equipo VARCHAR(30) NULL,
    requiere_calibracion BIT NOT NULL CONSTRAINT DF_dim_tipo_equipo_calibracion DEFAULT 0,
    vida_util_meses INT NULL
);
GO

CREATE INDEX idx_categoria ON dim_tipo_equipo(categoria_equipo);
CREATE INDEX idx_familia ON dim_tipo_equipo(familia_equipo);
GO

-- ============================================================
-- Tabla de dimensión: dim_equipo
-- ============================================================
CREATE TABLE dim_equipo (
    equipo_id INT NOT NULL PRIMARY KEY,
    nombre_equipo VARCHAR(50) NOT NULL,
    tipo_equipo_id INT NOT NULL,
    tipo_equipo_nombre VARCHAR(50) NOT NULL,
    cantidad_total INT NOT NULL,
    cantidad_disponible INT NOT NULL,
    descripcion VARCHAR(100) NULL,
    codigo_barras VARCHAR(15) NOT NULL,
    estado_actual VARCHAR(20) NOT NULL CONSTRAINT CHK_dim_equipo_estado CHECK (estado_actual IN ('Disponible','Prestado','Mantenimiento','Baja')),
    ubicacion_actual VARCHAR(50) NULL,
    fecha_adquisicion DATE NULL,
    valor_adquisicion DECIMAL(10,2) NULL,
    proveedor VARCHAR(50) NULL,
    garantia_hasta DATE NULL
);
GO

CREATE INDEX idx_tipo_equipo ON dim_equipo(tipo_equipo_id);
CREATE INDEX idx_estado ON dim_equipo(estado_actual);
GO

ALTER TABLE dim_equipo
ADD CONSTRAINT FK_dim_equipo_tipo FOREIGN KEY (tipo_equipo_id) REFERENCES dim_tipo_equipo(tipo_equipo_id);
GO

-- ============================================================
-- Tabla de dimensión: dim_sala
-- ============================================================
CREATE TABLE dim_sala (
    sala_id INT NOT NULL PRIMARY KEY,
    nombre_sala VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL,
    edificio VARCHAR(1) NULL CONSTRAINT CHK_dim_sala_edificio CHECK (edificio IN ('A','B','C','D','E','F')),
    planta VARCHAR(1) NULL CONSTRAINT CHK_dim_sala_planta CHECK (planta IN ('1','2','3','4')),
    numero_sala VARCHAR(10) NULL,
    equipo_disponible VARCHAR(100) NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT CHK_dim_sala_estado CHECK (estado IN ('Disponible','Ocupada','Mantenimiento','Cerrada')),
    tipo_sala VARCHAR(20) NULL CONSTRAINT CHK_dim_sala_tipo CHECK (tipo_sala IN ('Aula','Laboratorio','Auditorio','Sala de reuniones')),
    tiene_proyector BIT NOT NULL CONSTRAINT DF_dim_sala_proyector DEFAULT 0,
    tiene_pcs BIT NOT NULL CONSTRAINT DF_dim_sala_pcs DEFAULT 0,
    pcs_disponibles INT NULL,
    area_m2 DECIMAL(6,2) NULL,
    responsable VARCHAR(50) NULL
);
GO

CREATE INDEX idx_edificio ON dim_sala(edificio);
CREATE INDEX idx_estado ON dim_sala(estado);
CREATE INDEX idx_tipo_sala ON dim_sala(tipo_sala);
GO

-- ============================================================
-- Tabla de dimensión: dim_responsable
-- ============================================================
CREATE TABLE dim_responsable (
    responsable_id INT NOT NULL PRIMARY KEY,
    usuario_id VARCHAR(15) NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    puesto VARCHAR(50) NULL,
    departamento VARCHAR(50) NULL,
    nivel_autorizacion INT NULL,
    activo BIT NOT NULL CONSTRAINT DF_dim_responsable_activo DEFAULT 1,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL
);
GO

CREATE INDEX idx_usuario ON dim_responsable(usuario_id);
GO

-- ============================================================
-- Tabla de hechos: fact_prestamos
-- ============================================================
CREATE TABLE fact_prestamos (
    prestamo_id INT NOT NULL PRIMARY KEY,
    usuario_id VARCHAR(15) NOT NULL,
    responsable_id INT NULL,
    equipo_id INT NULL,
    sala_id INT NULL,
    tipo_equipo_id INT NULL,
    carrera_id INT NULL,
    fecha_prestamo_id DATE NOT NULL,
    hora_inicio_id TIME NOT NULL,
    fecha_devolucion_id DATE NULL,
    hora_final_id TIME NULL,
    cantidad_prestada INT NULL,
    turno VARCHAR(30) NOT NULL CONSTRAINT CHK_fact_prestamos_turno CHECK (turno IN ('Matutino (7-14 hrs)','Vespertino (14-16 hrs)','Nocturno (16-20 hrs)')),
    tipo_prestamo VARCHAR(10) NOT NULL CONSTRAINT CHK_fact_prestamos_tipo_prestamo CHECK (tipo_prestamo IN ('Sala','Equipo')),
    estado_prestamo VARCHAR(20) NULL CONSTRAINT CHK_fact_prestamos_estado CHECK (estado_prestamo IN ('Prestado','Devuelto','En reparación','Extraviado','Retrasado')),
    pc_usada VARCHAR(10) NULL CONSTRAINT CHK_fact_prestamos_pc_usada CHECK (pc_usada IN ('Propia','Prestada')),
    numero_pc INT NULL,
    motivo VARCHAR(100) NOT NULL,
    observaciones VARCHAR(100) NULL,
    duracion_minutos INT NULL,
    retraso_minutos INT NULL,
    cantidad_equipos_total INT NULL,
    cantidad_salas_total INT NULL
);
GO

CREATE INDEX idx_usuario ON fact_prestamos(usuario_id);
CREATE INDEX idx_fecha ON fact_prestamos(fecha_prestamo_id);
CREATE INDEX idx_equipo ON fact_prestamos(equipo_id);
CREATE INDEX idx_sala ON fact_prestamos(sala_id);
CREATE INDEX idx_tipo_equipo ON fact_prestamos(tipo_equipo_id);
CREATE INDEX idx_carrera ON fact_prestamos(carrera_id);
CREATE INDEX idx_responsable ON fact_prestamos(responsable_id);
GO

ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_usuario FOREIGN KEY (usuario_id) REFERENCES dim_usuario(usuario_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_responsable FOREIGN KEY (responsable_id) REFERENCES dim_responsable(responsable_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_equipo FOREIGN KEY (equipo_id) REFERENCES dim_equipo(equipo_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_sala FOREIGN KEY (sala_id) REFERENCES dim_sala(sala_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_tipo_equipo FOREIGN KEY (tipo_equipo_id) REFERENCES dim_tipo_equipo(tipo_equipo_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_carrera FOREIGN KEY (carrera_id) REFERENCES dim_carrera(carrera_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_fecha_prestamo FOREIGN KEY (fecha_prestamo_id) REFERENCES dim_fecha(fecha_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_hora_inicio FOREIGN KEY (hora_inicio_id) REFERENCES dim_tiempo(tiempo_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_fecha_devolucion FOREIGN KEY (fecha_devolucion_id) REFERENCES dim_fecha(fecha_id);
ALTER TABLE fact_prestamos
ADD CONSTRAINT FK_fact_prestamos_hora_final FOREIGN KEY (hora_final_id) REFERENCES dim_tiempo(tiempo_id);
GO

-- ============================================================
-- Tabla de hechos: fact_reportes
-- ============================================================
CREATE TABLE fact_reportes (
    reporte_id INT NOT NULL PRIMARY KEY,
    usuario_solicitante_id VARCHAR(15) NOT NULL,
    usuario_responsable_id VARCHAR(15) NULL,
    sala_id INT NOT NULL,
    fecha_reporte_id DATE NOT NULL,
    hora_generacion_id TIME NOT NULL,
    fecha_cierre_id DATE NULL,
    hora_cierre_id TIME NULL,
    tipo_problema VARCHAR(20) NOT NULL CONSTRAINT CHK_fact_reportes_tipo_problema CHECK (tipo_problema IN ('Red','Hardware','Software','Mobiliario','Electricidad','Otro')),
    subtipo_problema VARCHAR(50) NULL,
    descripcion VARCHAR(MAX) NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_fact_reportes_estado DEFAULT 'Abierto' CONSTRAINT CHK_fact_reportes_estado CHECK (estado IN ('Abierto','En progreso','Cerrado','Reabierto')),
    prioridad VARCHAR(10) NOT NULL CONSTRAINT DF_fact_reportes_prioridad DEFAULT 'Media' CONSTRAINT CHK_fact_reportes_prioridad CHECK (prioridad IN ('Baja','Media','Alta','Critica')),
    tiempo_resolucion_minutos INT NULL,
    equipos_afectados INT NULL,
    requiere_externo BIT NOT NULL CONSTRAINT DF_fact_reportes_externo DEFAULT 0,
    costo_reparacion DECIMAL(10,2) NULL
);
GO

CREATE INDEX idx_solicitante ON fact_reportes(usuario_solicitante_id);
CREATE INDEX idx_responsable ON fact_reportes(usuario_responsable_id);
CREATE INDEX idx_sala ON fact_reportes(sala_id);
CREATE INDEX idx_fecha ON fact_reportes(fecha_reporte_id);
CREATE INDEX idx_tipo_problema ON fact_reportes(tipo_problema);
CREATE INDEX idx_estado ON fact_reportes(estado);
GO

ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_usuario_solicitante FOREIGN KEY (usuario_solicitante_id) REFERENCES dim_usuario(usuario_id);
ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_usuario_responsable FOREIGN KEY (usuario_responsable_id) REFERENCES dim_usuario(usuario_id);
ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_sala FOREIGN KEY (sala_id) REFERENCES dim_sala(sala_id);
ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_fecha_reporte FOREIGN KEY (fecha_reporte_id) REFERENCES dim_fecha(fecha_id);
ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_hora_generacion FOREIGN KEY (hora_generacion_id) REFERENCES dim_tiempo(tiempo_id);
ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_fecha_cierre FOREIGN KEY (fecha_cierre_id) REFERENCES dim_fecha(fecha_id);
ALTER TABLE fact_reportes
ADD CONSTRAINT FK_fact_reportes_hora_cierre FOREIGN KEY (hora_cierre_id) REFERENCES dim_tiempo(tiempo_id);
GO

-- ============================================================
-- Tabla de hechos: fact_inventario
-- ============================================================
CREATE TABLE fact_inventario (
    inventario_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    fecha_id DATE NOT NULL,
    equipo_id INT NULL,
    sala_id INT NULL,
    tipo_equipo_id INT NULL,
    cantidad_total INT NOT NULL,
    cantidad_disponible INT NOT NULL,
    cantidad_prestada INT NOT NULL,
    cantidad_mantenimiento INT NOT NULL,
    cantidad_danada INT NOT NULL
);
GO

CREATE INDEX idx_fecha ON fact_inventario(fecha_id);
CREATE INDEX idx_equipo ON fact_inventario(equipo_id);
CREATE INDEX idx_sala ON fact_inventario(sala_id);
CREATE INDEX idx_tipo_equipo ON fact_inventario(tipo_equipo_id);
GO

ALTER TABLE fact_inventario
ADD CONSTRAINT FK_fact_inventario_fecha FOREIGN KEY (fecha_id) REFERENCES dim_fecha(fecha_id);
ALTER TABLE fact_inventario
ADD CONSTRAINT FK_fact_inventario_equipo FOREIGN KEY (equipo_id) REFERENCES dim_equipo(equipo_id);
ALTER TABLE fact_inventario
ADD CONSTRAINT FK_fact_inventario_sala FOREIGN KEY (sala_id) REFERENCES dim_sala(sala_id);
ALTER TABLE fact_inventario
ADD CONSTRAINT FK_fact_inventario_tipo_equipo FOREIGN KEY (tipo_equipo_id) REFERENCES dim_tipo_equipo(tipo_equipo_id);
GO

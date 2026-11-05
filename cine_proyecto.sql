-- =====================================================================
--  BASE DE DATOS: CINE (cine_proyecto) - versión corregida
--  Para importar en XAMPP (MySQL / MariaDB) desde phpMyAdmin:
--    1) Crea una base llamada cine_proyecto y ábrela.
--    2) Pestaña "Importar" -> elige este archivo -> "Importar".
--
--  Cambios respecto a la versión anterior:
--    - horarios: id_horario ahora es número (antes era tipo hora y
--      los dos horarios tenían el mismo id) y tiene llave primaria.
--    - peliculas: "reparto" ahora acepta texto (antes era varchar(0)),
--      King Kong tiene id 1, fecha, duración y clasificación reales.
--    - generos: un género por fila (antes todos estaban en una sola).
--    - Se quitaron datos repetidos (+13, ingles, salas 1 y 2).
--    - Se agregaron llaves foráneas entre las tablas.
-- =====================================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET NAMES utf8mb4;

-- Borra las tablas si ya existían, para poder volver a importar
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS funciones, pelicula_genero, peliculas, usuarios, salas,
  horarios, idiomas, generos, formatos, estados, clasificaciones;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- CATÁLOGOS
-- ---------------------------------------------------------------------

CREATE TABLE clasificaciones (
  id_clasificacion INT(11) NOT NULL AUTO_INCREMENT,
  nombre           VARCHAR(50)  NOT NULL UNIQUE,
  descripcion      VARCHAR(255) NOT NULL,
  PRIMARY KEY (id_clasificacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO clasificaciones (id_clasificacion, nombre, descripcion) VALUES
  (1, 'Todo público', 'Apta para todo público'),
  (2, '+13',          'Mayores de 13 años'),
  (3, '+16',          'Mayores de 16 años'),
  (4, '+18',          'Solo adultos');

CREATE TABLE estados (
  id_estado     INT(11) NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (id_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO estados (id_estado, nombre_estado) VALUES
  (1, 'En cartelera'),
  (2, 'Próximamente'),
  (3, 'Avanzada');

CREATE TABLE formatos (
  id_formato     INT(11) NOT NULL AUTO_INCREMENT,
  nombre_formato VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (id_formato)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO formatos (id_formato, nombre_formato) VALUES
  (1, '2D'),
  (2, '3D'),
  (3, 'IMAX');

CREATE TABLE generos (
  id_genero     INT(11) NOT NULL AUTO_INCREMENT,
  nombre_genero VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (id_genero)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO generos (id_genero, nombre_genero) VALUES
  (1, 'Acción'),
  (2, 'Comedia'),
  (3, 'Drama'),
  (4, 'Terror'),
  (5, 'Romance'),
  (6, 'Aventura'),
  (7, 'Animación'),
  (8, 'Ciencia ficción');

CREATE TABLE idiomas (
  id_idioma     INT(11) NOT NULL AUTO_INCREMENT,
  nombre_idioma VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (id_idioma)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO idiomas (id_idioma, nombre_idioma) VALUES
  (1, 'Inglés'),
  (2, 'Español'),
  (3, 'Francés');

CREATE TABLE horarios (
  id_horario  INT(11) NOT NULL AUTO_INCREMENT,
  hora_inicio TIME NOT NULL,
  hora_fin    TIME NOT NULL,
  PRIMARY KEY (id_horario),
  CONSTRAINT chk_horas CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO horarios (id_horario, hora_inicio, hora_fin) VALUES
  (1, '10:00:00', '12:00:00'),
  (2, '13:00:00', '15:00:00');

CREATE TABLE salas (
  id_sala     INT(11) NOT NULL AUTO_INCREMENT,
  nombre_sala VARCHAR(50) NOT NULL UNIQUE,
  capacidad   INT(11) NOT NULL,
  tipo_sala   VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_sala)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO salas (id_sala, nombre_sala, capacidad, tipo_sala) VALUES
  (1, 'Sala 1', 100, '2D'),
  (2, 'Sala 2', 120, '3D');

-- ---------------------------------------------------------------------
-- PELÍCULAS
-- ---------------------------------------------------------------------

CREATE TABLE peliculas (
  id_pelicula      INT(11) NOT NULL AUTO_INCREMENT,
  titulo           VARCHAR(150) NOT NULL,
  imagen           VARCHAR(255) NOT NULL,
  duracion         INT(11) NOT NULL,            -- en minutos
  fecha_estreno    DATE NOT NULL,
  director         VARCHAR(250) NOT NULL,
  reparto          VARCHAR(500) NULL,
  sinopsis         TEXT NOT NULL,
  id_clasificacion INT(11) NOT NULL,
  id_idioma        INT(11) NOT NULL,
  id_formato       INT(11) NOT NULL,
  id_estado        INT(11) NOT NULL,
  PRIMARY KEY (id_pelicula),
  CONSTRAINT fk_peliculas_clasificacion FOREIGN KEY (id_clasificacion)
    REFERENCES clasificaciones (id_clasificacion),
  CONSTRAINT fk_peliculas_idioma  FOREIGN KEY (id_idioma)  REFERENCES idiomas (id_idioma),
  CONSTRAINT fk_peliculas_formato FOREIGN KEY (id_formato) REFERENCES formatos (id_formato),
  CONSTRAINT fk_peliculas_estado  FOREIGN KEY (id_estado)  REFERENCES estados (id_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO peliculas (id_pelicula, titulo, imagen, duracion, fecha_estreno, director,
                       reparto, sinopsis, id_clasificacion, id_idioma, id_formato, id_estado) VALUES
  (1, 'King Kong', 'https://images7.alphacoders.com/412/412904.jpg', 187, '2005-12-14',
   'Peter Jackson', 'Naomi Watts, Jack Black, Adrien Brody',
   'Un equipo de cine viaja a la misteriosa Isla Calavera, donde descubre a Kong, un gorila gigantesco que es el rey de la selva. Cuando lo capturan y lo llevan a Nueva York, Kong escapa y siembra el caos en la ciudad, en una historia sobre el choque entre la naturaleza y la civilización.',
   2, 1, 3, 2);

-- Tabla intermedia: una película puede tener varios géneros
CREATE TABLE pelicula_genero (
  id_pelicula INT(11) NOT NULL,
  id_genero   INT(11) NOT NULL,
  PRIMARY KEY (id_pelicula, id_genero),
  CONSTRAINT fk_pg_pelicula FOREIGN KEY (id_pelicula) REFERENCES peliculas (id_pelicula)
    ON DELETE CASCADE,
  CONSTRAINT fk_pg_genero   FOREIGN KEY (id_genero)   REFERENCES generos (id_genero)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES
  (1, 1),   -- King Kong: Acción
  (1, 6);   -- King Kong: Aventura

-- ---------------------------------------------------------------------
-- FUNCIONES (qué película se da, en qué sala, qué día y a qué hora)
-- ---------------------------------------------------------------------

CREATE TABLE funciones (
  id_funcion  INT(11) NOT NULL AUTO_INCREMENT,
  id_pelicula INT(11) NOT NULL,
  id_horario  INT(11) NOT NULL,
  id_sala     INT(11) NOT NULL,
  fecha       DATE NOT NULL,
  PRIMARY KEY (id_funcion),
  -- No puede haber dos funciones en la misma sala, día y horario
  UNIQUE KEY uq_sala_fecha_horario (id_sala, fecha, id_horario),
  CONSTRAINT fk_funciones_pelicula FOREIGN KEY (id_pelicula) REFERENCES peliculas (id_pelicula),
  CONSTRAINT fk_funciones_horario  FOREIGN KEY (id_horario)  REFERENCES horarios (id_horario),
  CONSTRAINT fk_funciones_sala     FOREIGN KEY (id_sala)     REFERENCES salas (id_sala)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- USUARIOS (para entrar al panel de administración)
-- ---------------------------------------------------------------------

CREATE TABLE usuarios (
  id_usuario INT(11) NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(100) NOT NULL,
  usuario    VARCHAR(50)  NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL,
  PRIMARY KEY (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Usuario de práctica. En un sistema real la contraseña se guarda
-- cifrada (por ejemplo con password_hash() de PHP), no en texto.
INSERT INTO usuarios (id_usuario, nombre, usuario, password) VALUES
  (1, 'Administrador', 'ADMIN', 'ADMIN1234');

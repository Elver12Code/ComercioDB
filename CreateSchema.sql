-- =============================================
--                 CREATE DATABASE
-- =============================================
USE MASTER
IF EXISTS
(
	SELECT *
	FROM SYS.DATABASES
	WHERE NAME = 'comercioDB'
)

ALTER DATABASE comercioDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE comercioDB
GO
CREATE DATABASE comercioDB
GO

USE comercioDB
GO

-- =============================================
--                   USERS
-- =============================================
IF EXISTS
(
    SELECT *
    FROM SYS.DATABASE_PRINCIPALS
    WHERE NAME ='usuario1'
)
DROP USER usuario1
GO
IF EXISTS
(
    SELECT *
    FROM SYS.SERVER_PRINCIPALS
    WHERE NAME ='usuario1'
)
DROP LOGIN usuario1
GO
CREATE LOGIN usuario1 WITH PASSWORD ='usuario1'
GO
CREATE USER usuario1 FOR LOGIN usuario1
GO

-- =============================================
--                    SCHEMAS
-- =============================================
IF EXISTS 
(
    SELECT name
    FROM SYS.SCHEMAS
    WHERE NAME = 'Ventas'
)
DROP SCHEMA Ventas
GO
CREATE SCHEMA Ventas AUTHORIZATION usuario1
GO

IF EXISTS 
(
    SELECT name
    FROM SYS.SCHEMAS
    WHERE NAME = 'Inventario'
)
DROP SCHEMA Inventario
GO
CREATE SCHEMA Inventario AUTHORIZATION usuario1
GO

IF EXISTS
(
    SELECT * 
    FROM SYS.SCHEMAS
    WHERE NAME = 'Opiniones'
)
DROP SCHEMA Opiniones
GO
CREATE SCHEMA Opiniones AUTHORIZATION usuario1
GO

-- =============================================
--                CREATE TABLES
-- =============================================
IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='ventas' AND T.NAME = 'clientes'
)
DROP TABLE ventas.clientes
GO
CREATE TABLE ventas.clientes
(
    id INT PRIMARY KEY NOT NULL,
    nombres NVARCHAR(50) NOT NULL,
    apellidos   NVARCHAR(50)NOT NULL,    
    correo VARCHAR(50) UNIQUE,
    direccion VARCHAR(255) NOT NULL,
    telefono VARCHAR(15) NOT NULL
)
GO  

IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='ventas' AND T.NAME = 'detalles_pedido'
)
DROP TABLE ventas.detalles_pedido
GO
CREATE TABLE ventas.detalles_pedido
(
    id int PRIMARY KEY NOT NULL,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad int NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL
)
GO

IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='ventas' AND T.NAME = 'pedidos'
)
DROP TABLE ventas.pedidos
GO
CREATE TABLE ventas.pedidos
(
    id int PRIMARY KEY NOT NULL,
    id_cliente INT NOT NULL,
    fecha DATETIME2  NOT NULL,
    estado  VARCHAR(20) DEFAULT 'Pendiente',
    total DECIMAL(10,2)  NOT NULL
)
GO

IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='ventas' AND T.NAME = 'pagos'
)
DROP TABLE ventas.pagos
GO
CREATE TABLE ventas.pagos
(
    id int PRIMARY KEY NOT NULL,
    id_pedido INT  NOT NULL,
    monto decimal(10,2)  NOT NULL,
    metodo VARCHAR(15)  NOT NULL,
    estado VARCHAR(15) DEFAULT 'Pendiente'
)
GO

IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='inventario' AND T.NAME = 'productos'
)
DROP TABLE inventario.productos
GO
CREATE TABLE inventario.productos
(
    id int PRIMARY KEY NOT NULL,
    nombre VARCHAR(50)  NOT NULL,
    descripcion varchar(255) ,
    precio DECIMAL(10,2)  NOT NULL,
    stock   INT  NOT NULL,
    id_categoria INT  NOT NULL
)
GO

IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='inventario' AND T.NAME = 'categorias'
)
DROP TABLE inventario.categorias
GO
CREATE TABLE inventario.categorias
(
    id int PRIMARY KEY NOT NULL,
    nombre VARCHAR(50)  NOT NULL,
    descripcion varchar(255) ,
)
GO

IF EXISTS 
(
        SELECT *
        FROM SYS.SCHEMAS S 
        INNER JOIN SYS.TABLES T 
        ON T.SCHEMA_ID = S.SCHEMA_ID
        WHERE S.NAME ='opiniones' AND T.NAME = 'reseña'
)
DROP TABLE opiniones.reseña
GO
CREATE TABLE opiniones.reseña
(
    id int PRIMARY KEY NOT NULL,
    id_cliente INT  NOT NULL,
    id_producto INT  NOT NULL,
    calificacion tinyint,
    comentario varchar(255),
    fecha DATETIME2  NOT NULL
)
GO

ALTER TABLE ventas.pedidos 
ADD CONSTRAINT FK_pedidos.clientes FOREIGN KEY (id_cliente) REFERENCES ventas.clientes(id)
ON DELETE CASCADE 
GO

ALTER TABLE ventas.detalles_pedido 
ADD CONSTRAINT FK_detalles_pedido_pedidos FOREIGN KEY (id_pedido) REFERENCES ventas.pedidos(id)
ON DELETE CASCADE
GO

ALTER TABLE ventas.detalles_pedido
ADD CONSTRAINT FK_detalles_pedido_productos FOREIGN KEY (id_producto) REFERENCES inventario.productos(id)
ON DELETE CASCADE
GO
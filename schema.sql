--Creacion de una base de datos
create database food_store;

-- Tipos enumerados
CREATE TYPE rol           AS ENUM ('ADMIN','USUARIO');
CREATE TYPE estado_pedido AS ENUM ('PENDIENTE','CONFIRMADO',
                                   'TERMINADO','CANCELADO');
CREATE TYPE forma_pago    AS ENUM ('TARJETA','TRANSFERENCIA','EFECTIVO');
 
-- Creacion de tablas con distintas validaciones
CREATE TABLE categoria (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre      VARCHAR(80)  NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    eliminado   BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
 
CREATE TABLE producto (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(120) NOT NULL,
    precio       NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    descripcion  VARCHAR(255),
    stock        INTEGER      NOT NULL DEFAULT 0 CHECK (stock >= 0),
    imagen       VARCHAR(255),
    disponible   BOOLEAN      NOT NULL DEFAULT TRUE,
    categoria_id BIGINT       NOT NULL REFERENCES categoria(id),
    eliminado    BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);
 
CREATE TABLE usuario (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre      VARCHAR(80)  NOT NULL,
    apellido    VARCHAR(80)  NOT NULL,
    mail        VARCHAR(120) NOT NULL UNIQUE,
    celular     VARCHAR(30),
    contrasena  VARCHAR(255) NOT NULL,
    rol         rol          NOT NULL DEFAULT 'USUARIO',
    eliminado   BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
 
CREATE TABLE pedido (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha      DATE          NOT NULL DEFAULT CURRENT_DATE,
    estado     estado_pedido NOT NULL DEFAULT 'PENDIENTE',
    total      NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    forma_pago forma_pago    NOT NULL,
    usuario_id BIGINT        NOT NULL REFERENCES usuario(id),
    eliminado  BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT now()
);
    
CREATE TABLE detalle_pedido (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cantidad       INTEGER       NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal       NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    pedido_id      BIGINT        NOT NULL REFERENCES pedido(id)
                                 ON DELETE RESTRICT,
    producto_id    BIGINT        NOT NULL REFERENCES producto(id),
    eliminado      BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (pedido_id, producto_id)
);

-- Creacion de indices
create index idx_producto_categoria on producto(categoria_id);
create index idx_pedido_usuario on pedido(usuario_id);
create index idx_detalle_pedido on detalle_pedido(pedido_id);


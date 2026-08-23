--                                  HISTORIAS DE USUARIO                              --
----  Épica 1 — Gestión de Categorías
-- Listar categorías
SELECT id, nombre, descripcion
FROM   categoria
WHERE  eliminado = FALSE
ORDER  BY id;

-- Crear categoría
INSERT INTO categoria(nombre, descripcion)
VALUES ('Empanadas', 'Variedad de empanadas')
RETURNING id;

-- Editar categoría
UPDATE categoria
SET    nombre = 'Pizzas y Empanadas', descripcion = 'Catálogo ampliado'
WHERE  id = 1 AND eliminado = FALSE;   -- 0 filas si no existe/eliminada

-- Eliminar categoría (baja lógica)
UPDATE categoria
SET    eliminado = TRUE
WHERE  id = 2 AND eliminado = FALSE;

---- Épica 2 — Gestión de Productos
-- Listar productos
SELECT p.id, p.nombre, p.precio, p.stock, c.nombre AS categoria
FROM   producto p
JOIN   categoria c ON c.id = p.categoria_id
WHERE  p.eliminado = FALSE
-- AND  p.categoria_id = 1            -- filtro opcional
ORDER  BY p.id;

-- Crear producto
INSERT INTO producto(nombre, descripcion, precio, stock,
                     imagen, disponible, categoria_id)
SELECT 'Fugazzeta', 'Pizza de cebolla', 1800.00, 10, NULL, TRUE, c.id
FROM   categoria c
WHERE  c.id = 1 AND c.eliminado = FALSE   -- garantiza categoría vigente
RETURNING id;

-- Editar producto
UPDATE producto
SET    precio = COALESCE(2000.00, precio),   -- NULL conserva el valor
       stock  = COALESCE(NULL,    stock)
WHERE  id = 1 AND eliminado = FALSE;

-- Eliminar producto (baja lógica)
UPDATE producto
SET    eliminado = TRUE
WHERE  id = 1 AND eliminado = FALSE;

---- Épica 3 — Gestión de Usuarios
-- Listar usuarios
SELECT id, nombre, apellido, mail, rol
FROM   usuario
WHERE  eliminado = FALSE
ORDER  BY id;

-- Crear usuario
INSERT INTO usuario(nombre, apellido, mail, celular, contrasena)
VALUES ('Juan', 'Pérez', 'juan@x.com', '2611234567', 'hash')
RETURNING id;   -- UNIQUE(mail) lanza error si el mail ya existe

-- Editar usuario
UPDATE usuario
SET    celular = '2617654321'
WHERE  id = 1 AND eliminado = FALSE;

-- Eliminar usuario (baja lógica)
UPDATE usuario
SET    eliminado = TRUE
WHERE  id = 1 AND eliminado = FALSE;

---- Épica 4 — Gestión de Pedidos y Detalles
-- Listar pedidos
SELECT id, usuario, fecha, estado, forma_pago, total
FROM   v_pedidos_resumen
-- WHERE usuario = 'Ana Garis'          -- filtro opcional
ORDER  BY id;

-- Crear pedido con detalles
CALL sp_crear_pedido(
     1,                 -- usuario_id (debe estar vigente)
     'EFECTIVO',
     '[{"producto_id":1,"cantidad":2},
       {"producto_id":2,"cantidad":1}]'::jsonb);

-- Actualizar estado / forma de pago
UPDATE pedido
SET    estado = 'CONFIRMADO', forma_pago = 'TARJETA'
WHERE  id = 1 AND eliminado = FALSE;

-- Eliminar pedido (baja lógica)
BEGIN;
  UPDATE detalle_pedido SET eliminado = TRUE WHERE pedido_id = 1;
  UPDATE pedido         SET eliminado = TRUE WHERE id = 1;
COMMIT;

--                                  Consultas analíticas (para profundizar)                         --
-- A) Top 5 productos más vendidos (por cantidad)
SELECT pr.id, pr.nombre, SUM(dp.cantidad) AS unidades
FROM   detalle_pedido dp
JOIN   producto pr ON pr.id = dp.producto_id
WHERE  dp.eliminado = FALSE
GROUP  BY pr.id, pr.nombre
ORDER  BY unidades DESC
LIMIT  5;
 
-- B) Facturación por categoría y por mes
SELECT c.nombre AS categoria,
       date_trunc('month', ped.fecha) AS mes,
       SUM(dp.subtotal) AS facturado
FROM   detalle_pedido dp
JOIN   pedido   ped ON ped.id = dp.pedido_id AND ped.eliminado = FALSE
JOIN   producto pr  ON pr.id  = dp.producto_id
JOIN   categoria c  ON c.id   = pr.categoria_id
WHERE  dp.eliminado = FALSE
GROUP  BY c.nombre, date_trunc('month', ped.fecha)
ORDER  BY mes, facturado DESC;
 
-- C) Ranking de usuarios por gasto acumulado (función de ventana)
SELECT u.id, u.nombre || ' ' || u.apellido AS usuario,
       SUM(ped.total) AS gasto,
       RANK() OVER (ORDER BY SUM(ped.total) DESC) AS puesto
FROM   pedido ped
JOIN   usuario u ON u.id = ped.usuario_id
WHERE  ped.eliminado = FALSE
GROUP  BY u.id, u.nombre, u.apellido
ORDER  BY puesto;
 
-- D) Pedidos cuyo total supera el promedio general (subconsulta)
SELECT id, total
FROM   pedido
WHERE  eliminado = FALSE
  AND  total > (SELECT AVG(total) FROM pedido WHERE eliminado = FALSE)
ORDER  BY total DESC;
 
-- E) Productos sin ventas (LEFT JOIN + IS NULL)
SELECT pr.id, pr.nombre
FROM   producto pr
LEFT   JOIN detalle_pedido dp
       ON dp.producto_id = pr.id AND dp.eliminado = FALSE
WHERE  pr.eliminado = FALSE
  AND  dp.id IS NULL
ORDER  BY pr.id;

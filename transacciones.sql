--                                  EJEMPLOS TRANSACCION                              --
-- 1. Atomicidad
CALL sp_crear_pedido(1, 'tarjeta', '[{"producto_id":1,"cantidad":0}]'); -- Ítem inválido

-- Verificamos que el pedido NO se creó (no quedará registro de la cabecera huérfana).
SELECT * FROM pedido ORDER BY id DESC LIMIT 5;

-- 2. Transacción manual
-- Transaccion exitosa
BEGIN;
INSERT INTO pedido(usuario_id, forma_pago) VALUES (1, 'efectivo');
COMMIT; -- Verificar que el pedido se creó
-- Verificación: El pedido se guardó correctamente.
SELECT * FROM pedido WHERE usuario_id = 1 ORDER BY id DESC LIMIT 1;

-- Transaccion invalida
BEGIN;
INSERT INTO pedido(usuario_id, forma_pago) VALUES (2, 'efectivo');
ROLLBACK; -- Verificar que el pedido no se creó
-- Verificación: El pedido de usuario_id = 2 NO existe en la base.
SELECT * FROM pedido WHERE usuario_id = 2 ORDER BY id DESC LIMIT 1;

-- 3. Aislamiento
-- (Ejecutar en dos sesiones psql simultáneas para demostrar fenómenos de concurrencia)
-- Primera sesion (Nivel de aislamiento: READ COMMITTED)
-- TERMINAL 1
BEGIN;
SELECT stock FROM producto WHERE id = 1; -- por ej:  50

-- TERMINAL 2 
BEGIN;
UPDATE producto SET stock = 40 WHERE id = 1;
COMMIT;

-- TERMINAL 1
SELECT stock FROM producto WHERE id = 1; -- Ahora devuelve 40. El cambio se realiza durante la misma transaccion
COMMIT;

-- Segunda sesion (Nivel de aislamiento: SERIALIZABLE)
-- TERMINAL 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT stock FROM producto WHERE id = 1; -- Devuelve 40

-- TERMINAL 2
BEGIN;
UPDATE producto SET stock = 30 WHERE id = 1;
COMMIT;

-- TERMINAL 1
SELECT stock FROM producto WHERE id = 1; -- Sigue devolviendo 40 (Lectura consistente)
COMMIT;
 
-- 4. Bloqueos
-- Para probar esto se debe realizar en dos consolas simultaneamente
-- TERMINAL 1 (Usuario A)
BEGIN;
SELECT stock FROM producto WHERE id = 1 FOR UPDATE; -- El Usuario A lee el producto y bloquea la fila para que nadie más la toque 

-- TERMINAL 2 (Usuario B)
-- El Usuario B intenta comprar el mismo producto al mismo tiempo
BEGIN;
SELECT stock FROM producto WHERE id = 1 FOR UPDATE;-- La Terminal 2 se quedará en espera porque la Terminal 1 tiene bloqueada la fila

-- TERMINAL 1 (Usuario A)
-- El Usuario A descuenta su stock y finaliza la transacción.
UPDATE producto SET stock = stock - 1 WHERE id = 1;
COMMIT;

-- TERMINAL 2 (Usuario B)
-- Apenas la Terminal 1 hace COMMIT, la Terminal 2 se destraba automáticamente.
-- Ahora lee el stock actualizado por el Usuario A, evitando la sobreventa.
UPDATE producto SET stock = stock - 1 WHERE id = 1;
COMMIT;
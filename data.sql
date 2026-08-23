--                                  DATOS DE EJEMPLO                              --
-- Insertar categorías
INSERT INTO categoria (nombre, descripcion) VALUES
('Empanadas', 'Variedad de empanadas'),
('Pizzas', 'Deliciosas pizzas de diferentes sabores'),
('Bebidas', 'Bebidas frías y calientes'),
('Postres', 'Dulces y postres para todos los gustos');
 
-- Insertar productos
INSERT INTO producto (nombre, descripcion, precio, stock, imagen, disponible, categoria_id) VALUES
('Empanada de Carne', 'Empanada rellena de carne', 150.00, 50, NULL, TRUE, 1),
('Empanada de Jamón y Queso', 'Empanada con jamón y queso', 160.00, 30, NULL, TRUE, 1),
('Pizza Margherita', 'Pizza clásica con tomate y mozzarella', 800.00, 20, NULL, TRUE, 2),
('Pizza Pepperoni', 'Pizza con pepperoni y queso', 900.00, 15, NULL, TRUE, 2),
('Coca Cola', 'Bebida gaseosa', 100.00, 100, NULL, TRUE, 3),
('Agua Mineral', 'Agua mineral sin gas', 50.00, 200, NULL, TRUE, 3),
('Tarta de Dulce de Leche', 'Deliciosa tarta de dulce de leche', 250.00, 25, NULL, TRUE, 4),
('Helado de Chocolate', 'Helado cremoso de chocolate', 300.00, 40, NULL, TRUE, 4),
('Pizza Cuatro Quesos', 'Pizza con cuatro tipos de queso', 950.00, 10, NULL, TRUE, 2),
('Empanada de Verdura', 'Empanada rellena de verduras', 140.00, 20, NULL, TRUE, 1);
 
-- Insertar usuarios
INSERT INTO usuario (nombre, apellido, mail, celular, contrasena, rol) VALUES
('Juan', 'Pérez', 'juan@x.com', '2611234567', 'hash1', 'USUARIO'),
('Ana', 'Garis', 'ana@x.com', '2617654321', 'hash2', 'USUARIO'),
('Luis', 'Martínez', 'luis@x.com', '2619876543', 'hash3', 'ADMIN'),
('María', 'González', 'maria@x.com', '2614567890', 'hash4', 'USUARIO'),
('Pedro', 'López', 'pedro@x.com', '2611234568', 'hash5', 'USUARIO');
 
-- Insertar pedidos
INSERT INTO pedido (fecha, estado, total, forma_pago, usuario_id) VALUES
(CURRENT_DATE, 'PENDIENTE', 0, 'EFECTIVO', 1),
(CURRENT_DATE, 'PENDIENTE', 0, 'TARJETA', 2),
(CURRENT_DATE, 'CONFIRMADO', 0, 'TRANSFERENCIA', 3),
(CURRENT_DATE, 'TERMINADO', 0, 'EFECTIVO', 4),
(CURRENT_DATE, 'CANCELADO', 0, 'TARJETA', 5);
 
-- Insertar detalles de pedidos
INSERT INTO detalle_pedido (cantidad, precio_unitario, subtotal, pedido_id, producto_id) VALUES
(2, 150.00, 300.00, 1, 1),  -- 2 Empanadas de Carne
(1, 160.00, 160.00, 1, 2),  -- 1 Empanada de Jamón y Queso
(1, 800.00, 800.00, 2, 3),   -- 1 Pizza Margherita
(1, 900.00, 900.00, 2, 4),   -- 1 Pizza Pepperoni
(3, 100.00, 300.00, 3, 5),   -- 3 Coca Cola
(2, 50.00, 100.00, 3, 6),     -- 2 Agua Mineral
(1, 950.00, 950.00, 4, 9),    -- 1 Pizza Cuatro Quesos
(1, 140.00, 140.00, 4, 10),   -- 1 Empanada de Verdura
(1, 250.00, 250.00, 5, 7),    -- 1 Tarta de Dulce de Leche
(1, 300.00, 300.00, 5, 8);     -- 1 Helado de Chocolate
 
-- Actualizar totales de pedidos
UPDATE pedido SET total = (SELECT SUM(subtotal) FROM detalle_pedido WHERE pedido_id = id) WHERE id IN (1, 2, 3, 4, 5);
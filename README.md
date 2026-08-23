# Sistema de Gestión para Tienda de Comida (Food Store)

Este proyecto contiene el diseño e implementación de una base de datos relacional para gestionar pedidos, productos, usuarios y categorías de un local gastronómico.

### 1. Orden de ejecución de los scripts

Los archivos SQL están modularizados y deben ejecutarse en un orden para respetar las dependencias y claves foráneas. El orden de ejecución es el siguiente:

*   **`schema.sql`**: Define la estructura principal. Crea los tipos enumerados (`rol`, `estado_pedido`, `forma_pago`), las 5 tablas principales con sus restricciones y los índices de optimización.
*   **`objects.sql`**: Construye la lógica de negocio en la base de datos. Crea las vistas (`v_categorias_vigentes`, `v_productos_vigentes`, etc.), la función de cálculo de totales, los triggers para automatizar los subtotales, y el procedimiento almacenado `sp_crear_pedido`.
*   **`data.sql`**: Puebla la base de datos con información de prueba. Inserta datos semilla para categorías, productos, usuarios, pedidos y detalles de pedidos.
*   **`queries.sql`**: Contiene las sentencias de prueba de Historias de Usuario y las consultas analíticas.
*   **`transacciones.sql`**: Script de pruebas transaccionales (atomicidad, aislamiento y bloqueos).

### 2. Cómo reproducir las pruebas

El proyecto incluye dos archivos dedicados a probar el correcto funcionamiento del sistema.

#### A. Pruebas de Historias de Usuario y Analítica (`queries.sql`)
Este archivo se puede ejecutar de forma secuencial. Contiene:

*   **Épicas 1 a 4:** Operaciones CRUD (Crear, Leer, Actualizar, Borrar lógicamente) para Categorías, Productos, Usuarios y Pedidos.
*   **Consultas Analíticas:** Comandos para extraer métricas de negocio, como el Top 5 de productos más vendidos, facturación por mes y ranking de gastos de usuarios.

#### B. Pruebas de Concurrencia y Transacciones (`transacciones.sql`)
Para evaluar los principios ACID, este archivo requiere pasos específicos:

*   **Atomicidad y Transacciones Manuales (Puntos 1 y 2):** Pueden ejecutarse en una sola consola para verificar cómo el motor aborta operaciones inválidas (ej: cantidad 0 en un pedido).
*   **Aislamiento y Bloqueos (Puntos 3 y 4):** Para reproducir estos escenarios, es obligatorio abrir **dos terminales psql simultáneas** apuntando a la base `food_store`. Deberás ejecutar las sentencias marcadas como `TERMINAL 1` en la primera consola, y las de `TERMINAL 2` en la segunda para observar cómo se bloquean los registros (usando `FOR UPDATE`) y cómo actúan los niveles de aislamiento (`READ COMMITTED` y `SERIALIZABLE`).

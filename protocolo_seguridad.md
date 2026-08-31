# Protocolo de Seguridad para Manejo de Base de Datos e IA

### 1. Copia de Trabajo
Nunca se opera sobre la base principal o datos productivos. Se crea una base aislada para pruebas:
`createdb -T base_proyecto_db copia_trabajo_db`

### 2. Transacción de Prueba
Todo script generado o modificado se inspecciona primero en un entorno transaccional antes de confirmar cambios:
```sql
BEGIN;
-- Ejecución del script DDL / DML
SELECT * FROM tabla_afectada; -- Verificación visual del impacto
ROLLBACK; -- Se revierte para validar sin persistir
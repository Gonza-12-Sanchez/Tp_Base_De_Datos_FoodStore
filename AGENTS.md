# AGENTS.md

Database design project (PostgreSQL) for a Food Store. Pure SQL deliverables — one `food_store` database built and exercised through sequential `.sql` scripts. No app code, build system, or automated tests.

## Script execution order (FK/dependency-sensitive)
Run scripts in this exact order against the same `food_store` DB:
1. `schema.sql` — creates DB + enums, 5 tables, indexes.
2. `objects.sql` — views, `calcular_total_pedido()`, subtotal/total triggers, `sp_crear_pedido()` procedure.
3. `data.sql` — seed data.
4. `queries.sql` — user-story CRUD + analytic queries (sequential-safe, single console).
5. `transacciones.sql` — ACID demonstrations.

`schema.sql` starts with `CREATE DATABASE food_store;` — it must run against a server (e.g. `createdb`/psql), not inside an existing DB-connection transaction, or the rest of the file fails.

## Soft deletes are mandatory everywhere
Every table has `eliminado BOOLEAN NOT NULL DEFAULT FALSE`. All reads/updates must filter `eliminado = FALSE` on the affected rows — the views already do this, but raw SQL does not. "Delete" means flipping `eliminado = TRUE` (baja lógica), except `detalle_pedido.pedido_id` which uses `ON DELETE RESTRICT`.

## Runtime behavior (non-obvious)
- `sp_crear_pedido(usuario_id, forma_pago, items jsonb)` handles its own transaction scope: validates the user/products, locks each product row `FOR UPDATE` to prevent oversell, decrements stock, and rolls back everything on any failure. Calling it does not need a manual `BEGIN`.
- `fn_set_subtotal` trigger auto-freezes `precio_unitario` from the current product price when `NULL` and computes `subtotal`.
- Two statement-level `AFTER` triggers (`trg_total_ins`, `trg_total_upd`) recalc `pedido.total` via the `afectados` transition table. There is **no delete trigger** — deleting `detalle_pedido` rows does not refresh the inventory/order total.

## `transacciones.sql` — two-terminal requirement
- Sections 1–2 (atomicity, manual transactions) run in a single console.
- Sections 3–4 (isolation `READ COMMITTED`/`SERIALIZABLE` and `FOR UPDATE` locks) **require two simultaneous `psql` sessions** into `food_store`, stepping through the `TERMINAL 1` / `TERMINAL 2` markers in interleaved order. Running them as one file will deadlock or produce misleading results.

## Safety protocol
Per `protocolo_seguridad.md`: never operate on the "production" DB. Test against a copy: `createdb -T base_proyecto_db copia_trabajo_db`. Inspect generated/modified scripts inside `BEGIN; ... ROLLBACK;` before persisting.

## Gotchas
- `data.sql` inserts product/category rows using hardcoded IDs (assumes a clean DB built fresh from `schema.sql`). Re-running `schema.sql`/`data.sql` on a used DB causes uniqueness/duplicate errors.
- `seed user 'Juan' has mail 'juan@x.com' and `usuario.mail` is `UNIQUE` — a duplicate inserts will error.
- Seed `pedido.total` values start at 0 and are corrected by the last `UPDATE` in `data.sql`; they're also recomputed by the triggers once details are inserted.
- State is not versioned between scripts; each `queries.sql` example assumes the seed data from `data.sql` is present and untouched.

SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Session B, block 1: a separate database connection.
-- The row waits for session A, then returns 5 after A rolls back.
BEGIN;
SET LOCAL lock_timeout='30s';
SELECT inventory_id,quantity_available FROM inventory WHERE inventory_id=12 FOR UPDATE;

-- Session B, block 2: releases the lock, or clears a timed-out transaction.
ROLLBACK;

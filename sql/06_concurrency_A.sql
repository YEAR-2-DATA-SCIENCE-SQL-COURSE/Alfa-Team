SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Session A, block 1: inventory 12 initially contains 5 kg of onions.
-- This exercise isolates stock locking; it is not a complete invoice.
BEGIN;
SELECT inventory_id,quantity_available FROM inventory WHERE inventory_id=12 FOR UPDATE;
UPDATE inventory SET quantity_available=quantity_available-4 WHERE inventory_id=12;

-- Session A, block 2: executed after session B is waiting.
ROLLBACK;

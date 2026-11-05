SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Starting conditions for the two-purchase experiment.
-- Expected: stock 5; no previous RACE-A or RACE-B purchases.
SELECT inventory_id,quantity_available,selling_price
FROM inventory WHERE inventory_id=12;
SELECT request_key FROM sales WHERE request_key IN ('RACE-A','RACE-B');
SELECT customer_tin,points_balance FROM loyalty_accounts
WHERE loyalty_account_id IN (3,5) ORDER BY loyalty_account_id;

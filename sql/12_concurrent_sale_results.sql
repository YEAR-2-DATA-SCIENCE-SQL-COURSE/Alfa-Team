SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Expected stock: 1.000.
SELECT inventory_id,quantity_available FROM inventory WHERE inventory_id=12;

-- Expected: RACE-A only; total 3400.00; fee 85.00; earned points 3.
SELECT sa.request_key,sa.customer_tin,sa.total_amount,pt.commission_amount,lt.points
FROM sales sa JOIN platform_transactions pt USING(sale_id)
JOIN loyalty_transactions lt USING(sale_id)
WHERE sa.request_key IN ('RACE-A','RACE-B') AND lt.transaction_type='EARN';

-- Expected: 0; no failed invoice survives the rollback.
SELECT count(*) AS failed_purchase_rows FROM sales WHERE request_key='RACE-B';

-- Expected balances: TIN-1003 = 12; TIN-1005 = 10.
SELECT customer_tin,points_balance FROM loyalty_accounts
WHERE loyalty_account_id IN (3,5) ORDER BY loyalty_account_id;

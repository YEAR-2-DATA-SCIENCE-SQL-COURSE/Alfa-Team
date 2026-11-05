SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- A. Stored points and movement totals. Expected result: no rows.
SELECT la.loyalty_account_id,la.customer_tin,la.stall_id,la.points_balance,
 coalesce(sum(CASE WHEN lt.transaction_type='EARN' THEN lt.points ELSE -lt.points END),0) AS ledger_balance
FROM loyalty_accounts la LEFT JOIN loyalty_transactions lt USING(loyalty_account_id)
GROUP BY la.loyalty_account_id
HAVING la.points_balance<>coalesce(sum(CASE WHEN lt.transaction_type='EARN' THEN lt.points ELSE -lt.points END),0);

-- B. Completed invoice subtotal and line ownership.
SELECT sa.sale_id,sa.subtotal,coalesce(sum(si.line_total),0) AS item_total
FROM sales sa LEFT JOIN sale_items si USING(sale_id)
WHERE sa.status='COMPLETED' GROUP BY sa.sale_id
HAVING count(si.sale_item_id)=0 OR sa.subtotal<>coalesce(sum(si.line_total),0);
SELECT si.sale_item_id,sa.stall_id AS invoice_store,i.stall_id AS stock_store
FROM sale_items si JOIN sales sa USING(sale_id) JOIN inventory i USING(inventory_id)
WHERE sa.stall_id<>i.stall_id;

-- C. Missing/wrong fee basis and mismatched ledger ownership.
SELECT sa.sale_id FROM sales sa LEFT JOIN platform_transactions pt USING(sale_id)
WHERE sa.status='COMPLETED' AND (pt.sale_id IS NULL OR pt.commission_base<>sa.total_amount);
SELECT lt.loyalty_transaction_id FROM loyalty_transactions lt
JOIN sales sa USING(sale_id) JOIN loyalty_accounts la USING(loyalty_account_id)
WHERE sa.customer_tin<>la.customer_tin OR sa.stall_id<>la.stall_id;

-- D. Expected points and redeemed discount per completed invoice.
WITH points AS (
 SELECT sale_id,coalesce(sum(points) FILTER(WHERE transaction_type='EARN'),0) AS earned,
 coalesce(sum(points) FILTER(WHERE transaction_type='REDEEM'),0) AS redeemed
 FROM loyalty_transactions GROUP BY sale_id
)
SELECT sa.sale_id,sa.total_amount,sa.loyalty_discount,coalesce(p.earned,0) AS earned,
 coalesce(p.redeemed,0) AS redeemed
FROM sales sa LEFT JOIN points p USING(sale_id)
WHERE sa.status='COMPLETED' AND (coalesce(p.earned,0)<>floor(sa.total_amount/1000)
 OR coalesce(p.redeemed,0)*10::numeric<>sa.loyalty_discount);

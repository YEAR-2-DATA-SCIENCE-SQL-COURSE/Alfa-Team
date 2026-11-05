SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- 1. Stores with their owners
SELECT s.stall_id, s.stall_name, v.full_name AS vendor_name
FROM stalls AS s
JOIN vendors AS v ON v.vendor_id = s.vendor_id
ORDER BY s.stall_name;

-- 2. Product stock and low-stock status
SELECT s.stall_name, p.product_name, p.unit,
       i.quantity_available, i.selling_price,
       i.quantity_available <= i.reorder_level AS low_stock
FROM inventory AS i
JOIN stalls AS s ON s.stall_id = i.stall_id
JOIN products AS p ON p.product_id = i.product_id
ORDER BY s.stall_name, p.product_name;

-- 3. Invoice lines for one sale
SELECT si.sale_id, p.product_name, si.quantity,
       si.unit_price, si.line_total
FROM sale_items AS si
JOIN inventory AS i ON i.inventory_id = si.inventory_id
JOIN products AS p ON p.product_id = i.product_id
WHERE si.sale_id = 1;

-- 4. Customer balances by store
SELECT la.customer_tin, s.stall_name, la.points_balance
FROM loyalty_accounts AS la
JOIN stalls AS s ON s.stall_id = la.stall_id
ORDER BY la.customer_tin, s.stall_name;

-- 5. Daily completed sales in Kigali time
SELECT (sale_date AT TIME ZONE 'Africa/Kigali')::date AS business_day,
       stall_id, COUNT(*) AS number_of_sales,
       SUM(total_amount) AS sales_total
FROM sales
WHERE status = 'COMPLETED'
GROUP BY 1, 2
ORDER BY 1, 2;

-- 6. Outstanding platform fees per store
SELECT s.stall_name, SUM(pt.commission_amount) AS fees_due
FROM platform_transactions AS pt
JOIN sales AS sa ON sa.sale_id = pt.sale_id
JOIN stalls AS s ON s.stall_id = sa.stall_id
WHERE sa.status = 'COMPLETED'
  AND pt.settlement_status = 'UNPAID'
GROUP BY s.stall_id, s.stall_name
ORDER BY fees_due DESC;

-- 7. Check a points balance against its history
SELECT la.loyalty_account_id, la.points_balance,
       COALESCE(SUM(CASE
         WHEN lt.transaction_type = 'EARN' THEN lt.points
         ELSE -lt.points END), 0) AS ledger_balance
FROM loyalty_accounts AS la
LEFT JOIN loyalty_transactions AS lt ON lt.loyalty_account_id = la.loyalty_account_id
GROUP BY la.loyalty_account_id, la.points_balance
ORDER BY la.loyalty_account_id;

-- 8. Find points by TIN and store
SELECT customer_tin, stall_id, points_balance
FROM loyalty_accounts
WHERE customer_tin = 'TIN-1001' AND stall_id = 1;

-- 9. Purchase history directly by TIN
SELECT customer_tin, sale_id, stall_id, sale_date,
       total_amount, status
FROM sales
WHERE customer_tin = 'TIN-1001'
ORDER BY sale_date, sale_id;


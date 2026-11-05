SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Session B, block B1: competing purchase of 4 kg from the same stock.
-- The stock SELECT waits for A2, then sees 1 kg remaining.
-- The stock deduction fails its CHECK; invoice and other writes cannot commit.
BEGIN;

-- Stock and points locks remain held until the transaction ends.
SELECT * FROM inventory WHERE inventory_id=12 FOR UPDATE;
SELECT * FROM loyalty_accounts WHERE loyalty_account_id=5 FOR UPDATE;

-- A unique request key prevents a second execution of the same purchase.
INSERT INTO sales(stall_id,customer_tin,subtotal,loyalty_discount,total_amount,
                  payment_method,status,request_key)
SELECT 3,'TIN-1005',selling_price*4,0,selling_price*4,
       'CASH','COMPLETED','RACE-B'
FROM inventory WHERE inventory_id=12;

INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price)
SELECT sa.sale_id,12,4,i.selling_price
FROM sales sa CROSS JOIN inventory i
WHERE sa.request_key='RACE-B' AND i.inventory_id=12;

-- The nonnegative-stock constraint rejects insufficient inventory.
UPDATE inventory SET quantity_available=quantity_available-4,
                     updated_at=CURRENT_TIMESTAMP
WHERE inventory_id=12;

INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points)
SELECT 5,sale_id,'EARN',floor(total_amount/1000)::integer
FROM sales WHERE request_key='RACE-B' AND total_amount>=1000;

UPDATE loyalty_accounts SET points_balance=points_balance+
 (SELECT floor(total_amount/1000)::integer FROM sales WHERE request_key='RACE-B'),
 updated_at=CURRENT_TIMESTAMP WHERE loyalty_account_id=5;

INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,
                                  commission_amount,settlement_status)
SELECT sa.sale_id,sa.total_amount,s.commission_rate,
       round(sa.total_amount*s.commission_rate/100,2),'UNPAID'
FROM sales sa JOIN stalls s USING(stall_id) WHERE sa.request_key='RACE-B';

-- End of B1. The stock constraint error is expected.

-- Session B, block B2: clears the failed transaction and removes partial writes.
ROLLBACK;

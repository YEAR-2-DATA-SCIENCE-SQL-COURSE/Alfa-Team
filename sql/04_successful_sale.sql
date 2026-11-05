SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Fixed teaching example: 2 kg of rice from inventory 1, buyer TIN-1001.
-- Existing account: loyalty_account_id 1, store 1. No points redeemed.
-- One transaction records the invoice, stock, earned points and platform fee.
BEGIN;

-- Stock and points locks remain held until the transaction ends.
SELECT * FROM inventory WHERE inventory_id=1 FOR UPDATE;
SELECT * FROM loyalty_accounts WHERE loyalty_account_id=1 FOR UPDATE;

-- A unique request key prevents a second execution of the same purchase.
INSERT INTO sales(stall_id,customer_tin,subtotal,loyalty_discount,total_amount,
                  payment_method,status,request_key)
SELECT 1,'TIN-1001',selling_price*2,0,selling_price*2,
       'CASH','COMPLETED','SALE-013'
FROM inventory WHERE inventory_id=1;

INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price)
SELECT sa.sale_id,1,2,i.selling_price
FROM sales sa CROSS JOIN inventory i
WHERE sa.request_key='SALE-013' AND i.inventory_id=1;

-- The nonnegative-stock constraint rejects insufficient inventory.
UPDATE inventory SET quantity_available=quantity_available-2,
                     updated_at=CURRENT_TIMESTAMP
WHERE inventory_id=1;

INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points)
SELECT 1,sale_id,'EARN',floor(total_amount/1000)::integer
FROM sales WHERE request_key='SALE-013' AND total_amount>=1000;

UPDATE loyalty_accounts SET points_balance=points_balance+
 (SELECT floor(total_amount/1000)::integer FROM sales WHERE request_key='SALE-013'),
 updated_at=CURRENT_TIMESTAMP WHERE loyalty_account_id=1;

INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,
                                  commission_amount,settlement_status)
SELECT sa.sale_id,sa.total_amount,s.commission_rate,
       round(sa.total_amount*s.commission_rate/100,2),'UNPAID'
FROM sales sa JOIN stalls s USING(stall_id) WHERE sa.request_key='SALE-013';

COMMIT;

-- Completed purchase and its financial result.
SELECT sa.sale_id,sa.total_amount,pt.commission_amount
FROM sales sa JOIN platform_transactions pt USING(sale_id)
WHERE sa.request_key='SALE-013';

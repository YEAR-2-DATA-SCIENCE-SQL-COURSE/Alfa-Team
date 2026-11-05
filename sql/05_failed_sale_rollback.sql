SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Intentional failure after an invoice row has been inserted.
-- Block A: the stock CHECK rejects the oversized deduction.
BEGIN;
SELECT * FROM inventory WHERE inventory_id=1 FOR UPDATE;
INSERT INTO sales(stall_id,customer_tin,subtotal,loyalty_discount,total_amount,
                  payment_method,status,request_key)
VALUES(1,'TIN-1001',1200000,0,1200000,'CASH','PENDING','FAILED-SALE');
UPDATE inventory SET quantity_available=quantity_available-1000 WHERE inventory_id=1;

-- Block B: clears the failed transaction and removes the partial invoice.
ROLLBACK;
SELECT count(*) AS failed_invoices FROM sales WHERE request_key='FAILED-SALE';
SELECT quantity_available FROM inventory WHERE inventory_id=1;

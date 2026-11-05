SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Fictional teaching records; store names and prices are illustrative.
-- TIN-1001 etc. are fictional identifiers, not registered taxpayer numbers.
-- Opening inventory precedes the twelve recorded purchases.
BEGIN;
INSERT INTO vendors(full_name,phone,email) VALUES
('Aline Mukamana','CONTACT-001',NULL),
('Eric Niyonzima','CONTACT-002',NULL),
('Claudine Uwase','CONTACT-003',NULL);
INSERT INTO stalls(vendor_id,stall_code,stall_name,location,commission_rate,status) VALUES
(1,'A-12','Aline Food Store','Kimironko - Section A',2.00,'ACTIVE'),
(2,'B-03','Green Basket','Kimironko - Section B',1.50,'ACTIVE'),
(3,'C-07','Claudine Essentials','Kimironko - Section C',2.50,'ACTIVE');
INSERT INTO products(product_name,category,unit) VALUES
('Rice','Grains','kg'),('Beans','Grains','kg'),('Sugar','Groceries','kg'),
('Cooking oil','Groceries','bottle'),('Potatoes','Vegetables','kg'),
('Tomatoes','Vegetables','kg'),('Onions','Vegetables','kg'),('Soap','Household','bar');
INSERT INTO inventory(stall_id,product_id,quantity_available,selling_price,reorder_level,updated_at) VALUES
(1,1,80,1200,15,CURRENT_TIMESTAMP),
(1,2,60,1500,10,CURRENT_TIMESTAMP),
(1,3,30,2200,8,CURRENT_TIMESTAMP),
(1,4,24,3500,5,CURRENT_TIMESTAMP),
(2,1,50,1250,10,CURRENT_TIMESTAMP),
(2,5,100,700,20,CURRENT_TIMESTAMP),
(2,6,40,1000,8,CURRENT_TIMESTAMP),
(2,7,30,800,8,CURRENT_TIMESTAMP),
(3,2,40,1450,10,CURRENT_TIMESTAMP),
(3,4,20,3600,5,CURRENT_TIMESTAMP),
(3,8,45,600,10,CURRENT_TIMESTAMP),
(3,7,5,850,5,CURRENT_TIMESTAMP);

-- Zero opening points; balances are derived from recorded movements.
INSERT INTO loyalty_accounts(customer_tin,stall_id,points_balance,updated_at) VALUES
('TIN-1001',1,0,CURRENT_TIMESTAMP),
('TIN-1002',2,0,CURRENT_TIMESTAMP),
('TIN-1003',3,0,CURRENT_TIMESTAMP),
('TIN-1004',1,0,CURRENT_TIMESTAMP),
('TIN-1005',3,0,CURRENT_TIMESTAMP),
('TIN-1006',2,0,CURRENT_TIMESTAMP),
('TIN-1001',2,0,CURRENT_TIMESTAMP),
('TIN-1006',1,0,CURRENT_TIMESTAMP);

-- Purchase 1: TIN-1001, store 1.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(1,'TIN-1001','2026-10-18 10:30:00+02',9000,0,9000,'CASH','COMPLETED','SALE-001');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(1,1,5,1200),
(1,2,2,1500);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(1,1,'EARN',9,'2026-10-18 10:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(1,9000,2,180.00,'PAID','2026-10-18 10:30:00+02','2026-10-18 10:30:00+02');

-- Purchase 2: TIN-1002, store 2.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(2,'TIN-1002','2026-10-18 11:30:00+02',9000,0,9000,'MOBILE_MONEY','COMPLETED','SALE-002');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(2,6,10,700),
(2,7,2,1000);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(2,2,'EARN',9,'2026-10-18 11:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(2,9000,1.5,135.00,'PAID','2026-10-18 11:30:00+02','2026-10-18 11:30:00+02');

-- Purchase 3: TIN-1003, store 3.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(3,'TIN-1003','2026-10-19 12:30:00+02',7600,0,7600,'CASH','COMPLETED','SALE-003');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(3,9,4,1450),
(3,11,3,600);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(3,3,'EARN',7,'2026-10-19 12:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(3,7600,2.5,190.00,'PAID','2026-10-19 12:30:00+02','2026-10-19 12:30:00+02');

-- Purchase 4: TIN-1001, store 1.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(1,'TIN-1001','2026-10-19 13:30:00+02',7900,50,7850,'MOBILE_MONEY','COMPLETED','SALE-004');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(4,3,2,2200),
(4,4,1,3500);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(1,4,'REDEEM',5,'2026-10-19 13:30:00+02'),
(1,4,'EARN',7,'2026-10-19 13:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(4,7850,2,157.00,'PAID','2026-10-19 13:30:00+02','2026-10-19 13:30:00+02');

-- Purchase 5: TIN-1004, store 1.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(1,'TIN-1004','2026-10-20 14:30:00+02',5100,0,5100,'CARD','COMPLETED','SALE-005');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(5,1,3,1200),
(5,2,1,1500);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(4,5,'EARN',5,'2026-10-20 14:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(5,5100,2,102.00,'PAID','2026-10-20 14:30:00+02','2026-10-20 14:30:00+02');

-- Purchase 6: TIN-1002, store 2.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(2,'TIN-1002','2026-10-20 09:30:00+02',6600,40,6560,'CASH','COMPLETED','SALE-006');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(6,5,4,1250),
(6,8,2,800);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(2,6,'REDEEM',4,'2026-10-20 09:30:00+02'),
(2,6,'EARN',6,'2026-10-20 09:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(6,6560,1.5,98.40,'PAID','2026-10-20 09:30:00+02','2026-10-20 09:30:00+02');

-- Purchase 7: TIN-1005, store 3.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(3,'TIN-1005','2026-10-21 10:30:00+02',10200,0,10200,'MOBILE_MONEY','COMPLETED','SALE-007');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(7,10,2,3600),
(7,11,5,600);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(5,7,'EARN',10,'2026-10-21 10:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(7,10200,2.5,255.00,'UNPAID','2026-10-21 10:30:00+02',NULL);

-- Purchase 8: TIN-1006, store 2.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(2,'TIN-1006','2026-10-21 11:30:00+02',4500,0,4500,'CASH','COMPLETED','SALE-008');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(8,6,5,700),
(8,7,1,1000);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(6,8,'EARN',4,'2026-10-21 11:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(8,4500,1.5,67.50,'UNPAID','2026-10-21 11:30:00+02',NULL);

-- Purchase 9: TIN-1004, store 1.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(1,'TIN-1004','2026-10-22 12:30:00+02',4600,30,4570,'MOBILE_MONEY','COMPLETED','SALE-009');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(9,3,1,2200),
(9,1,2,1200);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(4,9,'REDEEM',3,'2026-10-22 12:30:00+02'),
(4,9,'EARN',4,'2026-10-22 12:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(9,4570,2,91.40,'UNPAID','2026-10-22 12:30:00+02',NULL);

-- Purchase 10: TIN-1003, store 3.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(3,'TIN-1003','2026-10-22 13:30:00+02',4100,20,4080,'CARD','COMPLETED','SALE-010');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(10,9,2,1450),
(10,11,2,600);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(3,10,'REDEEM',2,'2026-10-22 13:30:00+02'),
(3,10,'EARN',4,'2026-10-22 13:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(10,4080,2.5,102.00,'UNPAID','2026-10-22 13:30:00+02',NULL);

-- Purchase 11: TIN-1001, store 2.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(2,'TIN-1001','2026-10-23 14:30:00+02',3500,0,3500,'CASH','COMPLETED','SALE-011');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(11,5,2,1250),
(11,7,1,1000);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(7,11,'EARN',3,'2026-10-23 14:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(11,3500,1.5,52.50,'UNPAID','2026-10-23 14:30:00+02',NULL);

-- Purchase 12: TIN-1006, store 1.
INSERT INTO sales(stall_id,customer_tin,sale_date,subtotal,loyalty_discount,total_amount,payment_method,status,request_key) VALUES
(1,'TIN-1006','2026-10-23 09:30:00+02',4700,0,4700,'MOBILE_MONEY','COMPLETED','SALE-012');
INSERT INTO sale_items(sale_id,inventory_id,quantity,unit_price) VALUES
(12,1,1,1200),
(12,4,1,3500);
INSERT INTO loyalty_transactions(loyalty_account_id,sale_id,transaction_type,points,created_at) VALUES
(8,12,'EARN',4,'2026-10-23 09:30:00+02');
INSERT INTO platform_transactions(sale_id,commission_base,commission_rate,commission_amount,settlement_status,created_at,settled_at) VALUES
(12,4700,2,94.00,'UNPAID','2026-10-23 09:30:00+02',NULL);

-- Closing stock = opening stock - recorded sale quantities.
UPDATE inventory SET quantity_available=quantity_available-11 WHERE inventory_id=1;
UPDATE inventory SET quantity_available=quantity_available-3 WHERE inventory_id=2;
UPDATE inventory SET quantity_available=quantity_available-3 WHERE inventory_id=3;
UPDATE inventory SET quantity_available=quantity_available-2 WHERE inventory_id=4;
UPDATE inventory SET quantity_available=quantity_available-6 WHERE inventory_id=5;
UPDATE inventory SET quantity_available=quantity_available-15 WHERE inventory_id=6;
UPDATE inventory SET quantity_available=quantity_available-4 WHERE inventory_id=7;
UPDATE inventory SET quantity_available=quantity_available-2 WHERE inventory_id=8;
UPDATE inventory SET quantity_available=quantity_available-6 WHERE inventory_id=9;
UPDATE inventory SET quantity_available=quantity_available-2 WHERE inventory_id=10;
UPDATE inventory SET quantity_available=quantity_available-10 WHERE inventory_id=11;
UPDATE inventory SET quantity_available=quantity_available-0 WHERE inventory_id=12;

-- Closing points = earned points - redeemed points.
UPDATE loyalty_accounts SET points_balance=11 WHERE loyalty_account_id=1;
UPDATE loyalty_accounts SET points_balance=11 WHERE loyalty_account_id=2;
UPDATE loyalty_accounts SET points_balance=9 WHERE loyalty_account_id=3;
UPDATE loyalty_accounts SET points_balance=6 WHERE loyalty_account_id=4;
UPDATE loyalty_accounts SET points_balance=10 WHERE loyalty_account_id=5;
UPDATE loyalty_accounts SET points_balance=4 WHERE loyalty_account_id=6;
UPDATE loyalty_accounts SET points_balance=3 WHERE loyalty_account_id=7;
UPDATE loyalty_accounts SET points_balance=4 WHERE loyalty_account_id=8;
COMMIT;

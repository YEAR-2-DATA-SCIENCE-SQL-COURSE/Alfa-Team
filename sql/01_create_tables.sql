-- Tables and relationships from the agreed nine-table ERD.
-- One-time creation in an empty project database.
BEGIN;
SET search_path TO public;
SET TIME ZONE 'Africa/Kigali';

-- Time zone configuration for accurate timestamp storage
SET TIME ZONE 'Africa/Kigali';
-- 01. vendors
CREATE TABLE vendors (
    vendor_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(25) NOT NULL,
    email VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 02. stalls
CREATE TABLE stalls (
    stall_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendor_id BIGINT NOT NULL REFERENCES vendors(vendor_id),
    stall_code VARCHAR(30) UNIQUE NOT NULL,
    stall_name VARCHAR(150) NOT NULL,
    location VARCHAR(200) NOT NULL,
    commission_rate NUMERIC(5,2) NOT NULL CHECK (commission_rate BETWEEN 0 AND 100),
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 03. products
CREATE TABLE products (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    description VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE NOT NULL
);

-- 04. inventory
CREATE TABLE inventory (
    inventory_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stall_id BIGINT NOT NULL REFERENCES stalls(stall_id),
    product_id BIGINT NOT NULL REFERENCES products(product_id),
    quantity_available NUMERIC(12,3) NOT NULL CHECK (quantity_available >= 0),
    selling_price NUMERIC(14,2) NOT NULL CHECK (selling_price >= 0),
    reorder_level NUMERIC(12,3) NOT NULL CHECK (reorder_level >= 0),
    updated_at TIMESTAMPTZ NOT NULL,
    UNIQUE (stall_id, product_id)
);

-- 05. loyalty_accounts
CREATE TABLE loyalty_accounts (
    loyalty_account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_tin VARCHAR(30) NOT NULL CHECK (customer_tin = BTRIM(customer_tin) AND customer_tin <> ''),
    stall_id BIGINT NOT NULL REFERENCES stalls(stall_id),
    points_balance INTEGER DEFAULT 0 NOT NULL CHECK (points_balance >= 0),
    updated_at TIMESTAMPTZ NOT NULL,
    UNIQUE (customer_tin, stall_id)
);

-- 06. sales
CREATE TABLE sales (
    sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stall_id BIGINT NOT NULL REFERENCES stalls(stall_id),
    customer_tin VARCHAR(30) NOT NULL CHECK (customer_tin = BTRIM(customer_tin) AND customer_tin <> ''),
    sale_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    subtotal NUMERIC(14,2) NOT NULL CHECK (subtotal >= 0),
    loyalty_discount NUMERIC(14,2) DEFAULT 0 NOT NULL CHECK (loyalty_discount BETWEEN 0 AND subtotal),
    total_amount NUMERIC(14,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('CASH', 'MOBILE_MONEY', 'CARD')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'COMPLETED', 'CANCELLED')),
    request_key VARCHAR(100) UNIQUE NOT NULL,
    CHECK (total_amount = subtotal - loyalty_discount)
);

-- Purchase history index
CREATE INDEX idx_sales_customer_tin_date ON sales(customer_tin, sale_date);
-- 07. sale_items
CREATE TABLE sale_items (
    sale_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id BIGINT NOT NULL REFERENCES sales(sale_id),
    inventory_id BIGINT NOT NULL REFERENCES inventory(inventory_id),
    quantity NUMERIC(12,3) NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
    line_total NUMERIC(14,2) GENERATED ALWAYS AS (ROUND(quantity * unit_price, 2)) STORED
);

-- 08. loyalty_transactions
CREATE TABLE loyalty_transactions (
    loyalty_transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loyalty_account_id BIGINT NOT NULL REFERENCES loyalty_accounts(loyalty_account_id),
    sale_id BIGINT NOT NULL REFERENCES sales(sale_id),
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('EARN', 'REDEEM')),
    points INTEGER NOT NULL CHECK (points > 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (sale_id, transaction_type)
);

-- 09. platform_transactions
CREATE TABLE platform_transactions (
    platform_transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id BIGINT UNIQUE NOT NULL REFERENCES sales(sale_id),
    commission_base NUMERIC(14,2) NOT NULL CHECK (commission_base >= 0),
    commission_rate NUMERIC(5,2) NOT NULL CHECK (commission_rate BETWEEN 0 AND 100),
    commission_amount NUMERIC(14,2) NOT NULL,
    settlement_status VARCHAR(20) NOT NULL CHECK (settlement_status IN ('UNPAID', 'PAID')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settled_at TIMESTAMPTZ,
    CHECK (commission_amount = ROUND(commission_base * commission_rate / 100, 2))
);
ALTER TABLE platform_transactions ADD CONSTRAINT settlement_consistent
CHECK ((settlement_status = 'PAID' AND settled_at IS NOT NULL)
    OR (settlement_status = 'UNPAID' AND settled_at IS NULL));
CREATE INDEX ON sales(stall_id, sale_date) WHERE status = 'COMPLETED';
CREATE INDEX ON sale_items(sale_id);
CREATE INDEX ON sale_items(inventory_id);
CREATE INDEX ON loyalty_transactions(loyalty_account_id);
COMMIT;

# Kigali Market Vendors Inventory

**ALFA TEAM | Transactions and Concurrency**  
**Kigali Independent University (ULK)**  
**Instructor:** Eric Maniraguha  
**Implementation:** PostgreSQL 18 and pgAdmin 4

This project demonstrates reliable market sales through SQL transactions, row-level locking, stock constraints, TIN-based loyalty and platform commission records. The practical evidence includes **all 24 execution screenshots**, displayed directly below with explanations.

## 1. Project Title

**Kigali Market Vendors Inventory**  
Assigned subject: **Transactions and Concurrency**

## 2. Group Members

| Member | Student ID | Team role |
|---|---|---|
| Abdulrahman Suliman | 202510853 | Project/database design and final review |
| Mohamed Omer | 202513481 | **Team Leader**; SQL and execution evidence |
| Abdalrhim Ahmed Elnor | 202513366 | Presentation and GitHub submission |
| Moayed Elrashid | 202512280 | README documentation |
| Amar Ahmed Alduom | 202512897 | Project/member|
| Amin Ali| 202512480 | Project/member |

The instructor approved the four-member team. All members participated in research and study. Individual contributions are detailed in Section 16.

## 3. Introduction

Market stores manage products, available stock and daily purchases. A purchase can also affect loyalty points and the fee owed for using a shared inventory system. These related changes must remain consistent when a sale fails or when two operators attempt to sell the same stock.

The project uses a small, understandable dataset and an existing nine-table design. Buyers are identified directly by `customer_tin` on their purchases. No buyer names, phone numbers or email addresses are collected. Vendor contact fields describe store owners, not buyers.

## 4. Problem Statement

A sale recorded separately from its stock deduction can leave an invoice without the corresponding inventory change. Similar partial updates can affect loyalty balances or platform commissions. Concurrent operators may also attempt to sell more stock than exists.

The central question is: **How can a sale update its invoice, inventory, loyalty and platform fee together, while preventing conflicting sales from overselling the same stock?**

## 5. Objectives

- Implement the agreed stores, vendors, products and sales database.
- Link purchases and store-specific loyalty balances directly through buyer TINs.
- Demonstrate a complete sale using `BEGIN` and `COMMIT`.
- Demonstrate rollback after a stock constraint failure.
- Show two independent sessions competing for the same stock row.
- Verify invoice totals, points balances and the absence of a failed purchase.
- Document reproducible SQL and its execution evidence.

## 6. Research and Key Concepts

### Transactions and ACID

A transaction groups related writes into one unit. In this project, a successful checkout commits its invoice, items, stock deduction, points and fee together. A failed transaction is rolled back. [PostgreSQL: Transactions](https://www.postgresql.org/docs/18/tutorial-transactions.html)

| Property | Application in this project |
|---|---|
| Atomicity | A failed sale leaves no partially committed invoice or stock change. |
| Consistency | Constraints and integrity checks protect stock, points and invoice relationships. |
| Isolation | Conflicting stock access is coordinated with row locks between sessions. |
| Durability | Successful COMMIT records the sale persistently; a crash-recovery test is outside this demonstration. |

### Row locks and concurrent access

`SELECT ... FOR UPDATE` locks the chosen stock row until the transaction ends. A competing writer/locking reader waits. Ordinary reads are not generally blocked by this row lock. The demonstration uses waiting, then a stock CHECK failure, to prevent the second purchase from committing. [PostgreSQL: Explicit Locking](https://www.postgresql.org/docs/18/explicit-locking.html)

### Keys, constraints and checks

Primary keys identify records; foreign keys link related tables. UNIQUE constraints protect request keys and store-specific loyalty accounts. CHECK constraints reject negative stock and invalid values. Cross-table totals and ownership need additional controlled logic or audit queries; basic foreign keys alone do not enforce all business rules. [PostgreSQL: Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)

### Project business rules

| Rule | Definition |
|---|---|
| Buyer identity | Required `customer_tin` on every sale; repeated TINs are expected. |
| Loyalty account | One account for each `(customer_tin, stall_id)` pair. |
| Points earned | `FLOOR(total_amount / 1000)` points. |
| Redemption | Each redeemed point gives a 10 RWF discount. |
| Invoice total | `subtotal - loyalty_discount`. |
| Platform commission | Final sale amount multiplied by the captured percentage, rounded to two decimals. |
| Historical price | The unit price at sale time is stored in `sale_items`. |

These rates and the sample records are fictional educational choices, not verified market prices or tax rules. TIN-1001 through TIN-1006 are fictional identifiers.

## 7. Technical Approach

SQL scripts run in the `public` schema of a dedicated PostgreSQL database. pgAdmin provides the query editor and two independent connections for the concurrency experiment. Draw.io contains the editable database design, while Markdown provides the project documentation.

```text
ALFA_TEAM_Kigali_Market/
├── README.md
├── sql/              # schema, reports and transaction experiments
├── sample-data/      # small SQL dataset
├── diagrams/         # original editable ERD
└── screenshots/      # all 24 execution images
```

### Execution order

1. Create an empty project database and open Query Tool.
2. Run [01_create_tables.sql](sql/01_create_tables.sql) once.
3. Run [02_sample_data.sql](sample-data/02_sample_data.sql) once.
4. Run each report in [03_reports.sql](sql/03_reports.sql) separately.
5. Run [04_successful_sale.sql](sql/04_successful_sale.sql) once.
6. Run block A of [05_failed_sale_rollback.sql](sql/05_failed_sale_rollback.sql); its error is intentional. Run block B separately to clear the failed transaction with ROLLBACK.
7. Run the complete concurrent-sale experiment in files 09-12 using the schedule in Section 10.
8. Run [08_data_checks.sql](sql/08_data_checks.sql); inconsistency queries should return no rows.

Files 06 and 07 provide an optional, stock-only locking exercise. They roll back their changes. Schema and seed scripts are one-time setup, not scripts to repeatedly run on populated tables. Identity sequences can have gaps after a rollback.

## 8. Database Design and Diagrams

[Open/download the original editable ERD](diagrams/Kigali_Market_Database_ERD.drawio). The original nine-table diagram is included unchanged.

The following relationship overview renders directly on GitHub:

```mermaid
erDiagram
    vendors ||--o{ stalls : owns
    stalls ||--o{ inventory : stocks
    products ||--o{ inventory : appears_in
    stalls ||--o{ loyalty_accounts : maintains
    stalls ||--o{ sales : records
    sales ||--o{ sale_items : contains
    inventory ||--o{ sale_items : supplies
    loyalty_accounts ||--o{ loyalty_transactions : records
    sales ||--o{ loyalty_transactions : generates
    sales ||--o| platform_transactions : incurs
```

Completed sales must contain items and one platform fee under the demonstrated business flow. The diagram shows the general structural cardinalities: pending records need not already contain these children. There is no customers table or customer foreign key. Loyalty movements connect a sale and its account; their TIN and store must agree.

| Table | Purpose |
|---|---|
| vendors | Store owner information |
| stalls | Store identity, owner and current platform fee rate |
| products | Product catalogue and sale units |
| inventory | Quantity and current price of each product in each store |
| loyalty_accounts | Points balance for one TIN at one store |
| sales | Purchase header, TIN, totals, status and request key |
| sale_items | Invoice products, quantities and historical prices |
| loyalty_transactions | Points earned or redeemed for purchases |
| platform_transactions | Captured platform fee and settlement status |

### Column reference

`PK` = primary key; `FK` = foreign key; `UQ` = unique. Columns are required unless marked NULL. Identity keys are generated by PostgreSQL. SQL uses `NUMERIC` for diagram `DECIMAL` and `TIMESTAMPTZ` for stored timestamps.

#### `vendors`

| Column | Type | Key / optionality |
|---|---|---|
| `vendor_id` | `BIGINT` | PK |
| `full_name` | `VARCHAR(150)` | Required |
| `phone` | `VARCHAR(25)` | Required |
| `email` | `VARCHAR(150)` | NULL |
| `created_at` | `TIMESTAMPTZ` | Required |

#### `stalls`

| Column | Type | Key / optionality |
|---|---|---|
| `stall_id` | `BIGINT` | PK |
| `vendor_id` | `BIGINT` | FK |
| `stall_code` | `VARCHAR(30)` | UQ |
| `stall_name` | `VARCHAR(150)` | Required |
| `location` | `VARCHAR(200)` | Required |
| `commission_rate` | `NUMERIC(5,2)` | Required |
| `status` | `VARCHAR(20)` | Required |
| `created_at` | `TIMESTAMPTZ` | Required |

#### `products`

| Column | Type | Key / optionality |
|---|---|---|
| `product_id` | `BIGINT` | PK |
| `product_name` | `VARCHAR(150)` | Required |
| `category` | `VARCHAR(100)` | Required |
| `unit` | `VARCHAR(30)` | Required |
| `description` | `VARCHAR(500)` | NULL |
| `is_active` | `BOOLEAN` | Required |

#### `inventory`

| Column | Type | Key / optionality |
|---|---|---|
| `inventory_id` | `BIGINT` | PK |
| `stall_id` | `BIGINT` | FK |
| `product_id` | `BIGINT` | FK |
| `quantity_available` | `NUMERIC(12,3)` | Required |
| `selling_price` | `NUMERIC(14,2)` | Required |
| `reorder_level` | `NUMERIC(12,3)` | Required |
| `updated_at` | `TIMESTAMPTZ` | Required |

#### `loyalty_accounts`

| Column | Type | Key / optionality |
|---|---|---|
| `loyalty_account_id` | `BIGINT` | PK |
| `customer_tin` | `VARCHAR(30)` | NOT NULL |
| `stall_id` | `BIGINT` | FK |
| `points_balance` | `INTEGER` | Required |
| `updated_at` | `TIMESTAMPTZ` | Required |

#### `sales`

| Column | Type | Key / optionality |
|---|---|---|
| `sale_id` | `BIGINT` | PK |
| `stall_id` | `BIGINT` | FK |
| `customer_tin` | `VARCHAR(30)` | NOT NULL |
| `sale_date` | `TIMESTAMPTZ` | Required |
| `subtotal` | `NUMERIC(14,2)` | Required |
| `loyalty_discount` | `NUMERIC(14,2)` | Required |
| `total_amount` | `NUMERIC(14,2)` | Required |
| `payment_method` | `VARCHAR(30)` | Required |
| `status` | `VARCHAR(20)` | Required |
| `request_key` | `VARCHAR(100)` | UQ |

#### `sale_items`

| Column | Type | Key / optionality |
|---|---|---|
| `sale_item_id` | `BIGINT` | PK |
| `sale_id` | `BIGINT` | FK |
| `inventory_id` | `BIGINT` | FK |
| `quantity` | `NUMERIC(12,3)` | Required |
| `unit_price` | `NUMERIC(14,2)` | Required |
| `line_total` | `NUMERIC(14,2)` | Required |

#### `loyalty_transactions`

| Column | Type | Key / optionality |
|---|---|---|
| `loyalty_transaction_id` | `BIGINT` | PK |
| `loyalty_account_id` | `BIGINT` | FK |
| `sale_id` | `BIGINT` | FK |
| `transaction_type` | `VARCHAR(20)` | Required |
| `points` | `INTEGER` | Required |
| `created_at` | `TIMESTAMPTZ` | Required |

#### `platform_transactions`

| Column | Type | Key / optionality |
|---|---|---|
| `platform_transaction_id` | `BIGINT` | PK |
| `sale_id` | `BIGINT` | FK, UQ |
| `commission_base` | `NUMERIC(14,2)` | Required |
| `commission_rate` | `NUMERIC(5,2)` | Required |
| `commission_amount` | `NUMERIC(14,2)` | Required |
| `settlement_status` | `VARCHAR(20)` | Required |
| `created_at` | `TIMESTAMPTZ` | Required |
| `settled_at` | `TIMESTAMPTZ` | NULL |

Composite uniqueness rules: `inventory(stall_id, product_id)`, `loyalty_accounts(customer_tin, stall_id)` and `loyalty_transactions(sale_id, transaction_type)`. Sale TINs are not globally unique: one buyer can purchase repeatedly. The fee table allows at most one fee record per sale.

## 9. SQL Implementation

| Script | Implementation |
|---|---|
| [01_create_tables.sql](sql/01_create_tables.sql) | Nine tables, primary/foreign keys, constraints and indexes |
| [02_sample_data.sql](sample-data/02_sample_data.sql) | Historical sample purchases, closing stock, points and fees |
| [03_reports.sql](sql/03_reports.sql) | Nine reports for stores, inventory, invoices, daily sales, TINs and loyalty |
| [04_successful_sale.sql](sql/04_successful_sale.sql) | Complete committed sale including stock, points and commission |
| [05_failed_sale_rollback.sql](sql/05_failed_sale_rollback.sql) | Intentional stock failure followed by rollback |
| [06_concurrency_A.sql](sql/06_concurrency_A.sql) | Optional stock-only locking session A |
| [07_concurrency_B.sql](sql/07_concurrency_B.sql) | Optional stock-only locking session B |
| [08_data_checks.sql](sql/08_data_checks.sql) | Audit queries for points, invoices, ownership and fee consistency |
| [09_concurrent_sale_precheck.sql](sql/09_concurrent_sale_precheck.sql) | Initial stock, request-key and account checks |
| [10_concurrent_sale_A.sql](sql/10_concurrent_sale_A.sql) | First complete purchase, held open until explicit COMMIT |
| [11_concurrent_sale_B.sql](sql/11_concurrent_sale_B.sql) | Competing purchase, stock constraint failure and ROLLBACK |
| [12_concurrent_sale_results.sql](sql/12_concurrent_sale_results.sql) | Remaining stock, successful sale, absent failed sale and account balances |

The successful-sale example uses fixed existing records to keep the SQL readable. It is not a general checkout API. Stock and account rows are locked before modification. `request_key` is unique, so rerunning the same completed example cannot record a second copy. An error aborts the transaction; a separate ROLLBACK clears it.

```sql
BEGIN;
SELECT * FROM inventory WHERE inventory_id = 12 FOR UPDATE;
-- Related invoice, item, stock, loyalty and commission writes.
COMMIT;
```

This excerpt illustrates the transaction boundary; the linked files contain the complete executable statements.

## 10. Practical Demonstration and Results

### Dataset and experiment summary

The seed contains 12 completed sales and 24 lines over six days. SALE-013 adds one successful purchase. RACE-A adds a second successful purchase, while FAILED-SALE and RACE-B must not persist. Reports captured before these experiments naturally show earlier balances and counts than the final checks.

| Experiment | Observed result |
|---|---|
| Successful sale | 2,400 RWF sale, 48 RWF fee, stock 69 → 67, points 11 → 13 |
| Failed sale | Stock constraint error followed by rollback |
| Concurrent purchases | Two requests for 4 kg from 5 kg; A commits, B waits then fails |
| Final concurrent stock | 1 kg |
| Concurrent fee and points | RACE-A: 85 RWF fee and 3 earned points |
| Failed concurrent invoice | RACE-B count = 0 |
| Final loyalty audit | Zero mismatched accounts |
| Final invoice audit | Zero missing-item or subtotal discrepancies |

### Reproducing the two-session experiment

| Step | Session A | Session B |
|---|---|---|
| 1 | Precheck: inventory 12 contains 5 kg, and RACE-A/RACE-B do not exist | Separate Query Tool connection |
| 2 | Run A1 in file 10; exclude COMMIT | — |
| 3 | Keep the transaction open | Run B1 in file 11; exclude ROLLBACK; waits on the stock lock |
| 4 | Execute COMMIT only | Continues after A commits |
| 5 | Sale is committed | Deduction would make stock -3; CHECK rejects it |
| 6 | — | Execute ROLLBACK separately |
| 7 | Run file 12 and the integrity checks after both sessions finish | — |

The negative value in the error is a rejected proposed row, not stored inventory. This experiment combines row locking with a nonnegative-stock CHECK; the lock alone does not decide whether the requested quantity is affordable.

### Execution evidence: all 24 screenshots

#### Figure 01. Database creation

The nine tables are created in PostgreSQL. The table list and successful schema execution document the implementation of the agreed design.

![Figure 01: Database creation](screenshots/01_database_tables.png)

#### Figure 02. Initial sample data

The initial dataset contains 3 vendors, 3 stores, 8 products, 12 inventory records, 8 loyalty accounts, 12 sales, 24 sale items, 16 points movements and 12 platform fee records. Six distinct buyer TINs are used.

![Figure 02: Initial sample data](screenshots/02_sample_data_counts.png)

#### Figure 03. Stores and their owners

A join between stalls and vendors associates each store with its owner. The three stores are Aline Food Store, Green Basket and Claudine Essentials.

![Figure 03: Stores and their owners](screenshots/03_stores_and_owners.png)

#### Figure 04. Inventory and low-stock status

The inventory report combines store, product, unit, available quantity and price. The low-stock flag compares the remaining quantity with the reorder level.

![Figure 04: Inventory and low-stock status](screenshots/04_inventory_status.png)

#### Figure 05. Invoice details

The invoice-line report retrieves quantities, historical unit prices and line totals for sale 1. Line prices come from sale_items, so later stock-price changes do not rewrite the invoice.

![Figure 05: Invoice details](screenshots/05_invoice_details.png)

#### Figure 06. Loyalty balances by store

The report lists TIN-based loyalty accounts by store. A buyer may have multiple store-specific balances; there is no customer-profile table.

![Figure 06: Loyalty balances by store](screenshots/06_loyalty_balances.png)

#### Figure 07. Daily completed sales

Completed purchases are grouped by business day in Africa/Kigali and by store. Only completed sales contribute to these totals.

![Figure 07: Daily completed sales](screenshots/07_daily_sales.png)

#### Figure 08. Outstanding platform fees

The report groups unpaid platform commissions by store. A platform fee is income owed to the system provider, distinct from the store's sales revenue.

![Figure 08: Outstanding platform fees](screenshots/08_unpaid_platform_fees.png)

#### Figure 09. Loyalty balance reconciliation

Stored points are compared with earned points minus redeemed points. Matching columns provide a direct check of the account balances against their movement history.

![Figure 09: Loyalty balance reconciliation](screenshots/09_loyalty_reconciliation.png)

#### Figure 10. Points lookup by TIN

The query locates TIN-1001's balance in store 1 without requiring a buyer name, phone number or email address.

![Figure 10: Points lookup by TIN](screenshots/10_points_by_tin.png)

#### Figure 11. Purchase history by TIN

Purchases are retrieved directly from sales.customer_tin and ordered by purchase time and sale ID. The same TIN may appear on multiple invoices.

![Figure 11: Purchase history by TIN](screenshots/11_purchase_history.png)

#### Figure 12. Successful atomic sale

SALE-013 records a 2 kg rice purchase for 2,400 RWF. The platform fee is 48 RWF at the store's 2% rate. COMMIT completes the related sale changes.

![Figure 12: Successful atomic sale](screenshots/12_successful_sale.png)

#### Figure 13. Stock and points after the successful sale

Rice stock falls from 69 to 67 kg, while the buyer's store-specific points increase from 11 to 13. These changes belong to the same transaction as SALE-013.

![Figure 13: Stock and points after the successful sale](screenshots/13_sale_stock_and_points.png)

#### Figure 14. Insufficient-stock failure

A pending invoice is inserted before an intentionally oversized stock deduction. The nonnegative-stock CHECK rejects the deduction and aborts the transaction.

![Figure 14: Insufficient-stock failure](screenshots/14_insufficient_stock_error.png)

#### Figure 15. Rollback after failure

ROLLBACK ends the failed transaction and removes its uncommitted changes. This screenshot records the rollback operation; the later final invoice check supplements the transaction evidence.

![Figure 15: Rollback after failure](screenshots/15_rollback_result.png)

#### Figure 16. Concurrent-sale starting stock

Inventory record 12 begins with 5 kg of onions priced at 850 RWF per kg. Both competing purchases request 4 kg.

![Figure 16: Concurrent-sale starting stock](screenshots/16_concurrency_initial_stock.png)

#### Figure 17. Second transaction waiting

Session A holds the inventory row lock while its purchase is uncommitted. Session B remains waiting at the conflicting SELECT FOR UPDATE.

![Figure 17: Second transaction waiting](screenshots/17_second_sale_waiting.png)

#### Figure 18. Second purchase rejected

Session A commits. Session B resumes and attempts to deduct 4 kg from the remaining 1 kg. The CHECK rejects the proposed -3 kg value; that negative value is not stored. Session B is subsequently rolled back.

![Figure 18: Second purchase rejected](screenshots/18_second_sale_rejected.png)

#### Figure 19. Final stock after concurrent purchases

The remaining stock is 1 kg. Only the first purchase consumed inventory.

![Figure 19: Final stock after concurrent purchases](screenshots/19_concurrency_remaining_stock.png)

#### Figure 20. Completed purchase, fee and points

The result contains RACE-A only: TIN-1003 paid 3,400 RWF, the platform fee is 85 RWF, and the purchase earned 3 points.

![Figure 20: Completed purchase, fee and points](screenshots/20_concurrency_completed_sale.png)

#### Figure 21. Failed purchase absent

The count of sales with request_key RACE-B is zero. No partial invoice from the rejected second purchase remains.

![Figure 21: Failed purchase absent](screenshots/21_concurrency_failed_sale_absent.png)

#### Figure 22. Loyalty balances after concurrency

TIN-1003 has 12 points, reflecting the successful purchase. TIN-1005 remains at 10 points because the second purchase was rolled back.

![Figure 22: Loyalty balances after concurrency](screenshots/22_concurrency_loyalty_balances.png)

#### Figure 23. Final loyalty integrity check

The query returns zero rows. No stored loyalty balance differs from the sum of its recorded earning and redemption movements.

![Figure 23: Final loyalty integrity check](screenshots/23_final_loyalty_check.png)

#### Figure 24. Final invoice integrity check

The query returns zero rows. Every completed invoice has at least one item and its subtotal matches the sum of its line totals.

![Figure 24: Final invoice integrity check](screenshots/24_final_invoice_check.png)

## 11. Real-World Applications

- Market operators can coordinate checkout against a shared stock record.
- Store owners can review daily sales and low-stock products.
- Buyers can earn and redeem store-specific points through an identifier on purchases.
- System providers can record commissions owed and distinguish paid from unpaid fees.
- Reconciliation queries can identify inconsistent records before reporting.

This is a classroom implementation of these use cases, not an operational tax, payment-processing or inventory deployment.

## 12. Challenges and Recommendations

| Challenge encountered | Resolution or recommendation |
|---|---|
| An earlier error leaves a transaction aborted | Inspect the original error and execute ROLLBACK before new commands. |
| A locking script commits or rolls back too quickly to show waiting | Execute the marked blocks separately in independent connections. |
| Repeating seed or demonstration scripts | Use a clean test database for a new full run; retain unique request keys. |
| Keeping points consistent | Record movements and balance changes together; verify balances against the ledger. |
| Different screenshots show different counts | Interpret each screenshot at its execution stage, before or after the added sales. |
| Simple constraints cannot enforce every cross-table rule | Use controlled transaction scripts and the supplied audits; add reusable validation routines in an extended version. |

The present examples use fixed IDs and known input data. They do not validate arbitrary checkout requests, enforce all cross-table invariants against unrestricted manual writes, or configure application-user permissions. Durability is described conceptually rather than demonstrated by forcing a server crash. The practical concurrency test covers row locking, not a comparison of every isolation level.

## 13. Future Improvements

- A parameterized checkout procedure with quantity and ownership validation.
- A dedicated application role with controlled write permissions.
- Supplier purchases and stock movement history.
- Refunds with corresponding stock, points and commission reversals.
- Additional concurrency tests for isolation levels and deadlock handling.
- A simple user interface and expanded realistic synthetic data after the core rules are secured.

## 14. References

1. PostgreSQL Global Development Group. [PostgreSQL 18: Transactions](https://www.postgresql.org/docs/18/tutorial-transactions.html).
2. PostgreSQL Global Development Group. [PostgreSQL 18: Explicit Locking](https://www.postgresql.org/docs/18/explicit-locking.html).
3. PostgreSQL Global Development Group. [PostgreSQL 18: Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html).
4. Eric Maniraguha. *SQL Database Group Project Assignment*, Kigali Independent University (ULK), released 15 October 2026. Course assignment brief.

Execution screenshots are the team's project evidence. The sample data is fictional and has no external market-data source.

## 15. Presentation Link

**Google Drive presentation link: pending addition.**

Presentation responsibility: **Abdalrhim Ahmed Elnor**. The shareable view link belongs here when available. The presentation file is hosted on Google Drive rather than included in this GitHub folder. Viewer access must be tested before submission.

**GitHub repository URL: pending addition.**

## 16. Group Contributions

The following contributions were reported by ALFA TEAM:

| Member | Student ID | Contributions |
|---|---|---|
| All four members | — | Joint research and study of the project topic |
| Abdulrahman Suliman | 202510853 | Project design, database design, ERD preparation and final review |
| Mohamed Omer — Team Leader | 202513481 | SQL queries and execution screenshots |
| Moayed Elrashid | 202512280 | README documentation |
| Abdalrhim Ahmed Elnor | 202513366 | Project presentation (PowerPoint) and GitHub submission |

The instructor approved the four-member group. Presentation and repository URLs remain to be inserted in Section 15; this document does not use the assigned submission role as proof that a particular upload or form submission has been completed.

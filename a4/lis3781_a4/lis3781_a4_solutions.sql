-- MS SQL Server

/* 
NOTES: Tables *must* include the following constraints and defaults:
*    per_ssn: must be unique (see indexes/keys), and SHA2_512 hashed
*    per_gender: m or f
*    per_type: c or s
Example: ([per_gender]='f' OR [per_gender]='m')
*    state: default = FL
*    zip: require entries in zip column to be 9 digits
Example: ([per_zip] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
*    phone num: require entries in phone column to be 10 digits
Example: ([phn_num] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] [0-9]')
*    phone type: home, cell, work, fax
Example: ([phn_type]='f' OR [phn_type]='w' OR [phn_type]='c' OR [phn_type]='h')
*    *all* numeric values: >= 0
Example: ([srp_yr_sales_goal] >= (0))

FK: Must require ON DELETE CASCADE, ON UPDATE CASCADE

Question: Why use dbo.?
Answer:
From my research, even if the SQL code doesn't have to use the fully qualified name (e.g., dbo.customer),
evidently, there is a slight performance gain in doing so, because the optimizer doesn't have to look up the schema.
And, it is considered a best practice.
http://www.sqlteam.com/article/understanding-the-difference-between-owners-and-schemas-in-sql-server
*/

-- (not the same, but) similar to SHOW WARNINGS;
SET ANSI_WARNINGS ON;
GO

-- avoids error that user kept db connection open
use master;
GO

-- drop existing database if it exists (use *your* username)
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'csp21b')
DROP DATABASE csp21b;
GO

-- create database if not exists (use *your* username)
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'csp21b')
CREATE DATABASE csp21b;
GO

use csp21b;
GO

-- ***BE SURE*** to create/populate tables in correct order--parent tables then child tables!

-- drop table if exists
-- N=subsequent string may be in Unicode (makes it portable to use with Unicode characters)
-- U=only look for objects with this name that are tables
-- *be sure* to use dbo. before *all* table references


-- -----------------------------------------
-- Table person
-- -----------------------------------------
IF OBJECT_ID (N'dbo.person', N'U') IS NOT NULL
DROP TABLE dbo.person;
GO

CREATE TABLE dbo.person
(
  per_id SMALLINT not null identity(1,1),
  per_ssn binary(64) NULL,
  per_fname VARCHAR(15) NOT NULL,
  per_lname VARCHAR(30) NOT NULL,
  per_gender CHAR(1) NOT NULL CHECK (per_gender IN('m', 'f')),
  per_dob DATE NOT NULL,
  per_street VARCHAR(30) NOT NULL,
  per_city VARCHAR(30) NOT NULL,
  per_state CHAR(2) NOT NULL DEFAULT 'FL',
  per_zip int NOT NULL check (per_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  per_email VARCHAR(100) NULL,
  per_type CHAR(1) NOT NULL CHECK (per_type IN('c', 's')),
  per_notes VARCHAR(45) NULL,
  PRIMARY KEY (per_id),
  
  -- make sure SSNs and State IDs are unique
  CONSTRAINT ux_per_ssn unique nonclustered (per_ssn ASC)
);

-- -----------------------------------------
-- Table phone
-- -----------------------------------------
IF OBJECT_ID (N'dbo.phone', N'U') IS NOT NULL
DROP TABLE dbo.phone;
GO

CREATE TABLE dbo.phone
(
  phn_id SMALLINT NOT NULL identity(1,1),
  per_id SMALLINT NOT NULL,
  phn_num bigint NOT NULL check (phn_num like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  phn_type char(1) NOT NULL CHECK (phn_type IN('h','c','w','f')),
  phn_notes VARCHAR(255) NULL,
  PRIMARY KEY (phn_id),
  
  CONSTRAINT fk_phone_person
    FOREIGN KEY (per_id)
    REFERENCES dbo.person (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- -----------------------------------------
-- Table customer
-- -----------------------------------------
IF OBJECT_ID (N'dbo.customer', N'U') IS NOT NULL
DROP TABLE dbo.customer;
GO

CREATE TABLE dbo.customer
(
  per_id SMALLINT not null,
  cus_balance decimal(7,2) NOT NULL check (cus_balance >= 0),
  cus_total_sales decimal(7,2) NOT NULL check (cus_total_sales >= 0),
  cus_notes VARCHAR(45) NULL,
  PRIMARY KEY (per_id),
  
  CONSTRAINT fk_customer_person
    FOREIGN KEY (per_id)
    REFERENCES dbo.person (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- -----------------------------------------
-- Table slsrep
-- -----------------------------------------
IF OBJECT_ID (N'dbo.slsrep', N'U') IS NOT NULL
DROP TABLE dbo.slsrep;
GO

CREATE TABLE dbo.slsrep
(
  per_id SMALLINT not null,
  srp_yr_sales_goal decimal(8,2) NOT NULL check (srp_yr_sales_goal >= 0),
  srp_ytd_sales decimal(8,2) NOT NULL check (srp_ytd_sales >= 0),
  srp_ytd_comm decimal(7,2) NOT NULL check (srp_ytd_comm >= 0),
  srp_notes VARCHAR(45) NULL,
  PRIMARY KEY (per_id),
  
  CONSTRAINT fk_slsrep_person
    FOREIGN KEY (per_id)
    REFERENCES dbo.person (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- -----------------------------------------
-- Table srp_hist
-- -----------------------------------------
IF OBJECT_ID (N'dbo.srp_hist', N'U') IS NOT NULL
DROP TABLE dbo.srp_hist;
GO

CREATE TABLE dbo.srp_hist
(
  sht_id SMALLINT not null identity(1,1),
  per_id SMALLINT not null,
  sht_type char(1) not null CHECK (sht_type IN('i', 'u', 'd')),
  sht_modified datetime not null,
  sht_modifier varchar(45) not null default system_user,
  sht_date date not null default getDate(),
  sht_yr_sales_goal decimal(8,2) NOT NULL check (sht_yr_sales_goal >= 0),
  sht_yr_total_sales decimal(8,2) NOT NULL check (sht_yr_total_sales >= 0),
  sht_yr_total_comm decimal(7,2) NOT NULL check (sht_yr_total_comm >= 0),
  sht_notes VARCHAR(45) NULL,
  PRIMARY KEY (sht_id),
  
  CONSTRAINT fk_srp_hist_slsrep
    FOREIGN KEY (per_id)
    REFERENCES dbo.slsrep (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- -----------------------------------------
-- Table contact
-- -----------------------------------------
IF OBJECT_ID (N'dbo.contact', N'U') IS NOT NULL
DROP TABLE dbo.contact;
GO

CREATE TABLE dbo.contact
(
  cnt_id int NOT NULL identity(1,1),
  per_cid smallint NOT NULL,
  per_sid smallint NOT NULL,
  cnt_date datetime NOT NULL,
  cnt_notes varchar(255) NULL,
  PRIMARY KEY (cnt_id),
  
  CONSTRAINT fk_contact_customer
    FOREIGN KEY (per_cid)
    REFERENCES dbo.customer (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    
  -- see note below
  CONSTRAINT fk_contact_slsrep
    FOREIGN KEY (per_sid)
    REFERENCES dbo.slsrep (per_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- -----------------------------------------
-- Table [order]
-- -----------------------------------------
-- must use delimiter [] for reserved words (e.g., order)
-- -----------------------------------------
IF OBJECT_ID (N'dbo.[order]', N'U') IS NOT NULL
DROP TABLE dbo.[order];
GO

CREATE TABLE dbo.[order]
(
  ord_id int NOT NULL identity(1,1),
  cnt_id int NOT NULL,
  ord_placed_date DATETIME NOT NULL,
  ord_filled_date DATETIME NULL,
  ord_notes VARCHAR(255) NULL,
  PRIMARY KEY (ord_id),
  
  CONSTRAINT fk_order_contact
    FOREIGN KEY (cnt_id)
    REFERENCES dbo.contact (cnt_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

----------------------------------------
-- Table store
----------------------------------------
IF OBJECT_ID (N'dbo.store', N'U') IS NOT NULL
DROP TABLE dbo.store;
GO

CREATE TABLE dbo.store
(
    str_id SMALLINT NOT NULL identity(1,1),
    str_name VARCHAR(45) NOT NULL,
    str_street VARCHAR(30) NOT NULL,
    str_city VARCHAR(30) NOT NULL,
    str_state CHAR(2) NOT NULL DEFAULT 'FL',
    str_zip int NOT NULL check (str_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_phone bigint NOT NULL check (str_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_email VARCHAR(100) NOT NULL,
    str_url VARCHAR(100) NOT NULL,
    str_notes VARCHAR(255) NULL,
    PRIMARY KEY (str_id)
);

----------------------------------------
-- Table invoice
----------------------------------------
IF OBJECT_ID (N'dbo.invoice', N'U') IS NOT NULL
DROP TABLE dbo.invoice;
GO

CREATE TABLE dbo.invoice
(
    inv_id int NOT NULL identity(1,1),
    ord_id int NOT NULL,
    str_id SMALLINT NOT NULL,
    inv_date DATETIME NOT NULL,
    inv_total DECIMAL(8,2) NOT NULL check (inv_total >= 0),
    inv_paid bit NOT NULL,
    inv_notes VARCHAR(255) NULL,
    PRIMARY KEY (inv_id),
    
-- create 1:1 relationship with order by making ord_id unique
    CONSTRAINT ux_ord_id unique nonclustered (ord_id ASC),
    
    CONSTRAINT fk_invoice_order
        FOREIGN KEY (ord_id )
        REFERENCES dbo.[order] (ord_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_invoice_store
        FOREIGN KEY (str_id )
        REFERENCES dbo.store (str_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

----------------------------------------
-- Table payment
----------------------------------------
IF OBJECT_ID (N'dbo.payment', N'U') IS NOT NULL
DROP TABLE dbo.payment;
GO

CREATE TABLE dbo.payment
(
    pay_id int NOT NULL identity(1,1),
    inv_id int NOT NULL,
    pay_date DATETIME NOT NULL,
    pay_amt DECIMAL(7,2) NOT NULL check (pay_amt >= 0),
    pay_notes VARCHAR(255) NULL,
    PRIMARY KEY (pay_id),
    
    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (inv_id )
        REFERENCES dbo.invoice (inv_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

----------------------------------------
-- Table vendor
----------------------------------------
IF OBJECT_ID (N'dbo.vendor', N'U') IS NOT NULL
DROP TABLE dbo.vendor;
GO

CREATE TABLE dbo.vendor
(
    ven_id SMALLINT NOT NULL identity(1,1),
    ven_name VARCHAR(45) NOT NULL,
    ven_street VARCHAR(30) NOT NULL,
    ven_city VARCHAR(30) NOT NULL,
    ven_state CHAR(2) NOT NULL DEFAULT 'FL',
    ven_zip int NOT NULL check (ven_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    ven_phone bigint NOT NULL check (ven_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    ven_email VARCHAR(100) NULL,
    ven_url VARCHAR(100) NULL,
    ven_notes VARCHAR(255) NULL,
    PRIMARY KEY (ven_id)
);

----------------------------------------
-- Table product
----------------------------------------
IF OBJECT_ID (N'dbo.product', N'U') IS NOT NULL
DROP TABLE dbo.product;
GO

CREATE TABLE dbo.product
(
    pro_id SMALLINT NOT NULL identity(1,1),
    ven_id SMALLINT NOT NULL,
    pro_name VARCHAR(30) NOT NULL,
    pro_descript VARCHAR(45) NULL,
    pro_weight FLOAT NOT NULL check (pro_weight >= 0),
    pro_qoh SMALLINT NOT NULL check (pro_qoh >= 0),
    pro_cost DECIMAL(7,2) NOT NULL check (pro_cost >= 0),
    pro_price DECIMAL(7,2) NOT NULL check (pro_price >= 0),
    pro_discount DECIMAL(3,0) NULL,
    pro_notes VARCHAR(255) NULL,
    PRIMARY KEY (pro_id),
    
    CONSTRAINT fk_product_vendor
        FOREIGN KEY (ven_id )
        REFERENCES dbo.vendor (ven_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

----------------------------------------
-- Table product_hist
----------------------------------------
IF OBJECT_ID (N'dbo.product_hist', N'U') IS NOT NULL
DROP TABLE dbo.product_hist;
GO

CREATE TABLE dbo.product_hist
(
    pht_id int NOT NULL identity(1,1),
    pro_id SMALLINT NOT NULL,
    pht_date DATETIME NOT NULL,
    pht_cost DECIMAL(7,2) NOT NULL check (pht_cost >= 0),
    pht_price DECIMAL(7,2) NOT NULL check (pht_price >= 0),
    pht_discount DECIMAL(3,0) NULL,
    pht_notes VARCHAR(255) NULL,
    PRIMARY KEY (pht_id),
    
    CONSTRAINT fk_product_hist_product
        FOREIGN KEY (pro_id )
        REFERENCES dbo.product (pro_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

----------------------------------------
-- Table order_line
----------------------------------------
IF OBJECT_ID (N'dbo.order_line', N'U') IS NOT NULL
DROP TABLE dbo.order_line;
GO

CREATE TABLE dbo.order_line
(
    oln_id int NOT NULL identity(1,1),
    ord_id int NOT NULL,
    pro_id SMALLINT NOT NULL,
    oln_qty SMALLINT NOT NULL check (oln_qty >= 0),
    oln_price DECIMAL(7,2) NOT NULL check (oln_price >= 0),
    oln_notes VARCHAR(255) NULL,
    PRIMARY KEY (oln_id),
    
-- must use delimiters [] on reserved words (e.g., order)
    CONSTRAINT fk_order_line_order
        FOREIGN KEY (ord_id )
        REFERENCES dbo.[order] (ord_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_order_line_product
        FOREIGN KEY (pro_id )
        REFERENCES dbo.product (pro_id )
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM information_schema.tables;

-- converts to binary
SELECT HASHBYTES('SHA2_512', 'test');

-- length 64 bytes
SELECT len(HASHBYTES('SHA2_512', 'test'));

-- ----------------------------------------------
-- Data for table person: 5 sales reps: 1 - 5, 10 customers: 6 - 15
-- NOTE: do *not* include attribute name or value for auto increment attributes (i.e., pks)
-- ----------------------------------------------
INSERT INTO dbo.person
(per_ssn, per_fname, per_lname, per_gender, per_dob, per_street, per_city, per_state, per_zip, per_email, per_type, per_notes)
VALUES
(HASHBYTES('SHA2_512', 'test1'), 'Michael', 'Johnson', 'm', '1985-04-17', '123 Maple Street', 'Chicago', 'IL', 606012345, 'mjohnson@gmail.com', 's', 'Senior sales rep'),
(HASHBYTES('SHA2_512', 'test2'), 'Jennifer', 'Williams', 'f', '1979-11-30', '456 Oak Avenue', 'Boston', 'MA', 221201234, 'jwilliams@outlook.com', 's', 'Northeast territory'),
(HASHBYTES('SHA2_512', 'test3'), 'David', 'Martinez', 'm', '1990-08-22', '789 Pine Road', 'Austin', 'TX', 787011234, 'dmartinez@yahoo.com', 's', 'New hire 2023'),
(HASHBYTES('SHA2_512', 'test4'), 'Sarah', 'Garcia', 'f', '1982-05-15', '321 Cedar Lane', 'Portland', 'OR', 972011234, 'sgarcia@hotmail.com', 's', 'Western sales manager'),
(HASHBYTES('SHA2_512', 'test5'), 'Robert', 'Taylor', 'm', '1975-09-03', '654 Birch Court', 'Denver', 'CO', 802011234, 'rtaylor@gmail.com', 's', 'Top performer 2024'),
(HASHBYTES('SHA2_512', 'test6'), 'Emily', 'Anderson', 'f', '1988-07-19', '987 Redwood Drive', 'Phoenix', 'AZ', 850151234, 'eanderson@yahoo.com', 'c', 'Premium customer'),
(HASHBYTES('SHA2_512', 'test7'), 'Christopher', 'Thomas', 'm', '1971-12-05', '159 Spruce Street', 'Nashville', 'TN', 372011234, 'cthomas@outlook.com', 'c', 'Since 2018'),
(HASHBYTES('SHA2_512', 'test8'), 'Jessica', 'White', 'f', '1995-03-28', '753 Elm Boulevard', 'Miami', 'FL', 331301234, 'jwhite@gmail.com', 'c', 'Monthly subscription'),
(HASHBYTES('SHA2_512', 'test9'), 'Daniel', 'Harris', 'm', '1980-01-14', '246 Aspen Way', 'San Diego', 'CA', 921001234, 'dharris@hotmail.com', 'c', 'High-volume orders'),
(HASHBYTES('SHA2_512', 'test10'), 'Amanda', 'Martin', 'f', '1992-06-08', '135 Willow Path', 'Atlanta', 'GA', 303041234, 'amartin@yahoo.com', 'c', 'New account 2024');

select * from dbo.person;

-- ----------------------------------------------
-- Data for table slsrep
-- ----------------------------------------------
INSERT INTO dbo.slsrep
(per_id, srp_yr_sales_goal, srp_ytd_sales, srp_ytd_comm, srp_notes)
VALUES
(1, 125000, 78500, 3925, 'Top performer in Q1'),
(2, 90000, 42600, 2130, 'Focusing on enterprise clients'),
(3, 175000, 93200, 4660, 'Regional sales director'),
(4, 110000, 56300, 2815, 'New territory assignment'),
(5, 145000, 82700, 4135, 'Exceeding quarterly targets');

select * from dbo.slsrep;

-- ----------------------------------------------
-- Data for table customer
-- ----------------------------------------------
INSERT INTO dbo.customer
(per_id, cus_balance, cus_total_sales, cus_notes)
VALUES
(6, 235.75, 18950.42, 'Corporate account, net 30 terms'),
(7, 0.00, 7625.18, 'Prepaid account, quarterly purchases'),
(8, 547.90, 12340.65, 'Educational institution discount'),
(9, 128.40, 5280.95, 'Small business program member'),
(10, 980.25, 23475.10, 'Wholesale distributor, bulk orders');

select * from dbo.customer;

-- ----------------------------------------------
-- Data for table contact
-- ----------------------------------------------
INSERT INTO dbo.contact
(per_sid, per_cid, cnt_date, cnt_notes)
VALUES
(1, 6, '2023-11-15', 'Annual contract renewal discussion'),
(2, 7, '2024-01-22', 'Product demonstration for new line'),
(3, 8, '2024-02-07', 'Support request follow-up'),
(4, 9, '2024-02-18', 'Quote for additional services'),
(5, 10, '2024-03-05', 'Scheduling quarterly review meeting');

select * from dbo.contact;

-- ----------------------------------------------
-- Data for table order
-- ----------------------------------------------
INSERT INTO dbo.[order]
(cnt_id, ord_placed_date, ord_filled_date, ord_notes)
VALUES
(1, '2023-09-15', '2023-09-22', NULL),
(2, '2023-11-03', '2023-11-18', NULL),
(3, '2024-01-07', '2024-01-15', NULL),
(4, '2024-02-12', '2024-02-26', NULL),
(5, '2024-03-05', '2024-03-10', NULL);

select * from dbo.[order];

-- ----------------------------------------------
-- Data for table store
-- ----------------------------------------------
INSERT INTO dbo.store
(str_name, str_street, str_city, str_state, str_zip, str_phone, str_email, str_url, str_notes)
VALUES
('Target', '1250 Broadway Ave', 'Seattle', 'WA', 981012345, 2065557890, 'seattle@target.com', 'http://www.target.com', NULL),
('Best Buy', '3450 Market Street', 'Phoenix', 'AZ', 850151234, 6025558765, 'phoenix@bestbuy.com', 'http://www.bestbuy.com', NULL),
('Home Depot', '8975 Shiloh Road', 'Dallas', 'TX', 752291234, 2145559876, 'dallas@homedepot.com', 'http://www.homedepot.com', NULL),
('Costco', '2150 Park Place', 'Boston', 'MA', 121081234, 6175554321, 'boston@costco.com', 'http://www.costco.com', NULL),
('Kroger', '7625 Jefferson Blvd', 'Nashville', 'TN', 372051234, 6155552468, 'nashville@kroger.com', 'http://www.kroger.com', NULL);

select * from dbo.store;

-- ----------------------------------------------
-- Data for table invoice
-- ----------------------------------------------
INSERT INTO dbo.invoice
(ord_id, str_id, inv_date, inv_total, inv_paid, inv_notes)
VALUES
(1, 2, '2023-10-12', 349.95, 1, NULL),
(2, 3, '2023-11-27', 186.45, 1, NULL),
(3, 1, '2024-01-05', 532.18, 0, NULL),
(4, 5, '2024-02-19', 275.60, 0, NULL),
(5, 4, '2024-03-08', 418.75, 0, NULL);

select * from dbo.invoice;

-- ----------------------------------------------
-- Data for table vendor
-- ----------------------------------------------
INSERT INTO dbo.vendor
(ven_name, ven_street, ven_city, ven_state, ven_zip, ven_phone, ven_email, ven_url, ven_notes)
VALUES
('Dell Technologies', '1 Dell Way', 'Round Rock', 'TX', 786820001, 8003389542, 'sales@dell.com', 'http://www.dell.com', NULL),
('Apple Inc', '1 Apple Park Way', 'Cupertino', 'CA', 950141234, 8002752273, 'business@apple.com', 'http://www.apple.com', NULL),
('Microsoft', '1 Microsoft Way', 'Redmond', 'WA', 980521234, 8006427676, 'msales@microsoft.com', 'http://www.microsoft.com', NULL),
('HP Inc', '1501 Page Mill Rd', 'Palo Alto', 'CA', 943041234, 6508571501, 'sales@hp.com', 'http://www.hp.com', NULL),
('Lenovo', '8001 Development Dr', 'Morrisville', 'NC', 275601234, 8668536465, 'sales@lenovo.com', 'http://www.lenovo.com', NULL);

select * from dbo.vendor;

-- ----------------------------------------------
-- Data for table product
-- ----------------------------------------------
INSERT INTO dbo.product
(ven_id, pro_name, pro_descript, pro_weight, pro_qoh, pro_cost, pro_price, pro_discount, pro_notes)
VALUES
(1, 'Laptop', 'Business Ultrabook 14"', 3.5, 85, 650.00, 999.99, 10, NULL),
(2, 'Smartphone', 'Latest model 256GB', 0.4, 120, 400.00, 799.99, NULL, NULL),
(3, 'Desktop PC', 'Gaming tower system', 18.5, 35, 850.00, 1399.99, 5, NULL),
(4, 'Tablet', '10" display with case', 1.2, 65, 195.00, 349.99, NULL, NULL),
(5, 'Monitor', '27" 4K HDR display', 12.6, 50, 225.00, 429.99, 15, NULL);

select * from dbo.product;

-- ----------------------------------------------
-- Data for table order_line
-- ----------------------------------------------
INSERT INTO dbo.order_line
(ord_id, pro_id, oln_qty, oln_price, oln_notes)
VALUES
(1, 1, 2, 989.99, NULL),
(2, 3, 1, 1329.99, NULL),
(3, 5, 3, 365.49, NULL),
(4, 2, 5, 799.99, NULL),
(5, 4, 2, 349.99, NULL);

select * from dbo.order_line;

-- ----------------------------------------------
-- Data for table payment
-- ----------------------------------------------
INSERT INTO dbo.payment
(inv_id, pay_date, pay_amt, pay_notes)
VALUES
(1, '2023-10-20', 349.95, NULL),
(2, '2023-12-05', 186.45, NULL),
(3, '2024-01-25', 250.00, NULL),
(4, '2024-02-28', 275.60, NULL),
(5, '2024-03-15', 200.00, NULL);

select * from dbo.payment;

-- ----------------------------------------------
-- Data for table product_hist
-- ----------------------------------------------
INSERT INTO dbo.product_hist
(pro_id, pht_date, pht_cost, pht_price, pht_discount, pht_notes)
VALUES
(1, '2023-09-15 10:30:00', 625.00, 949.99, 5, NULL),
(2, '2023-10-22 14:45:00', 380.00, 749.99, NULL, NULL),
(3, '2023-12-01 09:15:00', 800.00, 1299.99, 10, NULL),
(4, '2024-01-18 13:20:00', 185.00, 329.99, NULL, NULL),
(5, '2024-02-05 11:10:00', 210.00, 399.99, 8, NULL);

select * from dbo.product_hist;

-- ----------------------------------------------
-- Data for table srp_hist
-- ----------------------------------------------
INSERT INTO dbo.srp_hist
(per_id, sht_type, sht_modified, sht_modifier, sht_date, sht_yr_sales_goal, sht_yr_total_sales, sht_yr_total_comm, sht_notes)
VALUES
(1, 'i', getDate(), SYSTEM_USER, getDate(), 125000, 45000, 2250, NULL),
(2, 'u', getDate(), SYSTEM_USER, getDate(), 95000, 52000, 2600, NULL),
(3, 'i', getDate(), SYSTEM_USER, getDate(), 175000, 68000, 3400, NULL),
(4, 'u', getDate(), SYSTEM_USER, getDate(), 110000, 37500, 1875, NULL),
(5, 'i', getDate(), SYSTEM_USER, getDate(), 145000, 59000, 2950, NULL);

select * from dbo.srp_hist;

select year(sht_date) from dbo.srp_hist;

-- %%%%%%%%%%%%% BEGIN REPORTS %%%%%%%%%%%%%
-- MS SQL Server:
-- list tables
-- select * from [database_name].information_schema.tables;

select * from [csp21b].information_schema.tables;
go

-- metadata of database tables
select * from [csp21b].information_schema.columns;
go

-- summary information of objects
-- sp_help 'object_name'

-- summary information of object dbo.srp_hist
sp_help 'dbo.srp_hist';
go

-- 1) Create a view that displays the sum of all *paid* invoice totals for each customer,
-- sort by the largest invoice total sum appearing first.

-- (your boss may want a comparison of paid and unpaid invoices)

-- View demo (MS SQL Server):
use csp21b;
go

-- a. snapshot of all invoices
select * from dbo.invoice;

-- b. snapshot of all *paid* invoices (i.e., inv_paid !=0):
select inv_id, inv_total as paid_invoice_total
from dbo.invoice
where inv_paid !=0;

-- c. snapshot of sum of all *paid* invoices:
select sum(inv_total) as sum_paid_invoice_total
from dbo.invoice
where inv_paid !=0;

-- use single quotation mark to escape single quotation mark (otherwise, error), also, notice additional space for line break
-- #1 Solution: create view (sum of each customer's *paid* invoices, in desc order):
;

--drop view if exists
--1st arg is object name, 2nd arg is type (V=view)
IF OBJECT_ID (N'dbo.v_paid_invoice_total', N'V') IS NOT NULL
DROP VIEW dbo.v_paid_invoice_total;
GO

--In MS SQL SERVER: do *NOT* use ORDER BY clause in *VIEWS* (non-guaranteed behavior)
create view dbo.v_paid_invoice_total as
select p.per_id, per_fname, per_lname, sum(inv_total) as sum_total, FORMAT(sum(inv_total), 'C', 'en-us') as paid_invoice_total
from dbo.person p
join dbo.customer c on p.per_id=c.per_id
join dbo.contact ct on c.per_id=ct.per_cid
join dbo.[order] o on ct.cnt_id=o.cnt_id
join dbo.invoice i on o.ord_id=i.ord_id
where inv_paid !=0
-- must be contained in group by, if not used in aggregate function
group by p.per_id, per_fname, per_lname
go

-- display view results (order by should be used outside of view)
select per_id, per_fname, per_lname, paid_invoice_total from dbo.v_paid_invoice_total order by sum_total desc;
go

-- compare views to base tables
SELECT * FROM information_schema.tables;
go

-- Display definition of trigger, stored procedure, or view
sp_helptext 'dbo.v_paid_invoice_total'
go

-- remove view from server memory
drop view dbo.v_paid_invoice_total;

-- 2) Create a stored procedure that displays all customers' outstanding balances
-- (unstored derived attribute based upon the difference of a customer's invoice total and their respective payments).
-- List their invoice totals, what was paid, and the difference.

-- a. individual customer (example query for a specific customer)
SELECT 
    p.per_id, 
    p.per_fname, 
    p.per_lname,
    SUM(i.inv_total) AS total_invoice_amount,
    SUM(pt.pay_amt) AS total_paid, 
    SUM(i.inv_total) - SUM(pt.pay_amt) AS invoice_diff
FROM dbo.person p
    JOIN dbo.customer c ON p.per_id = c.per_id
    JOIN dbo.contact ct ON c.per_id = ct.per_cid
    JOIN dbo.[order] o ON ct.cnt_id = o.cnt_id
    JOIN dbo.invoice i ON o.ord_id = i.ord_id
    JOIN dbo.payment pt ON i.inv_id = pt.inv_id
WHERE p.per_id = 7
GROUP BY p.per_id, p.per_fname, p.per_lname;

-- use single quotation mark to escape single quotation mark (otherwise, error)
PRINT '#2 Solution: create procedure (displays all customers'' outstanding balances):';

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.sp_all_customers_outstanding_balances', N'P') IS NOT NULL
    DROP PROC dbo.sp_all_customers_outstanding_balances;
GO

-- In MS SQL SERVER: *can* use ORDER BY clause in stored procedures, though, *not* views
CREATE PROC dbo.sp_all_customers_outstanding_balances AS
BEGIN
    SELECT 
        p.per_id, 
        p.per_fname, 
        p.per_lname,
        SUM(i.inv_total) AS total_invoice_amount,
        SUM(pt.pay_amt) AS total_paid, 
        SUM(i.inv_total) - SUM(pt.pay_amt) AS outstanding_balance
    FROM dbo.person p
        JOIN dbo.customer c ON p.per_id = c.per_id
        JOIN dbo.contact ct ON c.per_id = ct.per_cid
        JOIN dbo.[order] o ON ct.cnt_id = o.cnt_id
        JOIN dbo.invoice i ON o.ord_id = i.ord_id
        JOIN dbo.payment pt ON i.inv_id = pt.inv_id
    GROUP BY p.per_id, p.per_fname, p.per_lname
    ORDER BY outstanding_balance DESC;
END;
GO

-- call stored procedure
EXEC dbo.sp_all_customers_outstanding_balances;

-- list all procedures (e.g., stored procedures or functions) for database
SELECT * FROM csp21b.information_schema.routines
WHERE routine_type = 'PROCEDURE';
GO

-- Display definition of trigger, stored procedure, or view
sp_helptext 'dbo.sp_all_customers_outstanding_balances';
GO

-- remove procedure from server memory
DROP PROC dbo.sp_all_customers_outstanding_balances;

-- 3) Create a stored procedure that populates the sales rep history table w/sales reps' data when called.
-- list sales reps' history before/after stored procedure called

-- *NOTE*: BOTH tables have existing data.
-- Demonstration illustrates how to initially populate a table w/another table's data, while adding dynamically generated data.

-- use single quotation mark to escape single quotation mark (otherwise, error)
PRINT '#3 Solution: create stored procedure to populate history table w/sales reps'' data when called';

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.sp_populate_srp_hist_table', N'P') IS NOT NULL
    DROP PROC dbo.sp_populate_srp_hist_table;
GO

CREATE PROC dbo.sp_populate_srp_hist_table AS
BEGIN
    INSERT INTO dbo.srp_hist
    (per_id, sht_type, sht_modified, sht_modifier, sht_date, sht_yr_sales_goal, sht_yr_total_sales, sht_yr_total_comm, sht_notes)
    -- mix dynamically generated data, with original sales reps' data
    SELECT 
        per_id, 
        'I', 
        GETDATE(), 
        SYSTEM_USER, 
        GETDATE(), 
        srp_yr_sales_goal, 
        srp_ytd_sales, 
        srp_ytd_comm, 
        srp_notes
    FROM dbo.slsrep;
END;
GO

PRINT 'list table data before call:';
SELECT * FROM dbo.slsrep;
SELECT * FROM dbo.srp_hist;

-- Purposefully deleting original data to simulate initially populating a "log" or history table
DELETE FROM dbo.srp_hist;

-- call stored procedure (populating srp_hist table with slsrep table data)
EXEC dbo.sp_populate_srp_hist_table;

PRINT 'list table data after call:';
SELECT * FROM dbo.slsrep;
SELECT * FROM dbo.srp_hist;

-- list all procedures (e.g., stored procedures or functions) for database
SELECT * FROM csp21b.information_schema.routines
WHERE routine_type = 'PROCEDURE';
GO

-- Display definition of trigger, stored procedure, or view
sp_helptext 'dbo.sp_populate_srp_hist_table'
go

-- remove procedure from server memory
drop PROC dbo.sp_populate_srp_hist_table;
go

-- use single quotation mark to escape single quotation mark (otherwise, error)
print '#4 Solution: Create a trigger that automatically adds a record to the sales reps'' history table for every record added to the sales rep table.
';

/*
Note: When using MS SQL Server triggers, there are two system tables created "Inserted" and "Deleted."
Inserted: contains new rows for insert and update operations
Deleted: contains original rows for update and delete operations
*/

--1st arg is object name, 2nd arg is type (TR=trigger)
IF OBJECT_ID(N'dbo.trg_sales_history_insert', N'TR') IS NOT NULL
DROP TRIGGER dbo.trg_sales_history_insert
GO

CREATE TRIGGER dbo.trg_sales_history_insert
ON dbo.slsrep
AFTER INSERT AS
BEGIN
 -- declare
 DECLARE
 @per_id_v smallint,
 @sht_type_v char(1),
 @sht_modified_v date,
 @sht_modifier_v varchar(45),
 @sht_date_v date,
 @sht_yr_sales_goal_v decimal(8,2),
 @sht_yr_total_sales_v decimal(8,2),
 @sht_yr_total_comm_v decimal(7,2),
 @sht_notes_v varchar(255);

 SELECT
 @per_id_v = per_id,
 @sht_type_v = 'I',
 @sht_modified_v = getDate(),
 @sht_modifier_v = SYSTEM_USER,
 @sht_date_v = getDate(),
 @sht_yr_sales_goal_v = srp_yr_sales_goal,
 @sht_yr_total_sales_v = srp_ytd_sales,
 @sht_yr_total_comm_v = srp_ytd_comm,
 @sht_notes_v = srp_notes
 FROM INSERTED;

 INSERT INTO dbo.srp_hist
(per_id, sht_type, sht_modified, sht_modifier, sht_date, sht_yr_sales_goal, sht_yr_total_sales, sht_yr_total_comm, sht_notes)
VALUES
(@per_id_v, @sht_type_v, @sht_modified_v, @sht_modifier_v, @sht_date_v, @sht_yr_sales_goal_v, @sht_yr_total_sales_v, @sht_yr_total_comm_v, @sht_notes_v);
END
GO

print 'list table data before trigger fires:
';
select * from slsrep;
select * from srp_hist;

-- fire trigger
INSERT INTO dbo.slsrep
(per_id, srp_yr_sales_goal, srp_ytd_sales, srp_ytd_comm, srp_notes)
VALUES
(6, 98000, 43000, 8750, 'per_id values 1-5 already used');

print 'list table data after trigger fires:
';
select * from slsrep;
select * from srp_hist;

-- To list all database triggers
SELECT * FROM sys.triggers;
go

-- Display definition of trigger, stored procedure, or view
sp_helptext 'dbo.trg_sales_history_insert'
go

-- remove trigger from server memory
DROP TRIGGER dbo.trg_sales_history_insert;
go

print '#5 Solution: Create trigger that automatically adds a record to the product history table for every record added to the product tabel
';

IF OBJECT_ID(N'dbo.trg_product_history_insert',N'TR') IS NOT NULL
DROP TRIGGER dbo.trg_product_history_insert
GO

CREATE TRIGGER dbo.trg_product_history_insert
ON dbo.product
AFTER INSERT AS
BEGIN
    DECLARE
        @pro_id_v smallint,
--          @pht_type_v, -- insert, update, or delete
        @pht_modified_v date, -- when recorded
--          @pht_modifier_v, -- who made the change
        @pht_cost_v decimal(7,2),
        @pht_price_v decimal(7,2),
        @pht_discount_v decimal(3,0),
        @pht_notes_v varchar(255);

        SELECT
        @pro_id_v = pro_id,
        @pht_modified_v = getDate(),
        @pht_cost_v = pro_cost,
        @pht_price_v = pro_discount,
        @pht_discount_v = pro_discount,
        @pht_notes_v = pro_notes
        FROM INSERTED;

        INSERT INTO dbo.product_hist
        (pro_id, pht_date, pht_cost, pht_price, pht_discount, pht_notes)
        VALUES
        (@pro_id_v, @pht_modified_v, @pht_cost_v, @pht_price_v, @pht_discount_v, @pht_notes_v);
END
GO

print 'list table data before trigger fires:

';
select * from product;
select * from product_hist;

-- fire trigger
INSERT INTO dbo.product
(ven_id, pro_name, pro_descript, pro_weight, pro_qoh, pro_cost, pro_price, pro_discount, pro_notes)
VALUES(3, 'desk lamp', 'small desk lamp with led lgihts', 3.6, 14, 5.98, 11.99, 15, 'No Discounts after sale.');

print 'list table data after trigger fires:

';
select * from product;
select * from product_hist;

-- To list all database triggers
SELECT * FROM sys.triggers;
GO

-- Display definition of trigger, stored procedure, or view
sp_helptext 'dbo.trg_product_history_insert'
go

-- Remove trigger from server memory
DROP TRIGGER dbo.trg_product_history_insert;
GO

-- Use single quotation mark to escape single quotation mark (otherwise, error)
print '#6 Solution: stored procedure updates sales reps" yearly_sales_goal in the slsrep table, based upon 8% more than their previous year"s total sales

';

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.sp_annual_salesrep_sales_goal', N'P')IS NOT NULL
DROP PROC dbo.sp_annual_salesrep_sales_goal
GO

CREATE PROC dbo.sp_annual_salesrep_sales_goal AS
BEGIN
-- Update is based upon 8% of each sales rep's previous year's individual total sales (Note: see sht_yr_total_sales in srp_hist table)
UPDATE slsrep 
SET srp_yr_sales_goal = sht_yr_total_sales * 1.08
from slsrep as sr
    JOIN srp_hist as sh
    ON sr.per_id = sh.per_id
    -- NOTE: since all data is recent, use max() function for testing
where sht_date=(select max(sht_date)from srp_hist);
END
GO

print 'list table data before call:

';
select * from dbo.slsrep;
select * from dbo.srp_hist;

-- call stored procedure 
exec dbo.sp_annual_salesrep_sales_goal;

print 'list table data after call:

';
select * from dbo.slsrep;








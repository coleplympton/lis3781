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
  per_salt binary(64) NULL,
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
-- Table region
----------------------------------------
IF OBJECT_ID(N'dbo.region', N'U') IS NOT NULL
DROP TABLE dbo.region;
GO

CREATE TABLE region
(
    reg_id    TINYINT NOT NULL identity(1,1),
    reg_name  CHAR(1) NOT NULL,  -- n,e,s,w,c (north, east, south, west, central)
    reg_notes VARCHAR(255) NULL,
    PRIMARY KEY (reg_id)
);
GO

----------------------------------------
-- Table state
----------------------------------------
IF OBJECT_ID(N'dbo.state', N'U') IS NOT NULL
DROP TABLE dbo.state;
GO

CREATE TABLE dbo.state
(
    ste_id    TINYINT NOT NULL identity(1,1),
    reg_id    TINYINT NOT NULL,
    ste_name  CHAR(2) NOT NULL DEFAULT 'FL',
    ste_notes VARCHAR(255) NULL,
    PRIMARY KEY (ste_id),

    CONSTRAINT fk_state_region
        FOREIGN KEY (reg_id)
        REFERENCES dbo.region (reg_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

----------------------------------------
-- Table city
----------------------------------------
IF OBJECT_ID(N'dbo.city', N'U') IS NOT NULL
DROP TABLE dbo.city;
GO

CREATE TABLE dbo.city
(
    cty_id    SMALLINT NOT NULL identity(1,1),
    ste_id    TINYINT NOT NULL,
    cty_name  VARCHAR(30) NOT NULL,
    cty_notes VARCHAR(255) NULL,
    PRIMARY KEY (cty_id),

    CONSTRAINT fk_city_state
        FOREIGN KEY (ste_id)
        REFERENCES dbo.state (ste_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

----------------------------------------
-- Table store
----------------------------------------
IF OBJECT_ID(N'dbo.store', N'U') IS NOT NULL
DROP TABLE dbo.store;
GO

CREATE TABLE dbo.store
(
    str_id     SMALLINT NOT NULL identity(1,1),
    cty_id     SMALLINT NOT NULL,
    str_name   VARCHAR(45) NOT NULL,
    str_street VARCHAR(30) NOT NULL,
    str_zip    INT NOT NULL CHECK (str_zip LIKE '[0-9][0-9][0-9][0-9][0-9]'),
    str_phone  BIGINT NOT NULL CHECK (str_phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_email  VARCHAR(100) NOT NULL,
    str_url    VARCHAR(100) NOT NULL,
    str_notes  VARCHAR(255) NULL,
    PRIMARY KEY (str_id),

    CONSTRAINT fk_store_city
        FOREIGN KEY (cty_id)
        REFERENCES dbo.city (cty_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

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

----------------------------------------
-- Table time
----------------------------------------
IF OBJECT_ID(N'dbo.time', N'U') IS NOT NULL
DROP TABLE dbo.time;
GO

CREATE TABLE dbo.time
(
    tim_id     INT NOT NULL identity(1,1),
    tim_yr     SMALLINT NOT NULL, -- 2 byte integer (no YEAR data type in MS SQL Server)
    tim_qtr    TINYINT NOT NULL,  -- 1 - 4
    tim_month  TINYINT NOT NULL,  -- 1 - 12
    tim_week   TINYINT NOT NULL,  -- 1 - 52
    tim_day    TINYINT NOT NULL,  -- 1 - 7
    tim_time   TIME NOT NULL,     -- based on 24-hour clock
    tim_notes  VARCHAR(255) NULL,
    PRIMARY KEY (tim_id)
);
GO

----------------------------------------
-- Table sale
----------------------------------------
IF OBJECT_ID(N'dbo.sale', N'U') IS NOT NULL
DROP TABLE dbo.sale;
GO

CREATE TABLE dbo.sale
(
    pro_id     SMALLINT NOT NULL,
    str_id     SMALLINT NOT NULL,
    cnt_id     INT NOT NULL,
    tim_id     INT NOT NULL,
    sal_qty    SMALLINT NOT NULL,
    sal_price  DECIMAL(8,2) NOT NULL,
    sal_total  DECIMAL(8,2) NOT NULL,
    sal_notes  VARCHAR(255) NULL,
    PRIMARY KEY (pro_id, cnt_id, tim_id, str_id),

    -- make sure combination of time, contact, store, and product are unique
    CONSTRAINT ux_pro_id_str_id_cnt_id_tim_id
        UNIQUE NONCLUSTERED (pro_id ASC, str_id ASC, cnt_id ASC, tim_id ASC),

    CONSTRAINT fk_sale_time
        FOREIGN KEY (tim_id)
        REFERENCES dbo.time (tim_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_sale_contact
        FOREIGN KEY (cnt_id)
        REFERENCES dbo.contact (cnt_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_sale_store
        FOREIGN KEY (str_id)
        REFERENCES dbo.store (str_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_sale_product
        FOREIGN KEY (pro_id)
        REFERENCES dbo.product (pro_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

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
(per_ssn, per_salt, per_fname, per_lname, per_gender, per_dob, per_street, per_city, per_state, per_zip, per_email, per_type, per_notes)
VALUES
(1, NULL, 'Michael', 'Johnson', 'm', '1985-04-17', '123 Maple Street', 'Chicago', 'IL', 606012345, 'mjohnson@gmail.com', 's', 'Senior sales rep'),
(2, NULL, 'Jennifer', 'Williams', 'f', '1979-11-30', '456 Oak Avenue', 'Boston', 'MA', 221201234, 'jwilliams@outlook.com', 's', 'Northeast territory'),
(3, NULL,  'David', 'Martinez', 'm', '1990-08-22', '789 Pine Road', 'Austin', 'TX', 787011234, 'dmartinez@yahoo.com', 's', 'New hire 2023'),
(4, NULL,  'Sarah', 'Garcia', 'f', '1982-05-15', '321 Cedar Lane', 'Portland', 'OR', 972011234, 'sgarcia@hotmail.com', 's', 'Western sales manager'),
(5, NULL, 'Robert', 'Taylor', 'm', '1975-09-03', '654 Birch Court', 'Denver', 'CO', 802011234, 'rtaylor@gmail.com', 's', 'Top performer 2024'),
(6, NULL, 'Emily', 'Anderson', 'f', '1988-07-19', '987 Redwood Drive', 'Phoenix', 'AZ', 850151234, 'eanderson@yahoo.com', 'c', 'Premium customer'),
(7, NULL, 'Christopher', 'Thomas', 'm', '1971-12-05', '159 Spruce Street', 'Nashville', 'TN', 372011234, 'cthomas@outlook.com', 'c', 'Since 2018'),
(8, NULL, 'Jessica', 'White', 'f', '1995-03-28', '753 Elm Boulevard', 'Miami', 'FL', 331301234, 'jwhite@gmail.com', 'c', 'Monthly subscription'),
(9, NULL, 'Daniel', 'Harris', 'm', '1980-01-14', '246 Aspen Way', 'San Diego', 'CA', 921001234, 'dharris@hotmail.com', 'c', 'High-volume orders'),
(10, NULL, 'Amanda', 'Martin', 'f', '1992-06-08', '135 Willow Path', 'Atlanta', 'GA', 303041234, 'amartin@yahoo.com', 'c', 'New account 2024');

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

-- ----------------------------
-- Data for table region
-- ----------------------------
INSERT INTO region
    (reg_name, reg_notes)
VALUES
    ('c', NULL),
    ('n', NULL),
    ('e', NULL),
    ('s', NULL),
    ('w', NULL);
GO

SELECT * FROM dbo.region;

-- ----------------------------
-- Data for table state
-- ----------------------------
INSERT INTO state
    (reg_id, ste_name, ste_notes)
VALUES
    (1, 'MI', NULL),
    (3, 'IL', NULL),
    (4, 'WA', NULL),
    (5, 'FL', NULL),
    (2, 'TX', NULL);
GO

SELECT * FROM dbo.state;

-- ----------------------------
-- Data for table city
-- ----------------------------
INSERT INTO city
    (ste_id, cty_name, cty_notes)
VALUES
    (1, 'Lansing', NULL),
    (2, 'Houston', NULL),
    (3, 'Springfield', NULL),
    (4, 'Seattle', NULL),
    (5, 'Orlando', NULL);
GO

SELECT * FROM dbo.city;

-- ----------------------------------------------
-- Data for table store
-- ----------------------------------------------
INSERT INTO dbo.store
(cty_id, str_name, str_street, str_zip, str_phone, str_email, str_url, str_notes)
VALUES
(3, 'Target', '1200 Market St', 63101, 3145556789, 'support@target.com', 'http://www.target.com', 'Opening new branch soon.'),
(4, 'Best Buy', '200 Tech Blvd', 94107, 4159876543, 'help@bestbuy.com', 'http://www.bestbuy.com', NULL),
(5, 'Home Depot', '333 Builder Rd', 85001, 8505553344, 'contact@homedepot.com', 'http://www.homedepot.com', 'Seasonal clearance ongoing.'),
(1, 'Publix', '789 Grocery Ln', 32304, 8501234567, 'info@publix.com', 'http://www.publix.com', NULL),
(2, 'Staples', '456 Office Park Dr', 10011, 2128765432, 'service@staples.com', 'http://www.staples.com', 'Store remodeled last month.');

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

-- ----------------------------
-- Data for table time
-- ----------------------------
INSERT INTO time
    (tim_yr, tim_qtr, tim_month, tim_week, tim_day, tim_time, tim_notes)
VALUES
    (2020, 1, 2, 3, 1, '08:00:00', NULL),
    (2021, 2, 5, 18, 2, '13:15:30', NULL),
    (2022, 3, 7, 30, 5, '17:45:00', NULL),
    (2023, 4, 10, 41, 7, '23:59:59', NULL),
    (2024, 1, 1, 1, 3, '06:30:45', NULL);
GO

SELECT * FROM dbo.time;

-- ----------------------------
-- Data for table sale (25 unique records)
-- ----------------------------
INSERT INTO sale
(pro_id, str_id, cnt_id, tim_id, sal_qty, sal_price, sal_total, sal_notes)
VALUES
(1, 1, 1, 1, 5, 9.99, 49.95, NULL),
(2, 2, 2, 2, 3, 19.99, 59.97, NULL),
(3, 3, 3, 3, 2, 5.99, 11.98, NULL),
(4, 4, 4, 4, 1, 99.99, 99.99, NULL),
(5, 5, 5, 5, 4, 15.99, 63.96, NULL),
(1, 2, 2, 3, 2, 8.99, 17.98, NULL),
(2, 3, 3, 4, 6, 7.99, 47.94, NULL),
(3, 4, 4, 5, 1, 2.99, 2.99, NULL),
(4, 5, 5, 1, 3, 3.99, 11.97, NULL),
(5, 1, 1, 2, 2, 12.99, 25.98, NULL),
(1, 3, 3, 5, 7, 13.99, 97.93, NULL),
(2, 4, 4, 1, 6, 9.99, 59.94, NULL),
(3, 5, 5, 2, 2, 4.99, 9.98, NULL),
(4, 1, 1, 3, 3, 14.99, 44.97, NULL),
(5, 2, 2, 4, 5, 6.99, 34.95, NULL),
(1, 4, 4, 2, 1, 11.99, 11.99, NULL),
(2, 5, 5, 3, 9, 10.99, 98.91, NULL),
(3, 1, 1, 4, 6, 7.99, 47.94, NULL),
(4, 2, 2, 5, 4, 8.99, 35.96, NULL),
(5, 3, 3, 1, 8, 3.99, 31.92, NULL),
(1, 5, 5, 4, 2, 22.99, 45.98, NULL),
(2, 1, 1, 5, 10, 5.99, 59.90, NULL),
(3, 2, 2, 1, 7, 6.99, 48.93, NULL),
(4, 3, 3, 2, 5, 9.99, 49.95, NULL),
(5, 4, 4, 3, 3, 12.99, 38.97, NULL);
GO

SELECT * FROM dbo.sale;

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

-- ----------------------------------------------
-- Data for table phone
-- ----------------------------------------------
INSERT INTO dbo.phone (per_id, phn_num, phn_type, phn_notes)
VALUES
(1, 8505551234, 'c', 'Personal cell phone'),
(2, 8505552345, 'h', 'Home landline'),
(3, 8505553456, 'w', 'Work phone for office use'),
(4, 8505554567, 'f', 'Fax machine'),
(5, 8505555678, 'c', 'Spare mobile phone');

select * from dbo.phone;

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
print '#1 Solution: Create a stored procedure (product_days_of_week) listing the product names, descriptions, ' + CHAR(13)+CHAR(10) + 'and the day of the week in which they were sold, in ascending order of the day of week:'

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.product_days_of_week', N'P') IS NOT NULL
    DROP PROC dbo.product_days_of_week;
GO

CREATE PROC dbo.product_days_of_week AS
BEGIN
    -- DATENAME ( datepart , date )
    -- tim_day is tinyint, not date. Compensate with offset. Sunday default start of week.
    SELECT pro_name, pro_descript, DATENAME(dw, tim_day - 1) AS 'day_of_week'
    FROM product p
    JOIN sale s ON p.pro_id = s.pro_id
    JOIN time t ON t.tim_id = s.tim_id
    ORDER BY tim_day - 1 ASC; -- sorts numerically, rather than string return of DATENAME() function
END
GO

-- call stored procedure
EXEC dbo.product_days_of_week;

-- list all procedures (e.g., stored procedures or functions) for database
SELECT * 
FROM test.information_schema.routines 
WHERE routine_type = 'PROCEDURE';
GO

-- use single quotation mark to escape single quotation mark (otherwise, error), also, notice additional space for line break
print '#2 Solution: Create a stored procedure (product_drill_down) listing the product name, quantity on hand, store name, ' + CHAR(13)+CHAR(10) +
'city name, state name, and region name where each product was purchased, in descending order of quantity on hand:';
GO

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.product_drill_down', N'P') IS NOT NULL
    DROP PROC dbo.product_drill_down;
GO

CREATE PROC dbo.product_drill_down AS
BEGIN
    SELECT pro_name, pro_qoh,
           FORMAT(pro_cost, 'C', 'en-us') AS cost,
           FORMAT(pro_price, 'C', 'en-us') AS price,
           str_name, cty_name, ste_name, reg_name
    FROM product p
    JOIN sale s ON p.pro_id = s.pro_id
    JOIN store sr ON sr.str_id = s.str_id
    JOIN city c ON sr.cty_id = c.cty_id
    JOIN state st ON c.ste_id = st.ste_id
    JOIN region r ON st.reg_id = r.reg_id
    ORDER BY pro_qoh DESC;
END
GO

-- call stored procedure
EXEC dbo.product_drill_down;

print '#3 Solution: Create a stored procedure (add_payment) that adds a payment record. Use variables and pass suitable arguments:';
GO

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.add_payment', N'P') IS NOT NULL
    DROP PROC dbo.add_payment;
GO

CREATE PROC dbo.add_payment
    @inv_id_p int,
    @pay_date_p datetime,
    @pay_amt_p decimal(7,2),
    @pay_notes_p varchar(255)
AS
BEGIN
    -- don't need pay_id pk, because it is auto-increment
    INSERT INTO payment (inv_id, pay_date, pay_amt, pay_notes)
    VALUES (@inv_id_p, @pay_date_p, @pay_amt_p, @pay_notes_p);
END
GO

print 'list table data before call:

';
SELECT * FROM payment;

-- initialize (i.e., declare and assign values to) variables
DECLARE
  @inv_id_v INT = 6,
  @pay_date_v DATETIME = '2014-01-05 11:56:38',
  @pay_amt_v DECIMAL(7,2) = 159.99,
  @pay_notes_v VARCHAR(255) = 'testing add_payment';

-- call stored procedure
EXEC dbo.add_payment @inv_id_v, @pay_date_v, @pay_amt_v, @pay_notes_v;

-- can't use parentheses to call stored procedure – will generate error
-- EXEC dbo.add_payment (@inv_id_v, @pay_date_v, @pay_amt_v, @pay_notes_v);

PRINT 'list table data after call:';
SELECT * FROM payment;

-- list all procedures (e.g., stored procedures or functions) for database
SELECT * 
FROM test.information_schema.routines
WHERE routine_type = 'PROCEDURE';
GO

print '#4 Solution: Create a stored procedure (customer_balance) listing the customer''s id, name, invoice id, total paid on invoice, ' + CHAR(13)+CHAR(10) + 'balance derived attribute from the difference of a customer''s invoice total and their respective payments), ' + CHAR(13)+CHAR(10) + 'pass customer''s last name as argument:';
GO

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.customer_balance', N'P') IS NOT NULL
    DROP PROC dbo.customer_balance;
GO

CREATE PROC dbo.customer_balance
    @per_lname_p VARCHAR(30)
AS
BEGIN
    SELECT p.per_id, per_fname, per_lname, i.inv_id,
           FORMAT(SUM(pay_amt), 'C', 'en-us') AS total_paid,
           FORMAT((inv_total - SUM(pay_amt)), 'C', 'en-us') AS invoice_diff
    FROM person p
    JOIN dbo.customer c ON p.per_id = c.per_id
    JOIN dbo.contact ct ON c.per_id = ct.per_cid
    JOIN dbo.[order] o ON ct.cnt_id = o.cnt_id
    JOIN dbo.invoice i ON o.ord_id = i.ord_id
    JOIN dbo.payment pt ON i.inv_id = pt.inv_id
    -- must be contained in group by, if not used in aggregate function
    WHERE per_lname = @per_lname_p
    GROUP BY p.per_id, i.inv_id, per_fname, per_lname, inv_total;
END
GO

-- can initialize variable to empty string (single-quotation marks), also case-insensitive
DECLARE @per_lname_v VARCHAR(30) = 'smith';

-- call stored procedure
EXEC dbo.customer_balance @per_lname_v;

-- use single quotation mark to escape single quotation mark (otherwise, error)
print '#5 Solution: Create and display the results of a stored procedure (store_sales_between_dates) that lists each store''s id, ' 
    + CHAR(13)+CHAR(10) + 'sum of total sales (formatted), and years for a given time period, by passing the start/end dates, group by years, '
    + CHAR(13)+CHAR(10) + 'and sort by total sales then years, both in descending order:';

-- 1st arg is object name, 2nd arg is type (P=procedure)
IF OBJECT_ID(N'dbo.store_sales_between_dates', N'P') IS NOT NULL
    DROP PROC dbo.store_sales_between_dates;
GO

-- create stored procedure w/parameters
CREATE PROC dbo.store_sales_between_dates
    @start_date_p SMALLINT,
    @end_date_p SMALLINT
AS
BEGIN
    SELECT st.str_id, 
           FORMAT(SUM(sal_total), 'C', 'en-us') AS 'total sales', 
           tim_yr AS year
    FROM store st
    JOIN sale s ON st.str_id = s.str_id
    JOIN time t ON s.tim_id = t.tim_id
    WHERE tim_yr BETWEEN @start_date_p AND @end_date_p
    GROUP BY tim_yr, st.str_id
    ORDER BY SUM(sal_total) DESC, tim_yr DESC;
END
GO

-- initialize variable to empty string (single-quotation marks), also case-insensitive
DECLARE 
    @start_date_v SMALLINT = 2010,
    @end_date_v SMALLINT = 2013;

-- call stored procedure
EXEC dbo.store_sales_between_dates @start_date_v, @end_date_v;

-- list all procedures (e.g., stored procedures or functions) for database
SELECT * 
FROM test.information_schema.routines
WHERE routine_type = 'PROCEDURE';
GO

print '#6 Solution: Create a trigger (trg_check_inv_paid) that updates an invoice record, after a payment has been made, ' 
    + CHAR(13)+CHAR(10) + 'indicating whether or not the invoice has been paid:';
GO

IF OBJECT_ID(N'dbo.trg_check_inv_paid', N'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_check_inv_paid;
GO

CREATE TRIGGER dbo.trg_check_inv_paid
ON dbo.payment
AFTER INSERT AS
BEGIN
    -- only use for testing: force all paid invoices to unpaid (0)
    UPDATE invoice
    SET inv_paid = 0;

    -- checks if sum of payments >= invoice total, if so, updates inv_paid attribute
    UPDATE invoice
    SET inv_paid = 1
    FROM invoice AS i
    JOIN (
        SELECT inv_id, SUM(pay_amt) AS total_paid
        FROM payment
        GROUP BY inv_id
    ) AS v ON i.inv_id = v.inv_id
    WHERE total_paid >= inv_total;
END
GO
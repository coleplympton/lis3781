-- Drop tables if they exist (drop dependent tables first)
DROP TABLE IF EXISTS `order`;
DROP TABLE IF EXISTS commodity;
DROP TABLE IF EXISTS customer;

-- Create the customer table.
-- Note: We add two columns (cus_addr and cus_balance) so that the inserted values match.
CREATE TABLE customer (
    cus_id      INT NOT NULL AUTO_INCREMENT,
    cus_fname   VARCHAR(15) NOT NULL,
    cus_lname   VARCHAR(15) NOT NULL,
    cus_addr    VARCHAR(30) NOT NULL,     -- Added address column
    cus_city    VARCHAR(20) NOT NULL,
    cus_state   CHAR(2) NOT NULL,
    cus_zip     VARCHAR(10) NOT NULL,
    cus_phone   BIGINT NOT NULL,
    cus_email   VARCHAR(100),
    cus_balance DECIMAL(10,2),           -- Added balance column
    cus_notes   VARCHAR(255),
    PRIMARY KEY (cus_id)
);

-- Create the commodity table.
-- Renamed the fourth column to com_notes (text) instead of a quantity.
CREATE TABLE commodity (
    com_id    INT NOT NULL AUTO_INCREMENT,
    com_name  VARCHAR(30) NOT NULL,
    com_price DECIMAL(8,2) NOT NULL,
    com_notes VARCHAR(50),
    PRIMARY KEY (com_id),
    UNIQUE KEY uq_com_name (com_name)
);

-- Create the order table.
-- Using backticks because order is a reserved word in MySQL.
CREATE TABLE `order` (
    ord_id         INT NOT NULL AUTO_INCREMENT,
    cus_id         INT,
    com_id         INT,
    ord_num_units  INT NOT NULL,
    ord_total_cost DECIMAL(8,2) NOT NULL,
    ord_notes      VARCHAR(255),
    PRIMARY KEY (ord_id),
    CONSTRAINT fk_order_customer FOREIGN KEY (cus_id) REFERENCES customer(cus_id),
    CONSTRAINT fk_order_commodity FOREIGN KEY (com_id) REFERENCES commodity(com_id),
    CHECK (ord_num_units > 0),
    CHECK (ord_total_cost > 0)
);

-- Insert data into the customer table.
INSERT INTO customer (cus_fname, cus_lname, cus_addr, cus_city, cus_state, cus_zip, cus_phone, cus_email, cus_balance, cus_notes)
VALUES 
    ('Beverly', 'Davis',    '123 Main St.', 'Detroit',     'MI', '48252', 3135551212, 'bdavis@aol.com',       1500.99, 'recently moved'),
    ('Stephen', 'Taylor',   '456 Elm St.',  'St. Louis',   'MO', '57252', 4185551212, 'staylor@comcast.net',    25.01,   NULL),
    ('Donna',   'Carter',   '789 Peach Ave.','Los Angeles', 'CA', '48252', 3135551212, 'dcarter@wow.com',       300.99,  'returning customer'),
    ('Robert',  'Silverman','857 Wilbur Rd.','Phoenix',     'AZ', '25278', 4805551212, 'rsilverman@aol.com',     NULL,    NULL),
    ('Sally',   'Victors',  '534 Holler Way','Charleston',  'WV', '78345', 9045551212, 'svictors@wow.com',       500.76,  'new customer');

-- Insert data into the commodity table.
INSERT INTO commodity (com_name, com_price, com_notes)
VALUES
    ('DVD & Player', 109.00, NULL),
    ('Cereal',        3.00, 'sugar free'),
    ('Scrabble',     29.00, 'original'),
    ('Licorice',      1.89, NULL),
    ('Tums',          2.45, 'antacid');

-- Insert data into the order table.
INSERT INTO `order` (cus_id, com_id, ord_num_units, ord_total_cost, ord_notes)
VALUES
    (1, 2, 50, 200, NULL),
    (2, 3, 30, 100, NULL),
    (3, 1, 6, 654, NULL),
    (5, 4, 24, 972, NULL),
    (3, 5, 7, 300, NULL),
    (1, 2, 5, 15, NULL),
    (2, 3, 40, 57, NULL),
    (3, 1, 4, 300, NULL),
    (5, 4, 14, 770, NULL),
    (3, 5, 15, 883, NULL);

-- In MySQL (with autocommit enabled) the commit is optional,
-- but you can include it if you are running within a transaction.
COMMIT;

-- Display the data.
SELECT * FROM customer;
SELECT * FROM commodity;
SELECT * FROM `order`;
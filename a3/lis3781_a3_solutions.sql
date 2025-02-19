SET DEFINE OFF

DROP SEQUENCE seq_cus_id;
Create sequence seq_cus_id
start with 1
increment by 1
minivalue 1
maxvalue 10000;

DROP TABLE customer CASCADE CONSTRAINTS PURGE;
CREATE TABLE customer (
    cus_id      NUMBER(3)    NOT NULL,  
    cus_fname   VARCHAR2(15) NOT NULL,
    cus_lname   VARCHAR2(15) NOT NULL,
    cus_city    VARCHAR2(20) NOT NULL,
    cus_state   CHAR(2)      NOT NULL,
    cus_zip     VARCHAR2(10) NOT NULL,
    cus_phone   NUMBER(10)   NOT NULL,
    cus_email   VARCHAR2(100),
    cus_notes   VARCHAR2(255),
    CONSTRAINT pk_customer PRIMARY KEY (cus_id)
);

DROP SEQUENCE seq_com_id;
CREATE SEQUENCE seq_com_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000;

DROP TABLE commodity CASCADE CONSTRAINTS PURGE;
CREATE TABLE commodity (
    com_id         NUMBER(3)    NOT NULL,
    com_name       VARCHAR2(30) NOT NULL,
    com_price      NUMBER(8,2)  NOT NULL,
    com_qty_onhand NUMBER(5)    NOT NULL,
    CONSTRAINT pk_commodity PRIMARY KEY (com_id),
    CONSTRAINT uq_com_name UNIQUE (com_name)
);

DROP SEQUENCE seq_ord_id; -- for auto increment
Create sequence seq_ord_id
start with 1
increment by 1
minvalue 1
maxvalue 10000;

-- Demo purposes: Quoted identifiers can be reserved words (e.g., order), although this is *not* recommended
drop table "order" CASCADE CONSTRAINTS PURGE;
CREATE TABLE "order"
(
    ord_id number(4,0) not null, -- max value 9999 (permitting only integers, no decimals)
    cus_id number,
    com_id number,
    ord_num_units number(5,0) NOT NULL, -- max value 99999 (permitting only integers, no decimals)
    ord_total_cost number(8,2) NOT NULL,
    ord_notes varchar2(255),

    CONSTRAINT pk_order PRIMARY KEY(ord_id),
    CONSTRAINT fk_order_customer
    FOREIGN KEY (cus_id)
    REFERENCES customer(cus_id),
    CONSTRAINT fk_order_commodity
    FOREIGN KEY (com_id)
    REFERENCES commodity(com_id),
    CONSTRAINT check_unit CHECK(ord_num_units > 0),
    CONSTRAINT check_total CHECK(ord_total_cost > 0)
);

-- Oracle NEXTVAL function used to retrieve next value in sequence
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Beverly', 'Davis', '123 Main St.', 'Detroit', 'MI', 48252, 3135551212, 'bdavis@aol.com', 1500.99, 'recently moved');
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Stephen', 'Taylor', '456 Elm St.', 'St. Louis', 'MO', 57252, 4185551212, 'staylor@comcast.net', 25.01, NULL);
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Donna', 'Carter', '789 Peach Ave.', 'Los Angeles', 'CA', 48252, 3135551212, 'dcarter@wow.com', 300.99, 'returning customer');
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Robert', 'Silverman', '857 Wilbur Rd.', 'Phoenix', 'AZ', 25278, 4805551212, 'rsilverman@aol.com', NULL, NULL);
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Sally', 'Victors', '534 Holler Way', 'Charleston', 'WV', 78345, 9045551212, 'svictors@wow.com', 500.76, 'new customer');
commit;

-- Note: Oracle does *not* autocommit by default! DML STATEMENTS WILL ONLY LAST FOR THE SESSION!
-- When forgetting to commit DML statements--for example, with inserts, selecting a table will display "no rows selected"!

INSERT INTO commodity VALUES (seq_com_id.nextval, 'DVD & Player', 109.00, NULL);
INSERT INTO commodity VALUES (seq_com_id.nextval, 'Cereal', 3.00, 'sugar free');
INSERT INTO commodity VALUES (seq_com_id.nextval, 'Scrabble', 29.00, 'original');
INSERT INTO commodity VALUES (seq_com_id.nextval, 'Licorice', 1.89, NULL);
INSERT INTO commodity VALUES (seq_com_id.nextval, 'Tums', 2.45, 'antacid');
commit;

INSERT INTO "order" VALUES (seq_ord_id.nextval, 1, 2, 50, 200, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 2, 3, 30, 100, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 3, 1, 6, 654, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 5, 4, 24, 972, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 3, 5, 7, 300, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 1, 2, 5, 15, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 2, 3, 40, 57, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 3, 1, 4, 300, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 5, 4, 14, 770, NULL);
INSERT INTO "order" VALUES (seq_ord_id.nextval, 3, 5, 15, 883, NULL);
commit;

select * from customer;
select * from commodity;
select * from "order";

-- 1. Display Oracle version (method 1)
SELECT * FROM v$version;

-- 2. Display Oracle version (method 2)
SELECT version FROM product_component_version WHERE product LIKE 'Oracle%';

-- 3. Display current user
SELECT user FROM dual;

-- 4. Display current day/time (formatted with AM/PM)
SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM') FROM dual;

-- 5. Display your privileges
SELECT * FROM USER_SYS_PRIVS;

-- 6. Display all user tables
SELECT table_name FROM user_tables;

-- 7. Display structure for each table
SELECT column_name, data_type, data_length FROM user_tab_columns WHERE table_name = 'CUSTOMER';
SELECT column_name, data_type, data_length FROM user_tab_columns WHERE table_name = 'COMMODITY';
SELECT column_name, data_type, data_length FROM user_tab_columns WHERE table_name = 'ORDER';

-- 8. List customer details
SELECT cus_id, cus_lname, cus_fname, cus_email FROM customer;

-- 9. List customer details with additional fields, sorted
SELECT cus_id, cus_lname, cus_fname, cus_email, cus_city, cus_state 
FROM customer 
ORDER BY cus_state DESC, cus_lname ASC;

-- 10. Find full name of customer number 3 (last name first)
SELECT cus_lname || ', ' || cus_fname AS "Full Name" FROM customer WHERE cus_id = 3;

-- 11. List customers with balance exceeding $1,000, sorted
SELECT cus_id, cus_lname, cus_fname, cus_notes AS balance FROM customer WHERE cus_notes > 1000 ORDER BY cus_notes DESC;

-- 12. List commodities and prices formatted
SELECT com_name, TO_CHAR(com_price, '$9999.99') AS price FROM commodity ORDER BY com_price ASC;

-- 13. List customer addresses formatted, ordered by zip
SELECT cus_lname || ', ' || cus_fname AS NAME, cus_city || ', ' || cus_state || ' ' || cus_zip AS ADDRESS FROM customer ORDER BY cus_zip DESC;

-- 14. List orders not including cereal
SELECT * FROM "order" WHERE com_id NOT IN (SELECT com_id FROM commodity WHERE com_name = 'Cereal');

-- 15. Customers with balance between $500 and $1,000, formatted
SELECT cus_id, cus_lname, cus_fname, TO_CHAR(cus_notes, '$9999.99') AS balance FROM customer WHERE cus_notes BETWEEN 500 AND 1000;

-- 16. Customers with balance greater than average balance
SELECT cus_id, cus_lname, cus_fname, TO_CHAR(cus_notes, '$9999.99') AS balance FROM customer WHERE cus_notes > (SELECT AVG(cus_notes) FROM customer);

-- 17. Customer total order amount sorted
SELECT o.cus_id, c.cus_lname, c.cus_fname, TO_CHAR(SUM(o.ord_total_cost), '$9999.99') AS "total orders" FROM "order" o JOIN customer c ON o.cus_id = c.cus_id GROUP BY o.cus_id, c.cus_lname, c.cus_fname ORDER BY SUM(o.ord_total_cost) DESC;

-- 18. Customers living on "Peach" street
SELECT cus_id, cus_lname, cus_fname, cus_city, cus_state FROM customer WHERE cus_city LIKE '%Peach%';

-- 19. Customers with total order amount > $1500
SELECT o.cus_id, c.cus_lname, c.cus_fname, TO_CHAR(SUM(o.ord_total_cost), '$9999.99') AS "total orders" FROM "order" o JOIN customer c ON o.cus_id = c.cus_id GROUP BY o.cus_id, c.cus_lname, c.cus_fname HAVING SUM(o.ord_total_cost) > 1500 ORDER BY SUM(o.ord_total_cost) DESC;

-- 20. Orders with 30, 40, or 50 units
SELECT cus_id, ord_num_units FROM "order" WHERE ord_num_units IN (30, 40, 50);

-- 21. Using EXISTS: Customers with at least 5 orders
SELECT c.cus_id, c.cus_lname, COUNT(o.ord_id) AS num_orders, MIN(o.ord_total_cost) AS min_order, MAX(o.ord_total_cost) AS max_order, SUM(o.ord_total_cost) AS total_orders FROM customer c JOIN "order" o ON c.cus_id = o.cus_id WHERE EXISTS (SELECT 1 FROM customer HAVING COUNT(*) >= 5) GROUP BY c.cus_id, c.cus_lname;

-- 22. Aggregate values for customers
SELECT COUNT(*) AS total_customers, COUNT(cus_notes) AS customers_with_balance, SUM(cus_notes) AS total_balance, AVG(cus_notes) AS avg_balance FROM customer;

-- 23. Count unique customers with orders
SELECT COUNT(DISTINCT cus_id) FROM "order";

-- 24. Customer orders with commodity name, sorted
SELECT c.cus_id, c.cus_lname, com.com_name, o.ord_id, TO_CHAR(o.ord_total_cost, '$9999.99') AS "order amount" FROM "order" o JOIN customer c ON o.cus_id = c.cus_id JOIN commodity com ON o.com_id = com.com_id ORDER BY o.ord_total_cost DESC;

-- 25. Modify prices for DVD players
UPDATE commodity SET com_price = 99.00 WHERE com_name = 'DVD & Player';
COMMIT;
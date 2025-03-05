USE csp21b;
-- --------------------------------------------
-- Table person
-- --------------------------------------------
DROP TABLE IF EXISTS person;

CREATE TABLE IF NOT EXISTS person (
    per_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_ssn BINARY(64) NULL,
    per_salt BINARY(64) NULL COMMENT '*only* demo purposes - do *NOT* use *salt* in the name!',
    per_fname VARCHAR(15) NOT NULL,
    per_lname VARCHAR(30) NOT NULL,
    per_street VARCHAR(30) NOT NULL,
    per_city VARCHAR(30) NOT NULL,
    per_state CHAR(2) NOT NULL,
    per_zip VARCHAR(9) NOT NULL,
    per_email VARCHAR(100) NOT NULL,
    per_dob DATE NOT NULL,
    per_type ENUM('a', 'c', 'j') NOT NULL COMMENT 'a=attorney, c=client, j=judge',
    per_notes VARCHAR(255) NULL,
    PRIMARY KEY (per_id),
    UNIQUE INDEX ux_per_ssn (per_ssn ASC)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

-- --------------------------------------------
-- Table attorney
-- --------------------------------------------

DROP TABLE IF EXISTS attorney;
CREATE TABLE IF NOT EXISTS attorney
(
    per_id SMALLINT UNSIGNED NOT NULL,
    aty_start_date DATE NOT NULL,
    aty_end_date DATE NULL DEFAULT NULL,
    aty_hourly_rate DECIMAL(5,2) NOT NULL,
    aty_years_in_practice TINYINT NOT NULL,
    aty_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_attorney_person
    FOREIGN KEY (per_id)
    REFERENCES person (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- --------------------------------------------
-- Table client
-- --------------------------------------------

DROP TABLE IF EXISTS client;
CREATE TABLE IF NOT EXISTS client
(
    per_id SMALLINT UNSIGNED NOT NULL,
    cli_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_client_person
    FOREIGN KEY (per_id)
    REFERENCES person (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- --------------------------------------------
-- Table court
-- --------------------------------------------

DROP TABLE IF EXISTS court;
CREATE TABLE IF NOT EXISTS court
(
    crt_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    crt_name VARCHAR(45) NOT NULL,
    crt_street VARCHAR(30) NOT NULL,
    crt_city VARCHAR(30) NOT NULL,
    crt_state CHAR(2) NOT NULL,
    crt_zip CHAR(9) NOT NULL,
    crt_phone BIGINT NOT NULL,
    crt_email VARCHAR(100) NOT NULL,
    crt_url VARCHAR(100) NOT NULL,
    crt_notes VARCHAR(255) NULL,
    PRIMARY KEY (crt_id)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- --------------------------------------------
-- Table judge
-- --------------------------------------------

DROP TABLE IF EXISTS judge;
CREATE TABLE IF NOT EXISTS judge
(
    per_id SMALLINT UNSIGNED NOT NULL,
    crt_id TINYINT UNSIGNED NULL DEFAULT NULL,
    jud_salary DECIMAL(8,2) NOT NULL,
    jud_years_in_practice TINYINT UNSIGNED NOT NULL,
    jud_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),
    INDEX idx_crt_id (crt_id ASC),

    CONSTRAINT fk_judge_person
    FOREIGN KEY (per_id)
    REFERENCES person (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,

    CONSTRAINT fk_judge_court
    FOREIGN KEY (crt_id)
    REFERENCES court (crt_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- --------------------------------------------
-- Table judge_hist
-- --------------------------------------------

DROP TABLE IF EXISTS judge_hist;
CREATE TABLE IF NOT EXISTS judge_hist
(
    jhs_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    jhs_crt_id TINYINT NULL,
    jhs_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    jhs_type ENUM('i', 'u', 'd') NOT NULL DEFAULT 'i',
    jhs_salary DECIMAL(8,2) NOT NULL,
    jhs_notes VARCHAR(255) NULL,
    PRIMARY KEY (jhs_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_judge_hist_judge
    FOREIGN KEY (per_id)
    REFERENCES judge (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- --------------------------------------------
-- Table case
-- --------------------------------------------
DROP TABLE IF EXISTS `case`;

CREATE TABLE IF NOT EXISTS `case` (
    cse_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    cse_type VARCHAR(45) NOT NULL,
    cse_description TEXT NOT NULL,
    cse_start_date DATE NOT NULL,
    cse_end_date DATE NULL,
    cse_notes VARCHAR(255) NULL,
    PRIMARY KEY (cse_id),
    INDEX idx_per_id (per_id ASC),
    CONSTRAINT fk_court_case_judge
        FOREIGN KEY (per_id)
        REFERENCES judge (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8
  COLLATE = utf8_unicode_ci;

-- --------------------------------------------
-- Table bar
-- --------------------------------------------
DROP TABLE IF EXISTS bar;

CREATE TABLE IF NOT EXISTS bar (
    bar_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    bar_name VARCHAR(45) NOT NULL,
    bar_notes VARCHAR(255) NULL,
    PRIMARY KEY (bar_id),
    
    INDEX idx_per_id (per_id ASC),
    
    CONSTRAINT fk_bar_attorney
        FOREIGN KEY (per_id)
        REFERENCES attorney (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8
  COLLATE = utf8_unicode_ci;

-- --------------------------------------------
-- Table specialty
-- --------------------------------------------
DROP TABLE IF EXISTS specialty;

CREATE TABLE IF NOT EXISTS specialty 
(
    spc_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    spc_type VARCHAR(45) NOT NULL,
    spc_notes VARCHAR(255) NULL,
    PRIMARY KEY (spc_id),
    
    INDEX idx_per_id (per_id ASC),
    CONSTRAINT fk_specialty_attorney
        FOREIGN KEY (per_id)
        REFERENCES attorney (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
        
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8
  COLLATE = utf8_unicode_ci;

-- --------------------------------------------
-- Table assignment
-- --------------------------------------------
DROP TABLE IF EXISTS assignment;
CREATE TABLE IF NOT EXISTS assignment
(
    asn_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_cid SMALLINT UNSIGNED NOT NULL,
    per_aid SMALLINT UNSIGNED NOT NULL,
    cse_id SMALLINT UNSIGNED NOT NULL,
    asn_notes VARCHAR(255) NULL,
    PRIMARY KEY (asn_id),

    INDEX idx_per_cid (per_cid ASC),
    INDEX idx_per_aid (per_aid ASC),
    INDEX idx_cse_id (cse_id ASC),

    UNIQUE INDEX ux_per_cid_per_aid_cse_id (per_cid ASC, per_aid ASC, cse_id ASC),

    CONSTRAINT fk_assign_case
    FOREIGN KEY (cse_id)
    REFERENCES `case` (cse_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,

    CONSTRAINT fk_assignment_client
    FOREIGN KEY (per_cid)
    REFERENCES client (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,

    CONSTRAINT fk_assignment_attorney
    FOREIGN KEY (per_aid)
    REFERENCES attorney (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- --------------------------------------------
-- Table phone
-- --------------------------------------------

DROP TABLE IF EXISTS phone;

CREATE TABLE IF NOT EXISTS phone 
(
    phn_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    phn_num BIGINT UNSIGNED NOT NULL,
    phn_type ENUM('h', 'c', 'w', 'f') NOT NULL COMMENT 'home, cell, work, fax',
    phn_notes VARCHAR(255) NULL,
    PRIMARY KEY (phn_id),
    
    INDEX idx_per_id (per_id ASC),
    CONSTRAINT fk_phone_person
        FOREIGN KEY (per_id)
        REFERENCES person (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
        
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8
  COLLATE = utf8_unicode_ci;

-- --------------------------------------------
-- Data for table person
-- --------------------------------------------
START TRANSACTION;
INSERT INTO person 
(per_id, per_ssn, per_salt, per_fname, per_lname, per_street, per_city, per_state, per_zip, per_email, per_dob, per_type, per_notes)
VALUES
(NULL, NULL, NULL, 'Steve', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', '324402222', 'srogers@comcast.net', '1923-10-03', 'c', NULL),
(NULL, NULL, NULL, 'Bruce', 'Wayne', '1007 Mountain Drive', 'Gotham', 'NY', '003208440', 'bwayne@knology.net', '1968-03-20', 'c', NULL),
(NULL, NULL, NULL, 'Peter', 'Parker', '20 Ingram Street', 'New York', 'NY', '102862341', 'parker@msn.com', '1988-09-12', 'c', NULL),
(NULL, NULL, NULL, 'Jane', 'Thompson', '13563 Ocean View Drive', 'Seattle', 'WA', '032084409', 'ithompson@gmail.com', '1978-05-08', 'c', NULL),
(NULL, NULL, NULL, 'Debra', 'Steele', '543 Oak Ln', 'Milwaukee', 'WI', '286234178', 'dsteele@verizon.net', '1994-07-19', 'c', NULL),
(NULL, NULL, NULL, 'Tony', 'Stark', '332 Palm Avenue', 'Malibu', 'CA', '902638332', 'tstark@yahoo.com', '1972-05-04', 'a', NULL),
(NULL, NULL, NULL, 'Hank', 'Pym', '2355 Brown Street', 'Cleveland', 'OH', '022348890', 'hpym@aol.com', '1980-08-28', 'a', NULL),
(NULL, NULL, NULL, 'Bob', 'Best', '4902 Avendale Avenue', 'Scottsdale', 'AZ', '872638332', 'bbest@yahoo.com', '1992-02-10', 'a', NULL),
(NULL, NULL, NULL, 'Sandra', 'Dole', '87912 Lawrence Ave', 'Atlanta', 'GA', '002348890', 'sdole@gmail.com', '1990-01-26', 'a', NULL),
(NULL, NULL, NULL, 'Ben', 'Avery', '6432 Thunderbird Ln', 'Sioux Falls', 'SD', '562638332', 'bavery@hotmail.com', '1983-12-24', 'a', NULL),
(NULL, NULL, NULL, 'Arthur', 'Curry', '3304 Euclid Avenue', 'Miami', 'FL', '000219932', 'acurry@gmail.com', '1975-12-15', 'j', NULL),
(NULL, NULL, NULL, 'Diana', 'Prince', '944 Green Street', 'Las Vegas', 'NV', '332048823', 'dprice@sympatico.com', '1980-08-22', 'j', NULL),
(NULL, NULL, NULL, 'Adam', 'Jurris', '98435 Valencia Dr.', 'Gulf Shores', 'AL', '870219932', 'ajurris@gmx.com', '1995-01-31', 'j', NULL),
(NULL, NULL, NULL, 'Judy', 'Sleen', '56343 Rover Ct.', 'Billings', 'MT', '672048823', 'jsleen@sympatico.com', '1970-03-22', 'j', NULL),
(NULL, NULL, NULL, 'Bill', 'Neiderheim', '43567 Netherland Blvd', 'South Bend', 'IN', '320219932', 'bneiderheim@comcast.net', '1982-03-13', 'j', NULL);
COMMIT;

-- --------------------------------------------
-- Data for table phone
-- --------------------------------------------
START TRANSACTION;

INSERT INTO phone (phn_id, per_id, phn_num, phn_type, phn_notes)
VALUES
(NULL, 1, '8032288827', 'c', NULL),
(NULL, 2, '2052338293', 'h', NULL),
(NULL, 4, '1034325598', 'w', 'has two office numbers'),
(NULL, 5, '6402338494', 'w', NULL),
(NULL, 6, '5508329842', 'f', 'fax number not currently working'),
(NULL, 7, '8202052203', 'c', 'prefers home calls'),
(NULL, 8, '4008338294', 'h', NULL),
(NULL, 9, '7654328912', 'w', NULL),
(NULL, 10, '5463721984', 'f', 'work fax number'),
(NULL, 11, '4537821902', 'h', 'prefers cell phone calls'),
(NULL, 12, '7867821902', 'w', 'best number to reach'),
(NULL, 13, '4537821654', 'w', 'call during lunch'),
(NULL, 14, '3721821902', 'c', 'prefers cell phone calls'),
(NULL, 15, '9217821945', 'f', 'use for faxing legal docs');

COMMIT;

-- --------------------------------------------
-- Data for table client
-- --------------------------------------------
START TRANSACTION;
INSERT INTO client
(per_id, cli_notes)
VALUES
(1, NULL),
(2, NULL),
(3, NULL),
(4, NULL),
(5, NULL);
COMMIT;

-- --------------------------------------------
-- Data for table attorney
-- --------------------------------------------
START TRANSACTION;
INSERT INTO attorney
(per_id, aty_start_date, aty_end_date, aty_hourly_rate, aty_years_in_practice, aty_notes)
VALUES
(6, '2006-06-12', NULL, 85, 5, NULL),
(7, '2003-08-20', NULL, 130, 28, NULL),
(8, '2009-12-12', NULL, 70, 17, NULL), 
(9, '2008-06-08', NULL, 78, 13, NULL),
(10, '2011-09-12', NULL, 60, 24, NULL);
COMMIT;

-- --------------------------------------------
-- Data for table bar
-- --------------------------------------------
START TRANSACTION;

INSERT INTO bar
(bar_id, per_id, bar_name, bar_notes)
VALUES
(NULL, 6, 'Florida bar', NULL),
(NULL, 7, 'Alabama bar', NULL),
(NULL, 8, 'Georgia bar', NULL),
(NULL, 9, 'Michigan bar', NULL),
(NULL, 10, 'South Carolina bar', NULL),
(NULL, 6, 'Montana bar', NULL),
(NULL, 7, 'Arizona Bar', NULL),
(NULL, 8, 'Nevada Bar', NULL),
(NULL, 9, 'New York Bar', NULL),
(NULL, 10, 'New York Bar', NULL),
(NULL, 6, 'Mississippi Bar', NULL),
(NULL, 7, 'California Bar', NULL),
(NULL, 8, 'Illinois Bar', NULL),
(NULL, 9, 'Indiana Bar', NULL),
(NULL, 10, 'Illinois Bar', NULL),
(NULL, 6, 'Tallahassee Bar', NULL),
(NULL, 7, 'Ocala Bar', NULL),
(NULL, 8, 'Bay County Bar', NULL),
(NULL, 9, 'Cincinatti Bar', NULL);

COMMIT;

-- --------------------------------------------
-- Data for table specialty
-- --------------------------------------------
START TRANSACTION;
INSERT INTO specialty
(spc_id, per_id, spc_type, spc_notes)
VALUES
(NULL, 6, 'business', NULL),
(NULL, 7, 'traffic', NULL), -- Corrected: Added closing single quote
(NULL, 8, 'bankruptcy', NULL),
(NULL, 9, 'insurance', NULL),
(NULL, 10, 'judicial', NULL),
(NULL, 6, 'environmental', NULL),
(NULL, 7, 'criminal', NULL),
(NULL, 8, 'real estate', NULL),
(NULL, 9, 'malpractice', NULL);
COMMIT;

-- --------------------------------------------
-- Data for table court
-- --------------------------------------------
START TRANSACTION;

INSERT INTO court
(crt_id, crt_name, crt_street, crt_city, crt_state, crt_zip, crt_phone, crt_email, crt_url, crt_notes)
VALUES
(NULL, 'leon county circuit court', '301 south monroe street', 'tallahassee', 'fl', 323035292, 8506065504, 'lccc@us.fl.gov', 'http://www.leoncountycircuitcourt.gov/', NULL),
(NULL, 'leon country traffic court', '1921 thomasville road', 'tallahassee', 'fl', 323035292, 8505774100, 'lctc@us.fl.gov', 'http://www.leoncountytrafficcourt.gov/', NULL),
(NULL, 'florida supreme court', '500 south duval street', 'tallahassee', 'fl', 323035292, 8504880125, 'fsc@us.fl.gov', 'http://www.floridasupremecourt.org/', NULL),
(NULL, 'orange county courthouse', '424 north orange avenue', 'orlando', 'fl', 328012248, 4078362000, 'occ@us.fl.gov', 'http://www.ninthcircuit.org/', NULL),
(NULL, 'fifth district court of appeal', '300 south beach street', 'daytona beach', 'fl', 321158763, 3862258600, '5dca@us.fl.gov', 'http://www.5dca.org/', NULL);

COMMIT;

-- --------------------------------------------
-- Data for table judge
-- --------------------------------------------
START TRANSACTION;
INSERT INTO judge
(per_id, crt_id, jud_salary, jud_years_in_practice, jud_notes)
VALUES
(11, 5, 150000, 10, NULL),
(12, 4, 185000, 3, NULL),
(13, 4, 135000, 2, NULL),
(14, 3, 170000, 6, NULL),
(15, 1, 120000, 1, NULL);
COMMIT;

-- --------------------------------------------
-- Data for table judge_hist
-- --------------------------------------------
START TRANSACTION;
INSERT INTO judge_hist
(jhs_id, per_id, jhs_crt_id, jhs_date, jhs_type, jhs_salary, jhs_notes)
VALUES
(NULL, 11, 3, '2009-01-16', 'i', 130000, NULL),
(NULL, 12, 2, '2010-05-27', 'i', 140000, NULL),
(NULL, 13, 5, '2000-01-02', 'i', 115000, NULL),
(NULL, 13, 4, '2005-07-05', 'i', 135000, NULL),
(NULL, 14, 4, '2008-12-09', 'i', 155000, NULL),
(NULL, 15, 1, '2011-03-17', 'i', 120000, 'freshman justice'),
(NULL, 11, 5, '2010-07-05', 'i', 150000, 'assigned to another court'),
(NULL, 12, 4, '2012-10-08', 'i', 165000, 'became chief justice'),
(NULL, 14, 3, '2009-04-19', 'i', 170000, 'reassigned to court based upon local area population growth');
COMMIT;

-- --------------------------------------------
-- Data for table case
-- --------------------------------------------
START TRANSACTION;

INSERT INTO `case`
(cse_id, per_id, cse_type, cse_description, cse_start_date, cse_end_date, cse_notes)
VALUES
(NULL, 13, 'civil', 'Client says that his logo is being used without his consent to promote a rival business', '2010-09-09', NULL, 'copyright infringement'),
(NULL, 12, 'criminal', 'Client is charged with assaulting her husband during an argument', '2009-11-18', '2010-12-23', 'assault'),
(NULL, 14, 'civil', 'Client broke an ankle while shopping at a local grocery store. No wet floor sign was posted although the floor had just been mopped', '2008-05-06', '2008-07-23', 'slip and fall'),
(NULL, 11, 'criminal', 'Client was charged with stealing several televisions from his former place of employment. Client has a solid alibi', '2011-05-20', NULL, 'grand theft'),
(NULL, 13, 'criminal', 'Client charged with possession of 10 grams of cocaine, allegedly found in his glove box by state police', '2011-06-05', NULL, 'possession of narcotics'),
(NULL, 14, 'civil', 'Client alleges newspaper printed false information about his personal activities while he ran a large laundry business in a small town.', '2007-01-19', '2007-05-20', 'defamation'),
(NULL, 12, 'criminal', 'Client charged with the murder of his co-worker over a lover’s feud. Client has no alibi', '2010-03-20', NULL, 'murder'),
(NULL, 15, 'civil', 'Client made the horrible mistake of selecting a degree other than IT and had to declare bankruptcy.', '2012-01-26', '2013-02-28', 'bankruptcy');

COMMIT;

-- --------------------------------------------
-- Data for table assignment
-- --------------------------------------------
START TRANSACTION;
INSERT INTO assignment
(asn_id, per_cid, per_aid, cse_id, asn_notes)
VALUES
(NULL, 1, 6, 7, NULL),
(NULL, 2, 6, 6, NULL),
(NULL, 3, 7, 2, NULL),
(NULL, 4, 8, 2, NULL),
(NULL, 5, 9, 5, NULL),
(NULL, 1, 10, 1, NULL),
(NULL, 2, 6, 3, NULL),
(NULL, 3, 7, 8, NULL),
(NULL, 4, 8, 8, NULL),
(NULL, 5, 9, 8, NULL),
(NULL, 4, 10, 4, NULL);
COMMIT;

DROP PROCEDURE IF EXISTS CreatePersonSSN;
DELIMITER $$
CREATE PROCEDURE CreatePersonSSN()
BEGIN
    DECLARE x, y INT;
    SET x = 1;
    SELECT COUNT(*) INTO y FROM person;
    WHILE x <= y DO
        SET @salt = RANDOM_BYTES(64);
        SET @ran_num = FLOOR(RAND() * (999999999 - 111111111 + 1)) + 111111111;
        SET @ssn = UNHEX(SHA2(CONCAT(@salt, @ran_num), 512)); -- Corrected line
        UPDATE person
        SET per_ssn = @ssn, per_salt = @salt
        WHERE per_id = x;
        SET x = x + 1;
    END WHILE;
END$$
DELIMITER ;
CALL CreatePersonSSN();

SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'csp21b';

SELECT now() AS report_date, table_schema, table_name, table_rows
FROM information_schema.tables
natural join information_schema.columns
WHERE tables.table_schema = 'csp21b'
group by table_schema, table_name, table_rows
ORDER by table_name;

-- --------------------------------------------
-- Report 1
-- --------------------------------------------
CREATE VIEW AttorneyDetails AS
SELECT
    CONCAT(p.per_fname, ' ', p.per_lname) AS full_name,
    CONCAT(p.per_street, ', ', p.per_city, ', ', p.per_state, ' ', p.per_zip) AS full_address,
    TIMESTAMPDIFF(YEAR, p.per_dob, CURDATE()) AS age,
    CONCAT('$', FORMAT(a.aty_hourly_rate, 2)) AS hourly_rate,
    b.bar_name,
    s.spc_type
FROM person p
JOIN attorney a ON p.per_id = a.per_id
LEFT JOIN bar b ON a.per_id = b.per_id
LEFT JOIN specialty s ON a.per_id = s.per_id
ORDER BY p.per_lname;
SELECT * FROM AttorneyDetails 

-- --------------------------------------------
-- Report 2
-- --------------------------------------------
DELIMITER $$
CREATE PROCEDURE JudgesBirthMonths()
BEGIN
    SELECT
        MONTHNAME(p.per_dob) AS birth_month,
        COUNT(*) AS judge_count
    FROM person p
    JOIN judge j ON p.per_id = j.per_id
    GROUP BY MONTH(p.per_dob)
    ORDER BY MONTH(p.per_dob);
END$$
DELIMITER ;
-- --------------------------------------------
-- Report 3
-- --------------------------------------------
DELIMITER $$
CREATE PROCEDURE CaseJudgeDetails()
BEGIN
    SELECT
        c.cse_type,
        c.cse_description,
        CONCAT(p.per_fname, ' ', p.per_lname) AS judge_name,
        CONCAT(p.per_street, ', ', p.per_city, ', ', p.per_state, ' ', p.per_zip) AS judge_address,
        GROUP_CONCAT(CONCAT(SUBSTRING(ph.phn_num, 1, 3), '-', SUBSTRING(ph.phn_num, 4, 3), '-', SUBSTRING(ph.phn_num, 7, 4)) SEPARATOR ', ') AS phone_numbers,
        j.jud_years_in_practice,
        c.cse_start_date,
        c.cse_end_date
    FROM `case` c
    JOIN person p ON c.per_id = p.per_id
    JOIN judge j ON p.per_id = j.per_id
    LEFT JOIN phone ph ON p.per_id = ph.per_id
    GROUP BY c.cse_id
    ORDER BY p.per_lname;
END$$
DELIMITER ;

-- --------------------------------------------
-- Report 4
-- --------------------------------------------
DELIMITER $$
CREATE TRIGGER JudgeInsertHistory
AFTER INSERT ON judge
FOR EACH ROW
BEGIN
    INSERT INTO judge_hist (per_id, jhs_crt_id, jhs_salary, jhs_notes)
    SELECT NEW.per_id, NEW.crt_id, jud_salary, jud_notes FROM judge WHERE per_id = NEW.per_id;
END$$
DELIMITER ;

-- --------------------------------------------
-- Report 5
-- --------------------------------------------
DELIMITER $$
CREATE TRIGGER JudgeUpdateHistory
AFTER UPDATE ON judge
FOR EACH ROW
BEGIN
    INSERT INTO judge_hist (per_id, jhs_crt_id, jhs_salary, jhs_notes, jhs_type)
    SELECT NEW.per_id, NEW.crt_id, jud_salary, jud_notes, 'u' FROM judge WHERE per_id = NEW.per_id;
END$$
DELIMITER ;
-- --------------------------------------------
-- Report 6
-- --------------------------------------------
DELIMITER $$
CREATE PROCEDURE one_time_add_judge()
BEGIN
    INSERT INTO person (per_fname, per_lname, per_street, per_city, per_state, per_zip, per_email, per_dob, per_type) VALUES ('New', 'Judge', '123 Main St', 'Anytown', 'CA', '91234', 'newjudge@example.com', '1985-01-01', 'j');
    INSERT INTO judge (per_id, crt_id, jud_salary, jud_years_in_practice) VALUES (LAST_INSERT_ID(), 1, 100000, 5);
END$$
DELIMITER ;

CREATE EVENT add_judge_event
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
	CALL one_time_add_judge();


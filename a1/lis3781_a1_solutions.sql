-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema csp21b
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `csp21b` ;

-- -----------------------------------------------------
-- Schema csp21b
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `csp21b` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `csp21b` ;

-- -----------------------------------------------------
-- Table `csp21b`.`job`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csp21b`.`job` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `csp21b`.`job` (
  `job_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_title` VARCHAR(45) NOT NULL,
  `job_notes` VARCHAR(255) NULL,
  PRIMARY KEY (`job_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `csp21b`.`employee`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csp21b`.`employee` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `csp21b`.`employee` (
  `emp_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_id` TINYINT UNSIGNED NOT NULL,
  `emp_ssn` INT(9) UNSIGNED ZEROFILL NOT NULL,
  `emp_fname` VARCHAR(15) NOT NULL,
  `emp_lname` VARCHAR(30) NOT NULL,
  `emp_dob` DATE NOT NULL,
  `emp_start_date` DATE NOT NULL,
  `emp_end_date` DATE NULL,
  `emp_salary` DECIMAL(8,2) NOT NULL,
  `emp_street` VARCHAR(30) NOT NULL,
  `emp_city` VARCHAR(20) NOT NULL,
  `emp_state` CHAR(2) NOT NULL,
  `emp_zip` INT(9) UNSIGNED ZEROFILL NOT NULL,
  `emp_phone` BIGINT UNSIGNED NOT NULL,
  `emp_email` VARCHAR(100) NOT NULL,
  `emp_notes` VARCHAR(255) NULL,
  PRIMARY KEY (`emp_id`),
  INDEX `fk_employee_job1_idx` (`job_id` ASC) VISIBLE,
  UNIQUE INDEX `emp_ssn_UNIQUE` (`emp_ssn` ASC) VISIBLE,
  CONSTRAINT `fk_employee_job1`
    FOREIGN KEY (`job_id`)
    REFERENCES `csp21b`.`job` (`job_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `csp21b`.`benefit`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csp21b`.`benefit` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `csp21b`.`benefit` (
  `ben_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ben_name` VARCHAR(45) NOT NULL,
  `ben_notes` VARCHAR(255) NULL,
  PRIMARY KEY (`ben_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `csp21b`.`plan`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csp21b`.`plan` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `csp21b`.`plan` (
  `pln_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `emp_id` SMALLINT UNSIGNED NOT NULL,
  `ben_id` TINYINT UNSIGNED NOT NULL,
  `pln_type` ENUM('single', 'spouse', 'family') NOT NULL,
  `pln_cost` DECIMAL(6,2) UNSIGNED NOT NULL,
  `pln_election_date` DATE NOT NULL,
  `pln_notes` VARCHAR(255) NULL,
  PRIMARY KEY (`pln_id`),
  INDEX `fk_plan_employee1_idx` (`emp_id` ASC) VISIBLE,
  INDEX `fk_plan_benefit1_idx` (`ben_id` ASC) VISIBLE,
  CONSTRAINT `fk_plan_employee1`
    FOREIGN KEY (`emp_id`)
    REFERENCES `csp21b`.`employee` (`emp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_plan_benefit1`
    FOREIGN KEY (`ben_id`)
    REFERENCES `csp21b`.`benefit` (`ben_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `csp21b`.`emp_hist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csp21b`.`emp_hist` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `csp21b`.`emp_hist` (
  `eht_id` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `emp_id` SMALLINT UNSIGNED NULL,
  `eht_date` DATETIME NOT NULL DEFAULT current_timestamp,
  `eht_type` ENUM('i', 'u', 'd') NOT NULL DEFAULT 'i',
  `eht_job_id` TINYINT UNSIGNED NOT NULL,
  `eht_emp_salary` DECIMAL(8,2) NOT NULL,
  `eht_usr_changed` VARCHAR(30) NOT NULL,
  `eht_reason` VARCHAR(45) NOT NULL,
  `eht_notes` VARCHAR(255) NULL,
  PRIMARY KEY (`eht_id`),
  INDEX `fk_emp_hist_employee1_idx` (`emp_id` ASC) VISIBLE,
  CONSTRAINT `fk_emp_hist_employee1`
    FOREIGN KEY (`emp_id`)
    REFERENCES `csp21b`.`employee` (`emp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `csp21b`.`dependent`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csp21b`.`dependent` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `csp21b`.`dependent` (
  `dep_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `emp_id` SMALLINT UNSIGNED NOT NULL,
  `dep_added` DATE NOT NULL,
  `dep_ssn` INT(9) UNSIGNED ZEROFILL NOT NULL,
  `dep_fname` VARCHAR(15) NOT NULL,
  `dep_lname` VARCHAR(30) NOT NULL,
  `dep_dob` DATE NOT NULL,
  `dep_relation` VARCHAR(20) NOT NULL,
  `dep_street` VARCHAR(30) NOT NULL,
  `dep_city` VARCHAR(20) NOT NULL,
  `dep_state` CHAR(2) NOT NULL,
  `dep_zip` INT(9) UNSIGNED ZEROFILL NOT NULL,
  `dep_phone` BIGINT UNSIGNED NOT NULL,
  `dep_email` VARCHAR(100) NULL,
  `dep_notes` VARCHAR(255) NULL,
  PRIMARY KEY (`dep_id`),
  INDEX `fk_dependent_employee_idx` (`emp_id` ASC) VISIBLE,
  UNIQUE INDEX `dep_ssn_UNIQUE` (`dep_ssn` ASC) VISIBLE,
  CONSTRAINT `fk_dependent_employee`
    FOREIGN KEY (`emp_id`)
    REFERENCES `csp21b`.`employee` (`emp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `csp21b`.`job`
-- -----------------------------------------------------
START TRANSACTION;
USE `csp21b`;
INSERT INTO `csp21b`.`job` (`job_id`, `job_title`, `job_notes`) VALUES (DEFAULT, 'Software Engineer', NULL);
INSERT INTO `csp21b`.`job` (`job_id`, `job_title`, `job_notes`) VALUES (DEFAULT, 'Data Analyst', NULL);
INSERT INTO `csp21b`.`job` (`job_id`, `job_title`, `job_notes`) VALUES (DEFAULT, 'Project Manager', NULL);
INSERT INTO `csp21b`.`job` (`job_id`, `job_title`, `job_notes`) VALUES (DEFAULT, 'System Administrator', NULL);
INSERT INTO `csp21b`.`job` (`job_id`, `job_title`, `job_notes`) VALUES (DEFAULT, 'HR Specialist', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `csp21b`.`employee`
-- -----------------------------------------------------
START TRANSACTION;
USE `csp21b`;
INSERT INTO `csp21b`.`employee` (`emp_id`, `job_id`, `emp_ssn`, `emp_fname`, `emp_lname`, `emp_dob`, `emp_start_date`, `emp_end_date`, `emp_salary`, `emp_street`, `emp_city`, `emp_state`, `emp_zip`, `emp_phone`, `emp_email`, `emp_notes`) VALUES (DEFAULT, 1, 123456789, 'John', 'Doe', '1985-01-15', '2020-06-01', NULL, 85000, '123 Main St', 'Springfield', 'IL', 627040123, 1234567890, 'john.doe@example.com', NULL);
INSERT INTO `csp21b`.`employee` (`emp_id`, `job_id`, `emp_ssn`, `emp_fname`, `emp_lname`, `emp_dob`, `emp_start_date`, `emp_end_date`, `emp_salary`, `emp_street`, `emp_city`, `emp_state`, `emp_zip`, `emp_phone`, `emp_email`, `emp_notes`) VALUES (DEFAULT, 2, 987654321, 'Jane', 'Smith', '1990-02-20', '2018-09-15', '2020-04-14', 70000, '456 Oak St', 'Madison', 'WI', 537030987, 9876543210, 'jane.smith@example.com', NULL);
INSERT INTO `csp21b`.`employee` (`emp_id`, `job_id`, `emp_ssn`, `emp_fname`, `emp_lname`, `emp_dob`, `emp_start_date`, `emp_end_date`, `emp_salary`, `emp_street`, `emp_city`, `emp_state`, `emp_zip`, `emp_phone`, `emp_email`, `emp_notes`) VALUES (DEFAULT, 3, 555667777, 'Alice', 'Johnson', '1982-12-05', '2015-03-30', NULL, 95000, '789 Pine Rd', 'Seattle', 'WA', 981010555, 5551234567, 'alice.johnson@example.com', NULL);
INSERT INTO `csp21b`.`employee` (`emp_id`, `job_id`, `emp_ssn`, `emp_fname`, `emp_lname`, `emp_dob`, `emp_start_date`, `emp_end_date`, `emp_salary`, `emp_street`, `emp_city`, `emp_state`, `emp_zip`, `emp_phone`, `emp_email`, `emp_notes`) VALUES (DEFAULT, 4, 444556666, 'Bob', 'Williams', '1978-07-22', '2012-01-01', NULL, 80000, '321 Cedar Ave', 'Austin', 'TX', 787020444, 4445556666, 'bob.williams@example.com', NULL);
INSERT INTO `csp21b`.`employee` (`emp_id`, `job_id`, `emp_ssn`, `emp_fname`, `emp_lname`, `emp_dob`, `emp_start_date`, `emp_end_date`, `emp_salary`, `emp_street`, `emp_city`, `emp_state`, `emp_zip`, `emp_phone`, `emp_email`, `emp_notes`) VALUES (DEFAULT, 5, 666778899, 'Eve', 'Miller', '1995-11-11', '2021-10-10', NULL, 60000, '987 Elm St', 'Denver', 'CO', 802030987, 6667788999, 'eve.miller@example.com', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `csp21b`.`benefit`
-- -----------------------------------------------------
START TRANSACTION;
USE `csp21b`;
INSERT INTO `csp21b`.`benefit` (`ben_id`, `ben_name`, `ben_notes`) VALUES (DEFAULT, 'Health Insurance', NULL);
INSERT INTO `csp21b`.`benefit` (`ben_id`, `ben_name`, `ben_notes`) VALUES (DEFAULT, 'Dental Insurance', NULL);
INSERT INTO `csp21b`.`benefit` (`ben_id`, `ben_name`, `ben_notes`) VALUES (DEFAULT, 'Vision Insurance', NULL);
INSERT INTO `csp21b`.`benefit` (`ben_id`, `ben_name`, `ben_notes`) VALUES (DEFAULT, 'Life Insurance', NULL);
INSERT INTO `csp21b`.`benefit` (`ben_id`, `ben_name`, `ben_notes`) VALUES (DEFAULT, 'Disability Insurance', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `csp21b`.`plan`
-- -----------------------------------------------------
START TRANSACTION;
USE `csp21b`;
INSERT INTO `csp21b`.`plan` (`pln_id`, `emp_id`, `ben_id`, `pln_type`, `pln_cost`, `pln_election_date`, `pln_notes`) VALUES (DEFAULT, 1, 1, 'Family', 150, '2021-01-01', NULL);
INSERT INTO `csp21b`.`plan` (`pln_id`, `emp_id`, `ben_id`, `pln_type`, `pln_cost`, `pln_election_date`, `pln_notes`) VALUES (DEFAULT, 2, 2, 'Spouse', 50, '2022-05-01', NULL);
INSERT INTO `csp21b`.`plan` (`pln_id`, `emp_id`, `ben_id`, `pln_type`, `pln_cost`, `pln_election_date`, `pln_notes`) VALUES (DEFAULT, 3, 3, 'Single', 25, '2023-03-01', NULL);
INSERT INTO `csp21b`.`plan` (`pln_id`, `emp_id`, `ben_id`, `pln_type`, `pln_cost`, `pln_election_date`, `pln_notes`) VALUES (DEFAULT, 4, 4, 'Family', 200, '2021-07-01', NULL);
INSERT INTO `csp21b`.`plan` (`pln_id`, `emp_id`, `ben_id`, `pln_type`, `pln_cost`, `pln_election_date`, `pln_notes`) VALUES (DEFAULT, 5, 5, 'Family', 180, '2022-11-01', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `csp21b`.`emp_hist`
-- -----------------------------------------------------
START TRANSACTION;
USE `csp21b`;
INSERT INTO `csp21b`.`emp_hist` (`eht_id`, `emp_id`, `eht_date`, `eht_type`, `eht_job_id`, `eht_emp_salary`, `eht_usr_changed`, `eht_reason`, `eht_notes`) VALUES (DEFAULT, 1, '2022-06-01 09:00:00', 'i', 1, 87000, 'test', 'Promotion', NULL);
INSERT INTO `csp21b`.`emp_hist` (`eht_id`, `emp_id`, `eht_date`, `eht_type`, `eht_job_id`, `eht_emp_salary`, `eht_usr_changed`, `eht_reason`, `eht_notes`) VALUES (DEFAULT, 2, '2021-03-01 10:00:00', 'u', 2, 70000, 'test', 'Demotion ', NULL);
INSERT INTO `csp21b`.`emp_hist` (`eht_id`, `emp_id`, `eht_date`, `eht_type`, `eht_job_id`, `eht_emp_salary`, `eht_usr_changed`, `eht_reason`, `eht_notes`) VALUES (DEFAULT, 3, '2020-12-15 15:30:00', 'i', 3, 97000, 'test', 'New hire', NULL);
INSERT INTO `csp21b`.`emp_hist` (`eht_id`, `emp_id`, `eht_date`, `eht_type`, `eht_job_id`, `eht_emp_salary`, `eht_usr_changed`, `eht_reason`, `eht_notes`) VALUES (DEFAULT, 4, '2019-08-20 11:45:00', 'u', 4, 82000, 'test', 'Annual salary adjustment', NULL);
INSERT INTO `csp21b`.`emp_hist` (`eht_id`, `emp_id`, `eht_date`, `eht_type`, `eht_job_id`, `eht_emp_salary`, `eht_usr_changed`, `eht_reason`, `eht_notes`) VALUES (DEFAULT, 5, '2021-10-10 08:00:00', 'i', 5, 60000, 'test', 'Annual salary adjustment', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `csp21b`.`dependent`
-- -----------------------------------------------------
START TRANSACTION;
USE `csp21b`;
INSERT INTO `csp21b`.`dependent` (`dep_id`, `emp_id`, `dep_added`, `dep_ssn`, `dep_fname`, `dep_lname`, `dep_dob`, `dep_relation`, `dep_street`, `dep_city`, `dep_state`, `dep_zip`, `dep_phone`, `dep_email`, `dep_notes`) VALUES (DEFAULT, 1, '2021-01-01', 111223333, 'Emma', 'Doe', '2010-03-25', 'Daughter', '123 Main St', 'Springfield', 'IL', 627040123, 1234567890, NULL, NULL);
INSERT INTO `csp21b`.`dependent` (`dep_id`, `emp_id`, `dep_added`, `dep_ssn`, `dep_fname`, `dep_lname`, `dep_dob`, `dep_relation`, `dep_street`, `dep_city`, `dep_state`, `dep_zip`, `dep_phone`, `dep_email`, `dep_notes`) VALUES (DEFAULT, 2, '2022-05-01', 222334444, 'Tom', 'Smith', '2013-05-18', 'Son', '456 Oak St', 'Madison', 'WI', 537030987, 9876543210, NULL, NULL);
INSERT INTO `csp21b`.`dependent` (`dep_id`, `emp_id`, `dep_added`, `dep_ssn`, `dep_fname`, `dep_lname`, `dep_dob`, `dep_relation`, `dep_street`, `dep_city`, `dep_state`, `dep_zip`, `dep_phone`, `dep_email`, `dep_notes`) VALUES (DEFAULT, 3, '2023-03-01', 333445555, 'Liam', 'Johnson', '2016-08-12', 'Son', '789 Pine Rd', 'Seattle', 'WA', 981010555, 5551234567, NULL, NULL);
INSERT INTO `csp21b`.`dependent` (`dep_id`, `emp_id`, `dep_added`, `dep_ssn`, `dep_fname`, `dep_lname`, `dep_dob`, `dep_relation`, `dep_street`, `dep_city`, `dep_state`, `dep_zip`, `dep_phone`, `dep_email`, `dep_notes`) VALUES (DEFAULT, 4, '2021-07-01', 444556666, 'Sophia', 'Williams', '2008-12-20', 'Daughter', '321 Cedar Ave', 'Austin', 'TX', 787020444, 4445556666, NULL, NULL);
INSERT INTO `csp21b`.`dependent` (`dep_id`, `emp_id`, `dep_added`, `dep_ssn`, `dep_fname`, `dep_lname`, `dep_dob`, `dep_relation`, `dep_street`, `dep_city`, `dep_state`, `dep_zip`, `dep_phone`, `dep_email`, `dep_notes`) VALUES (DEFAULT, 5, '2022-11-01', 555667777, 'Mia', 'Miller', '2015-02-10', 'Daughter', '987 Elm St', 'Denver', 'CO', 802030987, 6667788999, NULL, NULL);

COMMIT;

-- 1
SELECT
    emp_id,
    emp_fname,
    emp_lname,
    CONCAT(emp_street, ", ", emp_city, ", ", emp_state, " ", SUBSTRING(emp_zip, 1, 5), "-", SUBSTRING(emp_zip, 6, 4)) AS address,
    CONCAT("(", SUBSTRING(emp_phone, 1, 3), ") ", SUBSTRING(emp_phone, 4, 3), "-", SUBSTRING(emp_phone, 7, 4)) AS phone_num,
    CONCAT(SUBSTRING(emp_ssn, 1, 3), "-", SUBSTRING(emp_ssn, 4, 2), "-", SUBSTRING(emp_ssn, 6, 4)) AS emp_ssn,
    job_title
FROM
    job AS j, employee AS e
WHERE
    j.job_id = e.job_id
ORDER BY
    emp_lname DESC;

-- 2
SELECT
    e.emp_id,
    e.emp_fname,
    e.emp_lname,
    h.eht_date,
    h.eht_job_id,
    j.job_title,
    h.eht_emp_salary,
    h.eht_notes
FROM
    employee e,
    emp_hist h,
    job j
WHERE
    e.emp_id = h.emp_id
    AND h.eht_job_id = j.job_id
ORDER BY
    e.emp_id,
    h.eht_date;

--3
SELECT
    employee.emp_fname,
    employee.emp_lname,
    employee.emp_dob,
    TIMESTAMPDIFF(YEAR, employee.emp_dob, CURDATE()) AS emp_age,
    dependent.dep_fname,
    dependent.dep_lname,
    dependent.dep_relation,
    dependent.dep_dob,
    TIMESTAMPDIFF(YEAR, dependent.dep_dob, CURDATE()) AS dep_age
FROM
    employee
    NATURAL JOIN dependent
ORDER BY
    employee.emp_lname;

--4
START TRANSACTION;

SELECT * FROM job;

UPDATE job
SET job_title = 'owner'
WHERE job_id = 1;

SELECT * FROM job;

--5 
DELIMITER //

CREATE PROCEDURE insert_benefit()
BEGIN
    SELECT * FROM benefit;

    INSERT INTO benefit
    (ben_name, ben_notes)
    VALUES
    ('new benefit', 'testing');

    SELECT * FROM benefit;
END //

DELIMITER ;

CALL insert_benefit();

--6
SELECT
    emp_id,
    emp_fname,
    emp_lname,
    emp_ssn,
    emp_email,
    dep_lname,
    dep_fname,
    dep_ssn,
    dep_street,
    emp_city,
    dep_state,
    emp_zip,
    dep_phone
FROM
    employee
    NATURAL LEFT OUTER JOIN dependent
ORDER BY
    emp_lname;

SELECT
    emp_id,
    CONCAT(emp_lname, ', ', emp_fname) AS employee,
    CONCAT(SUBSTRING(emp_ssn, 1, 3), '-', SUBSTRING(emp_ssn, 4, 2), '-', SUBSTRING(emp_ssn, 6, 4)) AS emp_ssn,
    emp_email AS email,
    CONCAT(dep_lname, ', ', dep_fname) AS dependent,
    CONCAT(SUBSTRING(dep_ssn, 1, 3), '-', SUBSTRING(dep_ssn, 4, 2), '-', SUBSTRING(dep_ssn, 6, 4)) AS dep_ssn,
    CONCAT(dep_street, ', ', emp_city, ', ', dep_state, ' ', SUBSTRING(emp_zip, 1, 5), '-', SUBSTRING(emp_zip, 6, 4)) AS address,
    CONCAT('(', SUBSTRING(dep_phone, 1, 3), ') ', SUBSTRING(dep_phone, 4, 3), '-', SUBSTRING(dep_phone, 7, 4)) AS phone_num
FROM
    employee
    NATURAL LEFT OUTER JOIN dependent
ORDER BY
    emp_lname;

--7
DELIMITER //

CREATE TRIGGER trg_employee_after_insert
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO emp_hist
    (eht_id, eht_date, eht_type, eht_job_id, eht_emp_salary, eht_usr_changed, eht_reason, eht_notes)
    VALUES
    (NEW.emp_id, NOW(), 'I', NEW.job_id, NEW.emp_salary, USER(), 'new employee', NEW.emp_notes);
END //

DELIMITER ;

INSERT INTO employee
(emp_id, job_id, emp_ssn, emp_fname, emp_lname, emp_dob, emp_start_date, emp_end_date, emp_salary, emp_street, emp_city, emp_state, emp_zip, emp_phone, emp_email, emp_notes)
VALUES
(3, 123456689, 'Rocky', 'Balboa', '1976-07-25', '1999-01-01', NULL, 59000.00, '457 Mockingbird Ln', 'Boise', 'ID', 837074532, 987654321, 'rbalboa@aol.com', 'meat packer');

--8
SELECT COUNT(eht_id), eht_job_id
FROM emp_hist
GROUP BY eht_job_id
ORDER BY COUNT(eht_id), eht_job_id DESC;

--9
SELECT COUNT(eht_id), eht_job_id
FROM emp_hist
GROUP BY eht_job_id
HAVING COUNT(eht_id) > 1
ORDER BY eht_job_id;


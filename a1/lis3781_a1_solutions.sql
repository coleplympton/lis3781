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

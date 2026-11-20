-- =====================================================================
-- schema.sql: tables, triggers and a view
-- Digital Student Payment and Document Release Management System
-- Partido State University - Goa Campus
-- Database: psu_payment_release_db (MySQL / InnoDB, also runs on MariaDB)
-- Run this file first, in ONE session (HeidiSQL: Run as one query; phpMyAdmin: SQL tab).
-- It drops and recreates every table, so do not run it on data you want to keep.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS psu_payment_release_db
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE psu_payment_release_db;


-- ---------------------------------------------------------------------
-- 0. Clean re-run
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW  IF EXISTS v_released_students;
DROP TABLE IF EXISTS registrar_audit_log, cashier_audit_log, document_release,
                     payment_receipt, payment_transaction, registrar_window,
                     registrar, cashier_counter, cashier, student, program,
                     department, payment_purpose, academic_term;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 1. Task 3: DDL (tables)
-- ---------------------------------------------------------------------
CREATE TABLE department (
  DepartmentID   INT NOT NULL AUTO_INCREMENT,
  DepartmentName VARCHAR(100) NOT NULL,
  PRIMARY KEY (DepartmentID),
  CONSTRAINT UQ_DEPARTMENT_NAME UNIQUE (DepartmentName)
) ENGINE=InnoDB;

CREATE TABLE registrar_window (
  WindowID     INT NOT NULL AUTO_INCREMENT,
  WindowNumber INT NOT NULL,
  Status       VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (WindowID),
  CONSTRAINT UQ_WINDOW_NUMBER UNIQUE (WindowNumber),
  CONSTRAINT CHK_WINDOW_NUMBER CHECK (WindowNumber > 0),
  CONSTRAINT CHK_WINDOW_STATUS CHECK (Status IN ('ACTIVE','INACTIVE'))
) ENGINE=InnoDB;

CREATE TABLE program (
  ProgramID    INT NOT NULL AUTO_INCREMENT,
  ProgramCode  VARCHAR(20)  NOT NULL,
  ProgramName  VARCHAR(150) NOT NULL,
  DepartmentID INT NOT NULL,
  WindowID     INT NOT NULL,      -- the one Registrar window that handles this program
  PRIMARY KEY (ProgramID),
  CONSTRAINT UQ_PROGRAM_CODE UNIQUE (ProgramCode),
  CONSTRAINT FK_PROGRAM_DEPARTMENT FOREIGN KEY (DepartmentID)
    REFERENCES department (DepartmentID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_PROGRAM_WINDOW FOREIGN KEY (WindowID)   -- a window can handle many programs
    REFERENCES registrar_window (WindowID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student (
  StudentID  INT NOT NULL AUTO_INCREMENT,
  SchoolID   VARCHAR(30) NOT NULL,
  FirstName  VARCHAR(50) NOT NULL,
  MiddleName VARCHAR(50) NULL,
  LastName   VARCHAR(50) NOT NULL,
  ProgramID  INT NOT NULL,
  Section    VARCHAR(20) NOT NULL,
  PRIMARY KEY (StudentID),
  CONSTRAINT UQ_STUDENT_SCHOOL_ID UNIQUE (SchoolID),
  KEY IDX_STUDENT_PROGRAM_SECTION (ProgramID, Section),
  CONSTRAINT FK_STUDENT_PROGRAM FOREIGN KEY (ProgramID)
    REFERENCES program (ProgramID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE academic_term (
  TermID     INT NOT NULL AUTO_INCREMENT,
  Semester   VARCHAR(30) NOT NULL,
  SchoolYear VARCHAR(20) NOT NULL,
  PRIMARY KEY (TermID),
  CONSTRAINT UQ_ACADEMIC_TERM UNIQUE (Semester, SchoolYear),
  CONSTRAINT CHK_TERM_SEMESTER CHECK (Semester IN ('1st Semester','2nd Semester','Summer'))
) ENGINE=InnoDB;

CREATE TABLE payment_purpose (
  PurposeID   INT NOT NULL AUTO_INCREMENT,
  PurposeName VARCHAR(100) NOT NULL,
  Amount      DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (PurposeID),
  CONSTRAINT UQ_PAYMENT_PURPOSE_NAME UNIQUE (PurposeName),
  CONSTRAINT CHK_PAYMENT_AMOUNT CHECK (Amount > 0)
) ENGINE=InnoDB;

CREATE TABLE cashier (
  CashierID INT NOT NULL AUTO_INCREMENT,
  FirstName VARCHAR(50) NOT NULL,
  LastName  VARCHAR(50) NOT NULL,
  PRIMARY KEY (CashierID)
) ENGINE=InnoDB;

CREATE TABLE cashier_counter (
  CounterID     INT NOT NULL AUTO_INCREMENT,
  CounterNumber INT NOT NULL,
  Status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (CounterID),
  CONSTRAINT UQ_COUNTER_NUMBER UNIQUE (CounterNumber),
  CONSTRAINT CHK_COUNTER_NUMBER CHECK (CounterNumber > 0),
  CONSTRAINT CHK_COUNTER_STATUS CHECK (Status IN ('ACTIVE','INACTIVE'))
) ENGINE=InnoDB;

CREATE TABLE registrar (
  RegistrarID INT NOT NULL AUTO_INCREMENT,
  FirstName   VARCHAR(50) NOT NULL,
  LastName    VARCHAR(50) NOT NULL,
  PRIMARY KEY (RegistrarID)
) ENGINE=InnoDB;


CREATE TABLE payment_transaction (
  TransactionID        INT NOT NULL AUTO_INCREMENT,
  TransactionReference VARCHAR(50) NOT NULL,
  StudentID            INT NOT NULL,
  TermID               INT NOT NULL,
  PurposeID            INT NOT NULL,
  CashierID            INT NULL,       -- NULL while PENDING
  CounterID            INT NULL,       -- NULL while PENDING
  TransactionDate      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TransactionStatus    VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (TransactionID),
  CONSTRAINT UQ_TRANSACTION_REFERENCE UNIQUE (TransactionReference),
  CONSTRAINT UQ_STUDENT_TERM_PURPOSE UNIQUE (StudentID, TermID, PurposeID),
  KEY FK_TRANSACTION_TERM (TermID),
  KEY FK_TRANSACTION_PURPOSE (PurposeID),
  KEY FK_TRANSACTION_CASHIER (CashierID),
  KEY FK_TRANSACTION_COUNTER (CounterID),
  CONSTRAINT CHK_TRANSACTION_STATUS CHECK (TransactionStatus IN ('PENDING','PAID','RELEASED')),
  CONSTRAINT FK_TRANSACTION_STUDENT FOREIGN KEY (StudentID)
    REFERENCES student (StudentID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_TRANSACTION_TERM FOREIGN KEY (TermID)
    REFERENCES academic_term (TermID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_TRANSACTION_PURPOSE FOREIGN KEY (PurposeID)
    REFERENCES payment_purpose (PurposeID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_TRANSACTION_CASHIER FOREIGN KEY (CashierID)
    REFERENCES cashier (CashierID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_TRANSACTION_COUNTER FOREIGN KEY (CounterID)
    REFERENCES cashier_counter (CounterID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Weak (dependent) entity: a receipt cannot exist without its transaction,
-- so deleting a transaction removes its receipt (ON DELETE CASCADE).
CREATE TABLE payment_receipt (
  ReceiptID     INT NOT NULL AUTO_INCREMENT,
  TransactionID INT NOT NULL,
  ReceiptNumber VARCHAR(50) NOT NULL,
  IssuedAt      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ReceiptID),
  CONSTRAINT UQ_RECEIPT_NUMBER UNIQUE (ReceiptNumber),
  CONSTRAINT UQ_RECEIPT_TRANSACTION UNIQUE (TransactionID),
  CONSTRAINT FK_RECEIPT_TRANSACTION FOREIGN KEY (TransactionID)
    REFERENCES payment_transaction (TransactionID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE document_release (
  ReleaseID        INT NOT NULL AUTO_INCREMENT,
  TransactionID    INT NOT NULL,
  RegistrarID      INT NOT NULL,
  WindowID         INT NOT NULL,
  ReleaseDate      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  SchoolIDVerified VARCHAR(30) NOT NULL,
  PRIMARY KEY (ReleaseID),
  CONSTRAINT UQ_RELEASE_TRANSACTION UNIQUE (TransactionID),  -- at most one release per transaction
  KEY FK_RELEASE_REGISTRAR (RegistrarID),
  KEY FK_RELEASE_WINDOW (WindowID),
  KEY FK_RELEASE_SCHOOL_ID (SchoolIDVerified),
  CONSTRAINT FK_RELEASE_TRANSACTION FOREIGN KEY (TransactionID)
    REFERENCES payment_transaction (TransactionID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_RELEASE_REGISTRAR FOREIGN KEY (RegistrarID)
    REFERENCES registrar (RegistrarID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_RELEASE_WINDOW FOREIGN KEY (WindowID)
    REFERENCES registrar_window (WindowID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_RELEASE_SCHOOL_ID FOREIGN KEY (SchoolIDVerified)
    REFERENCES student (SchoolID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- NEW: cashier activity history. Primary records stay in payment_transaction
-- and payment_receipt; this table only stores who did what and when.
CREATE TABLE cashier_audit_log (
  CashierLogID  INT NOT NULL AUTO_INCREMENT,
  CashierID     INT NOT NULL,
  TransactionID INT NULL,               -- NULL when the action has no specific transaction
  ActionType    VARCHAR(30)  NOT NULL,
  Description   VARCHAR(255) NOT NULL,
  ActionDate    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (CashierLogID),
  KEY IDX_CASHIER_LOG_CASHIER_DATE (CashierID, ActionDate),
  KEY IDX_CASHIER_LOG_TRANSACTION (TransactionID),
  CONSTRAINT CHK_CASHIER_LOG_ACTION CHECK (ActionType IN
    ('CONFIRM_PAYMENT','UPDATE_TRANSACTION','ISSUE_RECEIPT','CORRECT_RECORD','PRINT_LOG')),
  CONSTRAINT FK_CASHIER_LOG_CASHIER FOREIGN KEY (CashierID)
    REFERENCES cashier (CashierID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_CASHIER_LOG_TRANSACTION FOREIGN KEY (TransactionID)
    REFERENCES payment_transaction (TransactionID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- NEW: registrar activity history (separate from the cashier log).
CREATE TABLE registrar_audit_log (
  RegistrarLogID INT NOT NULL AUTO_INCREMENT,
  RegistrarID    INT NOT NULL,
  ReleaseID      INT NULL,              -- NULL when the action has no release record yet
  ActionType     VARCHAR(30)  NOT NULL,
  Description    VARCHAR(255) NOT NULL,
  ActionDate     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (RegistrarLogID),
  KEY IDX_REGISTRAR_LOG_REGISTRAR_DATE (RegistrarID, ActionDate),
  KEY IDX_REGISTRAR_LOG_RELEASE (ReleaseID),
  CONSTRAINT CHK_REGISTRAR_LOG_ACTION CHECK (ActionType IN
    ('VERIFY_SCHOOL_ID','RELEASE_DOCUMENT','UPDATE_RELEASE','RECORD_RELEASE_ACTION','PRINT_LOG')),
  CONSTRAINT FK_REGISTRAR_LOG_REGISTRAR FOREIGN KEY (RegistrarID)
    REFERENCES registrar (RegistrarID) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT FK_REGISTRAR_LOG_RELEASE FOREIGN KEY (ReleaseID)
    REFERENCES document_release (ReleaseID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. Business-rule triggers (cross-table rules that CHECK cannot express)
--    PENDING -> PAID -> RELEASED only; PAID needs Cashier + counter;
--    receipt only for confirmed payments; release only for PAID with a
--    matching School ID.
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_pt_before_insert
BEFORE INSERT ON payment_transaction
FOR EACH ROW
BEGIN
  IF NEW.TransactionStatus = 'RELEASED' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A new transaction cannot start as RELEASED.';
  END IF;
  IF NEW.TransactionStatus = 'PAID'
     AND (NEW.CashierID IS NULL OR NEW.CounterID IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A PAID transaction must record the Cashier and the counter.';
  END IF;
END$$

CREATE TRIGGER trg_pt_before_update
BEFORE UPDATE ON payment_transaction
FOR EACH ROW
BEGIN
  IF NEW.TransactionStatus <> OLD.TransactionStatus
     AND NOT ((OLD.TransactionStatus = 'PENDING' AND NEW.TransactionStatus = 'PAID')
           OR (OLD.TransactionStatus = 'PAID'    AND NEW.TransactionStatus = 'RELEASED')) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid status change. Allowed: PENDING to PAID, PAID to RELEASED.';
  END IF;
  IF NEW.TransactionStatus IN ('PAID','RELEASED')
     AND (NEW.CashierID IS NULL OR NEW.CounterID IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A PAID or RELEASED transaction must record the Cashier and the counter.';
  END IF;
  IF OLD.TransactionStatus = 'PAID' AND NEW.TransactionStatus = 'RELEASED'
     AND NOT EXISTS (SELECT 1 FROM document_release WHERE TransactionID = OLD.TransactionID) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A transaction becomes RELEASED only after a document release is recorded.';
  END IF;
END$$

CREATE TRIGGER trg_receipt_before_insert
BEFORE INSERT ON payment_receipt
FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(20);
  SELECT TransactionStatus INTO v_status
    FROM payment_transaction WHERE TransactionID = NEW.TransactionID;
  IF v_status IS NULL OR v_status NOT IN ('PAID','RELEASED') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A receipt can only be issued for a cashier-confirmed (PAID) transaction.';
  END IF;
END$$

CREATE TRIGGER trg_release_before_insert
BEFORE INSERT ON document_release
FOR EACH ROW
BEGIN
  DECLARE v_status    VARCHAR(20);
  DECLARE v_school_id VARCHAR(30);
  DECLARE v_window_id INT;
  SELECT pt.TransactionStatus, s.SchoolID, p.WindowID INTO v_status, v_school_id, v_window_id
    FROM payment_transaction pt
    JOIN student s ON s.StudentID = pt.StudentID
    JOIN program p ON p.ProgramID = s.ProgramID
   WHERE pt.TransactionID = NEW.TransactionID;
  IF v_status IS NULL OR v_status <> 'PAID' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Only a PAID transaction can be released.';
  END IF;
  IF NEW.SchoolIDVerified <> v_school_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The verified School ID does not match the student of this transaction.';
  END IF;
  IF NEW.WindowID <> v_window_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The release must go through the window assigned to the student''s program.';
  END IF;
END$$

CREATE TRIGGER trg_release_after_insert
AFTER INSERT ON document_release
FOR EACH ROW
BEGIN
  UPDATE payment_transaction
     SET TransactionStatus = 'RELEASED'
   WHERE TransactionID = NEW.TransactionID;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 4. View (kept from the original schema)
-- ---------------------------------------------------------------------
CREATE VIEW v_released_students AS
SELECT pt.TransactionID, pt.TransactionReference, s.StudentID, s.SchoolID,
       s.FirstName, s.MiddleName, s.LastName, pt.TransactionStatus
  FROM payment_transaction pt
  JOIN student s ON pt.StudentID = s.StudentID
 WHERE pt.TransactionStatus = 'RELEASED';


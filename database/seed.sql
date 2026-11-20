-- =====================================================================
-- seed.sql: sample data
-- Digital Student Payment and Document Release Management System
-- Partido State University - Goa Campus
-- Database: psu_payment_release_db (MySQL / InnoDB, also runs on MariaDB)
-- Run this file second, after schema.sql. Insert order follows the foreign keys.
-- =====================================================================

USE psu_payment_release_db;

-- ---------------------------------------------------------------------
-- 3. Sample data (insert order follows the foreign keys)
-- ---------------------------------------------------------------------
INSERT INTO department (DepartmentID, DepartmentName) VALUES
  (1, 'College of Computer Studies'),
  (2, 'College of Education'),
  (3, 'College of Business Management');

-- Registrar windows first (programs point to them). One window can handle several programs.
-- Sample mapping only: change it to the real window assignment of the campus.
INSERT INTO registrar_window (WindowID, WindowNumber, Status) VALUES
  (1, 1, 'ACTIVE'), (2, 2, 'ACTIVE');

INSERT INTO program (ProgramID, ProgramCode, ProgramName, DepartmentID, WindowID) VALUES
  (1, 'BSIT', 'Bachelor of Science in Information Technology', 1, 1),
  (2, 'BSED', 'Bachelor of Secondary Education', 2, 2),
  (3, 'BSBA', 'Bachelor of Science in Business Administration', 3, 2);   -- shares window 2 with BSED

INSERT INTO academic_term (TermID, Semester, SchoolYear) VALUES
  (1, '1st Semester', '2025-2026'),
  (2, '2nd Semester', '2025-2026'),
  (3, '1st Semester', '2026-2027');

INSERT INTO payment_purpose (PurposeID, PurposeName, Amount) VALUES
  (1, 'Certificate of Enrollment', 10.00),
  (2, 'Student Sticker', 10.00);

INSERT INTO cashier (CashierID, FirstName, LastName) VALUES
  (1, 'Juan', 'Cashier'), (2, 'Maria', 'Cashier');

INSERT INTO cashier_counter (CounterID, CounterNumber, Status) VALUES
  (1, 1, 'ACTIVE'), (2, 2, 'ACTIVE');

INSERT INTO registrar (RegistrarID, FirstName, LastName) VALUES
  (1, 'Ana', 'Registrar'), (2, 'Maria', 'Registrar');

INSERT INTO student (StudentID, SchoolID, FirstName, MiddleName, LastName, ProgramID, Section) VALUES
  (1, '2024-0001', 'Juan',   'Dela', 'Cruz',       1, '3A'),
  (2, '2024-0002', 'Maria',  NULL,   'Santos',     1, '3A'),
  (3, '2024-0003', 'Pedro',  NULL,   'Reyes',      2, '2B'),
  (4, '2024-0004', 'Ana',    NULL,   'Garcia',     3, '1A'),
  (5, '2024-0005', 'Carlo',  NULL,   'Mendoza',    1, '3B'),
  (6, '2024-0006', 'Liza',   NULL,   'Ramos',      2, '2B'),
  (7, '2024-0007', 'Mark',   NULL,   'Villanueva', 3, '1A'),
  (8, '2024-0008', 'Joy',    NULL,   'Navarro',    1, '3B');

-- Transactions 3 and 6 are inserted as PAID; the release trigger changes them to RELEASED.
INSERT INTO payment_transaction
  (TransactionID, TransactionReference, StudentID, TermID, PurposeID, CashierID, CounterID, TransactionDate, TransactionStatus) VALUES
  (1, 'TXN-2026-0001', 1, 3, 1, 1,    1,    '2026-09-01 09:00:00', 'PAID'),
  (2, 'TXN-2026-0002', 2, 3, 1, 2,    2,    '2026-09-01 09:15:00', 'PAID'),
  (3, 'TXN-2026-0003', 3, 3, 1, 1,    1,    '2026-09-02 10:00:00', 'PAID'),
  (4, 'TXN-2026-0004', 4, 3, 2, NULL, NULL, '2026-09-02 10:30:00', 'PENDING'),
  (5, 'TXN-2026-0005', 5, 3, 1, 1,    1,    '2026-09-03 11:00:00', 'PAID'),
  (6, 'TXN-2026-0006', 6, 3, 1, 2,    2,    '2026-09-03 11:30:00', 'PAID'),
  (7, 'TXN-2026-0007', 7, 3, 1, NULL, NULL, '2026-09-04 08:30:00', 'PENDING'),
  (8, 'TXN-2026-0008', 8, 3, 2, 1,    1,    '2026-09-04 09:10:00', 'PAID');

INSERT INTO payment_receipt (ReceiptID, TransactionID, ReceiptNumber, IssuedAt) VALUES
  (1, 1, 'OR-2026-0001', '2026-09-01 09:05:00'),
  (2, 2, 'OR-2026-0002', '2026-09-01 09:20:00'),
  (3, 3, 'OR-2026-0003', '2026-09-02 10:05:00'),
  (4, 5, 'OR-2026-0005', '2026-09-03 11:05:00'),
  (5, 6, 'OR-2026-0006', '2026-09-03 11:35:00'),
  (6, 8, 'OR-2026-0008', '2026-09-04 09:15:00');

INSERT INTO document_release (ReleaseID, TransactionID, RegistrarID, WindowID, ReleaseDate, SchoolIDVerified) VALUES
  (1, 3, 1, 2, '2026-09-02 10:30:00', '2024-0003'),
  (2, 6, 2, 2, '2026-09-03 13:00:00', '2024-0006');

INSERT INTO cashier_audit_log (CashierID, TransactionID, ActionType, Description, ActionDate) VALUES
  (1, 1,    'CONFIRM_PAYMENT', 'Confirmed cash payment of PHP 10.00',     '2026-09-01 09:03:00'),
  (1, 1,    'ISSUE_RECEIPT',   'Issued receipt OR-2026-0001',             '2026-09-01 09:05:00'),
  (2, 2,    'CONFIRM_PAYMENT', 'Confirmed cash payment of PHP 10.00',     '2026-09-01 09:18:00'),
  (2, 2,    'ISSUE_RECEIPT',   'Issued receipt OR-2026-0002',             '2026-09-01 09:20:00'),
  (1, 3,    'CONFIRM_PAYMENT', 'Confirmed cash payment of PHP 10.00',     '2026-09-02 10:03:00'),
  (1, 3,    'ISSUE_RECEIPT',   'Issued receipt OR-2026-0003',             '2026-09-02 10:05:00'),
  (1, 5,    'CONFIRM_PAYMENT', 'Confirmed cash payment of PHP 10.00',     '2026-09-03 11:03:00'),
  (1, 5,    'ISSUE_RECEIPT',   'Issued receipt OR-2026-0005',             '2026-09-03 11:05:00'),
  (2, 6,    'CONFIRM_PAYMENT', 'Confirmed cash payment of PHP 10.00',     '2026-09-03 11:33:00'),
  (2, 6,    'ISSUE_RECEIPT',   'Issued receipt OR-2026-0006',             '2026-09-03 11:35:00'),
  (1, 8,    'CONFIRM_PAYMENT', 'Confirmed cash payment of PHP 10.00',     '2026-09-04 09:13:00'),
  (1, 8,    'ISSUE_RECEIPT',   'Issued receipt OR-2026-0008',             '2026-09-04 09:15:00'),
  (1, NULL, 'PRINT_LOG',       'Printed Cashier log for BSIT 3A',         '2026-09-01 16:00:00');

INSERT INTO registrar_audit_log (RegistrarID, ReleaseID, ActionType, Description, ActionDate) VALUES
  (1, 1,    'VERIFY_SCHOOL_ID', 'Verified School ID before release',      '2026-09-02 10:29:00'),
  (1, 1,    'RELEASE_DOCUMENT', 'Released Certificate of Enrollment',     '2026-09-02 10:30:00'),
  (2, 2,    'VERIFY_SCHOOL_ID', 'Verified School ID before release',      '2026-09-03 12:59:00'),
  (2, 2,    'RELEASE_DOCUMENT', 'Released Certificate of Enrollment',     '2026-09-03 13:00:00'),
  (1, NULL, 'PRINT_LOG',        'Printed Registrar log for BSED 2B',      '2026-09-03 15:00:00');


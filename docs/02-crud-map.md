# CRUD Map: Digital-Student-Payment-and-Document-Release-Management-System

Roles: Guest, Student, Cashier, Registrar. "System" means the app does it automatically.

## 1. CRUD map

| Table | C | R | U | D | Pages | Who |
|-------|---|---|---|---|-------|-----|
| student | – | ✓ | ✓ | – | login, student-home, account, cashier-home, registrar-home | Student: R own, U own password · Cashier: R by School ID search · Registrar: R in the paid list. No C: students are loaded from school records (seed.sql), not self-registered. No D: kept as history, payments depend on it. |
| department | – | ✓ | – | – | logs (filter by department) | Cashier, Registrar: R. Set up in seed.sql, no admin page yet. No D: programs depend on it. |
| program | – | ✓ | – | – | login (window list), cashier-home, registrar-home | Student, Cashier, Registrar: R. Set up in seed.sql. No D: students depend on it. |
| registrar_window | – | ✓ | – | – | login (Registrar picks an active window), registrar-home | Registrar: R. Set up in seed.sql. Status ACTIVE or INACTIVE. No D: releases refer to it. |
| academic_term | – | ✓ | – | – | student-home, payment-form, receipt | Student: R (term list). Set up in seed.sql. No D: payments are kept per term. |
| payment_purpose | – | ✓ | – | – | payment-form, receipt | Student: R (name and amount). Set up in seed.sql. No D: transactions depend on it. |
| cashier | – | ✓ | ✓ | – | login, account, receipt | Cashier: R, U own password. Accounts are created by campus staff. No D: payments and audit logs depend on it. |
| cashier_counter | – | ✓ | – | – | login (Cashier picks an active counter), receipt | Cashier: R. Set up in seed.sql. Marked INACTIVE, not deleted, because payments refer to it. |
| registrar | – | ✓ | ✓ | – | login, account | Registrar: R, U own password. Accounts are created by campus staff. No D: releases and audit logs depend on it. |
| payment_transaction | ✓ | ✓ | ✓ | ✓ | student-home, payment-form, cashier-home, registrar-home | Student: C, R own · U purpose and D only while PENDING · Cashier: R, U (confirm, status becomes PAID) · Registrar: R. A release sets RELEASED (trigger). PAID and RELEASED rows are never deleted. |
| payment_receipt | ✓ | ✓ | – | – | cashier-home, receipt | System: C when the Cashier confirms a payment · Student: R own. No U: a receipt is a record. No D by users: it is removed only together with its transaction (CASCADE). |
| document_release | ✓ | ✓ | – | – | registrar-home, release-form | Registrar: C, R. No U or D: a release is a final record. |
| cashier_audit_log | ✓ | ✓ | – | – | logs (nice-to-have) | System: C on every Cashier action · Cashier: R own log. No U or D: it is history. |
| registrar_audit_log | ✓ | ✓ | – | – | logs (nice-to-have) | System: C on every Registrar action · Registrar: R own log. No U or D: it is history. |

### Pages used above

| Page | What it does |
|------|--------------|
| login | Choose a role, enter the ID and password. Cashier picks a counter, Registrar picks a window. |
| student-home | Register a payment and list my transactions. |
| payment-form | Register a payment, or edit a PENDING one. |
| receipt | View and print the receipt of a confirmed payment. |
| account | Change my password. |
| cashier-home | Search a School ID, see the pending payment, confirm the cash. |
| registrar-home | List the paid students of the programs of my window. |
| release-form | Verify the School ID and release the COE and sticker. |
| logs | Print the Cashier or Registrar log (nice-to-have). |

## 2. Form fields

### payment_transaction (page: payment-form, the "Add" form)

| Column | Form control | Required? | Note |
|--------|--------------|-----------|------|
| TransactionID INT AUTO_INCREMENT | none | – | MySQL makes it. On "Edit" it is a hidden field. |
| TransactionReference VARCHAR(50) | none | – | The app builds it (TXN-year-id). The student does not type it. |
| StudentID INT | none | – | Taken from the logged-in student, not a field. |
| TermID INT (FK to academic_term) | `<select name="TermID">` | Yes * | Show the semester and school year, store the id. |
| PurposeID INT (FK to payment_purpose) | `<select name="PurposeID">` | Yes * | Show the purpose name and amount, store the id. |
| CashierID INT NULL | none | – | Stays NULL until the Cashier confirms. |
| CounterID INT NULL | none | – | Stays NULL until the Cashier confirms. |
| TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP | none | – | MySQL fills it. |
| TransactionStatus VARCHAR(20) DEFAULT 'PENDING' | none | – | Starts as PENDING. |

"Edit" form (only while PENDING): a hidden `TransactionID` and the `PurposeID` select.

### document_release (page: release-form, the "Add" form)

| Column | Form control | Required? | Note |
|--------|--------------|-----------|------|
| ReleaseID INT AUTO_INCREMENT | none | – | MySQL makes it. |
| TransactionID INT (FK to payment_transaction) | `<input type="hidden" name="TransactionID">` | Yes * | Set when the Registrar clicks Release on a student in the paid list. |
| RegistrarID INT | none | – | Taken from the logged-in Registrar. |
| WindowID INT | none | – | Taken from the window chosen at login. |
| ReleaseDate DATETIME DEFAULT CURRENT_TIMESTAMP | none | – | MySQL fills it. |
| SchoolIDVerified VARCHAR(30) | `<input type="text" name="SchoolIDVerified" maxlength="30">` | Yes * | The Registrar types the School ID. It must match the student of the transaction. |

## 3. Schema changes

1. Added `PasswordHash VARCHAR(255) NULL` to `student`, `cashier` and `registrar`. Why: every user logs in with a password, and the password must be stored as a hash, never as plain text. The columns were first added by a setup script, so now they are in `schema.sql`.
2. Moved the link between `registrar_window` and `program`. Before, `registrar_window` had `ProgramID` (one program per window). Now `program` has `WindowID`, and `registrar_window` has no `ProgramID`. Why: at the campus, one window can handle more than one program (for example, one window handles both BSIT and BSCS), but each program has only one window.

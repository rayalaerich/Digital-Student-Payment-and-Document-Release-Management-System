# Project Brief: Digital-Student-Payment-and-Document-Release-Management-System

## 1. The problem

Students at PSU – Goa Campus pay the ₱10 ID Validation Fee in cash, then claim the Certificate of Enrollment (COE) and the student sticker. Today the Cashier and the Registrar write every payment and release in a logbook. Lines get long and entries can be lost or misread. It is also hard to find who processed a payment, at which counter, and in which term.

## 2. Users and what they need to do

| User role | What they need to do in the app |
|-----------|---------------------------------|
| Student | Register the ₱10 payment for the current term. Edit or cancel it while it is PENDING. See the status and the receipt. |
| Cashier | Log in at an active counter. Search a student by School ID. Confirm the cash payment and issue a receipt. |
| Registrar | Log in at an active window. See the paid students of the programs that window handles. Verify the School ID and release the COE and sticker. |

## 3. The database behind it

Database name: `psu_payment_release_db`. It has 14 tables.

- `department`: a department of the campus. It has one or more programs.
- `program`: an academic program such as BSIT. It belongs to one department and one Registrar window.
- `registrar_window`: a Registrar window. It handles one or more programs.
- `student`: a student with a unique School ID, one program and one section.
- `academic_term`: a semester and school year.
- `payment_purpose`: what is paid for and the amount, such as the ₱10 ID Validation Fee.
- `cashier`: a Cashier who confirms payments.
- `cashier_counter`: one of the Cashier counters, active or inactive.
- `registrar`: a Registrar who releases documents.
- `payment_transaction`: one fee registration with the student, term, purpose, Cashier, counter and status (PENDING, PAID or RELEASED).
- `payment_receipt`: the digital receipt of a confirmed payment, one per transaction.
- `document_release`: the release of the COE and sticker, with the Registrar, the window, the date and the verified School ID.
- `cashier_audit_log`: the history of Cashier actions.
- `registrar_audit_log`: the history of Registrar actions.

## 4. Must-have features (for the final project)

1. Register the ₱10 payment for the current term (`payment_transaction`, `academic_term`, `payment_purpose`).
2. Edit or cancel a PENDING payment (`payment_transaction`).
3. Search a student's pending payment by School ID (`student`, `payment_transaction`).
4. Confirm the cash payment, issue a receipt, and log the action (`payment_transaction`, `payment_receipt`, `cashier`, `cashier_counter`, `cashier_audit_log`).
5. Show the paid students of the programs that a Registrar window handles (`payment_transaction`, `student`, `program`, `registrar_window`).
6. Release the COE and sticker after the School ID check, and log the action (`document_release`, `registrar`, `registrar_window`, `registrar_audit_log`).

## 5. Nice-to-have features (only if there's time)

1. Print the Cashier log and the Registrar log per program and section, with a signature column (`payment_transaction`, `document_release`, `student`, `program`).
2. Filter reports by department, program, section, term, status, Cashier, Registrar and date range.
3. Add an admin page to manage programs, windows and counters (`program`, `registrar_window`, `cashier_counter`).
4. Pay the fee with an e-wallet (such as GCash) and record the payment method (`payment_transaction`, `payment_purpose`).
5. Scan the barcode on the student's ID, so the Cashier and the Registrar do not type the School ID (`student`, `payment_transaction`, `document_release`).
6. Filter reports by program, section, term, status and date range, and print the Cashier log and the Registrar log with a signature column (`payment_transaction`, `document_release`, `student`, `program`).

## 6. Similar apps I looked at

1. **GCash**: every payment gets a reference number and a digital receipt. I will borrow this for the transaction reference and the receipt.
2. **A parcel tracking page (for example LBC or J&T)**: the status moves one step at a time. I will borrow this for the PENDING, PAID, RELEASED status.

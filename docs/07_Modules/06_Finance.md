# Module: Finance & Cash Book

## 6.1 Purpose
Maintains business liquidity by tracking every rupee moving in and out of the enterprise.

## 6.2 Features
- **Cash Balance Management**: Real-time calculation of total available liquidity.
- **Transaction Ledger**: Searchable history of all income and expenses.
- **Payment Mode Tracking**: Categorization by Cash, Bank, or UPI.
- **Automated Balancing**: Each transaction updates the global balance instantly.

## 6.3 Workflow
1.  **Entry**: Accountant records a payment (e.g., "Electricity Bill") as an Expense.
2.  **Persist**: The entry is posted to the backend and immediately reflected in the local in-memory state.
3.  **Review**: Directors monitor the "Live Account Status" to ensure healthy cash flow.

## 6.4 Business Rules
-   Transactions are immutable; corrections must be handled via reversal entries.
-   "Expense" categories automatically subtract from the total balance.
-   "Income" categories automatically add to the total balance.

## 6.5 Permissions
| Role | Action |
| :--- | :--- |
| Admin | Full access to record and delete (reversal) entries. |
| Manager | View only. |
| Employee | No access. |

## 6.6 Future Improvements
-   **Bank Statement Import**: Automatic reconciliation by uploading bank CSV files.
-   **Tax Estimation**: Real-time projection of monthly GST liabilities.
-   **Petty Cash**: Sub-ledgers for minor daily office expenses.

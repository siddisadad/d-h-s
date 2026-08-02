# 03 Business Requirement Document (BRD)

## 3.1 Business Objectives
The primary objective of the DCI ERP project is to digitize the entire commercial lifecycle of Deshmukh Hardware & Steel, from procurement to final sale and collection.

## 3.2 Current Problems (AS-IS)
| Problem Area | Description |
| :--- | :--- |
| **Sales** | Hand-written invoices lead to tax calculation errors and lost records. |
| **Inventory** | Manual stock counting is prone to theft and misreporting. |
| **Collections** | Difficulty in determining who owes what, leading to cash flow issues. |
| **Communication** | Lack of automated notifications for staff logins or stock adjustments. |

## 3.3 Proposed Solution (TO-BE)
A centralized cloud-connected mobile and web platform that automates all calculations, enforces role permissions, and provides a real-time analytics dashboard for directors.

## 3.4 Business Rules
1.  **Sales Invoicing**: An invoice cannot be generated without a valid GSTIN or a "Walking Customer" override.
2.  **Stock Adjustment**: Only users with "Manager" or "Admin" roles can manually decrease stock without a sales order.
3.  **Authentication**: All users must have a unique company email and belong to a valid role.
4.  **Financial entries**: Every sale must automatically update the Customer Ledger and the Business Cash Book.

## 3.5 Stakeholders
*   **Business Owners (Directors)**: Approve strategy and review financial health.
*   **Operational Staff**: Day-to-day users for sales and stock entry.
*   **Tax Consultants**: Require accurate GST and Sales reports for monthly filings.
*   **IT Lead**: Manages deployment and server stability.

## 3.6 Success Criteria
*   **Time Reduction**: 50% faster checkout time for customers.
*   **Stock Discrepancy**: Reduce inventory errors to less than 1%.
*   **User Adoption**: 100% of staff transactions performed through the ERP within 1 month of deployment.

# Module: Sales & Invoicing

## 3.1 Purpose
Streamlines the customer checkout process and automates financial document generation.

## 3.2 Features
- **Invoice Draft System**: Real-time total calculation (Subtotal, GST, Grand Total) as items are added.
- **Customer Selection**: Linked to the [CRM Module](file:///A:/Workspace/d-h-s/lib/features/crm/presentation/providers/crm_provider.dart).
- **PDF Generation**: Instant creation of professional tax invoices via [PdfService](file:///A:/Workspace/d-h-s/lib/core/services/pdf_service.dart).
- **Direct Printing**: Wireless printing support for yard receipts.

## 3.3 Workflow
1.  **Draft**: Sales executive opens [SalesInvoiceScreen](file:///A:/Workspace/d-h-s/lib/features/sales/presentation/screens/sales_invoice_screen.dart).
2.  **Identify**: Selects a customer from the synced cloud directory.
3.  **Cart**: Adds products from inventory; logic validates stock availability.
4.  **Finalize**: Applies discount and posts to `/invoices`.
5.  **Output**: Generates PDF and triggers WhatsApp share option.

## 3.4 Business Rules
-   GST rate is defaulted to 18% for steel products but adjustable per line item.
-   Invoice IDs are auto-generated with the pattern `INV-<Timestamp>`.
-   Invoices are immutable once created (Credit Note required for reversals).

## 3.5 Validation
-   Must have at least 1 item to generate an invoice.
-   Grand total must be >= 0.

## 3.6 Future Improvements
-   **Partial Payments**: Support for splitting a single invoice into multiple cash/UPI payments.
-   **GST Integration**: Direct integration with government portals for E-Way Bill generation.
-   **Inventory Auto-Debit**: Automatic reduction of stock upon invoice finalization.

# Walkthrough - Cloud Printing (Thermal Receipts)

I have implemented a specialized **Thermal Receipt** printing feature for sales invoices. This is optimized for 80mm roll printers commonly used in hardware yards and warehouses.

## Changes Made

### 1. Thermal PDF Generation
- **[pdf_service.dart](file:///A:/Workspace/d-h-s/lib/core/services/pdf_service.dart)**:
    - Added `generateThermalReceipt(SalesInvoice invoice)`.
    - Optimized the layout for `PdfPageFormat.roll80`.
    - Features:
        - Center-aligned header for business identity.
        - Narrow, readable item list with quantity and price on separate lines to maximize space.
        - Clear breakdown of Subtotal, GST, and Discount.
        - Large, bold Grand Total for quick verification.

### 2. Provider Integration
- **[sales_provider.dart](file:///A:/Workspace/d-h-s/lib/features/sales/presentation/providers/sales_provider.dart)**:
    - Added `generateThermalReceiptPreview` to the `SalesInvoiceNotifier`. This bridges the UI to the underlying PDF service.

### 3. Updated Sales UI
- **[sales_invoice_screen.dart](file:///A:/Workspace/d-h-s/lib/features/sales/presentation/screens/sales_invoice_screen.dart)**:
    - Refactored the bottom action bar.
    - Replaced the generic "PRINT / PDF" button with two distinct options:
        - **PDF**: Generates a standard A4 invoice for formal record-keeping.
        - **RECEIPT**: Generates the new 80mm thermal receipt for the customer.

## How it Works
1.  Complete a new sales draft.
2.  Tap the **RECEIPT** button in the bottom bar.
3.  The system print dialog will open with the narrow thermal preview.
4.  Select your yard printer and print instantly.

## Verification Results

### Automated Tests
- Ran `flutter analyze`: **No issues found!**

### Manual Verification
- Verified that the thermal layout correctly calculates and displays GST and Discounts.
- Confirmed that the "PDF" and "RECEIPT" buttons trigger their respective specialized layouts.

> [!TIP]
> The thermal receipt is designed to save paper. It uses a smaller font size (9pt) and removes heavy borders, making it faster to print on thermal hardware.

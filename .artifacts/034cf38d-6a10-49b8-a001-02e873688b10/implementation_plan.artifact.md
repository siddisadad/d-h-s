# Implementation Plan - Automated Procurement & Smart Planner

This feature introduces an intelligent procurement workflow that suggests restock quantities based on AI demand forecasting and helps managers create purchase orders with one tap.

## User Review Required

> [!IMPORTANT]
> This change modifies the `Product` entity to include `preferredSupplierId` and `reorderPoint`. Existing products will default to no preferred supplier and a reorder point of 0.

## Proposed Changes

### 1. Domain & Data

#### [MODIFY] [product.dart](file:///A:/Workspace/d-h-s/lib/features/inventory/domain/entities/product.dart)
- Add `preferredSupplierId` (String?) and `reorderPoint` (double).

#### [MODIFY] [product_model.dart](file:///A:/Workspace/d-h-s/lib/features/inventory/data/models/product_model.dart)
- Update JSON mapping for the new fields.

#### [NEW] [restock_suggestion.dart](file:///A:/Workspace/d-h-s/lib/features/analytics/domain/entities/restock_suggestion.dart)
- `RestockSuggestion`: `product`, `suggestedQty`, `urgency`, `supplierId`.

### 2. Intelligence

#### [NEW] [procurement_service.dart](file:///A:/Workspace/d-h-s/lib/features/analytics/data/services/procurement_service.dart)
- Logic to scan all products and generate `RestockSuggestion` objects.
- Uses `DemandForecast` to calculate `suggestedQty` (e.g., Qty needed for next 14 days).

#### [NEW] [procurement_provider.dart](file:///A:/Workspace/d-h-s/lib/features/analytics/presentation/providers/procurement_provider.dart)
- `restockSuggestionsProvider`: Returns a list of suggestions grouped by supplier.

### 3. UI Layer

#### [NEW] [procurement_planner_screen.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/presentation/screens/procurement_planner_screen.dart)
- Dashboard showing items that need restocking.
- Grouped by Supplier.
- Button to "Create Draft Purchase Order" which navigates to `PurchaseEntryScreen` with pre-filled data.

#### [MODIFY] [purchases_screen.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/presentation/screens/purchases_screen.dart)
- Add "Smart Planner" action button in the AppBar.

#### [MODIFY] [purchase_entry_screen.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/presentation/screens/purchase_entry_screen.dart)
- Update to accept an optional list of `PurchaseItem` and a `supplierId` in the constructor to support pre-filling from the planner.

## Verification Plan

### Manual Verification
1.  **Configure Product**: Set a reorder point of 1000kg for "TMT Bar 12mm".
2.  **Generate Demand**: Create sales for 500kg.
3.  **Check Planner**: Verify "TMT Bar 12mm" appears in the Smart Planner with a suggested restock quantity.
4.  **Create PO**: Tap "Create PO" in the planner and verify `PurchaseEntryScreen` is pre-filled with the supplier and item details.

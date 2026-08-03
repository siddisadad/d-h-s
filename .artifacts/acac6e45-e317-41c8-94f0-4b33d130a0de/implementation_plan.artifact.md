# Implementation Plan - Phase 5: Advanced Procurement & Supplier Management

This phase focuses on the "Inbound" lifecycle of the hardware yard: recording purchases from suppliers, automatically increasing stock levels, and tracking liabilities in supplier ledgers.

## User Review Required

> [!IMPORTANT]
> **Stock Increment**: Recording a purchase will now automatically increase inventory stock levels across the system.

- **Liability Tracking**: Every purchase will create a "Credit" entry in the supplier's ledger, increasing the "Due Amount" shown in the Procurement dashboard.
- **Offline Reliability**: Like Sales, Purchases will support full offline entry with a background sync queue.

## Proposed Changes

### 1. Entity & Model Upgrades
#### [MODIFY] [purchase_order.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/domain/entities/purchase_order.dart)
- Upgrade `PurchaseOrder` to include `customerId` (Supplier), `items` (List<PurchaseItem>), `discount`, and `totalAmount`.
#### [NEW] [purchase_model.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/data/models/purchase_model.dart)
- Implement `toJson` and `fromJson` for the upgraded `PurchaseOrder`.

### 2. Database Foundation (v4)
#### [MODIFY] [local_database.dart](file:///A:/Workspace/d-h-s/lib/core/database/local_database.dart)
- Add `purchases` table.
- Columns: `id` (PK), `supplierId`, `supplierName`, `date`, `totalAmount`, `status`, `items` (JSON text).
- Implement `savePurchase` and `getPurchases` helper methods.

### 3. Transactional Procurement Logic
#### [MODIFY] [purchase_repository_impl.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/data/repositories/purchase_repository_impl.dart)
- Implement `createPurchase` using a `db.transaction`:
    1. Save the `PurchaseOrder` locally.
    2. **Stock Update**: For each item, increment `inventory.stock` by the purchased quantity.
    3. **Ledger Update**: Create a "Credit" entry in the `ledgers` table for the supplier.
    4. **Balance Update**: Update the supplier's balance in the `contacts` table.
    5. **Sync Queue**: If remote fails, queue a `POST /purchases` task.

### 4. UI: Intelligent Purchase Entry
#### [MODIFY] [purchase_entry_screen.dart](file:///A:/Workspace/d-h-s/lib/features/purchases/presentation/screens/purchase_entry_screen.dart)
- Implement real input dialogs for Cost Price and Quantity when adding items.
- Link the "Record Purchase Entry" button to the new repository logic.
- Add a "Scan Barcode" button to the Purchase Items section.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` on the Purchases module.

### Manual Verification
1.  **Inventory Check**: Note the stock of "Bosch Professional Drill" (e.g., 8).
2.  **Purchase Entry**: Create a purchase for 20 units from a supplier.
3.  **Stock Verify**: Check Inventory; stock should now be 28.
4.  **Ledger Verify**: Open Supplier Ledger; verify the new credit entry.
5.  **Dashboard Verify**: Verify "Due Amount" in Purchase Management dashboard has increased.

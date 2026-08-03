# Task: Phase 5 - Advanced Procurement & Supplier Management

- [x] **Entity & Model Upgrades**
    - [x] Update `PurchaseOrder` and `PurchaseItem` entities
    - [x] Create `PurchaseModel` with JSON serialization
- [x] **Database Foundation (v4)**
    - [x] Update `LocalDatabase` with `purchases` table
    - [x] Implement local save/get methods for purchases
- [x] **Transactional Procurement Logic**
    - [x] Implement `PurchaseRepositoryImpl.createPurchase` with `db.transaction`
    - [x] Logic: Stock Increment -> Ledger Credit -> Balance Update
- [x] **UI: Intelligent Purchase Entry**
    - [x] Implement Price/Qty inputs in `PurchaseEntryScreen`
    - [x] Add "Scan Barcode" functionality to purchase entry
    - [x] Link "Record Purchase Entry" button to repository
- [x] **Verification**
    - [x] Run `flutter analyze`
    - [x] Verify atomic purchase flow (Stock up -> Ledger credit)

---

# Task: Phase 4 - Rapid Inventory Auditing & Barcode Integration

- [x] **Employee Module Upgrade (Local-First)**
...
- [x] **Verification**
...
- [x] Fix compilation errors from entity/model changes

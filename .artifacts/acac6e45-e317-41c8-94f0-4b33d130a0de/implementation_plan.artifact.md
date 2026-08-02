# Enterprise-Grade ERP Overhaul Implementation Plan

This plan outlines the transformation of the Deshmukh ERP into a production-ready, enterprise-grade application with Clean Architecture, robust security, offline resilience, and global localization.

## Phase 1: Foundation & RBAC (Architecture & Security)

### [MODIFY] [Clean Architecture Refactoring]
- Complete the migration of all feature providers (CRM, Employees, Finance, Purchases) to use Riverpod-based Dependency Injection for Repositories and Use Cases.
- This ensures the presentation layer is decoupled from the Service Locator (`sl`).

### [NEW] [RBAC (Role-Based Access Control) Matrix]
- Define a `Permission` enum (e.g., `viewInventory`, `editPrice`, `manageEmployees`).
- Map `AppUser` roles (`Admin`, `Manager`, `Employee`) to specific permission sets.
- Update `PermissionWrapper` to accept permissions instead of raw role strings.

### [MODIFY] [Global Error Handling]
- Extend `GlobalErrorBoundary` to include a "Report Error" feature (simulated for now, can be linked to a backend logging endpoint).
- Integrate `connectivity_plus` to show a "No Internet" banner globally.

---

## Phase 2: Offline Resilience & Synchronization

### [NEW] [Offline Engine (SQFlite + Sync Queue)]
- Implement a local database using `sqflite` to mirror critical cloud data (Inventory, Contacts).
- **Change Tracker**: Create a mechanism to log local mutations (Create/Update/Delete) when the device is offline.
- **Background Sync**: Implement a sync service that pushes the local "mutation queue" to the server when connectivity is restored, including basic timestamp-based conflict resolution.

---

## Phase 3: Enterprise Features & Localization

### [NEW] [Audit Trail Service]
- Create an `AuditService` that automatically logs every state-changing operation with the user ID, timestamp, and action details.
- Integrate this service into all Notifiers.

### [NEW] [Localization (l10n)]
- Set up `flutter_localizations`.
- Implement `AppLocalizations` for:
    - **English** (Primary)
    - **Marathi** (Regional)
    - **Hindi** (National)
- Create a `Settings` option to toggle language dynamically.

### [MODIFY] [Analytics & Reports]
- Connect the `AnalyticsScreen` to real aggregated data from the repositories.
- Implement "Drill-down" reports (e.g., tap a bar in the "Sales" chart to see the specific invoices for that day).

---

## Phase 4: CI/CD & Production Readiness

### [NEW] [Automated Testing Suite]
- Expand unit tests for all Use Cases.
- Add widget tests for complex UI components like `SalesInvoiceScreen`.

### [NEW] [CI/CD Pipeline]
- Create a `.github/workflows/main.yml` file for:
    - Automated `flutter analyze`.
    - Automated `flutter test`.
    - Automated Build (Android APK, Web).

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` after every phase.
- Execute the E2E flow test in `integration_test/full_flow_test.dart`.

### Manual Verification
1.  **RBAC**: Log in as an "Employee" and verify they cannot see the "Finance" tab or edit product prices.
2.  **Offline**: Disable internet, create a mock sale, then enable internet and verify it syncs to the "Recent Activity" log.
3.  **L10n**: Switch to "Marathi" in settings and verify the entire Dashboard labels update.

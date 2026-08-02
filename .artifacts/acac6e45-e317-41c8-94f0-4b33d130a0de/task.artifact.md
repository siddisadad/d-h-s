# Task: Enterprise Overhaul - Phase 1 (Foundation & RBAC)

- `[/]` Clean Architecture Refactoring (DI Migration)
    - `[ ]` Refactor `CrmNotifier` & add providers
    - `[ ]` Refactor `EmployeeNotifier` & add providers
    - `[ ]` Refactor `FinanceNotifier` & add providers
    - `[ ]` Refactor `PurchaseNotifier` & add providers
- `[ ]` Security & RBAC Implementation
    - `[ ]` Define `Permission` enum in `core/security/permissions.dart`
    - `[ ]` Create `RolePermissions` mapping
    - `[ ]` Update `AppUser` to include permissions (computed or stored)
    - `[ ]` Refactor `PermissionWrapper` to use `Permission` enum
- `[ ]` Global Resilience
    - `[ ]` Implement `ConnectivityService` with `connectivity_plus`
    - `[ ]` Add global "No Internet" indicator in `AppScaffold`
- `[ ]` Verification
    - `[ ]` Run `flutter analyze`
    - `[ ]` Verify role-based UI visibility

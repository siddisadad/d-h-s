# Implementation Plan - Fixing Side Navigation for All Modules

This plan ensures that the Side Navigation Drawer is consistently integrated and working correctly across all modules of the ERP system. It also ensures that the active item is accurately highlighted in the drawer.

## Proposed Changes

### Core Design System

#### [MODIFY] [app_scaffold.dart](file:///A:/Workspace/d-h-s/lib/core/design_system/app_scaffold.dart)
- Ensure the drawer icon is always visible and functional.
- Pass through the `drawer` parameter correctly to the `Scaffold`.

---

### Navigation Component

#### [MODIFY] [side_nav_widget.dart](file:///A:/Workspace/d-h-s/lib/components/side_nav/side_nav_widget.dart)
- Synchronize route names between `side_nav_widget.dart` and `nav.dart`.
- Fixed the `isSelected` logic to be more robust by matching exact route names where possible.
- Corrected the target name for Settings from `SettingsScreen` to `BusinessSettings`.

---

### Module Integration

#### [MODIFY] [inventory_screen.dart](file:///A:/Workspace/d-h-s/lib/features/inventory/presentation/screens/inventory_screen.dart)
- Replace the standard `Scaffold` with `AppScaffold` to automatically inherit the side navigation drawer.
- Wrap the body content within `AppScaffold` structure.

#### [MODIFY] [login_screen.dart](file:///A:/Workspace/d-h-s/lib/features/auth/presentation/screens/login_screen.dart)
- Ensure the login screen *does not* have a side nav (this is already the case as it uses standard `Scaffold`).

## Verification Plan

### Manual Verification
1.  **Inventory Screen**: Verify that the "hamburger" menu icon now appears and opens the drawer.
2.  **Highlighting**: Navigate through all modules (Dashboard, Inventory, Sales, etc.) and verify that the correct item is highlighted in the drawer.
3.  **Settings**: Verify that the Settings link correctly navigates to the Business Settings screen.
4.  **Consistency**: Check every major screen to ensure the drawer is present and functional.

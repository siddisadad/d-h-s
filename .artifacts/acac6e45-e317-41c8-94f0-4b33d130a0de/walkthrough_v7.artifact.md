# Walkthrough - Responsive Side Nav & Layout Engine

I have implemented a professional, enterprise-grade **Responsive Layout Engine** with a collapsible side navigation system. This ensures the app feels native and high-performance on both mobile and desktop screens.

## Changes Made

### 1. Persistent Navigation Shell
- **[app_router.dart](file:///A:/Workspace/d-h-s/lib/core/router/app_router.dart)**: Refactored the routing system to use a `ShellRoute`. All authenticated pages (Inventory, Dashboard, etc.) are now children of a unified `AppScaffold`. This prevents the sidebar from "reloading" or flickering when navigating between pages.

### 2. Collapsible Layout Engine
- **[side_nav_provider.dart](file:///A:/Workspace/d-h-s/lib/core/providers/side_nav_provider.dart)**: Created a global state to manage the expanded/collapsed status of the sidebar.
- **[app_scaffold.dart](file:///A:/Workspace/d-h-s/lib/core/design_system/app_scaffold.dart)**: Updated the root layout to be responsive.
    - **Desktop (>1024px)**: Shows a persistent sidebar and a fixed top header.
    - **Mobile/Tablet**: Remains clean with standard drawer behavior managed by individual screens.
- **[app_bar_provider.dart](file:///A:/Workspace/d-h-s/lib/core/providers/app_bar_provider.dart)**: Implemented a global AppBar state management system. This allows children screens (like Inventory) to inject their own titles and action buttons into the shared desktop header dynamically.

### 3. High-Fidelity Side Nav
- **[side_nav_widget.dart](file:///A:/Workspace/d-h-s/lib/components/side_nav/side_nav_widget.dart)**:
    - **Expanded Mode**: Full-width (280px) with icons, labels, and a rich profile header.
    - **Collapsed Mode**: Narrow rail (80px) with icons and tooltips.
    - Uses `AnimatedContainer` for smooth width transitions.
    - Profiles are automatically truncated in collapsed mode for visual clarity.

## How it Works
1.  On a large screen, look for the **Toggle Icon** (left of the title).
2.  Click it to collapse the sidebar into a narrow icon-only rail.
3.  Navigate through different modules (Dashboard -> Inventory) and notice the sidebar stays exactly where you left it.
4.  Each screen automatically updates the top header with its own name and relevant actions (like "Add Product").

## Verification Results

### Automated Tests
- Ran `flutter analyze`: **No issues found!**

### Manual Verification
- Verified that the "DCI ERP" title correctly changes to "PRODUCT INVENTORY" when switching pages.
- Verified that the sidebar correctly hides labels when collapsed.

> [!TIP]
> The sidebar state is global. If you collapse it on the Dashboard, it will stay collapsed on the Inventory screen, providing a consistent workspace for power users.

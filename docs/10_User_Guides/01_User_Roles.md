# 10 User Role Documentation (RBAC)

## 1.1 Director (Super Admin)
- **Permissions**: Full system access, financial analytics, delete/edit any transaction, staff management.
- **Dashboard**: High-level financial trends and profit/loss reports.
- **Restrictions**: None.

## 1.2 Administrator
- **Permissions**: Operational control, inventory oversight, CRM management, reports.
- **Responsibilities**: Ensuring data accuracy and approving bulk stock adjustments.
- **Restrictions**: Cannot modify Director-level settings.

## 1.3 Manager
- **Permissions**: Stock management, sales invoicing, customer lookups.
- **Responsibilities**: Inventory health and yard operations.
- **Restrictions**: Cannot view staff salaries or total business profit figures.

## 1.4 Employee (Sales Executive)
- **Permissions**: Invoice creation, product search, customer entry.
- **Responsibilities**: Daily customer interactions and checkout.
- **Restrictions**: No access to purchase costs, salaries, or financial ledgers.

## 1.5 Permission Enforcement
Permissions are enforced at two levels:
1.  **UI Level**: [PermissionWrapper](file:///A:/Workspace/d-h-s/lib/core/widgets/permission_wrapper.dart) hides buttons and entire screens.
2.  **API Level**: Spring Boot JWT roles prevent unauthorized endpoint access.

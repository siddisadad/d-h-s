# Module: Inventory Management

## 2.1 Purpose
Centralized control of the product master and real-time stock levels. Critical for maintaining steel inventory and yard operations.

## 2.2 Features
- **Product Master**: Detailed tracking of SKU, Unit (Kg/MT), HSN Codes, and Pricing.
- **Real-Time Sync**: Background synchronization with the Spring Boot API.
- **Stock Alerts**: Intelligent highlighting of low-stock items using [InventoryStatCardWidget](file:///A:/Workspace/d-h-s/lib/components/inventory_stat_card/inventory_stat_card_widget.dart).
- **Global Search**: High-speed lookup by product name or SKU across thousands of items.

## 2.3 Workflow
1.  **View**: User browses categorized product list.
2.  **Adjust**: Manager selects a product and manually updates stock (In/Out/Return).
3.  **Audit**: Every change triggers a new record in the [Activity Log](file:///A:/Workspace/d-h-s/lib/features/dashboard/presentation/providers/activity_provider.dart).
4.  **Export**: Export current stock status to Excel for physical verification audits.

## 2.4 Business Rules
-   Stock cannot be negative (enforced at Notifier level).
-   Manual stock adjustment requires a "Subtitle" explanation (reason for change).
-   Category names are fixed to standard industrial groups (Steel, Power Tools, etc.).

## 2.5 Database (Products Table)
| Field | UI Type | Validation |
| :--- | :--- | :--- |
| `sku` | Text | Unique, Max 50 chars. |
| `stock` | Double | Must be >= 0. |
| `unit` | Enum | Restricted to MT, Kg, Piece, Meter. |

## 2.6 Future Improvements
-   **Barcode Integration**: Mobile camera scanning for instant inventory lookups.
-   **Multi-Warehouse**: Logical separation of stock across different physical locations.
-   **Price History**: Tracking price fluctuations over time for predictive cost analysis.

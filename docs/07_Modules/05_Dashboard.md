# Module: Dashboard & Command Center

## 5.1 Purpose
The operational heart of the DCI ERP. Provides an at-a-glance view of business performance and quick entry points for common tasks.

## 5.2 Features
- **Real-Time KPI Cards**: Live tracking of Sales, Purchases, Collections, and Low Stock counts.
- **Revenue Trends**: Interactive charts showing financial performance over the last 7 days.
- **Activity Log**: Chronological feed of system events (logins, adjustments, transactions).
- **Quick Action Grid**: One-tap access to New Sale, Inventory, Customers, and Reports.

## 5.3 Workflow
1.  **Load**: Upon successful login, the dashboard fetches aggregate stats from `/dashboard/stats`.
2.  **Monitor**: User reviews trend lines for any anomalies in daily revenue.
3.  **React**: User identifies a "Low Stock" alert and taps the KPI card to jump to the filtered Inventory list.
4.  **Execute**: User taps "New Sale" to initiate a checkout flow.

## 5.4 Business Rules
-   KPI values are updated every time the dashboard is focused or manually refreshed.
-   The activity log displays the most recent 5 entries by default to maintain performance.

## 5.5 Database (Activities Table)
| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | Text | Primary action description. |
| `subtitle` | Text | Contextual metadata. |
| `type` | String | Logic mapping (e.g., 'userLogin' uses info blue). |

## 5.6 Future Improvements
-   **Customizable Layout**: Allow users to drag and drop KPI cards to prioritize their most relevant metrics.
-   **Notification Badge**: Integrated alert count for pending approvals.
-   **Multi-Branch Toggle**: Switch between different business units directly from the header.

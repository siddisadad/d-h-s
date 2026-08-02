# 04 Software Requirement Specification (SRS)

## 4.1 Functional Requirements
*   **FR-01: Authentication**: Users must log in via email/password. Password reset functionality must be available.
*   **FR-02: Dashboard**: Real-time KPI display for Today's Sales, Purchases, Collections, and Low Stock.
*   **FR-03: Inventory**: Product master with SKU, category, and real-time stock levels.
*   **FR-04: Sales**: Multi-item invoice generation with auto-calculated GST and discounts.
*   **FR-05: CRM**: Searchable customer/supplier directories with location and GST data.
*   **FR-06: Reporting**: PDF generation for invoices and Excel export for stock lists.
*   **FR-07: Search**: Global search overlay to find anything from SKU to Invoice ID.

## 4.2 Non-Functional Requirements
*   **Performance**: Any API-backed screen must load in under 1.5 seconds on a 4G connection.
*   **Availability**: System uptime objective is 99.9%.
*   **Reliability**: Data must be consistent; no partial transactions allowed.
*   **Security**: Use JWT for API authentication and Flutter Secure Storage for tokens.
*   **Accessibility**: High-contrast "Industrial Blue" theme for visibility in outdoor yards.
*   **Scalability**: Architecture must support horizontal scaling of the Spring Boot backend to 10k+ concurrent users.

## 4.3 System Constraints
*   **Frontend**: Restricted to Flutter 3.22+.
*   **OS Support**: Android 8.0+ (for mobile) and modern browsers (Chrome/Edge for Web).
*   **Backend**: Must use the specified Spring Boot REST API endpoints.

## 4.4 Responsiveness
The UI must use a token-based layout system to adapt to:
-   **Mobile**: Single column, drawer-based navigation.
-   **Tablet**: Multi-pane views for lists and details.
-   **Desktop**: Dashboard with nav rail and expanded data tables.

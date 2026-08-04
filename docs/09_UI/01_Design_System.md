# UI Design System: DCI ERP

## 1.1 Visual Identity
The DCI ERP UI follows a **Material 3** "Industrial Purple" design system. It is designed to prioritize legibility in high-brightness outdoor environments (e.g., steel yards).

## 1.2 Color Palette

### Primary (Industrial Purple)
- **Hex**: `#6B4FA9`
- **Usage**: App bars, primary buttons, headers.

### Accent (Industrial Amber)
- **Hex**: `#F59E0B`
- **Usage**: Warnings, highlights, secondary CTAs.

### Semantic Colors
- **Success**: `#16A34A` (In Stock, Paid)
- **Error**: `#DC2626` (Low Stock, Overdue)

## 1.3 Typography
- **Primary Font**: Poppins (via Google Fonts).
- **Secondary Font**: Inter (for data tables and forms).

| Style | Size | Weight |
| :--- | :--- | :--- |
| Headline Large | 32pt | 700 |
| Title Medium | 16pt | 600 |
| Body Small | 12pt | 400 |

## 1.4 Spacing & Radius
Standardized via [DesignTokens](file:///A:/Workspace/d-h-s/lib/core/design_system/theme/design_tokens.dart).
- **Tokens**: `space8`, `space16`, `space24`, `space32`.
- **Radius**: `radiusMd` (12px), `radiusLg` (16px), `radiusFull`.

## 1.5 Key Components
- **CustomCard**: Standard elevated surface with a `#D1D5DB` border.
- **KpiCard**: Specialized dashboard component with trend indicators.
- **IconButton**: Consistent 52x52px touch target for yard operations.

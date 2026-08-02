# 09 UI: Responsive & Adaptive Design

## 2.1 Multi-Platform Strategy
DCI ERP is built to be "One Codebase, Every Device". We use a fluid layout system that scales from handheld mobile devices to 4K desktop monitors.

## 2.2 Device Breakpoints
| Device Type | Range | Strategy |
| :--- | :--- | :--- |
| **Mobile** | < 600px | Single column, Bottom navigation, Drawer menu. |
| **Tablet** | 600px - 1024px | Multi-pane layouts, persistent side rail. |
| **Desktop** | > 1024px | Expanded grids, side navigation, multi-column tables. |

## 2.3 Adaptive Widgets
- **CustomCard**: Adjusts internal padding based on screen width (`tokens.space16` on mobile vs `tokens.space24` on desktop).
- **KpiGrid**: Uses `LayoutBuilder` to toggle between a 2x2 grid (mobile) and a 4x1 row (desktop).
- **Navigation**: Automatically switches from a `Drawer` to a permanent `SideNav` on large screens.

## 2.4 Rendering Performance
- **Repaint Boundaries**: Used around complex charts to ensure smooth scrolling on lower-end Android hardware.
- **WASM for Web**: The web version uses CanvasKit for hardware-accelerated rendering, providing 60FPS animations.

# Implementation Plan - Purple Theme Migration

Migration of the application's primary brand color from Blue (`#0F4C81`) to Purple (`#6B4FA9`) across the entire system, including the UI theme, PDF service, and web manifest.

## Proposed Changes

### [Core Design System]

#### [MODIFY] [app_theme.dart](file:///A:/Workspace/d-h-s/lib/core/design_system/theme/app_theme.dart)
- Update `_Palette.primary` to `#6B4FA9`.
- Update `_Palette.primaryContainer` to `#EADDFF`.
- Update `_Palette.onPrimaryContainer` to `#21005D`.
- Update `_Palette.darkPrimary` to `#D0BCFF`.
- Update `_Palette.darkPrimaryContainer` to `#4F378B`.
- Update `_Palette.darkOnPrimaryContainer` to `#EADDFF`.

### [Core Services]

#### [MODIFY] [pdf_service.dart](file:///A:/Workspace/d-h-s/lib/core/services/pdf_service.dart)
- Update `_brandColor` to `#6B4FA9` for consistency in generated documents.

### [Web Configuration]

#### [MODIFY] [manifest.json](file:///A:/Workspace/d-h-s/web/manifest.json)
- Update `background_color` and `theme_color` to `#6B4FA9`.

### [Documentation]

#### [MODIFY] [01_Design_System.md](file:///A:/Workspace/d-h-s/docs/09_UI/01_Design_System.md)
- Update color tokens in documentation to reflect the new purple theme.

## Verification Plan

### Manual Verification
- Launch the application and verify that all primary buttons, headers, and highlights are now purple.
- Switch between Light and Dark modes to ensure the purple accents look correct in both.
- Generate a sample invoice PDF and verify the brand color in the header and totals section is purple.
- Check the browser tab color (on Web) if possible.

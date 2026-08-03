# Implementation Plan - Fix Compilation Errors

This plan addresses several compilation errors in the project, primarily related to syntax, incorrect imports, and type mismatches in the analytics and inventory modules, as well as null-safety issues in the Firebase service.

## Proposed Changes

### Core Services
#### [MODIFY] [firebase_database_service.dart](file:///A:/Workspace/d-h-s/lib/core/services/firebase_database_service.dart)
- Fix null safety errors in `deleteData` and `pushData` by adding null checks for `_db`.

### Analytics Module
#### [MODIFY] [forecast_provider.dart](file:///A:/Workspace/d-h-s/lib/features/analytics/presentation/providers/forecast_provider.dart)
- Fix incorrect import path for `ForecastingService`.
- Fix `DemandForecast` constructor call:
    - Change `DemandTrend.stable` to `TrendDirection.stable`.
    - Change `daysUntilStockOut` to `estimatedDaysUntilStockOut`.

### Inventory Module
#### [MODIFY] [product_detail_screen.dart](file:///A:/Workspace/d-h-s/lib/features/inventory/presentation/screens/product_detail_screen.dart)
- Remove extra closing brace `}` at line 175 which is causing a syntax error.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to verify that all compilation errors are resolved.
- Run `dart run build_runner build --delete-conflicting-outputs` to regenerate the Riverpod providers.

### Manual Verification
- Verify that the app builds and runs without errors.
- Check the Product Detail Screen to ensure "Demand Insights" are displayed correctly.

# 14 Coding Standards: DHS Development Guidelines

## 1.1 Clean Architecture Enforcement
- **Features-First**: Every new feature must reside in its own folder under `lib/features/`.
- **Dependency Flow**: The presentation layer must never import from the data layer directly; it must always go through a Use Case.

## 1.2 Naming Conventions
- **Data Classes**: Must suffix with `Data` (e.g., `ProductData`).
- **DTOs**: Must suffix with `Model` (e.g., `ProductModel`).
- **Widgets**: PascalCase with `Widget` or `Screen` suffix.

## 1.3 State Management
- Use **Generated Riverpod Notifiers** exclusively.
- Prefer `AsyncNotifier` for any operation involving the [ApiClient](file:///A:/Workspace/d-h-s/lib/core/network/api_client.dart).

## 1.4 UI Consistency
- Always use `context.tokens` for margins and padding.
- Hardcoded hex colors are strictly forbidden; use `AppColors` from `app_theme.dart`.

## 1.5 Documentation Requirements
- All public Domain methods must have KDoc comments.
- Major architectural changes must be documented in a new `walkthrough_vX.artifact.md`.

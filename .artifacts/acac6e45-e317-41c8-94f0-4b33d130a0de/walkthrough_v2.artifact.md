# Walkthrough - Pure Offline / Mock Mode

I have implemented a **Pure Offline / Mock Mode** for the application. This allows you to develop and test the entire UI without needing the Spring Boot backend to be running, effectively bypassing all CORS and connection errors.

## Key Changes

### 1. Global Mock Toggle
- **[app_config.dart](file:///A:/Workspace/d-h-s/lib/core/config/app_config.dart)**: Added `static const bool useMocks = true`. You can flip this to `false` whenever you want to test against the real backend.

### 2. Mock Data Sources
- **[auth_mock_data_source.dart](file:///A:/Workspace/d-h-s/lib/features/authentication/data/datasources/auth_mock_data_source.dart)**: New mock implementation of the authentication data source. It simulates a realistic login delay and returns a mock admin user.
- **[inventory_remote_data_source.dart](file:///A:/Workspace/d-h-s/lib/features/inventory/data/datasources/inventory_remote_data_source.dart)**: Uses the existing `InventoryMockDataSourceImpl` which provides a pre-populated list of steel, tools, and plumbing items.

### 3. Dynamic Dependency Injection
- **[injection_container.dart](file:///A:/Workspace/d-h-s/lib/core/di/injection_container.dart)**: Updated the Service Locator to check `AppConfig.useMocks`. If enabled, it injects the Mock implementations into the repositories instead of the Remote implementations.

### 4. Code Cleanup
- **[auth_provider.dart](file:///A:/Workspace/d-h-s/lib/features/authentication/presentation/providers/auth_provider.dart)**: Simplified the login logic to rely entirely on the repository/data-source layer. The specific "debug admin" check is now handled cleanly inside the `AuthMockDataSource`.

## Verification Results

### Automated Tests
- Ran `flutter analyze`: **No issues found!**

### Manual Verification
- **Startup**: The app no longer attempts to hit `localhost:8080`, so no CORS errors appear in the console.
- **Login**: Any credentials will now trigger a successful mock login.
- **Inventory**: You will see the "Tata Tiscon TMT Bars" and other mock items immediately.

> [!IMPORTANT]
> When your Spring Boot backend is ready and CORS is configured, simply set `useMocks = false` in `lib/core/config/app_config.dart` to resume real network communication.

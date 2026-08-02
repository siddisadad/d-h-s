# 13 Security: Data & Access Protection

## 13.1 Authentication
- **Protocol**: JWT (JSON Web Tokens).
- **Client Storage**: Tokens are stored in **Flutter Secure Storage** (Keychain for iOS, Keystore for Android).
- **Session Life**: Tokens expire every 24 hours; refresh logic implemented in `AuthNotifier`.

## 13.2 Authorization (RBAC)
Access is controlled via a centralized `PermissionWrapper`.
-   **Strict Path Guards**: Non-admin users attempting to access `/finance` are redirected to `/dashboard`.
-   **Action Shields**: "Delete" and "Export" buttons are hidden from "Employee" accounts.

## 13.3 Network Security
-   **TLS**: All communication with Spring Boot happens over HTTPS.
-   **Interceptors**: Centralized [AuthInterceptor](file:///A:/Workspace/d-h-s/lib/core/network/api_client.dart) ensures no unauthenticated request leaves the device.

## 13.4 Persistence Security
-   **In-Memory Only**: Sensitive session data is cleared upon logout.
-   **WASM Isolation**: Web database (SQLite/WASM) runs in a separate worker thread to prevent main-thread XSS interference.

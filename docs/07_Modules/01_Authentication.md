# Module: Authentication

## 1.1 Purpose
Secure entry point for the DCI ERP ecosystem. Ensures that only authorized Deshmukh Hardware & Steel personnel can access proprietary business data.

## 1.2 Features
- **Email/Password Login**: Standard enterprise authentication.
- **Session Recovery**: Uses [TokenRepository](file:///A:/Workspace/d-h-s/lib/features/authentication/data/repositories/token_repository.dart) with `FlutterSecureStorage` to keep users logged in.
- **Reactive Protection**: Automatically redirects unauthenticated users to the login screen via [AppRouter](file:///A:/Workspace/d-h-s/lib/core/router/app_router.dart).
- **Password Reset**: Automated self-service email flow.

## 1.3 Workflow
1.  **Launch**: App checks for valid JWT in secure storage.
2.  **Challenge**: If token is missing/expired, user is presented with the Login Card.
3.  **Validate**: Credentials sent to Spring Boot `/auth/login`.
4.  **Authorized**: App receives JWT, stores it, and transitions to Dashboard.

## 1.4 Business Rules
-   Passwords must meet a minimum complexity requirement.
-   Login attempts are logged in the system audit trail.
-   Roles (Admin/Manager/Employee) are immutable from the frontend; assigned via backend database.

## 1.5 Permissions
| Action | Role Required |
| :--- | :--- |
| Login | Any valid staff account. |
| Reset Password | Any valid staff account. |
| Modify Roles | System Administrator (Backend only). |

## 1.6 Future Improvements
-   **Biometric Login**: Integration of Fingerprint/FaceID for mobile devices.
-   **OAuth 2.0**: Support for Google/Microsoft business accounts.
-   **Device Locking**: Restrict login to authorized yard devices only.

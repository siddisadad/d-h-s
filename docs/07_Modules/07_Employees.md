# Module: Employee Management

## 7.1 Purpose
Centralized staff directory and workforce tracking for Deshmukh Hardware & Steel.

## 7.2 Features
- **Staff Directory**: Detailed profiles including contact info, role, and department.
- **Attendance Tracking**: Simple check-in/out logic for yard staff.
- **Salary Oversight**: Restricted view of payroll details for authorized personnel.
- **Role Assignment**: Integration with RBAC to define application permissions.

## 7.3 Workflow
1.  **Onboard**: Admin adds a new employee profile to the cloud.
2.  **Sync**: App fetches real-time directory updates from `/employees`.
3.  **Track**: Managers record daily attendance status (Present/Absent).
4.  **Audit**: Payroll reviews monthly attendance reports for salary processing.

## 7.4 Security Rules
-   Salary data is hidden from non-Admin roles via [PermissionWrapper](file:///A:/Workspace/d-h-s/lib/core/widgets/permission_wrapper.dart).
-   Attendance can only be updated by the current site Manager or Admin.

## 7.5 Future Improvements
-   **Biometric Integration**: Linking mobile Fingerprint/FaceID to attendance logs.
-   **GPS Fencing**: Ensuring check-ins only happen within the yard perimeter.
-   **Payslip Generation**: Automated PDF generation for monthly salaries.

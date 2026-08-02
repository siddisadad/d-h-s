# 12 Deployment Guide: DCI ERP

## 12.1 Multi-Platform Build Strategy
DCI ERP is a cross-platform application. Follow these instructions to build for production.

### Web Deployment (Firebase Hosting)
1. **Build the WASM version**:
   ```bash
   flutter build web --wasm
   ```
2. **Deploy**:
   ```bash
   firebase deploy --only hosting
   ```

### Android Build (Google Play)
1. **Build AAB**:
   ```bash
   flutter build appbundle --release
   ```
2. **Path**: `build/app/outputs/bundle/release/app-release.aab`

### Windows Desktop
1. **Build MSIX**:
   ```bash
   flutter build windows --release
   ```

## 12.2 Environment Variables
Ensure the following are configured in [AppConfig](file:///A:/Workspace/d-h-s/lib/core/config/app_config.dart) before deployment:
- `prodBaseUrl`: Point to your production Spring Boot instance.
- `firebaseOptions`: Configure for production environment.

## 12.3 Backend Prerequisites
The Spring Boot backend must be deployed with:
- **CORS Configuration**: Allow requests from your ERP web domain.
- **SSL Certificates**: Mandatory for secure cookie/header handling.
- **Postgres Database**: Migrated with the latest ERP schema.

## 12.4 CI/CD Pipeline (Recommended)
- **GitHub Actions**: Automated `flutter analyze` and `flutter test` on every PR.
- **Codemagic**: Recommended for automated App Store and Play Store distribution.

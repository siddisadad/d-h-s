# Deshmukh Steel ERP

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## CI/CD

GitHub Actions runs dependency resolution, static analysis, tests, and Android
and web builds for pushes and pull requests targeting `flutterflow` or `dev`.

Deployments are manually triggered through the **Deploy** workflow. Configure
the following GitHub Actions secrets before releasing:

- Android: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
  `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, and
  `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`.
- iOS: `APPLE_ID`, `APP_STORE_CONNECT_API_KEY_ID`,
  `APP_STORE_CONNECT_API_KEY_ISSUER_ID`, and
  `APP_STORE_CONNECT_API_KEY_CONTENT`.

Set the Apple Developer team ID in `ios/ExportOptions.plist` before running an
iOS deployment.

# Implementation Plan - Automated Deployment with Fastlane

Automate the build and distribution process for both Android (Google Play) and iOS (TestFlight) using Fastlane and GitHub Actions.

## User Review Required

> [!IMPORTANT]
> This setup requires several sensitive credentials that must be added as **GitHub Secrets**. You will need to prepare:
> 1. **Android**: Google Play Service Account JSON key, Keystore file, Keystore password.
> 2. **iOS**: App Store Connect API Key (P8 file), Issuer ID, Key ID, and Distribution Certificate.

## Proposed Changes

### [Android Deployment]

#### [NEW] [Appfile](file:///C:/Users/USER/StudioProjects/d-h-s/android/fastlane/Appfile)
Defines the package name and path to the JSON key file.

#### [NEW] [Fastfile](file:///C:/Users/USER/StudioProjects/d-h-s/android/fastlane/Fastfile)
Defines lanes for:
- `build_aab`: Builds the release App Bundle.
- `upload_to_play_store`: Uploads the AAB to the Internal track.

---

### [iOS Deployment]

#### [NEW] [Appfile](file:///C:/Users/USER/StudioProjects/d-h-s/ios/fastlane/Appfile)
Defines the Bundle Identifier and Apple ID/Team ID.

#### [NEW] [Fastfile](file:///C:/Users/USER/StudioProjects/d-h-s/ios/fastlane/Fastfile)
Defines lanes for:
- `beta`: Builds the IPA and uploads it to TestFlight.
- Uses `match` or `sync_code_signing` to handle certificates.

---

### [CI/CD Orchestration]

#### [NEW] [deploy.yml](file:///C:/Users/USER/StudioProjects/d-h-s/.github/workflows/deploy.yml)
A new GitHub Actions workflow that:
- Triggers manually via `workflow_dispatch`.
- Decodes secrets (Keystore, P8 key) from GitHub Secrets.
- Installs Ruby and Fastlane dependencies.
- Runs the respective Fastlane lanes for Android and iOS.

## Verification Plan

### Automated Checks
- Validate that the new workflow file is syntactically correct.
- Verify that `fastlane` is configured to use environment variables for all sensitive paths.

### Manual Verification
- The user will need to run the workflow manually once secrets are added to verify the connection to Play Store/App Store.

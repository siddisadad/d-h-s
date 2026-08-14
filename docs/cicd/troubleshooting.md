# Troubleshooting CI/CD

Common issues and how to resolve them.

## 1. Keystore Decoding Failure
**Error**: `base64: invalid input` or build fails with "Invalid keystore format".
**Fix**: Ensure `ANDROID_KEYSTORE_BASE64` is a single-line string without spaces. Verify the encoding process described in `setup.md`.

## 2. Google Play Authentication Failure
**Error**: `Google Play API: Unauthorized` or `Service account not found`.
**Fix**: 
- Verify `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` is correct.
- Ensure the Service Account has been added to the Google Play Console with "Release Manager" permissions.
- Ensure the Google Play Developer API is enabled in the Google Cloud Console.

## 3. Duplicate Version Code
**Error**: `Version code 10 has already been used`.
**Fix**: Increment the build number in `pubspec.yaml` (e.g., `1.0.0+11`) and push.

## 4. Flutter/Gradle Version Mismatch
**Error**: `Gradle task assembleRelease failed`.
**Fix**: Ensure the Java version in the workflow (`java-version: '17'`) matches your local environment. Check `android/gradle/wrapper/gradle-wrapper.properties` for the expected Gradle version.

## 5. Artifact Retention
**Issue**: Build artifacts are missing.
**Info**: Artifacts are kept for 7-14 days by default to save storage. Important releases should be tracked via GitHub Releases.

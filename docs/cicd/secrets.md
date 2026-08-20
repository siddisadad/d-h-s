# Secrets Management

This project follows strict security practices for managing sensitive information.

## Security Principles

1.  **Zero Persistence**: Secrets are never committed to the repository.
2.  **Encrypted Storage**: All secrets are stored in GitHub Encrypted Secrets.
3.  **Environment Isolation**: Production secrets can be restricted to specific environments.
4.  **Ephemeral Usage**: Sensitive files (like keystores and JSON keys) are created during the workflow run and deleted immediately after use.

## Required Secrets

### Android Signing
- `ANDROID_KEYSTORE_BASE64`: The base64 representation of the signing keystore.
- `ANDROID_KEYSTORE_PASSWORD`: Keystore passphrase.
- `ANDROID_KEY_ALIAS`: Key alias name.
- `ANDROID_KEY_PASSWORD`: Key passphrase.

### Google Play
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: The JSON key for the Google Play Developer API service account.

## Safe to Commit
The following files are **safe** to commit as they do not contain sensitive secrets:
- `google-services.json`: Contains public project identifiers for Firebase.
- `pubspec.yaml`: Project dependencies.
- `analysis_options.yaml`: Linting rules.

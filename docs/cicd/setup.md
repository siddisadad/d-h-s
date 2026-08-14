# CI/CD Setup Guide

Follow these steps to set up the CI/CD pipeline for your project.

## 1. Android Signing Setup

### Generate Keystore
If you don't have one, generate a keystore:
```bash
keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

### Encode Keystore
Base64 encode your keystore file to add it to GitHub Secrets:
```bash
# macOS/Linux
base64 -i upload-keystore.jks | pbcopy

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | clip
```

## 2. Google Play Setup

### Service Account
1.  Go to the [Google Play Console](https://play.google.com/console).
2.  Navigate to **Setup** > **API access**.
3.  Create a Google Cloud Project or link an existing one.
4.  Create a **Service Account** with the "Release Manager" role.
5.  Generate a **JSON Key** and download it.

## 3. GitHub Secrets Configuration

Add the following secrets to your GitHub repository (**Settings > Secrets and variables > Actions**):

| Secret Name | Description |
| :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded content of your `.jks` file. |
| `ANDROID_KEYSTORE_PASSWORD` | Password for your keystore. |
| `ANDROID_KEY_ALIAS` | Alias name for your key. |
| `ANDROID_KEY_PASSWORD` | Password for your key. |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Content of the Service Account JSON key. |

## 4. GitHub Environments

Create environments in **Settings > Environments**:
- `internal`
- `alpha`
- `beta`
- `production` (Add "Required reviewers" for extra security)

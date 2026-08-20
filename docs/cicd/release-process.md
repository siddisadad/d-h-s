# Release Process

This document outlines the process for releasing a new version of the application.

## Versioning Strategy

We use Semantic Versioning (SemVer) combined with a build number: `major.minor.patch+build`.
- Example: `1.2.0+45`
- The version is updated in `pubspec.yaml`.

## Release Workflow

### 1. Feature Development
Developers work on `feature/*` branches. CI runs on every PR to `develop`.

### 2. Internal Release
Merging to `develop` or manual trigger:
1.  CI checks pass.
2.  Build signed AAB.
3.  Deploy to Google Play **Internal Testing** track.
4.  QA team verifies on devices.

### 3. Production Release
When ready for production:
1.  Create a tag: `git tag v1.2.0`
2.  Push tag: `git push origin v1.2.0`
3.  The `Android Release` workflow triggers automatically.
4.  Deployment to **Production** requires manual approval in GitHub Actions.

## Rollback Process

In case of a critical issue in production:

1.  Identify the last stable build in the **GitHub Actions** history.
2.  Manually trigger the `Android Release` workflow for that specific commit or tag.
3.  Provide a higher build number if necessary to override the failing version in the Play Store.
4.  Verify the fix on the Internal track before promoting to Production.

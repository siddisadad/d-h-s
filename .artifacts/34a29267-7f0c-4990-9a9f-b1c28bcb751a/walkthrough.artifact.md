# Walkthrough - Fixed sqflite_ffi Initialization for Desktop

The application was failing on Desktop platforms because `sqflite` requires explicit initialization of the `databaseFactory` using `sqflite_common_ffi`. The previous implementation was attempting to check the state of `databaseFactory` before setting it, which itself triggered the "Bad state" exception.

## Changes

### Core Database

#### [local_database.dart](file:///A:/Workspace/d-h-s/lib/core/database/local_database.dart)
- Updated `_initDatabase` to safely initialize `sqflite_ffi` without pre-checking the `databaseFactory` getter.
- Wrapped the initialization in a `try-catch` block for better reliability.
- Restricted automatic FFI initialization to Windows and Linux (where it's strictly required and default factory is missing).

### Application Entry Point

#### [main.dart](file:///A:/Workspace/d-h-s/lib/main.dart)
- Synchronized the Desktop initialization logic with `LocalDatabase`.
- Added error handling to the `main` initialization sequence.

## Verification Results

### Manual Verification
- [x] Verified that initialization logic is now robust against "Bad state" errors during the setup phase.
- [x] Confirmed that `sqfliteFfiInit()` and `databaseFactory = databaseFactoryFfi` are called before any `openDatabase` calls on Desktop.

> [!TIP]
> This fix ensures that even if the app starts in a "clean" state on Desktop, the database is ready for use as soon as the Inventory or CRM features are accessed.

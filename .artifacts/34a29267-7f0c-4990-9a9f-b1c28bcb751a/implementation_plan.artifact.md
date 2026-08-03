# Fix sqflite_ffi Initialization for Desktop

The application is failing on Desktop (specifically Windows/Linux) because the `sqflite` database factory is not correctly initialized before the first database access. The current check in `LocalDatabase` might be crashing before it can perform the initialization because it accesses the `databaseFactory` getter, which throws if uninitialized on these platforms.

## User Review Required

> [!IMPORTANT]
> This change modifies the core database initialization logic. It ensures that `sqflite_common_ffi` is correctly set up for Desktop platforms.

## Proposed Changes

### Core

#### [MODIFY] [local_database.dart](file:///A:/Workspace/d-h-s/lib/core/database/local_database.dart)
- Simplify the Desktop initialization guard to avoid accessing `databaseFactory` getter before it's set.
- Use a safer initialization pattern that works across Windows, Linux, and macOS (if using FFI).
- Add robust error handling during database initialization.

#### [MODIFY] [main.dart](file:///A:/Workspace/d-h-s/lib/main.dart)
- Ensure the initialization in `main` is consistent with `LocalDatabase`.
- Add more descriptive logging to confirm Desktop initialization status.

## Verification Plan

### Manual Verification
- Run the application on Windows/Desktop.
- Navigate to the Inventory screen (which triggers the database access).
- Verify that the "Bad state: databaseFactory not initialized" error no longer appears in the logs.
- Check the debug logs for "🖥️ Initializing sqflite_ffi for Desktop".

class AppConfig {
  static const String devBaseUrl = 'http://localhost:8080/api/v1';
  static const String prodBaseUrl = 'https://api.deshmukh-erp.com/v1';
  
  static String get baseUrl => devBaseUrl; // Default to dev

  // Set this to TRUE to bypass all backend network calls and use local mock data
  static const bool useMocks = false;

  // Set this to TRUE to use Firebase Realtime Database as the remote source
  static const bool useFirebase = true;

  static bool get isDevelopment => true; // Could be determined by kDebugMode
}

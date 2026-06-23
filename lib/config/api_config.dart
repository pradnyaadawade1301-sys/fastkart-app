// lib/config/api_config.dart
// FastKart API Configuration

class ApiConfig {
  // ─── Environment ──────────────────────────────────────────────────────────
  // Development:  flutter run
  // Production:   flutter build apk --dart-define=PRODUCTION=true
  //               flutter build appbundle --dart-define=PRODUCTION=true
  //
  // Android emulator ke liye dev URL: 10.0.2.2 (localhost proxy)
  // Physical device dev:  apne computer ka LAN IP daalo

  static const bool isProduction =
      bool.fromEnvironment('PRODUCTION', defaultValue: false);

  static const String _devBaseUrl  = 'http://10.0.2.2:8080/api';
  static const String _prodBaseUrl = 'https://api.fastkart.in/api';

  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

  // /health backend root par hai, /api ke andar nahi
  static String get healthUrl => baseUrl.replaceFirst('/api', '/health');

 
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
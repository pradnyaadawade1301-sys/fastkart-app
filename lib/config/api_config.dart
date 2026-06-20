// lib/config/api_config.dart
class ApiConfig {
  // ─── Yahan sirf apna production domain daalo ───────────────────────────
  static const String _prodDomain = 'api.fastkart.in'; // <-- sirf yahi badlo

  // ─── Dev URLs (kuch touch mat karo) ────────────────────────────────────
  static const String _devHost = 'http://192.168.1.30:8080';
  static const String _prodHost = 'https://$_prodDomain';

  // ─── isProduction = true karo jab deploy karo ──────────────────────────
  static const bool isProduction = false;

  static String get baseHost => isProduction ? _prodHost : _devHost;
  static String get baseUrl => '$baseHost/api';
  // WebSocket URL (wss production mein, ws dev mein)
  static String get wsBaseUrl =>
isProduction ? 'wss://$_prodDomain' : 'ws://192.168.1.30:8080';
  // Razorpay — https://dashboard.razorpay.com
  static const String razorpayKeyId = 'rzp_test_XXXXXXXXXX';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
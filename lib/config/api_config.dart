// lib/config/api_config.dart
// FastKart API Configuration

class ApiConfig {
  // ─── Development mein yeh use karo ───
  // Android emulator ke liye: 10.0.2.2
  // Physical device: apna computer ka IP
  // Production: apna domain

  static const String _devBaseUrl = 'http://10.0.2.2:8080/api/v1';
  static const String _prodBaseUrl = 'https://api.fastkart.in/api/v1';

  static const bool isProduction = false; // production mein true karo

  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

  // Razorpay — https://dashboard.razorpay.com se lo
  static const String razorpayKeyId = 'rzp_test_XXXXXXXXXX'; // apni test key daalo

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
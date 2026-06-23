// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static String? _token;

  // ── Token Management ──────────────────────────────────────────────────────
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── Backend Health Check ───────────────────────────────────────────────────
  static Future<bool> isBackendOnline() async {
    try {
      final res = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));
      return res.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Login (email + password) ───────────────────────────────────────────────
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    // Demo credentials
    if (email == 'pradnya@gmail.com' && password == '123456') {
      return {
        'user': {
          'id':             'u_pradnya',
          'name':           'Pradnya',
          'email':          email,
          'phone':          '',
          'wallet_balance': 450.0,
          'points':         1280,
        }
      };
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token']?.toString();
        if (token != null) await saveToken(token);
        return data;
      }
      if (kDebugMode) debugPrint('login failed: ${res.statusCode} ${res.body}');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('login error: $e');
      return null;
    }
  }

  // ── OTP ───────────────────────────────────────────────────────────────────
  /// Returns true if OTP was sent successfully by the server.
  /// OTP is delivered via SMS only — never returned to client.
  static Future<bool> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      if (kDebugMode) debugPrint('sendOtp error: $e');
      return false;
    }
  }

  /// Returns user data map on success, null on failure.
  static Future<Map<String, dynamic>?> verifyOtp(String phone, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token']?.toString();
        if (token != null) await saveToken(token);
        return data;
      }
      if (kDebugMode) debugPrint('verifyOtp failed: ${res.statusCode}');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('verifyOtp error: $e');
      return null;
    }
  }

  // ── USER ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>? ?? data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getMe error: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(String name, String email) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('updateProfile error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getWallet() async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/me/wallet'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>? ?? data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getWallet error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> addWalletBalance(double amount) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.post(
        Uri.parse('$baseUrl/payments/wallet/add'),
        headers: _headers,
        body: jsonEncode({'amount': amount}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('addWalletBalance error: $e');
      return null;
    }
  }

  // ── RESTAURANTS ───────────────────────────────────────────────────────────
  static Future<List<dynamic>?> getRestaurants({
    String category = '', String search = '', int page = 1,
  }) async {
    try {
      if (_token == null) await loadToken();
      final uri = Uri.parse('$baseUrl/restaurants').replace(queryParameters: {
        if (category.isNotEmpty) 'category': category,
        if (search.isNotEmpty)   'search':   search,
        'page': '$page',
      });
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['data'] as List?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getRestaurants error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getRestaurant(String id) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>? ?? data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getRestaurant error: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getMenu(String restaurantId) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/restaurants/$restaurantId/menu'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['data'] as List?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getMenu error: $e');
      return null;
    }
  }

  // ── ORDERS ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> orderData) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: jsonEncode(orderData),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      if (kDebugMode) debugPrint('placeOrder failed: ${res.statusCode}');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('placeOrder error: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getOrders() async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['orders'] as List?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getOrders error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getOrder(String id) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getOrder error: $e');
      return null;
    }
  }

  static Future<bool> cancelOrder(String id) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.post(
        Uri.parse('$baseUrl/orders/$id/cancel'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('cancelOrder error: $e');
      return false;
    }
  }
}
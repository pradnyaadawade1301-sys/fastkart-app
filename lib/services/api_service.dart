// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';
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

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Backend Online Check ──────────────────────────────────────────────────
  static Future<bool> isBackendOnline() async {
    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:8080/health'),
      ).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  /// Send OTP — returns OTP string (dev mode) or null on error
  static Future<String?> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['otp']?.toString() ?? '123456';
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('sendOtp error: $e');
      return null;
    }
  }

  /// Verify OTP — returns user map or null on error
  static Future<Map<String, dynamic>?> verifyOtp(String phone, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp, 'role': 'customer'}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token']?.toString();
        if (token != null) await saveToken(token);
        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('verifyOtp error: $e');
      return null;
    }
  }

  // ── USER ──────────────────────────────────────────────────────────────────

  /// Get current user profile
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getMe error: $e');
      return null;
    }
  }

  /// Update profile
  static Future<bool> updateProfile(String name, String email) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get wallet balance + transactions
  static Future<Map<String, dynamic>?> getWallet() async {
    try {
      if (_token == null) await loadToken();
      final res = await http.get(
        Uri.parse('$baseUrl/me/wallet'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Add wallet balance
  static Future<Map<String, dynamic>?> addWalletBalance(double amount) async {
    try {
      if (_token == null) await loadToken();
      final res = await http.post(
        Uri.parse('$baseUrl/payments/wallet/add'),
        headers: _headers,
        body: jsonEncode({'amount': amount}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (_) {
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
        if (search.isNotEmpty) 'search': search,
        'page': '$page',
      });
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
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
        final data = jsonDecode(res.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (_) {
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
        final data = jsonDecode(res.body);
        return data['data'] as List?;
      }
      return null;
    } catch (_) {
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
        return jsonDecode(res.body);
      }
      return null;
    } catch (_) {
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
        final data = jsonDecode(res.body);
        return data['orders'] as List?;
      }
      return null;
    } catch (_) {
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
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (_) {
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
    } catch (_) {
      return false;
    }
  }
}
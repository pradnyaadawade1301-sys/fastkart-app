// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend server ka address
  static const baseUrl = 'http://localhost:8080';

  // ── Token save/get ────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('jwt_token');
  }

  static Future<void> clearToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('jwt_token');
  }

  static Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<bool> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> verifyOtp(
      String phone, String otp, String role) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp, 'role': role}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveToken(data['token']);
        return data['user'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Restaurants ───────────────────────────────────────────────────────────
  static Future<List> getRestaurants() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/restaurants'),
        headers: await _headers,
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────
  static Future<Map?> placeOrder(Map orderData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: await _headers,
        body: jsonEncode(orderData),
      );
      if (res.statusCode == 201) return jsonDecode(res.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── User Profile ──────────────────────────────────────────────────────────
  static Future<Map?> getProfile() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/me'),
        headers: await _headers,
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      return null;
    }
  }
}
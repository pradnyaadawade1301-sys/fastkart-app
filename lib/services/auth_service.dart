// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  AppUser? user;

  bool get isLoggedIn => isAuthenticated;
  bool get isAuthenticated => user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('is_logged_in') ?? false;
    if (!saved) return;
    await ApiService.loadToken();
    user = AppUser(
      id:             prefs.getString('user_id')      ?? '',
      name:           prefs.getString('user_name')    ?? '',
      phone:          prefs.getString('user_phone')   ?? '',
      email:          prefs.getString('user_email')   ?? '',
      defaultAddress: prefs.getString('user_address') ?? '',
      walletBalance:  prefs.getDouble('user_wallet')  ?? 0,
      points:         prefs.getInt('user_points')     ?? 0,
      profileImageUrl: prefs.getString('user_avatar'),
    );
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await ApiService.login(email, password);

    if (result != null) {
      final u = result['user'] as Map<String, dynamic>? ?? {};
      user = AppUser(
        id:             u['id']?.toString()                        ?? 'u_demo',
        name:           u['name']?.toString()                      ?? email.split('@').first,
        phone:          u['phone']?.toString()                     ?? '',
        email:          u['email']?.toString()                     ?? email,
        walletBalance:  (u['wallet_balance'] as num?)?.toDouble()  ?? 0,
        points:         (u['points'] as num?)?.toInt()             ?? 0,
        defaultAddress: u['address']?.toString()                   ?? '',
      );
      await _saveSession();
      isLoading = false;
      notifyListeners();
      return true;
    }

    error = 'Invalid email or password';
    isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    String? password,
    String? phone,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    user = AppUser(
      id:           'u_${DateTime.now().millisecondsSinceEpoch}',
      name:         name,
      phone:        phone ?? '',
      email:        email,
      walletBalance: 0,
      points:       0,
    );
    await _saveSession();
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> refreshUser() async {
    try {
      final data = await ApiService.getMe();
      if (data != null && user != null) {
        user = user!.copyWith(
          name:          data['name']?.toString(),
          email:         data['email']?.toString(),
          walletBalance: (data['wallet_balance'] as num?)?.toDouble(),
          points:        (data['points'] as num?)?.toInt(),
        );
        await _saveSession();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    user = null;
    error = null;
    notifyListeners();
  }

  void updateUser(AppUser updated) {
    user = updated;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in',    true);
    await prefs.setString('user_id',       user!.id);
    await prefs.setString('user_name',     user!.name);
    await prefs.setString('user_phone',    user!.phone);
    await prefs.setString('user_email',    user!.email);
    await prefs.setString('user_address',  user!.defaultAddress);
    await prefs.setDouble('user_wallet',   user!.walletBalance);
    await prefs.setInt('user_points',      user!.points);
    if (user!.profileImageUrl != null) {
      await prefs.setString('user_avatar', user!.profileImageUrl!);
    }
  }
}
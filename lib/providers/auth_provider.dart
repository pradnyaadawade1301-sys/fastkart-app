// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  AppUser? user;

  bool get isLoggedIn => user != null;
  bool get isAuthenticated => user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('is_logged_in') ?? false;
    if (!saved) return;
    await ApiService.loadToken();
    user = AppUser(
      id:              prefs.getString('user_id')      ?? '',
      name:            prefs.getString('user_name')    ?? '',
      phone:           prefs.getString('user_phone')   ?? '',
      email:           prefs.getString('user_email')   ?? '',
      defaultAddress:  prefs.getString('user_address') ?? '',
      walletBalance:   prefs.getDouble('user_wallet')  ?? 0,
      points:          prefs.getInt('user_points')     ?? 0,
      profileImageUrl: prefs.getString('user_avatar'),
    );
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  // First tries backend API, falls back to locally saved credentials
  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    // Validate inputs
    if (email.trim().isEmpty || !email.contains('@')) {
      error = 'Please enter a valid email address';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      error = 'Password must be at least 6 characters';
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Try backend API first
    try {
      final result = await ApiService.login(email, password);
      if (result != null) {
        final u = result['user'] as Map<String, dynamic>? ?? {};
        user = AppUser(
          id:             u['id']?.toString()                       ?? 'u_${DateTime.now().millisecondsSinceEpoch}',
          name:           u['name']?.toString()                     ?? email.split('@').first,
          phone:          u['phone']?.toString()                    ?? '',
          email:          u['email']?.toString()                    ?? email,
          walletBalance:  (u['wallet_balance'] as num?)?.toDouble() ?? 0,
          points:         (u['points'] as num?)?.toInt()            ?? 0,
          defaultAddress: u['address']?.toString()                  ?? '',
        );
        await _saveSession();
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Backend failed — try local credentials
    final prefs = await SharedPreferences.getInstance();
    final savedEmail    = prefs.getString('reg_email')    ?? '';
    final savedPassword = prefs.getString('reg_password') ?? '';

    if (savedEmail.toLowerCase() == email.trim().toLowerCase() &&
        savedPassword == password) {
      user = AppUser(
        id:             prefs.getString('user_id')      ?? 'u_local',
        name:           prefs.getString('user_name')    ?? email.split('@').first,
        phone:          prefs.getString('user_phone')   ?? '',
        email:          email.trim(),
        walletBalance:  prefs.getDouble('user_wallet')  ?? 0,
        points:         prefs.getInt('user_points')     ?? 0,
        defaultAddress: prefs.getString('user_address') ?? '',
        profileImageUrl: prefs.getString('user_avatar'),
      );
      await _saveSession();
      isLoading = false;
      notifyListeners();
      return true;
    }

    error = savedEmail.isEmpty
        ? 'No account found. Please create an account first.'
        : 'Incorrect email or password. Please try again.';
    isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  // Saves credentials locally and tries backend
  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    String? password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    // Check if email already registered locally
    final prefs = await SharedPreferences.getInstance();
    final existingEmail = prefs.getString('reg_email') ?? '';
    if (existingEmail.isNotEmpty &&
        existingEmail.toLowerCase() == email.trim().toLowerCase()) {
      error = 'An account with this email already exists. Please sign in.';
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Save credentials locally for offline login
    await prefs.setString('reg_email',    email.trim());
    await prefs.setString('reg_password', password ?? '');

    user = AppUser(
      id:            'u_${DateTime.now().millisecondsSinceEpoch}',
      name:          name,
      phone:         phone ?? '',
      email:         email.trim(),
      walletBalance: 0,
      points:        0,
    );
    await _saveSession();

    // Try backend registration in background
    try {
      await ApiService.login(email, password ?? '');
    } catch (_) {}

    isLoading = false;
    notifyListeners();
    return true;
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile({required String name, required String email}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final success = await ApiService.updateProfile(name, email);

    if (success && user != null) {
      user = user!.copyWith(name: name, email: email);
      await _saveSession();
      isLoading = false;
      notifyListeners();
      return true;
    }

    // Update locally even if backend fails
    if (user != null) {
      user = user!.copyWith(name: name, email: email);
      await _saveSession();
      isLoading = false;
      notifyListeners();
      return true;
    }

    error = 'Profile update failed. Please try again.';
    isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Refresh User ──────────────────────────────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final data = await ApiService.getMe();
      if (data != null && user != null) {
        user = user!.copyWith(
          name:           data['name']?.toString(),
          email:          data['email']?.toString(),
          walletBalance:  (data['wallet_balance'] as num?)?.toDouble(),
          points:         (data['points'] as num?)?.toInt(),
          defaultAddress: data['address']?.toString() ?? user!.defaultAddress,
        );
        await _saveSession();
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    // Keep reg_email and reg_password so user can login again
    final regEmail    = prefs.getString('reg_email');
    final regPassword = prefs.getString('reg_password');
    await prefs.clear();
    if (regEmail != null)    await prefs.setString('reg_email',    regEmail);
    if (regPassword != null) await prefs.setString('reg_password', regPassword);
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
    await prefs.setBool('is_logged_in',   true);
    await prefs.setString('user_id',      user!.id);
    await prefs.setString('user_name',    user!.name);
    await prefs.setString('user_phone',   user!.phone);
    await prefs.setString('user_email',   user!.email);
    await prefs.setString('user_address', user!.defaultAddress);
    await prefs.setDouble('user_wallet',  user!.walletBalance);
    await prefs.setInt('user_points',     user!.points);
    if (user!.profileImageUrl != null) {
      await prefs.setString('user_avatar', user!.profileImageUrl!);
    }
  }
}
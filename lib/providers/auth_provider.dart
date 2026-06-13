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

  // ── Send OTP ──────────────────────────────────────────────────────────────
  Future<String?> sendOtp(String phone) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final returnedOtp = await ApiService.sendOtp(phone);
      isLoading = false;
      notifyListeners();
      // Backend se OTP aaya — dev mode mein response mein hoga
      return returnedOtp ?? '123456';
    } catch (_) {
      // Backend offline — demo mode
      isLoading = false;
      notifyListeners();
      return '123456';
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String phone, String otp, {required UserRole role}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Pehle real backend try karo
      final result = await ApiService.verifyOtp(phone, otp);
      if (result != null) {
        final u = result['user'] as Map<String, dynamic>? ?? {};
        user = AppUser(
          id:             u['id']?.toString()             ?? 'u_$phone',
          name:           u['name']?.toString()           ?? '',
          phone:          u['phone']?.toString()          ?? phone,
          email:          u['email']?.toString()          ?? '',
          profileImageUrl: u['avatar_url']?.toString(),
          walletBalance:  (u['wallet_balance'] as num?)?.toDouble() ?? 0,
          points:         (u['points'] as num?)?.toInt()            ?? 0,
          defaultAddress: '',
        );
        await _saveSession();
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Backend se nahi hua — demo mode (any OTP works)
    if (otp.length == 6) {
      user = AppUser(
        id:             'u_${phone.replaceAll(' ', '')}',
        name:           'User ${phone.substring(phone.length - 4)}',
        phone:          phone,
        email:          '',
        walletBalance:  450.0,
        points:         1280,
        defaultAddress: 'Mumbai',
      );
      await _saveSession();
      isLoading = false;
      notifyListeners();
      return true;
    }

    error = 'Invalid OTP. Please try again.';
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({required String name, required String email, String? phone}) async {
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

  Future<bool> sendOTP(String phone) async {
    final otp = await sendOtp(phone);
    return otp != null;
  }

  Future<bool> verifyOTP(String phone, String otp, {String role = 'customer'}) async {
    return verifyOtp(phone, otp, role: UserRole.customer);
  }

  Future<void> _saveSession() async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in',  true);
    await prefs.setString('user_id',     user!.id);
    await prefs.setString('user_name',   user!.name);
    await prefs.setString('user_phone',  user!.phone);
    await prefs.setString('user_email',  user!.email);
    await prefs.setDouble('user_wallet', user!.walletBalance);
    await prefs.setInt('user_points',    user!.points);
    if (user!.profileImageUrl != null) {
      await prefs.setString('user_avatar', user!.profileImageUrl!);
    }
  }
}
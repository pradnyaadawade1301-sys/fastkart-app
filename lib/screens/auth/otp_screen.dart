// lib/screens/auth/otp_screen.dart
// OTP screen ab use nahi hoti — Email+Password auth hai
// Agar future mein OTP chahiye toh yahan add karna
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatelessWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone, dynamic role});

  @override
  Widget build(BuildContext context) {
    // Redirect to login — OTP flow removed
    WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
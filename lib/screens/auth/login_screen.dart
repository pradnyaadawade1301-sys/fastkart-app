// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      name:  _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: Text('🛒', style: TextStyle(fontSize: 44))),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(child: Text('FastKart',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary))),
                const Center(child: Text("India's own super app",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                const SizedBox(height: 40),
                const Text('Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Enter your name and mobile number to continue',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 28),

                // Name field
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) return 'Please enter a valid name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: const Icon(Icons.phone_rounded),
                    prefixText: '+91 ',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your mobile number';
                    if (v.trim().length != 10) return 'Please enter a 10-digit number';
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) return 'Please enter a valid Indian mobile number';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Error message
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => auth.error != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(auth.error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        )
                      : const SizedBox(),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text("Don't have an account? Register",
                        style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 16),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
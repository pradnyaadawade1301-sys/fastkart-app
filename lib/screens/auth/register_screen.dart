// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  bool _obscure      = true;
  bool _obscureConf  = true;
  String? _localError;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _localError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      setState(() => _localError = auth.error ?? 'Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 24),

                // Logo
                Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Text('🛒', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('FastKart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                        color: Color(0xFFFF6F00))),
                    Text("India's Super App",
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ]),
                const SizedBox(height: 28),

                const Text('Create Account 🎉',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Fill in your details to get started',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                // Full Name
                _label('Full Name *'),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDec('Enter your full name', Icons.person_outline_rounded),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'Name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email
                _label('Email Address *'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDec('you@example.com', Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
                      return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone
                _label('Mobile Number *'),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: _inputDec('10-digit mobile number', Icons.phone_outlined)
                      .copyWith(counterText: '', prefixText: '+91 '),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                    if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim()))
                      return 'Enter a valid Indian mobile number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                _label('Password *'),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _inputDec('Min 6 characters', Icons.lock_outline_rounded).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.textSecondary, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Confirm Password
                _label('Confirm Password *'),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConf,
                  decoration: _inputDec('Re-enter password', Icons.lock_outline_rounded).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConf ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.textSecondary, size: 20),
                      onPressed: () => setState(() => _obscureConf = !_obscureConf),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Error
                if (_localError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_localError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12))),
                    ]),
                  ),

                const SizedBox(height: 24),

                // Register button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Create Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login link
                Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text('Sign In',
                        style: TextStyle(color: Color(0xFFFF6F00),
                            fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ])),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary)),
  );

  InputDecoration _inputDec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
    prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6F00), width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
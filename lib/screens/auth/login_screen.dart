// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _obscure    = true;
  String? _localError;

  static const _orange    = Color(0xFFFF8C00);
  static const _orangeEnd = Color(0xFFFFB300);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _localError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      setState(() => _localError = auth.error ?? 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Orange gradient top
        Container(
          height: MediaQuery.of(context).size.height * 0.42,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_orange, _orangeEnd],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),

        SafeArea(
          child: Column(children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('🛒', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 10),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FastKart',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text("India's Super App",
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                ]),
              ]),
            ),

            const SizedBox(height: 20),
            // Welcome! Sign In — in orange area
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text('Sign In',
                      style: TextStyle(fontSize: 15, color: Colors.white70)),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // White card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20,
                      offset: Offset(0, -4))],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      // Avatar circle
                      Transform.translate(
                        offset: const Offset(0, -36),
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_orange, _orangeEnd],
                                begin: Alignment.topLeft, end: Alignment.bottomRight),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [BoxShadow(
                                color: _orange.withValues(alpha: 0.35),
                                blurRadius: 16, offset: const Offset(0, 6))],
                          ),
                          child: const Center(child: Text('🛒', style: TextStyle(fontSize: 32))),
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Column(children: [
                          // FastKart title — not "App Name here"
                          const Text('FastKart',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 2),
                          const Text("India's Super App",
                              style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 24),

                          // Email
                          const Align(alignment: Alignment.centerLeft,
                            child: Text('Email Address',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                    color: Colors.grey))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDec('you@example.com',
                                Icons.email_outlined, focused: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
                                return 'Enter a valid email address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Align(alignment: Alignment.centerLeft,
                            child: Text('Password',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                    color: Colors.grey))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: _inputDec('Enter your password',
                                Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                    color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Error box
                          if (_localError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_localError!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12))),
                              ]),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Sign In button
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => SizedBox(
                              width: double.infinity, height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [_orange, _orangeEnd]),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(
                                      color: _orange.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4))],
                                ),
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5, color: Colors.white))
                                      : const Text('Sign In',
                                          style: TextStyle(fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register link
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text("Don't have an account? ",
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: const Text('Register Now',
                                  style: TextStyle(fontSize: 13, color: _orange,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon, {bool focused = false}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
        prefixIcon: Icon(icon, size: 20,
            color: focused ? _orange : Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: focused ? _orange : Colors.grey.shade200,
                width: focused ? 1.5 : 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _orange, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}
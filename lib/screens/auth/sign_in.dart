// lib/screens/auth/sign_in.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();

    await auth.sendOTP(_phoneCtrl.text.trim());

    final success = await auth.verifyOTP(
      _phoneCtrl.text.trim(),
      '123456',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final currentUser = auth.user;
      if (currentUser != null && _nameCtrl.text.trim().isNotEmpty) {
        auth.updateUser(currentUser.copyWith(name: _nameCtrl.text.trim()));
      }

      // ✅ Login state save karo — dobara nahi maangega
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('user_phone', _phoneCtrl.text.trim());

      if (!mounted) return;
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed, please try again'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF97316),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            left: 0, right: 0, bottom: 0,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20, offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shopping_cart_rounded,
                          size: 40, color: Color(0xFFF97316)),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        children: [
                          TextSpan(text: 'Fast', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Kart', style: TextStyle(color: Color(0xFFFDE68A))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('India\'s very own super app',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 28),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Create your account',
                                    style: TextStyle(fontSize: 20,
                                        fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                                const SizedBox(height: 4),
                                const Text('Enter your name and number, that\'s it!',
                                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                                const SizedBox(height: 28),

                                const Text('Your Name',
                                    style: TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w700, color: Color(0xFF444444))),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.name,
                                  decoration: _inputDeco(
                                    hint: 'E.g.: Rahul Sharma',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Name is required';
                                    if (v.trim().length < 2) return 'At least 2 characters required';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                const Text('Mobile Number',
                                    style: TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w700, color: Color(0xFF444444))),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _inputDeco(
                                    hint: '10 digit number',
                                    prefix: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(width: 14),
                                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Text('+91',
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15)),
                                        const SizedBox(width: 8),
                                        Container(width: 1, height: 22, color: Colors.grey[300]),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter phone number';
                                    if (v.length < 10) return 'Enter all 10 digits';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF97316),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          const Color(0xFFF97316).withValues(alpha: 0.6),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22, width: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2.5))
                                        : const Text('Open App  →',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800, fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: Text(
                                    'By logging in you agree to our Terms & Privacy Policy',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[400], height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, IconData? icon, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: prefix != null
          ? null
          : (icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null),
      prefix: prefix,
      counterText: '',
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.8)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8)),
    );
  }
}
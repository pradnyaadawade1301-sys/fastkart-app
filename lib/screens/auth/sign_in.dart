// lib/screens/auth/sign_in.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isRegister   = false; // false = Login, true = Register
  bool _obscurePass  = true;
  bool _obscureConf  = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isRegister = !_isRegister);
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    bool ok;

    if (_isRegister) {
      ok = await auth.register(
        name:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
    } else {
      ok = await auth.login(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
    }

    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Kuch galat hua, dobara try karo'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pehle email daalo'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Password reset link bheja gaya: $email'
          : 'Email nahi mili, check karo'),
      backgroundColor: ok ? Colors.green : Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF97316),
      body: Stack(children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.30,
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
              child: Column(children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.canPop() ? context.pop() : null,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Logo
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.shopping_cart_rounded,
                      size: 38, color: Color(0xFFF97316)),
                ),
                const SizedBox(height: 10),
                RichText(text: const TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: 'Fast', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'Kart', style: TextStyle(color: Color(0xFFFDE68A))),
                  ],
                )),
                const SizedBox(height: 2),
                const Text("India's very own super app",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),

                // Form card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Login / Register toggle
                            Row(children: [
                              _TabBtn(
                                label: 'Login',
                                selected: !_isRegister,
                                onTap: () { if (_isRegister) _toggle(); },
                              ),
                              const SizedBox(width: 12),
                              _TabBtn(
                                label: 'Register',
                                selected: _isRegister,
                                onTap: () { if (!_isRegister) _toggle(); },
                              ),
                            ]),
                            const SizedBox(height: 24),

                            // Name (only register)
                            if (_isRegister) ...[
                              _label('Full Name'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameCtrl,
                                textCapitalization: TextCapitalization.words,
                                decoration: _deco(
                                    hint: 'Rahul Sharma',
                                    icon: Icons.person_outline_rounded),
                                validator: _isRegister
                                    ? (v) => (v == null || v.trim().length < 2)
                                        ? 'Naam daalo (min 2 letters)' : null
                                    : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email
                            _label('Email Address'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s'))
                              ],
                              decoration: _deco(
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email daalo';
                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'Valid email daalo';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _label('Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              decoration: _deco(
                                hint: _isRegister ? 'Min 6 characters' : 'Password',
                                icon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                      color: Colors.grey, size: 20),
                                  onPressed: () =>
                                      setState(() => _obscurePass = !_obscurePass),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password daalo';
                                if (v.length < 6) return 'Min 6 characters chahiye';
                                return null;
                              },
                            ),

                            // Confirm password (only register)
                            if (_isRegister) ...[
                              const SizedBox(height: 16),
                              _label('Confirm Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConf,
                                decoration: _deco(
                                  hint: 'Password dobara likho',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConf
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                        color: Colors.grey, size: 20),
                                    onPressed: () =>
                                        setState(() => _obscureConf = !_obscureConf),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != _passCtrl.text) {
                                    return 'Passwords match nahi kar rahe';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            // Forgot password (only login)
                            if (!_isRegister) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _forgotPassword,
                                  child: const Text('Password bhool gaye?',
                                      style: TextStyle(
                                          color: Color(0xFFF97316), fontSize: 12)),
                                ),
                              ),
                            ] else
                              const SizedBox(height: 24),

                            // Submit button
                            Consumer<AuthProvider>(
                              builder: (_, auth, __) => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFFF97316).withValues(alpha: 0.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(height: 22, width: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2.5))
                                      : Text(
                                          _isRegister ? 'Create Account →' : 'Login →',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800, fontSize: 16)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Center(
                              child: Text(
                                'By continuing you agree to our Terms & Privacy Policy',
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
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444)));

  InputDecoration _deco({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFF97316), width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Colors.redAccent, width: 1.8)),
      );
}

// ── Tab toggle button ─────────────────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF97316) : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: selected ? Colors.white : Colors.grey[600],
              )),
        ),
      );
}
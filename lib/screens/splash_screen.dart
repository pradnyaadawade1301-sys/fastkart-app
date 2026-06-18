// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _badgeCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _titleCtrl;
  late AnimationController _gridCtrl;
  late AnimationController _btnsCtrl;
  late AnimationController _bgCtrl;

  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _gridFade;
  late Animation<Offset> _gridSlide;
  late Animation<double> _btnsFade;
  late Animation<Offset> _btnsSlide;
  late Animation<double> _bgScale;

  final List<_ServiceItem> _services = const [
    _ServiceItem(icon: Icons.restaurant_menu_rounded, label: 'Food'),
    _ServiceItem(icon: Icons.directions_car_rounded, label: 'Rides'),
    _ServiceItem(icon: Icons.hotel_rounded, label: 'Hotels'),
    _ServiceItem(icon: Icons.movie_filter_rounded, label: 'Movies'),
    _ServiceItem(icon: Icons.shopping_bag_rounded, label: 'Shop'),
    _ServiceItem(icon: Icons.medication_rounded, label: 'Pharma'),
    _ServiceItem(icon: Icons.favorite_rounded, label: 'Health'),
    _ServiceItem(icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _bgScale = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _badgeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _badgeFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeOut));
    _badgeSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeOut));

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _titleFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));

    _gridCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _gridFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _gridCtrl, curve: Curves.easeOut));
    _gridSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _gridCtrl, curve: Curves.easeOut));

    _btnsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _btnsFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _btnsCtrl, curve: Curves.easeOut));
    _btnsSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _btnsCtrl, curve: Curves.easeOut));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // ✅ FIX: Pehle animations chalao, phir auto-login check karo
    await Future.delayed(const Duration(milliseconds: 200));
    _badgeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _gridCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _btnsCtrl.forward();

    // ✅ Animations complete hone ke baad check karo
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkAutoLogin();
  }

  // ✅ Auto-login check — already logged in toh seedha home
  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn && mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _gridCtrl.dispose();
    _btnsCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  // ✅ FIX: Navigator.push hata diya, go_router ka context.go use kiya
  void _goToSignIn() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFA8320), Color(0xFFF97316)],
          ),
        ),
        child: Stack(
          children: [
            _buildBgCircle(top: -80, right: -60, size: 260),
            _buildBgCircle(bottom: 100, left: -60, size: 200),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _badgeFade,
                      child: SlideTransition(position: _badgeSlide, child: _buildBadge()),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(scale: _logoScale, child: _buildLogo()),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(position: _titleSlide, child: _buildTitle()),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _gridFade,
                      child: SlideTransition(position: _gridSlide, child: _buildServiceGrid()),
                    ),
                    const Spacer(),
                    FadeTransition(
                      opacity: _btnsFade,
                      child: SlideTransition(position: _btnsSlide, child: _buildButtons()),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _btnsFade,
                      child: const Text(
                        "By continuing, you agree to FastKart's Terms & Privacy Policy",
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBgCircle({double? top, double? bottom, double? left, double? right, required double size}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: AnimatedBuilder(
        animation: _bgScale,
        builder: (_, __) => Transform.scale(
          scale: _bgScale.value,
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFDE68A))),
          const SizedBox(width: 8),
          const Text("INDIA'S #1 SUPER APP",
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88, height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.shopping_cart_rounded, size: 48, color: Color(0xFFF97316)),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            children: [
              TextSpan(text: 'Fast', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Kart', style: TextStyle(color: Color(0xFFFDE68A))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'One App. Infinite Possibilities.\nYour everyday life, simplified.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1,
      ),
      itemCount: _services.length,
      itemBuilder: (_, i) => _ServiceTile(item: _services[i]),
    );
  }

  Widget _buildButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _goToSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFC2500A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: const Text('Sign In to Your Account',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  const _ServiceItem({required this.icon, required this.label});
}

class _ServiceTile extends StatefulWidget {
  final _ServiceItem item;
  const _ServiceTile({required this.item});

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB44600).withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.item.icon, color: Colors.white, size: 26),
              const SizedBox(height: 5),
              Text(widget.item.label,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
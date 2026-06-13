// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.isAuthenticated) {
          return _NotLoggedIn();
        }
        return _LoggedInProfile(auth: auth);
      },
    );
  }
}

// ── NOT LOGGED IN ─────────────────────────────────────────────────────────
class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text('Login',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Login to access your account',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 20),
                _benefit(Icons.local_offer_rounded, 'Exclusive Offers',
                    'Get special deals after login', AppColors.primary),
                const SizedBox(height: 16),
                _benefit(Icons.receipt_long_rounded, 'Order History',
                    'Track your past orders', AppColors.catMovie),
                const SizedBox(height: 16),
                _benefit(Icons.favorite_rounded, 'Save Favourites',
                    'Save your favourite restaurants', AppColors.error),
                const SizedBox(height: 16),
                _benefit(Icons.wallet_rounded, 'FastKart Wallet',
                    'Earn cashback and rewards', AppColors.success),
                const Spacer(),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: const Text('Login / Sign Up',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text('Create new account →',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

// ── LOGGED IN PROFILE ─────────────────────────────────────────────────────
class _LoggedInProfile extends StatelessWidget {
  final AuthProvider auth;
  const _LoggedInProfile({required this.auth});

  @override
  Widget build(BuildContext context) {
    final u = auth.user;
    final initial =
        (u?.name.isNotEmpty ?? false) ? u!.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Row(children: [
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10)
                        ],
                      ),
                      child: Center(
                        child: Text(initial,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u?.name ?? 'User',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text(u?.phone ?? '',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black
                                        .withValues(alpha: 0.55))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('FastKart Member',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.black54),
                      onPressed: () => context.push('/edit-profile'),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          // ── Stats row ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  _stat('💰',
                      u == null ? '₹0' : '₹${u.walletBalance.toStringAsFixed(0)}',
                      'Wallet',
                      () => context.push('/wallet')),
                  const SizedBox(width: 12),
                  _stat('⭐', '${u?.points ?? 0}', 'Points',
                      () => context.push('/points')),
                  const SizedBox(width: 12),
                  _stat('🎁', '3', 'Vouchers',
                      () => context.push('/vouchers')),
                ]),
              ),
            ),
          ),

          // ── Menu sections ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _heading('My Account'),
                _menuGroup([
                  _Entry(Icons.edit_outlined, 'Edit Profile',
                      AppColors.primary,
                      () => context.push('/edit-profile')),
                  _Entry(Icons.location_on_outlined, 'Saved Addresses',
                      AppColors.catRide,
                      () => context.push('/addresses')),
                  _Entry(Icons.payment_outlined, 'Payment Methods',
                      AppColors.catFood,
                      () => context.push('/payment-methods')),
                  _Entry(Icons.receipt_long_outlined, 'My Orders',
                      AppColors.catMovie,
                      () => context.go('/orders')),
                  _Entry(Icons.favorite_outline, 'Favourites',
                      AppColors.error,
                      () => context.push('/favorites')),
                ], context),

                _heading('Preferences'),
                _menuGroup([
                  _Entry(Icons.notifications_outlined, 'Notifications',
                      AppColors.catLeisure,
                      () => context.push('/notifications')),
                  _Entry(Icons.language_outlined, 'Language',
                      AppColors.catBike,
                      () => _showLanguageSheet(context)),
                  _Entry(Icons.dark_mode_outlined, 'Appearance',
                      AppColors.catHotel,
                      () => _showAppearanceSheet(context)),
                ], context),

                _heading('Support'),
                _menuGroup([
                  _Entry(Icons.help_outline_rounded, 'Help & Support',
                      AppColors.catDelivery,
                      () => context.push('/chat?type=support')),
                  _Entry(Icons.info_outline_rounded, 'About FastKart',
                      AppColors.catTravel,
                      () => _showAboutSheet(context)),
                ], context),

                const SizedBox(height: 16),

                // Logout
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Logout?',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        content:
                            Text('${u?.name ?? 'Aap'} will be logged out.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              auth.logout();
                              context.go('/home');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text('Log Out',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ]),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String val, String label, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(val,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final langs = [
      {'name': 'English', 'flag': '🇺🇸', 'selected': true},
      {'name': 'हिंदी', 'flag': '🇮🇳', 'selected': false},
      {'name': 'मराठी', 'flag': '🇮🇳', 'selected': false},
      {'name': 'தமிழ்', 'flag': '🇮🇳', 'selected': false},
      {'name': 'తెలుగు', 'flag': '🇮🇳', 'selected': false},
      {'name': 'বাংলা', 'flag': '🇮🇳', 'selected': false},
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Language',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...langs.map((l) => ListTile(
                    leading: Text(l['flag'] as String,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(l['name'] as String,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: (l['selected'] as bool)
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      final name = l['name'] as String;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Language changed to $name'),
                        backgroundColor: AppColors.success,
                      ));
                    },
                  )),
            ]),
      ),
    );
  }

  // ── APPEARANCE SHEET — theme actually change hoga ──────────────────────
  void _showAppearanceSheet(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    final options = [
      {'icon': Icons.light_mode_rounded,     'label': 'Light Mode',     'mode': ThemeMode.light},
      {'icon': Icons.dark_mode_rounded,       'label': 'Dark Mode',      'mode': ThemeMode.dark},
      {'icon': Icons.brightness_auto_rounded, 'label': 'System Default', 'mode': ThemeMode.system},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Appearance',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                ...options.map((a) {
                  final isSelected =
                      themeProvider.themeMode == a['mode'];
                  return ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(a['icon'] as IconData,
                          color: AppColors.primary),
                    ),
                    title: Text(a['label'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      themeProvider
                          .setThemeMode(a['mode'] as ThemeMode);
                      setModalState(() {}); // checkmark update
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
                child: Text('🛒', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          const Text('FastKart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('Version 1.0.0',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          const Text(
            'India ka apna super app — food, movies, hotels, rides aur bahut kuch!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _aboutBtn('Privacy Policy', () => Navigator.pop(context)),
            _aboutBtn('Terms of Use', () => Navigator.pop(context)),
            _aboutBtn('Rate App', () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 12),
          const Text('Made with ❤️ in India',
              style:
                  TextStyle(color: AppColors.textHint, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _aboutBtn(String label, VoidCallback onTap) => TextButton(
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w600)));

  Widget _heading(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary)),
    );
  }

  Widget _menuGroup(List<_Entry> entries, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          return Column(children: [
            ListTile(
              onTap: entry.onTap,
              leading: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: entry.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(entry.icon, color: entry.color, size: 18),
              ),
              title: Text(entry.label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            ),
            if (i < entries.length - 1)
              const Divider(height: 1, indent: 66),
          ]);
        }).toList(),
      ),
    );
  }
}

class _Entry {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Entry(this.icon, this.label, this.color, this.onTap);
}
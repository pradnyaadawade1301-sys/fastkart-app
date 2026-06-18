// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PageController _bannerCtrl = PageController(viewportFraction: 0.92);
  int _bannerIdx = 0;
  Timer? _autoTimer;
  late AnimationController _greetAnim;
  late Animation<double> _greetFade;

  @override
  void initState() {
    super.initState();
    _greetAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _greetFade = CurvedAnimation(parent: _greetAnim, curve: Curves.easeOut);
    _greetAnim.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<RestaurantProvider>();
      if (!prov.isLoaded) prov.loadData();

      _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final prov = context.read<RestaurantProvider>();
        if (prov.banners.isEmpty) return;
        if (!_bannerCtrl.hasClients) return;
        final next = (_bannerIdx + 1) % prov.banners.length;
        _bannerCtrl.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      });
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _bannerCtrl.dispose();
    _greetAnim.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return Container(
              decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              child: const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Loading FastKart...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: prov.refreshData,
            child: CustomScrollView(
              slivers: [
                // ── APPBAR ─────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 140,
                  backgroundColor: AppColors.primaryDark,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              FadeTransition(
                                opacity: _greetFade,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(_greeting(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  Consumer<AuthProvider>(
                                    builder: (_, a, __) => Text(
                                      a.user?.name.split(' ').first ?? 'Guest',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ]),
                              ),
                              const Spacer(),
                              Consumer<AuthProvider>(
                                builder: (_, a, __) => GestureDetector(
                                  onTap: () => context.push('/wallet'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Row(children: [
                                      const Text('💰', style: TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text('₹${a.user?.walletBalance.toStringAsFixed(0) ?? '0'}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                                    ]),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => context.push('/notifications'),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  Container(width: 34, height: 34,
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                                    child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 18)),
                                  Positioned(top: 1, right: 1,
                                    child: Container(width: 8, height: 8,
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                                ])),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => context.push('/chat?type=support'),
                                child: Container(width: 34, height: 34,
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 18))),
                            ]),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {},
                              child: const Row(children: [
                                Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Mumbai, Bandra West', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                                Spacer(),
                                Text('☀️', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text('36°C', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ]),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => context.push('/search'),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: Row(children: [
                                  const SizedBox(width: 14),
                                  const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(child: Text('Search food, movies, hotels...', style: TextStyle(fontSize: 13, color: AppColors.textHint))),
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]), borderRadius: BorderRadius.circular(16)),
                                    child: const Text('Search', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                  ),
                                ]),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── CATEGORY GRID ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: _CategoryGrid(cats: prov.categories),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(child: _PromoStrip()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── BANNERS ───────────────────────────────────────────
                if (prov.banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _BannerCarousel(banners: prov.banners, controller: _bannerCtrl, current: _bannerIdx, onChanged: (i) => setState(() => _bannerIdx = i)),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── TOP RATED ─────────────────────────────────────────
                SliverToBoxAdapter(child: _SectionHeader(title: 'Top Rated ⭐', onSeeAll: () => context.push('/restaurants'))),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(child: _TopRatedRow(restaurants: prov.topRated())),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── SERVICES ──────────────────────────────────────────
                SliverToBoxAdapter(child: _SectionHeader(title: 'Our Services 🇮🇳', onSeeAll: () {})),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(child: _ServicesGrid()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── OFFERS BANNER ─────────────────────────────────────
                const SliverToBoxAdapter(child: _OffersBanner()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── NEAR YOU ──────────────────────────────────────────
                SliverToBoxAdapter(child: _SectionHeader(title: 'Near You 📍', onSeeAll: () => context.push('/restaurants'))),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RestaurantCard(restaurant: prov.restaurants[i]),
                      childCount: prov.restaurants.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── CATEGORY GRID ──────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> cats;
  const _CategoryGrid({required this.cats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 4,
        mainAxisSpacing: 10,
      ),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        final color = Color(cat.colorValue);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(cat.route),
            borderRadius: BorderRadius.circular(14),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.08)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: Text(cat.icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 5),
              Text(cat.name,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ]),
          ),
        );
      },
    );
  }
}

// ── PROMO STRIP ────────────────────────────────────────────────────────────
class _PromoStrip extends StatelessWidget {
  const _PromoStrip();

  @override
  Widget build(BuildContext context) {
    final promos = [
      {'icon': '🆓', 'text': 'Free Delivery\n₹299+', 'color': 0xFF2E7D32},
      {'icon': '⚡', 'text': '30 Min\nDelivery', 'color': 0xFFFF6F00},
      {'icon': '🔒', 'text': '100% Safe\n& Secure', 'color': 0xFF1565C0},
      {'icon': '💯', 'text': 'Fresh\nGuarantee', 'color': 0xFF6A1B9A},
    ];
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: promos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final p = promos[i];
          final color = Color(p['color'] as int);
          return Container(
            width: 115,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(p['icon'] as String, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(p['text'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, height: 1.3))),
            ]),
          );
        },
      ),
    );
  }
}

// ── BANNER CAROUSEL ────────────────────────────────────────────────────────
class _BannerCarousel extends StatelessWidget {
  final List<BannerModel> banners;
  final PageController controller;
  final int current;
  final ValueChanged<int> onChanged;
  const _BannerCarousel({required this.banners, required this.controller, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 175,
        child: PageView.builder(
          controller: controller,
          itemCount: banners.length,
          onPageChanged: onChanged,
          itemBuilder: (_, i) {
            final b = banners[i];
            return GestureDetector(
              onTap: () => context.push(b.targetRoute),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(b.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(decoration: const BoxDecoration(gradient: AppColors.headerGradient))),
                    Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent], begin: Alignment.bottomLeft, end: Alignment.topRight))),
                    Positioned(top: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                        child: const Text('🔥 HOT DEAL', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    Positioned(bottom: 14, left: 14, right: 14,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black38, blurRadius: 4)])),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                          child: Text(b.subtitle, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      AnimatedSmoothIndicator(
        activeIndex: current,
        count: banners.length,
        effect: const ExpandingDotsEffect(dotWidth: 8, dotHeight: 8, activeDotColor: AppColors.primary, dotColor: AppColors.border, expansionFactor: 3),
      ),
    ]);
  }
}

// ── SERVICES GRID ──────────────────────────────────────────────────────────
// ✅ FIX: Routes app_router.dart ke routes se match karti hain
class _ServicesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'icon': '🎬',
        'title': 'Movies',
        'sub': 'Book tickets instantly',
        'color': 0xFFE91E63,
        'route': '/movies',       // ✅ /category/movies → /movies
        'badge': '',
      },
      {
        'icon': '🏨',
        'title': 'Hotels',
        'sub': '10,000+ hotels',
        'color': 0xFF7C4DFF,
        'route': '/hotels',       // ✅ /category/hotels → /hotels
        'badge': '',
      },
      {
        'icon': '✈️',
        'title': 'Travel',
        'sub': 'Flights & trains',
        'color': 0xFFFF9800,
        'route': '/flights',      // ✅ /category/travel → /flights
        'badge': '',
      },
      {
        'icon': '🚕',
        'title': 'Cab Ride',
        'sub': 'Safe & fast rides',
        'color': 0xFF2196F3,
        'route': '/rides',        // ✅ /category/ride → /rides
        'badge': '',
      },
      {
        'icon': '🛒',
        'title': 'Grocery',
        'sub': '10 min delivery',
        'color': 0xFF009688,
        'route': '/grocery',      // ✅ /category/grocery → /grocery
        'badge': 'NEW',
      },
      {
        'icon': '🎭',
        'title': 'Leisure',
        'sub': 'Spa, events & more',
        'color': 0xFF00BCD4,
        'route': '/leisure',      // ✅ /category/leisure → /leisure
        'badge': '',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.0, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: services.length,
        itemBuilder: (_, i) {
          final s = services[i];
          final color = Color(s['color'] as int);
          final badge = (s['badge'] ?? '') as String;
          return Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => context.push(s['route'] as String),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Stack(children: [
                  Positioned(bottom: -10, right: -10,
                    child: Container(width: 60, height: 60, decoration: BoxDecoration(color: color.withValues(alpha: 0.08), shape: BoxShape.circle))),
                  Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(16)),
                        child: Center(child: Text(s['icon'] as String, style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(height: 8),
                      Text(s['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(s['sub'] as String, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  if (badge.isNotEmpty)
                    Positioned(top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                      )),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── OFFERS BANNER ─────────────────────────────────────────────────────────
class _OffersBanner extends StatelessWidget {
  const _OffersBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF283593)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
            child: const Text('🎉 SPECIAL OFFER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
          ),
          const SizedBox(height: 10),
          const Text('FastKart Plus', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Free delivery + exclusive deals\nAll for just ₹99 per month!', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
            child: const Text('Subscribe Now →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black)),
          ),
        ])),
        const SizedBox(width: 10),
        const Text('⚡', style: TextStyle(fontSize: 64)),
      ]),
    );
  }
}

// ── SECTION HEADER ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        GestureDetector(
          onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]), borderRadius: BorderRadius.circular(14)),
            child: const Text('See All', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

// ── TOP RATED ROW ──────────────────────────────────────────────────────────
class _TopRatedRow extends StatelessWidget {
  final List<Restaurant> restaurants;
  const _TopRatedRow({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: restaurants.length,
        itemBuilder: (_, i) {
          final r = restaurants[i];
          return GestureDetector(
            onTap: () => context.push('/restaurant/${r.id}'),
            child: Container(
              width: 148,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(children: [
                    Image.network(r.imageUrl, height: 105, width: 148, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 105, color: AppColors.divider, child: const Icon(Icons.restaurant, color: AppColors.textHint))),
                    Positioned(top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.star_rounded, size: 10, color: Colors.white),
                          Text(' ${r.rating}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSecondary),
                      Text(' ${r.deliveryTime}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const Spacer(),
                      Text(r.deliveryFee == 0 ? 'FREE' : '₹${r.deliveryFee.toInt()}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: r.deliveryFee == 0 ? AppColors.success : AppColors.textSecondary)),
                    ]),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── RESTAURANT CARD ────────────────────────────────────────────────────────
class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: () => context.push('/restaurant/${r.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(r.imageUrl, height: 170, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 170, color: AppColors.divider, child: const Icon(Icons.restaurant, size: 48, color: AppColors.textHint))),
            ),
            Positioned.fill(child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            )),
            Positioned(top: 10, left: 10, child: Wrap(spacing: 6, children: r.tags.take(2).map(_tag).toList())),
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: () => context.read<RestaurantProvider>().toggleFavorite(r.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)]),
                  child: Icon(r.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18, color: r.isFavorite ? Colors.red : AppColors.textSecondary),
                ),
              ),
            ),
            if (!r.isOpen)
              Positioned.fill(child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(color: Colors.black.withValues(alpha: 0.6),
                    child: const Center(child: Text('CLOSED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 4)))),
              )),
            Positioned(bottom: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                  Text(' ${r.rating.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(r.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (r.isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('● Open', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700)),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(r.categories.join(' · '), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8F5F0), borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _infoChip(Icons.access_time_rounded, r.deliveryTime, AppColors.textSecondary),
                  Container(width: 1, height: 22, color: AppColors.divider),
                  _infoChip(Icons.delivery_dining_rounded, r.deliveryFee == 0 ? 'Free' : '₹${r.deliveryFee.toInt()}', r.deliveryFee == 0 ? AppColors.success : AppColors.textSecondary),
                  Container(width: 1, height: 22, color: AppColors.divider),
                  _infoChip(Icons.location_on_rounded, r.distance, AppColors.textSecondary),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tag(String tag) {
    Color bg = AppColors.primary;
    if (tag == 'Free Delivery') bg = AppColors.success;
    if (tag == 'Popular') bg = AppColors.accent;
    if (tag == 'Top Rated') bg = Colors.purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
    ]);
  }
}
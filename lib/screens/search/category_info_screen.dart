// lib/screens/category/category_info_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class CategoryInfoScreen extends StatelessWidget {
  final String categoryId;
  const CategoryInfoScreen({super.key, required this.categoryId});

  static const Map<String, _CatInfo> _info = {
    'food': _CatInfo(
      icon: '🍛', color: AppColors.catFood,
      title: 'Food Delivery',
      subtitle: 'Order from home, eat like a king!',
      description: 'Order fresh, hot food from your favourite restaurants. From Biryani to Pizza, everything delivered to your doorstep in 30 minutes.',
      features: ['500+ restaurants available', 'Live order tracking', '30 min average delivery', 'No minimum order on select restaurants', 'Scheduled delivery available'],
      offers: ['50% OFF on first order', 'Free delivery above ₹299', 'Weekend special deals'],
      actionRoute: '/restaurants',
      actionLabel: 'Order Food Now',
    ),
    'movies': _CatInfo(
      icon: '🎬', color: AppColors.catMovie,
      title: 'Movie Tickets',
      subtitle: 'Book blockbusters in seconds!',
      description: 'Book tickets for the latest movies at cinemas near you. Choose the best seats and add snack combos easily.',
      features: ['100+ cinemas across India', 'Seat selection available', 'M-ticket (no printout needed)', 'Snack combos pre-order', 'Group booking discounts'],
      offers: ['₹99 tickets every Tuesday', 'Couple combo offer', '10% cashback on first booking'],
      actionRoute: '/movies',
      actionLabel: 'Book Movie Tickets',
    ),
    'hotels': _CatInfo(
      icon: '🏨', color: AppColors.catHotel,
      title: 'Hotel Booking',
      subtitle: 'Rest easy, book smart!',
      description: 'Book hotels from budget to luxury. Verified photos, real reviews and best price guarantee on every stay.',
      features: ['10,000+ hotels pan India', 'Instant confirmation', 'Free cancellation option', 'Breakfast included deals', '24/7 customer support'],
      offers: ['Early bird — 25% off', 'Weekend getaway deals', 'Couple special packages'],
      actionRoute: '/hotels',
      actionLabel: 'Book a Hotel',
    ),
    'leisure': _CatInfo(
      icon: '🎭', color: AppColors.catLeisure,
      title: 'Leisure & Entertainment',
      subtitle: 'Fun and experiences every day!',
      description: 'Spa, salon, amusement parks, comedy shows and much more. Life is better with a little fun!',
      features: ['Spa & salon bookings', 'Event & concert tickets', 'Amusement park passes', 'Adventure activities', 'Group & family packages'],
      offers: ['30% off on spa', 'Kids free on weekends', 'Buy 2 get 1 free on events'],
      // ✅ FIXED: now goes to the proper leisure booking screen
      actionRoute: '/leisure',
      actionLabel: 'Explore Leisure',
    ),
    'delivery': _CatInfo(
      icon: '🛵', color: AppColors.catDelivery,
      title: 'Express Delivery',
      subtitle: 'Whatever you need, whenever you need it!',
      description: 'Grocery, medicine, documents — send or receive anything. Hyperlocal express delivery in 60 minutes.',
      features: ['Delivery in 60 minutes', 'Real-time tracking', 'Safe & insured delivery', 'Documents & parcels', 'Same-day service'],
      offers: ['First delivery free', 'Subscribe & save 20%', 'Bulk order discounts'],
      actionRoute: '/grocery',
      actionLabel: 'Order Now',
    ),
    'ride': _CatInfo(
      icon: '🚕', color: AppColors.catRide,
      title: 'Cab & Ride',
      subtitle: 'Safe, fast and affordable rides!',
      description: 'AC cabs, autos and outstation trips — all in one place. Verified drivers, transparent pricing, no surge.',
      features: ['AC & non-AC options', 'Outstation & airport rides', 'Women safety features', 'Live driver tracking', 'In-app SOS button'],
      offers: ['₹50 off on first ride', 'Airport flat fare', 'Monthly pass available'],
      actionRoute: '/rides',
      actionLabel: 'Book a Ride',
    ),
    'bike': _CatInfo(
      icon: '🚲', color: AppColors.catBike,
      title: 'Bike Taxi',
      subtitle: 'Beat traffic, ride fast!',
      description: 'The fastest option for short distances. Reach on time even in traffic — easy on your wallet too.',
      features: ['Fastest for short trips', 'Helmet provided', '40% cheaper than cab', 'GPS tracked rides', 'Available 24/7'],
      offers: ['First 3 rides free', 'Student discount 20%', 'Office commute pack'],
      actionRoute: '/rides',
      actionLabel: 'Book Bike Taxi',
    ),
    'travel': _CatInfo(
      icon: '✈️', color: AppColors.catTravel,
      title: 'Travel Booking',
      subtitle: 'Travel the way you love!',
      description: 'Flights, trains, buses and holiday packages — all in one app. Best prices guaranteed with instant booking confirmation.',
      features: ['Flights across 500+ routes', 'Train & bus tickets', 'Holiday packages', 'Visa assistance', 'Travel insurance'],
      offers: ['Flight cashback ₹500', 'Holiday EMI available', 'Group travel discounts'],
      actionRoute: '/flights',
      actionLabel: 'Book Travel',
    ),
    'grocery': _CatInfo(
      icon: '🛒', color: AppColors.catGrocery,
      title: 'Grocery & Essentials',
      subtitle: 'Daily needs delivered to your door!',
      description: 'Fresh vegetables, dairy, snacks and daily essentials — everything delivered to your home in 10 minutes.',
      features: ['Delivery in 10 minutes', 'Fresh & quality checked', '5000+ products available', 'Weekly subscription option', 'Free delivery above ₹199'],
      offers: ['10% off on vegetables', 'Buy 2 get 1 on snacks', 'Daily dairy deals'],
      actionRoute: '/grocery',
      actionLabel: 'Shop Grocery',
    ),
    'more': _CatInfo(
      icon: '⋯', color: AppColors.catMore,
      title: 'And Much More!',
      subtitle: 'Explore everything FastKart has to offer',
      description: 'Medicine delivery, pet care, home services, laundry and a lot more. FastKart is your complete lifestyle super-app.',
      features: ['Medicine & healthcare', 'Home services (plumber, electrician)', 'Laundry & dry cleaning', 'Pet care services', 'Bill payments & recharge'],
      offers: ['New service launch offers', 'Refer & earn ₹200', 'FastKart Plus membership'],
      actionRoute: '/home',
      actionLabel: 'Explore All',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cat = _info[categoryId] ?? const _CatInfo(
      icon: '⚡', color: AppColors.primary,
      title: 'FastKart Service', subtitle: 'Coming soon!',
      description: 'This service is launching soon. Stay tuned!',
      features: [], offers: [],
      actionRoute: '/home',
      actionLabel: 'Go Home',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: cat.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cat.color, cat.color.withValues(alpha: 0.75)],
                  ),
                ),
                child: Stack(children: [
                  Positioned(
                    top: -30, right: -30,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20, left: -20,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(cat.icon,
                            style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 10),
                        Text(cat.title,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(cat.subtitle,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white
                                    .withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Description ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(cat.description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6)),
                  ),
                  const SizedBox(height: 20),

                  // ── Leisure sub-category shortcuts ────────────────────
                  if (categoryId == 'leisure') ...[
                    const Text('✨  Browse by Category',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _LeisureShortcuts(color: cat.color),
                    const SizedBox(height: 20),
                  ],

                  // ── What You Get ───────────────────────────────────────
                  const Text('✅  What You Get',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: cat.features
                          .asMap()
                          .entries
                          .map((e) => Column(children: [
                                ListTile(
                                  leading: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: cat.color
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check_rounded,
                                        color: cat.color, size: 16),
                                  ),
                                  title: Text(e.value,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2),
                                ),
                                if (e.key < cat.features.length - 1)
                                  const Divider(height: 1, indent: 64),
                              ]))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Current Offers ─────────────────────────────────────
                  const Text('🎁  Current Offers',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...cat.offers.map((offer) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            cat.color.withValues(alpha: 0.12),
                            cat.color.withValues(alpha: 0.04),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: cat.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Icon(Icons.local_offer_rounded,
                              color: cat.color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(offer,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: cat.color
                                          .withValues(alpha: 0.9)))),
                        ]),
                      )),
                  const SizedBox(height: 24),

                  // ── Action Button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.push(cat.actionRoute),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cat.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(cat.actionLabel,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── LEISURE SHORTCUTS ──────────────────────────────────────────────────────
class _LeisureShortcuts extends StatelessWidget {
  final Color color;
  const _LeisureShortcuts({required this.color});

  static const _items = [
    {'icon': '🧖', 'label': 'Spa & Salon', 'tab': '0'},
    {'icon': '🎤', 'label': 'Events',      'tab': '1'},
    {'icon': '🎡', 'label': 'Amusement',   'tab': '2'},
    {'icon': '🧗', 'label': 'Adventure',   'tab': '3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _items.map((item) {
        return GestureDetector(
          // ✅ Opens LeisureScreen at the correct tab via query param
          onTap: () => context.push('/leisure?tab=${item['tab']}'),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.06),
                ]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Center(
                  child: Text(item['icon']!,
                      style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 6),
            Text(item['label']!,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ]),
        );
      }).toList(),
    );
  }
}

// ── DATA CLASS ─────────────────────────────────────────────────────────────
class _CatInfo {
  final String icon;
  final Color color;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final List<String> offers;
  final String actionRoute;
  final String actionLabel;

  const _CatInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.offers,
    required this.actionRoute,
    required this.actionLabel,
  });
}
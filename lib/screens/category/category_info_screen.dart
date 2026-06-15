// lib/screens/category/category_info_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class CategoryInfoScreen extends StatefulWidget {
  final String category;
  const CategoryInfoScreen({super.key, required this.category});

  @override
  State<CategoryInfoScreen> createState() => _CategoryInfoScreenState();
}

class _CategoryInfoScreenState extends State<CategoryInfoScreen> {
  String _selectedTab = 'All';

  // ─── Route map ────────────────────────────────────────────────────────────
  static const _routes = {
    'Package Delivery':   '',
    'Flower Delivery':    '',
    'Cake Delivery':      '',
    'Medicine Delivery':  '/medicine',
    'Shopping Delivery':  '/category/grocery',
    'Spa & Wellness':     '/category/leisure',
    'Art & Workshops':    '/category/leisure',
    'Activities':         '/category/leisure',
    'Yoga & Fitness':     '/category/leisure',
    'Live Events':        '/category/leisure',
    'Swimming':           '/category/leisure',
    'Train Booking':      '/trains',
    'Bus Booking':        '',
    'Event Tickets':      '/movies',
    'Healthcare':         '/medicine',
    'Education':          '',
    'Home Services':      '',
    // Health
    'Doctor Consultation': '/medicine',
    'Lab Tests at Home':   '/medicine',
    'Mental Wellness':     '/medicine',
    'Pharmacy':            '/medicine',
    'Dentist':             '',
    'Eye Care':            '',
    // Travel
    'Train Booking (IRCTC)': '/trains',
    'Flight Booking':        '',
    'Hotel Booking':         '',
    'Cab Rental':            '',
    'Tour Packages':         '',
    // Education
    'Online Courses':      '',
    'Home Tutoring':       '',
    'Skill Workshops':     '',
    'Test Prep':           '',
    'Language Classes':    '',
    'Kids Learning':       '',
  };

  @override
  Widget build(BuildContext context) {
    final config = _configs[widget.category.toLowerCase()] ?? _configs['more']!;
    final color = Color(config['color'] as int);

    // Tabs for this category
    final List<String> tabs = List<String>.from(config['tabs'] as List);

    // Filter services by selected tab
    final allServices = (config['services'] as List)
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
    final filteredServices = _selectedTab == 'All'
        ? allServices
        : allServices.where((s) => s['tab'] == _selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(slivers: [
        // ── App Bar ──────────────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: color,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, Color(config['color2'] as int)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // FIX: was 50
                  Text(config['emoji'] as String,
                      style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 6),
                  Text(config['title'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900)),
                  Text(config['subtitle'] as String,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4), // FIX: was 14
                  // ── Tabs inside app bar ───────────────────────────────────
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final tab = tabs[i];
                        final selected = _selectedTab == tab;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white38),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: selected ? color : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Stats row ─────────────────────────────────────────────────
              Row(
                children: (config['stats'] as List)
                    .map((e) => Map<String, String>.from(e as Map))
                    .map((s) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8)
                              ],
                            ),
                            child: Column(children: [
                              Text(s['value']!,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: color)),
                              const SizedBox(height: 2),
                              Text(s['label']!,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary),
                                  textAlign: TextAlign.center),
                            ]),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // ── Promo banner ──────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.85),
                               Color(config['color2'] as int)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(config['cta_emoji'] as String,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(config['promo_title'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                          Text(config['promo_sub'] as String,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('Grab',
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),

              // ── Tab chips ─────────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.map((tab) {
                    final selected = _selectedTab == tab;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selected ? color : Colors.grey.shade300),
                          boxShadow: selected
                              ? [BoxShadow(
                                  color: color.withValues(alpha: 0.25),
                                  blurRadius: 8, offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // ── Section heading ───────────────────────────────────────────
              Text(
                _selectedTab == 'All'
                    ? 'All Services'
                    : '$_selectedTab Services',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color),
              ),
              const SizedBox(height: 10),

              // ── Service cards ─────────────────────────────────────────────
              ...filteredServices.map((s) {
                final route = _routes[s['title']] ?? '';
                final hasRoute = route.isNotEmpty;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Text(s['icon']!,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        title: Row(children: [
                          Expanded(
                            child: Text(s['title']!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ),
                          if (s['badge'] != null && s['badge']!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: s['badge'] == '24/7'
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(s['badge']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                            ),
                        ]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on,
                                  size: 11, color: AppColors.textSecondary),
                              const SizedBox(width: 2),
                              Text(s['sub']!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ]),
                            if (s['rating'] != null &&
                                s['rating']!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.star,
                                    size: 11, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(s['rating']!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                              ]),
                            ],
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () => _onServiceTap(context, s, route, hasRoute, color),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 7),
                            decoration: BoxDecoration(
                              color: hasRoute ? color : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hasRoute ? 'Open' : 'Soon',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        onTap: () => _onServiceTap(
                            context, s, route, hasRoute, color),
                      ),
                      // Price + features row
                      if (s['price'] != null && s['price']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 14, right: 14, bottom: 12),
                          child: Row(children: [
                            Text(s['price']!,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: color)),
                            if (s['mrp'] != null && s['mrp']!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(s['mrp']!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      decoration:
                                          TextDecoration.lineThrough)),
                            ],
                            const SizedBox(width: 10),
                            if (s['tags'] != null && s['tags']!.isNotEmpty)
                              Expanded(
                                child: Text(s['tags']!,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w600)),
                              ),
                          ]),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ── CTA bottom banner ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color, Color(config['color2'] as int)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config['cta_title'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(config['cta_sub'] as String,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => context.push(
                            widget.category.toLowerCase() == 'leisure'
                                ? '/category/leisure'
                                : widget.category.toLowerCase() == 'delivery'
                                    ? '/category/grocery'
                                    : '/more',
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('Explore',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                    fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(config['cta_emoji'] as String,
                      style: const TextStyle(fontSize: 52)),
                ]),
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ]),
    );
  }

  void _onServiceTap(BuildContext context, Map<String, String> s,
      String route, bool hasRoute, Color color) {
    if (hasRoute) {
      context.push(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${s['title']} coming soon!'),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  // ─── Config data ──────────────────────────────────────────────────────────
  static final Map<String, Map<String, dynamic>> _configs = {
    'delivery': {
      'emoji': '🛵',
      'title': 'Delivery',
      'subtitle': 'Fast & reliable delivery services',
      'color': 0xFF4CAF50,
      'color2': 0xFF388E3C,
      'tabs': ['All', 'Food', 'Pharmacy', 'Shopping'],
      'promo_title': 'Free delivery on first 3 orders!',
      'promo_sub': 'Use code: FASTFIRST',
      'stats': [
        {'value': '10 min', 'label': 'Avg Delivery'},
        {'value': '500+', 'label': 'Partners'},
        {'value': '4.8⭐', 'label': 'Rating'},
      ],
      'services': [
        {'icon': '📦', 'title': 'Package Delivery', 'sub': 'Send packages across the city', 'tab': 'Shopping', 'badge': '', 'rating': '4.7 (12k)', 'price': '₹49', 'mrp': '₹99', 'tags': 'Express available'},
        {'icon': '🌸', 'title': 'Flower Delivery', 'sub': 'Fresh flowers in 30 min', 'tab': 'Shopping', 'badge': '', 'rating': '4.8 (8k)', 'price': '₹199', 'mrp': '₹299', 'tags': 'Same day delivery'},
        {'icon': '🎂', 'title': 'Cake Delivery', 'sub': 'Custom cakes for all occasions', 'tab': 'Food', 'badge': '', 'rating': '4.9 (5k)', 'price': '₹349', 'mrp': '₹499', 'tags': 'Custom messages free'},
        {'icon': '💊', 'title': 'Medicine Delivery', 'sub': 'Prescription medicines delivered', 'tab': 'Pharmacy', 'badge': '24/7', 'rating': '4.8 (20k)', 'price': '₹0', 'mrp': '', 'tags': 'Free delivery · Upload Rx'},
        {'icon': '🛍️', 'title': 'Shopping Delivery', 'sub': 'Anything from nearby stores', 'tab': 'Shopping', 'badge': '', 'rating': '4.6 (9k)', 'price': '₹29', 'mrp': '₹59', 'tags': 'Track in real-time'},
      ],
      'cta_title': 'Send a package now!',
      'cta_sub': 'Same-day delivery available',
      'cta_emoji': '🚀',
    },

    'leisure': {
      'emoji': '🎭',
      'title': 'Leisure',
      'subtitle': 'Relax, unwind & experience more',
      'color': 0xFF00BCD4,
      'color2': 0xFF0097A7,
      'tabs': ['All', 'Wellness', 'Sports', 'Events'],
      'promo_title': 'Up to 40% off wellness packages!',
      'promo_sub': 'Use code: RELAX40',
      'stats': [
        {'value': '200+', 'label': 'Experiences'},
        {'value': '50+', 'label': 'Spas & Salons'},
        {'value': '4.9⭐', 'label': 'Rating'},
      ],
      'services': [
        {'icon': '💆', 'title': 'Spa & Wellness', 'sub': 'Book spa & massage sessions', 'tab': 'Wellness', 'badge': '', 'rating': '4.9 (15k)', 'price': '₹799', 'mrp': '₹1299', 'tags': '60 min session · At home'},
        {'icon': '🎨', 'title': 'Art & Workshops', 'sub': 'Creative classes for all ages', 'tab': 'Events', 'badge': '', 'rating': '4.8 (3k)', 'price': '₹499', 'mrp': '₹799', 'tags': 'Weekends · Materials included'},
        {'icon': '🎳', 'title': 'Activities', 'sub': 'Bowling, gaming, laser tag & more', 'tab': 'Sports', 'badge': '', 'rating': '4.7 (10k)', 'price': '₹299', 'mrp': '₹499', 'tags': 'Group bookings available'},
        {'icon': '🌿', 'title': 'Yoga & Fitness', 'sub': 'Top-rated instructors near you', 'tab': 'Wellness', 'badge': '', 'rating': '4.9 (18k)', 'price': '₹199', 'mrp': '₹399', 'tags': 'Online & offline · Flexible timing'},
        {'icon': '🎸', 'title': 'Live Events', 'sub': 'Concerts, comedy, open mics', 'tab': 'Events', 'badge': '', 'rating': '4.8 (7k)', 'price': '₹399', 'mrp': '₹699', 'tags': 'Exclusive early bird pricing'},
        {'icon': '🏊', 'title': 'Swimming', 'sub': 'Pool access & swimming lessons', 'tab': 'Sports', 'badge': '', 'rating': '4.7 (6k)', 'price': '₹249', 'mrp': '₹399', 'tags': 'All levels · Kids batches too'},
      ],
      'cta_title': 'Treat yourself today!',
      'cta_sub': 'New experiences added weekly',
      'cta_emoji': '✨',
    },

    'more': {
      'emoji': '🌟',
      'title': 'More Services',
      'subtitle': 'Everything else you need',
      'color': 0xFF546E7A,
      'color2': 0xFF37474F,
      'tabs': ['All', 'Health', 'Travel', 'Education'],
      'promo_title': 'Explore new services!',
      'promo_sub': 'Use code: EXPLORE',
      'stats': [
        {'value': '20+', 'label': 'Services'},
        {'value': '1M+', 'label': 'Users'},
        {'value': '4.7⭐', 'label': 'Rating'},
      ],
      'services': [
        {
          'icon': '👨‍⚕️', 'title': 'Doctor Consultation',
          'sub': '200+ specialist doctors',
          'tab': 'Health', 'badge': '24/7',
          'rating': '4.9 (18k)',
          'price': '₹299', 'mrp': '₹499',
          'tags': 'Video · Chat · In-clinic visits',
        },
        {
          'icon': '🧪', 'title': 'Lab Tests at Home',
          'sub': 'Home sample pickup',
          'tab': 'Health', 'badge': 'Home Visit',
          'rating': '4.7 (9k)',
          'price': '₹199', 'mrp': '₹350',
          'tags': 'Reports in 24 hrs · 300+ tests',
        },
        {
          'icon': '🧠', 'title': 'Mental Wellness',
          'sub': 'Certified therapists & counselors',
          'tab': 'Health', 'badge': '',
          'rating': '4.8 (6k)',
          'price': '₹499', 'mrp': '₹799',
          'tags': 'Private & confidential sessions',
        },
        {
          'icon': '💊', 'title': 'Pharmacy',
          'sub': 'Medicines delivered to door',
          'tab': 'Health', 'badge': '24/7',
          'rating': '4.8 (25k)',
          'price': '₹0', 'mrp': '',
          'tags': 'Free delivery · Upload prescription',
        },
        {
          'icon': '🦷', 'title': 'Dentist',
          'sub': 'Book dental appointments nearby',
          'tab': 'Health', 'badge': '',
          'rating': '4.6 (4k)',
          'price': '₹399', 'mrp': '₹599',
          'tags': 'Cleaning · Braces · Root canal',
        },
        {
          'icon': '👁️', 'title': 'Eye Care',
          'sub': 'Eye check-up & glasses at home',
          'tab': 'Health', 'badge': '',
          'rating': '4.7 (3k)',
          'price': '₹199', 'mrp': '₹349',
          'tags': 'Free eye test with frames purchase',
        },
        {
          'icon': '🚂', 'title': 'Train Booking (IRCTC)',
          'sub': 'IRCTC trains across India',
          'tab': 'Travel', 'badge': '',
          'rating': '4.8 (30k)',
          'price': '₹0', 'mrp': '',
          'tags': 'No booking fee · PNR tracking',
        },
        {
          'icon': '🚌', 'title': 'Bus Booking',
          'sub': 'Intercity & state buses',
          'tab': 'Travel', 'badge': '',
          'rating': '4.6 (12k)',
          'price': '₹149', 'mrp': '₹249',
          'tags': 'AC & Sleeper · Live tracking',
        },
        {
          'icon': '✈️', 'title': 'Flight Booking',
          'sub': 'Domestic & international flights',
          'tab': 'Travel', 'badge': '',
          'rating': '4.7 (20k)',
          'price': '₹2499', 'mrp': '₹3999',
          'tags': 'Lowest fares · Free cancellation',
        },
        {
          'icon': '🏨', 'title': 'Hotel Booking',
          'sub': '10,000+ hotels across India',
          'tab': 'Travel', 'badge': '',
          'rating': '4.7 (15k)',
          'price': '₹799', 'mrp': '₹1499',
          'tags': 'Free cancellation · Breakfast deals',
        },
        {
          'icon': '🚗', 'title': 'Cab Rental',
          'sub': 'Outstation & local cabs',
          'tab': 'Travel', 'badge': '',
          'rating': '4.6 (8k)',
          'price': '₹999', 'mrp': '₹1499',
          'tags': 'AC cars · Verified drivers',
        },
        {
          'icon': '🌴', 'title': 'Tour Packages',
          'sub': 'Curated holiday packages',
          'tab': 'Travel', 'badge': '',
          'rating': '4.8 (5k)',
          'price': '₹4999', 'mrp': '₹7999',
          'tags': 'Hotels + Flights + Sightseeing',
        },
        {
          'icon': '💻', 'title': 'Online Courses',
          'sub': 'Learn from top instructors',
          'tab': 'Education', 'badge': '',
          'rating': '4.8 (22k)',
          'price': '₹499', 'mrp': '₹1999',
          'tags': 'Certification · Self-paced learning',
        },
        {
          'icon': '📚', 'title': 'Home Tutoring',
          'sub': 'Expert tutors at your home',
          'tab': 'Education', 'badge': '',
          'rating': '4.9 (11k)',
          'price': '₹299', 'mrp': '₹499',
          'tags': 'Class 1–12 · All subjects',
        },
        {
          'icon': '🎓', 'title': 'Skill Workshops',
          'sub': 'Weekend hands-on workshops',
          'tab': 'Education', 'badge': '',
          'rating': '4.7 (4k)',
          'price': '₹599', 'mrp': '₹999',
          'tags': 'Coding · Design · Finance',
        },
        {
          'icon': '📝', 'title': 'Test Prep',
          'sub': 'JEE · NEET · UPSC · CAT',
          'tab': 'Education', 'badge': '',
          'rating': '4.8 (9k)',
          'price': '₹799', 'mrp': '₹1499',
          'tags': 'Mock tests · Expert guidance',
        },
        {
          'icon': '🗣️', 'title': 'Language Classes',
          'sub': 'English, French, Spanish & more',
          'tab': 'Education', 'badge': '',
          'rating': '4.7 (6k)',
          'price': '₹399', 'mrp': '₹699',
          'tags': 'Live classes · Conversation practice',
        },
        {
          'icon': '🧒', 'title': 'Kids Learning',
          'sub': 'Fun learning for ages 4–12',
          'tab': 'Education', 'badge': '',
          'rating': '4.9 (8k)',
          'price': '₹249', 'mrp': '₹449',
          'tags': 'Coding · Art · Math · Science',
        },
      ],
      'cta_title': 'Discover new services!',
      'cta_sub': 'New services added every week',
      'cta_emoji': '🎯',
    },
  };
}

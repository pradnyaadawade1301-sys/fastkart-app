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
  int _cartCount = 0;
  final List<_CartEntry> _cartItems = [];

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

  // ---------------- Add to cart ----------------
  void _addToCart(Map<String, String> s, Color color) {
    final title = s['title'] ?? '';
    setState(() {
      _cartCount++;
      final idx = _cartItems.indexWhere((e) => e.title == title);
      if (idx >= 0) {
        _cartItems[idx].qty++;
      } else {
        _cartItems.add(_CartEntry(
          title: title,
          icon: s['icon'] ?? '🛒',
          price: s['price'] ?? '',
          color: color,
        ));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s['title']} added to cart'),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _parsePrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  void _incrementCartItem(_CartEntry entry, void Function(void Function()) setSheetState) {
    setState(() => entry.qty++);
    setSheetState(() {});
  }

  void _decrementCartItem(_CartEntry entry, void Function(void Function()) setSheetState) {
    setState(() {
      entry.qty--;
      if (entry.qty <= 0) _cartItems.remove(entry);
      _cartCount = _cartItems.fold(0, (sum, e) => sum + e.qty);
    });
    setSheetState(() {});
  }

  // ---------------- Cart sheet (shows added items) ----------------
  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final total = _cartItems.fold<int>(
                0, (sum, e) => sum + _parsePrice(e.price) * e.qty);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text('Your Cart',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  if (_cartItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            const Text('Your cart is empty',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height * 0.45),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 6),
                        itemCount: _cartItems.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = _cartItems[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color:
                                        item.color.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(11),
                                  ),
                                  child: Center(
                                    child: Text(item.icon,
                                        style:
                                            const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text(
                                          item.price.isEmpty ||
                                                  item.price == '₹0'
                                              ? 'Free'
                                              : item.price,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: item.color,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _decrementCartItem(
                                          item, setSheetState),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.remove,
                                            size: 14),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 28,
                                      child: Text('${item.qty}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ),
                                    GestureDetector(
                                      onTap: () => _incrementCartItem(
                                          item, setSheetState),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: item.color,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.add,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (_cartItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('₹$total',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proceeding to checkout...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- Booking form (collects user details) ----------------
  void _showBookingForm(Map<String, String> s, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _BookingDetailsForm(
        serviceTitle: s['title'] ?? '',
        serviceIcon: s['icon'] ?? '⭐',
        servicePrice: s['price'] ?? '',
        color: color,
        onSubmit: (name, phone, address, paymentMethod, paymentDetail) {
          Navigator.pop(sheetContext);
          _showBookingSuccess(s, color, name, paymentMethod, paymentDetail);
        },
      ),
    );
  }

  void _showBookingSuccess(Map<String, String> s, Color color, String name,
      String paymentMethod, String paymentDetail) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: color),
            const SizedBox(width: 8),
            const Text('Booked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Confirmed for $name',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Paid via $paymentMethod${paymentDetail.isNotEmpty ? ' · $paymentDetail' : ''}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            if ((s['price'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Amount: ${s['price']}',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, color: color)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

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
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  onPressed: _showCartSheet,
                ),
                if (_cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_cartCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
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
              // NOTE: rebuilt without ListTile (its fixed intrinsic-height
              // layout was causing the "BOTTOM OVERFLOWED BY 1 PIXEL" warning
              // once the trailing cart+Book buttons were added). A plain
              // Row/Column layout inside InkWell gives full control over
              // sizing and removes the overflow.
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
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _onServiceTap(context, s, route, hasRoute, color),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(14, 12, 14, 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(
                                    child: Text(s['icon']!,
                                        style:
                                            const TextStyle(fontSize: 22)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                          child: Text(s['title']!,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w800)),
                                        ),
                                        if (s['badge'] != null &&
                                            s['badge']!.isNotEmpty)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: s['badge'] == '24/7'
                                                  ? Colors.green
                                                  : Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(s['badge']!,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                      ]),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        const Icon(Icons.location_on,
                                            size: 11,
                                            color: AppColors.textSecondary),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(s['sub']!,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .textSecondary)),
                                        ),
                                      ]),
                                      if (s['rating'] != null &&
                                          s['rating']!.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Row(children: [
                                          const Icon(Icons.star,
                                              size: 11,
                                              color: Colors.amber),
                                          const SizedBox(width: 2),
                                          Text(s['rating']!,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors.black87)),
                                        ]),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // ── Cart + Book buttons side-by-side ──
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _addToCart(s, color),
                                      child: Container(
                                        width: 30,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: color, width: 1.2),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Center(
                                          child: Icon(
                                              Icons
                                                  .add_shopping_cart_rounded,
                                              size: 14,
                                              color: color),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () =>
                                          _showBookingForm(s, color),
                                      child: Container(
                                        height: 28,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Book',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                if (s['mrp'] != null &&
                                    s['mrp']!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(s['mrp']!,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          decoration: TextDecoration
                                              .lineThrough)),
                                ],
                                const SizedBox(width: 10),
                                if (s['tags'] != null &&
                                    s['tags']!.isNotEmpty)
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
                    ),
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

// ====================================================================
// Cart entry - holds a single added service + quantity
// ====================================================================
class _CartEntry {
  final String title;
  final String icon;
  final String price;
  final Color color;
  int qty;

  _CartEntry({
    required this.title,
    required this.icon,
    required this.price,
    required this.color,
  }) : qty = 1;
}

// ====================================================================
// Booking details form - shown when user taps "Book"
// ====================================================================
class _BookingDetailsForm extends StatefulWidget {
  final String serviceTitle;
  final String serviceIcon;
  final String servicePrice;
  final Color color;
  final void Function(String name, String phone, String address,
      String paymentMethod, String paymentDetail) onSubmit;

  const _BookingDetailsForm({
    required this.serviceTitle,
    required this.serviceIcon,
    required this.servicePrice,
    required this.color,
    required this.onSubmit,
  });

  @override
  State<_BookingDetailsForm> createState() => _BookingDetailsFormState();
}

class _BookingDetailsFormState extends State<_BookingDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _paymentDetailController = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';
  static const _paymentMethods = ['Cash on Delivery', 'UPI', 'Card'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _paymentDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(widget.serviceIcon,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Booking Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('for ${widget.serviceTitle}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (widget.servicePrice.isNotEmpty)
                    Text(widget.servicePrice,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: widget.color)),
                ],
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (v.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your address'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── Payment method ────────────────────────────────────────
              const Text('Payment Method',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: _paymentMethods.map((method) {
                  final selected = _paymentMethod == method;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _paymentMethod = method;
                        _paymentDetailController.clear();
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? widget.color : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected
                                  ? widget.color
                                  : Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              method == 'Cash on Delivery'
                                  ? Icons.payments_outlined
                                  : method == 'UPI'
                                      ? Icons.qr_code_rounded
                                      : Icons.credit_card_rounded,
                              size: 18,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method == 'Cash on Delivery' ? 'COD' : method,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_paymentMethod != 'Cash on Delivery') ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _paymentDetailController,
                  keyboardType: _paymentMethod == 'UPI'
                      ? TextInputType.text
                      : TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        _paymentMethod == 'UPI' ? 'UPI ID' : 'Card Number',
                    hintText: _paymentMethod == 'UPI'
                        ? 'yourname@upi'
                        : '1234 5678 9012 3456',
                    prefixIcon: Icon(_paymentMethod == 'UPI'
                        ? Icons.qr_code_rounded
                        : Icons.credit_card_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter your ${_paymentMethod == 'UPI' ? 'UPI ID' : 'card number'}'
                      : null,
                ),
              ],

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSubmit(
                        _nameController.text.trim(),
                        _phoneController.text.trim(),
                        _addressController.text.trim(),
                        _paymentMethod,
                        _paymentDetailController.text.trim(),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
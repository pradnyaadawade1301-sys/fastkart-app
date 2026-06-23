// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/restaurant/restaurant_detail_screen.dart';
import '../screens/restaurant/restaurant_list_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/maps/tracking_screen.dart';
import '../screens/maps/maps_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/addresses_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/vouchers_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/food/food_detail_screen.dart';
import '../screens/category/category_info_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/hotels/hotel_screen.dart';
import '../screens/flights/flights_screen.dart';
import '../screens/grocery/grocery_screen.dart';
import '../screens/bikes/bikes_screen.dart';
import '../screens/medicine/medicine_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/offers/offers_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/supports/chat_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/rides/rides_screen.dart';
import '../screens/saved/saved_screen.dart'; // ✅ FavouriteScreen ki jagah SavedScreen import
import '../screens/leisure/leisure_screen.dart';
import '../screens/trains/trains_screen.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  AppRouter._();

  static const _publicPaths = ['/', '/login', '/register'];

  static void setAuth(AuthProvider auth) {
    _notifier._auth = auth;
    auth.addListener(_notifier.notifyListeners);
  }

  static final _notifier = _AuthNotifier();

  static final router = GoRouter(
    initialLocation: '/',
    refreshListenable: _notifier,
    redirect: (context, state) {
      final auth = _notifier._auth;
      if (auth == null) return null;
      final loggedIn = auth.isLoggedIn;
      final path = state.matchedLocation;
      if (path == '/') return null;
      final isPublic = _publicPaths.contains(path) || path.startsWith('/login');
      if (loggedIn && isPublic) return '/home';
      if (!loggedIn && !isPublic) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (BuildContext _, GoRouterState __) => const SplashScreen()),

      GoRoute(
        path: '/login',
        builder: (BuildContext _, GoRouterState __) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (BuildContext context, GoRouterState state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return OtpScreen(
                phone: extra['phone'] as String? ?? '',
                role: extra['role'] as UserRole? ?? UserRole.customer,
              );
            },
          ),
        ],
      ),

      GoRoute(path: '/register', builder: (BuildContext _, GoRouterState __) => const RegisterScreen()),

      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home',      builder: (BuildContext _, GoRouterState __) => const HomeScreen()),
          GoRoute(path: '/search',    builder: (BuildContext _, GoRouterState __) => const SearchScreen()),
          // ✅ /favorites ab SavedScreen kholega (bottom nav "Saved" tab isi route ko use karta hai)
          GoRoute(path: '/favorites', builder: (BuildContext _, GoRouterState __) => const SavedScreen()),
          GoRoute(path: '/profile',   builder: (BuildContext _, GoRouterState __) => const ProfileScreen()),
          GoRoute(path: '/orders',    builder: (BuildContext _, GoRouterState __) => const OrdersScreen()),
          GoRoute(
            path: '/orders/:id',
            builder: (BuildContext context, GoRouterState state) =>
                OrderDetailScreen(orderId: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),

      // ✅ Grocery category directly opens GroceryScreen
      GoRoute(
        path: '/category/grocery',
        builder: (BuildContext _, GoRouterState __) => const GroceryScreen(),
      ),

      // ✅ Leisure category directly opens LeisureScreen
      GoRoute(
        path: '/category/leisure',
        builder: (BuildContext context, GoRouterState state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return LeisureScreen(initialTab: tab);
        },
      ),

      // All other categories go to CategoryInfoScreen
      GoRoute(
        path: '/category/:id',
        builder: (BuildContext context, GoRouterState state) =>
            CategoryInfoScreen(category: state.pathParameters['id'] ?? 'food'),
      ),

      GoRoute(
        path: '/leisure',
        builder: (BuildContext context, GoRouterState state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return LeisureScreen(initialTab: tab);
        },
      ),

      GoRoute(path: '/movies',   builder: (BuildContext _, GoRouterState __) => const MoviesScreen()),
      GoRoute(path: '/hotels',   builder: (BuildContext _, GoRouterState __) => const HotelsScreen()),
      GoRoute(path: '/flights',  builder: (BuildContext _, GoRouterState __) => const FlightsScreen()),
      GoRoute(path: '/rides',    builder: (BuildContext _, GoRouterState __) => const RidesScreen()),
      GoRoute(path: '/grocery',  builder: (BuildContext _, GoRouterState __) => const GroceryScreen()),
      GoRoute(path: '/bikes',    builder: (BuildContext _, GoRouterState __) => const BikeScreen()),
      GoRoute(path: '/medicine', builder: (BuildContext _, GoRouterState __) => const MedicineScreen()),
      GoRoute(path: '/trains',   builder: (BuildContext _, GoRouterState __) => const TrainsScreen()),
      GoRoute(path: '/more',     builder: (BuildContext _, GoRouterState __) => const MedicineScreen()),

      GoRoute(path: '/addresses',       builder: (BuildContext _, GoRouterState __) => const AddressesScreen()),
      GoRoute(path: '/edit-profile',    builder: (BuildContext _, GoRouterState __) => const EditProfileScreen()),
      GoRoute(path: '/payment-methods', builder: (BuildContext _, GoRouterState __) => const _PaymentMethodsScreen()),
      GoRoute(path: '/points',          builder: (BuildContext _, GoRouterState __) => const _PointsScreen()),
      GoRoute(path: '/vouchers',        builder: (BuildContext _, GoRouterState __) => const VouchersScreen()),

      GoRoute(path: '/restaurants', builder: (BuildContext _, GoRouterState __) => const RestaurantListScreen()),
      GoRoute(
        path: '/restaurant/:id',
        builder: (BuildContext context, GoRouterState state) =>
            RestaurantDetailScreen(restaurantId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/food/:id',
        builder: (BuildContext context, GoRouterState state) =>
            FoodDetailScreen(foodId: state.pathParameters['id'] ?? ''),
      ),

      GoRoute(path: '/cart',     builder: (BuildContext _, GoRouterState __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (BuildContext _, GoRouterState __) => const CheckoutScreen()),

      GoRoute(path: '/wallet',        builder: (BuildContext _, GoRouterState __) => const WalletScreen()),
      GoRoute(path: '/offers',        builder: (BuildContext _, GoRouterState __) => const OffersScreen()),
      GoRoute(path: '/notifications', builder: (BuildContext _, GoRouterState __) => const NotificationsScreen()),
      GoRoute(
        path: '/chat',
        builder: (BuildContext context, GoRouterState state) =>
            ChatScreen(type: state.uri.queryParameters['type'] ?? 'support'),
      ),
      GoRoute(
        path: '/tracking/:id',
        builder: (BuildContext context, GoRouterState state) =>
            TrackingScreen(orderId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/map', builder: (BuildContext _, GoRouterState __) => const MapsScreen()),
    ],

    errorBuilder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go('/home');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    },
  );
}

class _AuthNotifier extends ChangeNotifier {
  AuthProvider? _auth;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAYMENT METHODS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class _PaymentMethodsScreen extends StatefulWidget {
  const _PaymentMethodsScreen();
  @override
  State<_PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<_PaymentMethodsScreen> {
  final _methods = <Map<String, dynamic>>[
    {'id': '1', 'type': 'upi',  'label': 'Google Pay',  'detail': 'user@okicici',   'icon': '📱', 'isDefault': true},
    {'id': '2', 'type': 'card', 'label': 'HDFC Debit',  'detail': '**** **** 4321', 'icon': '💳', 'isDefault': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFFFF6F00),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFFFF6F00).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            const Text('💰', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FastKart Wallet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('₹450.00 available', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Text('Add Money', style: TextStyle(color: Color(0xFFFF6F00), fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Saved Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ..._methods.map((m) => _buildMethodCard(m)),
      ]),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> m) {
    final isDefault = m['isDefault'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? const Color(0xFFFF6F00) : Colors.grey.shade200, width: isDefault ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFFFF6F00).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(m['icon'] as String, style: const TextStyle(fontSize: 22))),
        ),
        title: Row(children: [
          Text(m['label'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFF6F00), borderRadius: BorderRadius.circular(6)),
              child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        subtitle: Text(m['detail'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (v) {
            if (v == 'default') {
              setState(() { for (var x in _methods) {
              x['isDefault'] = false;
            } m['isDefault'] = true; });
            }
            if (v == 'delete') setState(() => _methods.remove(m));
          },
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    String selectedType = 'upi';
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('Add Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(children: [
            _typeBtn('upi', '📱 UPI', selectedType, (v) => setS(() => selectedType = v)),
            const SizedBox(width: 10),
            _typeBtn('card', '💳 Card', selectedType, (v) => setS(() => selectedType = v)),
            const SizedBox(width: 10),
            _typeBtn('netbanking', '🏦 NetBank', selectedType, (v) => setS(() => selectedType = v)),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: selectedType == 'upi' ? 'Enter UPI ID' : selectedType == 'card' ? 'Card Number' : 'Bank Name',
              filled: true, fillColor: const Color(0xFFF8F5F0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (ctrl.text.isEmpty) return;
                setState(() => _methods.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'type': selectedType,
                  'label': selectedType == 'upi' ? 'UPI' : selectedType == 'card' ? 'Card' : 'NetBanking',
                  'detail': ctrl.text,
                  'icon': selectedType == 'upi' ? '📱' : selectedType == 'card' ? '💳' : '🏦',
                  'isDefault': false,
                }));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Save Method', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            )),
        ]),
      )),
    );
  }

  Widget _typeBtn(String value, String label, String active, ValueChanged<String> onTap) {
    final isActive = value == active;
    return Expanded(child: GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF6F00) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? const Color(0xFFFF6F00) : Colors.grey.shade300),
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : Colors.grey)),
      ),
    ));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// POINTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class _PointsScreen extends StatelessWidget {
  const _PointsScreen();

  @override
  Widget build(BuildContext context) {
    const points = 1280;
    const cashback = '12.80';

    final history = [
      {'emoji': '🍔', 'title': 'Food Order #1042',    'pts': '+120', 'date': '10 Jun 2026', 'plus': true},
      {'emoji': '🎬', 'title': 'Movie Booking',        'pts': '+50',  'date': '08 Jun 2026', 'plus': true},
      {'emoji': '🏨', 'title': 'Hotel Stay – Mumbai',  'pts': '+200', 'date': '01 Jun 2026', 'plus': true},
      {'emoji': '⭐', 'title': 'Review Submitted',     'pts': '+20',  'date': '28 May 2026', 'plus': true},
      {'emoji': '🛒', 'title': 'Points Redeemed',      'pts': '-100', 'date': '20 May 2026', 'plus': false},
      {'emoji': '👥', 'title': 'Referral Bonus',       'pts': '+100', 'date': '15 May 2026', 'plus': true},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE65100),
        title: const Text('My Points', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: BackButton(color: Colors.white, onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFFFF6F00).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(children: [
            const Text('⭐', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            const Text('$points', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
            const Text('Total Points', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: const Text('= ₹$cashback cashback value',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('How to Earn Points', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...[
          {'emoji': '🍔', 'text': 'Order food — 1 point per ₹1 spent'},
          {'emoji': '🎬', 'text': 'Book movies — 5 points per ticket'},
          {'emoji': '🏨', 'text': 'Hotel booking — 10 points per night'},
          {'emoji': '⭐', 'text': 'Write a review — 20 points'},
          {'emoji': '👥', 'text': 'Refer a friend — 100 points'},
        ].map((item) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
          child: Row(children: [
            Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(item['text']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
        )),
        const SizedBox(height: 24),
        const Text('Points History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
          child: Column(
            children: history.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isPlus = item['plus'] as bool;
              return Column(children: [
                ListTile(
                  leading: Container(width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: (isPlus ? const Color(0xFF4CAF50) : const Color(0xFFE53935)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 20)))),
                  title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: Text(item['date'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  trailing: Text(item['pts'] as String,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15,
                      color: isPlus ? const Color(0xFF4CAF50) : const Color(0xFFE53935))),
                ),
                if (i < history.length - 1) const Divider(height: 1, indent: 66),
              ]);
            }).toList(),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

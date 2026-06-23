import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/restaurant_provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabs;
  Restaurant? _r;
  List<String> _cats = [];

  @override
  void initState() {
    super.initState();
    _tryFindRestaurant();

    final prov = context.read<RestaurantProvider>();
    if (!prov.isLoaded) {
      prov.loadData();
      prov.addListener(_onRestaurantsUpdated);
    }
  }

  void _tryFindRestaurant() {
    _r = context.read<RestaurantProvider>().byId(widget.restaurantId);
    if (_r != null) {
      _cats = ['All', ..._r!.menu.map((f) => f.category).toSet()];
      _tabs = TabController(length: _cats.length < 1 ? 1 : _cats.length, vsync: this);
    }
  }

  void _onRestaurantsUpdated() {
    if (_r != null) return;
    final prov = context.read<RestaurantProvider>();
    setState(() => _tryFindRestaurant());
    if (_r != null) prov.removeListener(_onRestaurantsUpdated);
  }

  @override
  void dispose() {
    context.read<RestaurantProvider>().removeListener(_onRestaurantsUpdated);
    _tabs?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_r == null) {
      final prov = context.watch<RestaurantProvider>();
      if (!prov.isLoaded) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Restaurant not found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.pop(), child: const Text('Go Back')),
          ]),
        ),
      );
    }
    final r = _r!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 230,
                pinned: true,
                backgroundColor: Colors.white,
                leading: _circleBtn(Icons.arrow_back_rounded,
                    () => context.pop()),
                actions: [
                  _circleBtn(
                    r.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    () {
                      context
                          .read<RestaurantProvider>()
                          .toggleFavorite(r.id);
                      setState(() {
                        _r = context
                            .read<RestaurantProvider>()
                            .byId(widget.restaurantId);
                      });
                    },
                    color: r.isFavorite ? AppColors.error : Colors.black87,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    r.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.divider),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(r.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (r.isOpen
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            r.isOpen ? '● Open' : '● Closed',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: r.isOpen
                                    ? AppColors.success
                                    : AppColors.error),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text(r.categories.join(' · '),
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.star),
                        Text(' ${r.rating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text('  (${r.reviewCount} reviews)',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(children: [
                        _tile('⏱️', r.deliveryTime, 'Delivery'),
                        _divider(),
                        _tile(
                          '🛵',
                          r.deliveryFee == 0
                              ? 'Free'
                              : '₹${r.deliveryFee.toStringAsFixed(0)}',
                          'Fee',
                        ),
                        _divider(),
                        _tile('🛍️', '₹${r.minOrder.toStringAsFixed(0)}',
                            'Min'),
                        _divider(),
                        _tile('📍', r.distance, 'Distance'),
                      ]),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _TabDelegate(
                  TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    labelColor: Colors.black87,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: _cats.map((c) => Tab(text: c)).toList(),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: _cats.map((cat) {
                final items = cat == 'All'
                    ? r.menu
                    : r.menu.where((f) => f.category == cat).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _FoodTile(food: items[i]),
                );
              }).toList(),
            ),
          ),

          _CartFab(),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color ?? Colors.black87),
        ),
      ),
    );
  }

  Widget _tile(String emoji, String val, String label) {
    return Expanded(
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(val,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 38, color: AppColors.divider);
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabDelegate(this.tabBar);

  @override
  Widget build(_, __, ___) =>
      Container(color: Colors.white, child: tabBar);

  @override double get maxExtent => tabBar.preferredSize.height;
  @override double get minExtent => tabBar.preferredSize.height;
  @override bool shouldRebuild(covariant _) => false;
}

class _FoodTile extends StatelessWidget {
  final FoodItem food;
  const _FoodTile({required this.food});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/food/${food.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(food.imageUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: AppColors.divider,
                      child: const Icon(Icons.fastfood,
                          color: AppColors.textHint))),
            ),
            if (food.isPopular)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('HOT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800)),
                ),
              ),
          ]),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(food.description,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('₹${food.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent)),
                        if (food.hasDiscount)
                          Text('₹${food.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                  decoration:
                                      TextDecoration.lineThrough)),
                      ]),
                      _AddBtn(food: food),
                    ],
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}

// ✅ CHANGE 1: Ab hamesha - 0 + dikhega, sirf + circle nahi
class _AddBtn extends StatelessWidget {
  final FoodItem food;
  const _AddBtn({required this.food});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final qty = cart.quantityOf(food.id);
        return Row(children: [
          _roundBtn(
            Icons.remove,
            () {
              if (qty > 0) cart.updateQuantity(food.id, qty - 1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$qty',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          _roundBtn(Icons.add, () => cart.addItem(food), filled: true),
        ]);
      },
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap,
      {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.primary),
        ),
        child: Icon(icon, size: 14, color: Colors.black87),
      ),
    );
  }
}

class _CartFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        if (cart.isEmpty) return const SizedBox.shrink();
        return Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => context.push('/cart'),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Row(children: [
                Container(
                  margin: const EdgeInsets.all(7),
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.shopping_bag_rounded,
                        color: Colors.black87, size: 20),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${cart.itemCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ]),
                ),
                const Expanded(
                  child: Text('View Cart',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text('₹${cart.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
// lib/screens/food/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/restaurant_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;
  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  FoodItem? _food;
  Restaurant? _restaurant;
  int _qty = 1;
  String _note = '';
  final List<FoodOptionItem> _selected = [];

  @override
  void initState() {
    super.initState();
    final prov = context.read<RestaurantProvider>();
    for (final r in prov.restaurants) {
      try {
        _food = r.menu.firstWhere((f) => f.id == widget.foodId);
        _restaurant = r;
        break;
      } catch (_) {}
    }
  }

  double get _total {
    if (_food == null) return 0;
    final extra = _selected.fold<double>(0, (s, o) => s + o.extraPrice);
    return (_food!.price + extra) * _qty;
  }

  void _addToCartAndConfirm() {
    final cart = context.read<CartProvider>();
    final f = _food!;

    cart.addItem(f, quantity: _qty, options: List.from(_selected), note: _note);

    // ✅ Order confirm screen pe navigate karo
    // CartProvider mein checkout karo aur Order object banao
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      restaurantId: _restaurant?.id ?? f.restaurantId,
      restaurantName: _restaurant?.name ?? 'Restaurant',
      restaurantImage: _restaurant?.imageUrl ?? f.imageUrl,
      items: [
        OrderItemModel(
          id: f.id,
          name: f.name,
          imageUrl: f.imageUrl,
          quantity: _qty,
          price: f.price,
        ),
      ],
      subtotal: _total,
      deliveryFee: (_restaurant?.deliveryFee ?? 39).toDouble(),
      discount: 0,
      total: _total + (_restaurant?.deliveryFee ?? 39),
      status: OrderStatus.confirmed,
      deliveryAddress: const DeliveryAddress(
        label: 'Home',
        fullAddress: 'B-204, Andheri West, Mumbai - 400053',
      ),
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 40)),
      paymentMethod: PaymentMethod.upi,
    );

    context.push('/order-confirmation', extra: order);
  }

  @override
  Widget build(BuildContext context) {
    if (_food == null) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }
    final f = _food!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 270,
              pinned: true,
              backgroundColor: Colors.white,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.black87),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: f.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.divider),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Name + badge
                  Row(children: [
                    Expanded(
                        child: Text(f.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800))),
                    if (f.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('HOT 🔥',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.star),
                    Text(' ${f.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('  ·  ${f.soldCount} sold',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                  const SizedBox(height: 12),
                  Text(f.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 16),

                  // Price
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('₹${f.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent)),
                    if (f.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text('₹${f.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                            '-${f.discountPct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  const Divider(height: 32),

                  // Options
                  ...f.options.map((grp) => _optionGroup(grp)),

                  // Special instructions
                  const Text('Special Instructions',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. No onion, extra spicy...',
                    ),
                    onChanged: (v) => _note = v,
                  ),
                  const SizedBox(height: 110),
                ]),
              ),
            ),
          ],
        ),

        // ✅ Bottom bar — "Order Now" button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Row(children: [
              // Qty selector
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                  ),
                  Text('$_qty',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => _qty++),
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addToCartAndConfirm, // ✅ direct order confirm
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Order Now · ₹${_total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _optionGroup(FoodOptionGroup grp) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(grp.name,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        if (grp.isRequired)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4)),
            child: const Text('Required',
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
      const SizedBox(height: 8),
      ...grp.items.map((item) => CheckboxListTile(
            value: item.isSelected,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() {
                if (!grp.isMultiple) {
                  for (final i in grp.items) {
                    i.isSelected = false;
                  }
                }
                item.isSelected = v ?? false;
                if (item.isSelected) {
                  _selected.add(item);
                } else {
                  _selected.remove(item);
                }
              });
            },
            title: Text(item.name),
            subtitle: item.extraPrice > 0
                ? Text('+₹${item.extraPrice.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.accent))
                : null,
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
      const Divider(height: 24),
    ]);
  }
}
// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.isEmpty ? const SizedBox()
              : TextButton(
                  onPressed: () => _confirmClearCart(context, cart),
                  child: const Text('Clear', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.isEmpty) return _empty(context);
          return Column(children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Items
                  _card(child: Column(children: [
                    ListTile(
                      leading: const Icon(Icons.restaurant_rounded, color: AppColors.primary),
                      title: Text(cart.restaurantName ?? 'Restaurant',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    const Divider(height: 1),
                    ...cart.items.map((item) => _ItemRow(item: item)),
                  ])),
                  const SizedBox(height: 12),

                  // Promo
                  _card(child: Row(children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.discount_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _promoCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Promo code (try FIRST50)',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () { cart.applyPromo(_promoCtrl.text); FocusScope.of(context).unfocus(); },
                      child: const Text('Apply', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ])),

                  if (cart.promoCode.isNotEmpty && cart.discount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Code "${cart.promoCode}" applied! Save ₹${cart.discount.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600))),
                        GestureDetector(
                          onTap: () {
                            cart.removePromo();
                            _promoCtrl.clear();
                          },
                          child: const Icon(Icons.close, color: AppColors.success, size: 16),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Order Summary
                  _card(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Order Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _row('Subtotal', '₹${cart.subtotal.toStringAsFixed(0)}'),
                      _row('Delivery Fee', cart.deliveryFee == 0 ? 'Free' : '₹${cart.deliveryFee.toStringAsFixed(0)}'),
                      if (cart.discount > 0)
                        _row('Discount', '-₹${cart.discount.toStringAsFixed(0)}', color: AppColors.success),
                      const Divider(height: 20),
                      _row('Total', '₹${cart.total.toStringAsFixed(0)}', bold: true, large: true),
                    ]),
                  )),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Checkout button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push('/checkout'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Consumer<CartProvider>(
                    builder: (_, c, __) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.lock_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text('Proceed to Checkout · ₹${c.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { cart.clear(); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🛒', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 20),
        const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Add items from a restaurant', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Browse Restaurants')),
      ]),
    );
  }

  Widget _card({required Widget child}) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: child);

  Widget _row(String label, String value, {Color? color, bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: large ? 15 : 13, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: large ? 18 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: color ?? AppColors.textPrimary)),
      ]),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(item.food.imageUrl, width: 58, height: 58, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 58, height: 58,
                color: AppColors.divider, child: const Icon(Icons.fastfood, color: AppColors.textHint))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.food.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text('₹${item.food.price.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500)),
        ])),
        Consumer<CartProvider>(
          builder: (_, cart, __) => Row(children: [
            _btn(Icons.remove, () => cart.updateQuantity(item.food.id, item.quantity - 1)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('${item.quantity}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            _btn(Icons.add, () => cart.addItem(item.food), filled: true),
          ]),
        ),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
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
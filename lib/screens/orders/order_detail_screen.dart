// lib/screens/orders/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>().byId(orderId);
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text('Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status
          _section(child: Row(children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(
                color: order.status == OrderStatus.delivered ? AppColors.success
                    : order.status == OrderStatus.cancelled ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(order.status.label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            if (order.estimatedDelivery != null)
              Text('ETA: ${_fmt(order.estimatedDelivery!)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ])),
          const SizedBox(height: 12),

          // Items
          _section(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.restaurantName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const Divider(height: 16),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${item.name} x${item.quantity}', style: const TextStyle(fontSize: 13)),
                Text('₹${item.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ]))),
          ])),
          const SizedBox(height: 12),

          // Address
          _section(child: Row(children: [
            const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(order.deliveryAddress.fullAddress,
                style: const TextStyle(color: AppColors.textSecondary))),
          ])),
          const SizedBox(height: 12),

          // Price
          _section(child: Column(children: [
            _row('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
            _row('Delivery Fee', order.deliveryFee == 0 ? 'Free' : '₹${order.deliveryFee.toStringAsFixed(0)}'),
            if (order.discount > 0)
              _row('Discount', '-₹${order.discount.toStringAsFixed(0)}', color: AppColors.success),
            const Divider(height: 16),
            _row('Total', '₹${order.total.toStringAsFixed(0)}', bold: true, large: true),
          ])),
          const SizedBox(height: 20),

          if (order.status.isActive)
            ElevatedButton.icon(
              onPressed: () => context.push('/tracking/${order.id}'),
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),

          if (order.status == OrderStatus.delivered) ...[
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _RatingScreenPlaceholder(
                      orderId: order.id, restaurantName: order.restaurantName,
                      restaurantImage: order.restaurantImage ?? ''))),
              icon: const Icon(Icons.star_rounded),
              label: const Text('Rate Your Order', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Reorder', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _section({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: child);

  Widget _row(String label, String value, {Color? color, bool bold = false, bool large = false}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: large ? 15 : 13, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: large ? 17 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: color ?? AppColors.textPrimary)),
      ]));

  String _fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// Inline placeholder that navigates to rating
class _RatingScreenPlaceholder extends StatefulWidget {
  final String orderId, restaurantName, restaurantImage;
  const _RatingScreenPlaceholder({required this.orderId, required this.restaurantName, required this.restaurantImage});
  @override
  State<_RatingScreenPlaceholder> createState() => _RatingScreenPlaceholderState();
}

class _RatingScreenPlaceholderState extends State<_RatingScreenPlaceholder> {
  int _foodRating = 0;
  int _deliveryRating = 0;
  final _reviewCtrl = TextEditingController();
  bool _submitted = false;
  final List<String> _selectedTags = [];
  final _positiveTags = ['Tasty Food', 'Quick Delivery', 'Good Packaging', 'Value for Money'];
  final _negativeTags = ['Late Delivery', 'Wrong Item', 'Cold Food'];

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 20),
        const Text('Thank You!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('You earned 50 loyalty points! ⭐', style: TextStyle(color: AppColors.success, fontSize: 14)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
          child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      ])));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.primary,
        title: const Text('Rate Your Order', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _ratingCard('How was the food?', '🍽️', _foodRating, (v) => setState(() => _foodRating = v)),
          const SizedBox(height: 12),
          _ratingCard('How was the delivery?', '🛵', _deliveryRating, (v) => setState(() => _deliveryRating = v)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Quick Tags', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: [..._positiveTags, ..._negativeTags].map((tag) {
                  final sel = _selectedTags.contains(tag);
                  final isPos = _positiveTags.contains(tag);
                  return GestureDetector(onTap: () => setState(() { if (sel) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  } }),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? (isPos ? AppColors.success : AppColors.error).withValues(alpha: 0.1) : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: sel ? (isPos ? AppColors.success : AppColors.error) : AppColors.border)),
                      child: Text(tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: sel ? (isPos ? AppColors.success : AppColors.error) : AppColors.textSecondary))));
                }).toList()),
              const SizedBox(height: 12),
              TextField(controller: _reviewCtrl, maxLines: 3,
                decoration: InputDecoration(hintText: 'Write your review...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: AppColors.background)),
            ])),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _foodRating == 0 ? null : () => setState(() => _submitted = true),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Submit Review', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
        ])));
  }

  Widget _ratingCard(String q, String emoji, int rating, Function(int) onRate) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Row(children: [Text(emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 8),
        Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) => GestureDetector(onTap: () => onRate(i + 1),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 36, color: i < rating ? AppColors.star : Colors.grey.shade300))))),
    ]));
}
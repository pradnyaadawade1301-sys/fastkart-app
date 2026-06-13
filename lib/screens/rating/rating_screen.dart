// lib/screens/rating/rating_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class RatingScreen extends StatefulWidget {
  final String restaurantId;
  final String orderId;
  const RatingScreen({super.key, required this.restaurantId, required this.orderId});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _food = 0, _delivery = 0, _overall = 0;
  final _ctrl = TextEditingController();
  String? _selectedTag;
  bool _submitted = false;

  final List<String> _tags = ['Fast Delivery', 'Hot Food', 'Great Packaging', 'Friendly Driver',
      'Accurate Order', 'Worth the Price'];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _submit() async {
    if (_overall == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please give an overall rating')));
      return;
    }
    setState(() => _submitted = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text('Thank You!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Your feedback helps us improve', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: const Text('🌟 +50 reward points earned!',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
      ])));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Rate Your Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Restaurant info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: Row(children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('🍛', style: TextStyle(fontSize: 28)))),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Punjabi Tadka', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Text('Order #${widget.orderId}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        // Overall
        _RatingCard(title: 'Overall Experience', emoji: '⭐',
            rating: _overall, onRate: (r) => setState(() => _overall = r)),
        const SizedBox(height: 12),
        _RatingCard(title: 'Food Quality', emoji: '🍽️',
            rating: _food, onRate: (r) => setState(() => _food = r)),
        const SizedBox(height: 12),
        _RatingCard(title: 'Delivery Experience', emoji: '🛵',
            rating: _delivery, onRate: (r) => setState(() => _delivery = r)),
        const SizedBox(height: 20),

        // Tags
        const Text('What went well?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) => GestureDetector(
          onTap: () => setState(() => _selectedTag = _selectedTag == t ? null : t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedTag == t ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _selectedTag == t ? AppColors.primary : AppColors.border),
            ),
            child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: _selectedTag == t ? Colors.black87 : AppColors.textSecondary)),
          ),
        )).toList()),
        const SizedBox(height: 20),

        // Comment
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: TextField(
            controller: _ctrl, maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share more details about your experience...',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: const Text('Submit Review', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final String title, emoji;
  final double rating;
  final void Function(double) onRate;
  const _RatingCard({required this.title, required this.emoji, required this.rating, required this.onRate});

  String get _label {
    if (rating == 0) return 'Tap to rate';
    if (rating <= 1) return 'Poor';
    if (rating <= 2) return 'Fair';
    if (rating <= 3) return 'Good';
    if (rating <= 4) return 'Very Good';
    return 'Excellent!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(_label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: rating > 0 ? AppColors.primary : AppColors.textHint)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
          GestureDetector(
            onTap: () => onRate(i + 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 36, color: i < rating ? const Color(0xFFFFB300) : AppColors.border),
            ),
          )
        )),
      ]),
    );
  }
}
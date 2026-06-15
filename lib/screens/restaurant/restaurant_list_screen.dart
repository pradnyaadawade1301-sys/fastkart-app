// lib/screens/restaurant/restaurant_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/restaurant_provider.dart';

class RestaurantListScreen extends StatefulWidget {
  final String category;
  const RestaurantListScreen({super.key, this.category = ''});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  String _sort = 'rating';
  bool _freeOnly = false;
  bool _openOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category.isEmpty ? 'Restaurants' : widget.category),
        backgroundColor: AppColors.primary,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip('Best Rating', _sort == 'rating', () => setState(() => _sort = 'rating')),
              const SizedBox(width: 8),
              _chip('Fastest', _sort == 'time', () => setState(() => _sort = 'time')),
              const SizedBox(width: 8),
              _chip('Free Delivery', _freeOnly, () => setState(() => _freeOnly = !_freeOnly)),
              const SizedBox(width: 8),
              _chip('Open Now', _openOnly, () => setState(() => _openOnly = !_openOnly)),
            ]),
          ),
        ),
        Expanded(
          child: Consumer<RestaurantProvider>(
            builder: (_, prov, __) {
              var list = List<Restaurant>.from(prov.restaurants);
              if (_freeOnly) list = list.where((r) => r.deliveryFee == 0).toList();
              if (_openOnly) list = list.where((r) => r.isOpen).toList();
              if (_sort == 'rating') list.sort((a, b) => b.rating.compareTo(a.rating));
              if (_sort == 'time') list.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));

              if (list.isEmpty) {
                return const Center(child: Text('No restaurants found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _Card(r: list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.black87 : AppColors.textSecondary)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Restaurant r;
  const _Card({required this.r});

  // ✅ CHANGE 2: Order Now pe click karne pe customer info bottom sheet
  void _showOrderSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(children: [
                  Expanded(
                    child: Text(
                      r.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close_rounded, size: 22),
                  ),
                ]),
                const SizedBox(height: 4),
                const Text(
                  'Fill in delivery details',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Name
                const Text('Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('Enter your name', Icons.person_outline_rounded),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),

                // Phone
                const Text('Phone Number',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: _inputDecoration('10 digit mobile number', Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    if (v.trim().length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Address
                const Text('Delivery Address',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration('Enter your complete address', Icons.location_on_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                ),
                const SizedBox(height: 14),

                // Note (optional)
                const Text('Order Note (Optional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noteController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration('Any special instruction? (e.g. less spice)', Icons.note_outlined),
                ),
                const SizedBox(height: 24),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx);
                        context.push('/restaurant/${r.id}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Confirm Order →',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image
        GestureDetector(
          onTap: () => context.push('/restaurant/${r.id}'),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              CachedNetworkImage(
                imageUrl: r.imageUrl,
                height: 160, width: double.infinity, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(height: 160, color: AppColors.divider,
                    child: const Icon(Icons.restaurant, size: 48, color: AppColors.textHint)),
              ),
              if (!r.isOpen)
                Positioned.fill(child: Container(
                  color: Colors.black54,
                  child: const Center(child: Text('CLOSED',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 3))),
                )),
              Positioned(top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                    Text(' ${r.rating}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ]),
                )),
            ]),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name + open badge
            Row(children: [
              Expanded(child: Text(r.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
              if (r.isOpen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Open', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 4),
            Text(r.categories.join(' · '),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),

            // Info chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _infoChip(Icons.star_rounded, '${r.rating}', AppColors.star),
                Container(width: 1, height: 18, color: AppColors.divider),
                _infoChip(Icons.access_time_rounded, r.deliveryTime, AppColors.textSecondary),
                Container(width: 1, height: 18, color: AppColors.divider),
                _infoChip(
                  Icons.delivery_dining_rounded,
                  r.deliveryFee == 0 ? 'Free' : '₹${r.deliveryFee.toInt()}',
                  r.deliveryFee == 0 ? AppColors.success : AppColors.textSecondary,
                ),
                Container(width: 1, height: 18, color: AppColors.divider),
                _infoChip(Icons.location_on_rounded, r.distance, AppColors.textSecondary),
              ]),
            ),
            const SizedBox(height: 12),

            // Min order + buttons
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Min Order', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text('₹${r.minOrder.toInt()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
              const Spacer(),
              // View Menu button
              OutlinedButton(
                onPressed: () => context.push('/restaurant/${r.id}'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('View Menu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              // ✅ Order Now — ab bottom sheet khulega
              ElevatedButton(
                onPressed: r.isOpen ? () => _showOrderSheet(context) : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('Order Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}
// lib/screens/medicine/medicine_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/history_service.dart';
import '../../models/history_item.dart';

const _moreServices = [
  {'name': 'Doctor Consultation', 'location': '200+ specialist doctors', 'rating': '4.9', 'reviews': '12k', 'price': 299.0, 'icon': Icons.medical_services_rounded, 'color': 0xFF4CAF50},
  {'name': 'Lab Tests', 'location': 'Home sample collection', 'rating': '4.8', 'reviews': '8k', 'price': 199.0, 'icon': Icons.biotech_rounded, 'color': 0xFF2196F3},
  {'name': 'Medicine Delivery', 'location': 'Delivered in 2 hours', 'rating': '4.7', 'reviews': '20k', 'price': 0.0, 'icon': Icons.local_pharmacy_rounded, 'color': 0xFFFF9800},
  {'name': 'Health Packages', 'location': 'Full body checkup', 'rating': '4.9', 'reviews': '5k', 'price': 999.0, 'icon': Icons.favorite_rounded, 'color': 0xFFE91E63},
  {'name': 'Mental Wellness', 'location': 'Therapy & counseling', 'rating': '4.8', 'reviews': '3k', 'price': 499.0, 'icon': Icons.psychology_rounded, 'color': 0xFF9C27B0},
  {'name': 'Dental Care', 'location': '100+ dentists near you', 'rating': '4.6', 'reviews': '6k', 'price': 349.0, 'icon': Icons.mood_rounded, 'color': 0xFF00BCD4},
  {'name': 'Eye Checkup', 'location': 'Vision tests & more', 'rating': '4.7', 'reviews': '4k', 'price': 249.0, 'icon': Icons.remove_red_eye_rounded, 'color': 0xFF3F51B5},
  {'name': 'Physiotherapy', 'location': 'Home visit available', 'rating': '4.8', 'reviews': '2k', 'price': 599.0, 'icon': Icons.self_improvement_rounded, 'color': 0xFF795548},
];

class _ServiceItem {
  final String name, location, rating, reviews;
  final double price;
  final IconData icon;
  final Color color;

  const _ServiceItem({
    required this.name, required this.location, required this.rating,
    required this.reviews, required this.price,
    required this.icon, required this.color,
  });
}

final _services = _moreServices.map((m) => _ServiceItem(
  name: m['name'] as String,
  location: m['location'] as String,
  rating: m['rating'] as String,
  reviews: m['reviews'] as String,
  price: m['price'] as double,
  icon: m['icon'] as IconData,
  color: Color(m['color'] as int),
)).toList();

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  bool _isBooking = false;
  int _cartCount = 0;

  // ---------------- Add to cart ----------------
  void _addToCart(_ServiceItem service) {
    setState(() => _cartCount++);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service.name} added to cart'),
        backgroundColor: service.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------------- Booking with user details ----------------
  Future<void> _bookService(
    _ServiceItem service, {
    String? name,
    String? phone,
    String? address,
  }) async {
    setState(() => _isBooking = true);

    final description = (name != null && name.isNotEmpty)
        ? '${service.name} booked for $name'
            '${phone != null && phone.isNotEmpty ? ' · $phone' : ''}'
        : '${service.name} booked · Rating ${service.rating}';

    await HistoryService.instance.saveItem(
      HistoryService.makeMore(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: service.name,
        subtitle: (address != null && address.isNotEmpty)
            ? address
            : service.location,
        description: description,
        amount: service.price,
        date: DateTime.now(),
        status: HistoryStatus.confirmed,
      ),
    );

    setState(() => _isBooking = false);

    if (!mounted) return;
    _showBookingSuccess(service);
  }

  void _showBookingForm(_ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _BookingDetailsForm(
        service: service,
        onSubmit: (name, phone, address) {
          Navigator.pop(sheetContext);
          _bookService(service, name: name, phone: phone, address: address);
        },
      ),
    );
  }

  void _showServiceDetail(_ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(service.icon, color: service.color, size: 34),
            ),
            const SizedBox(height: 14),
            Text(service.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(service.location,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFC107), size: 18),
                const SizedBox(width: 4),
                Text('${service.rating} · ${service.reviews} reviews',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consultation Fee',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                    service.price == 0
                        ? 'FREE'
                        : '₹${service.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: service.price == 0
                          ? AppColors.success
                          : AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Add + Book buttons (replaces old single "Open" action) ----
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _addToCart(service);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: service.color, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart_rounded,
                              color: service.color, size: 18),
                          const SizedBox(width: 6),
                          Text('Add',
                              style: TextStyle(
                                  color: service.color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBookingForm(service);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service.color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSuccess(_ServiceItem service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: service.color),
            const SizedBox(width: 8),
            const Text('Booked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(service.location,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              service.price == 0
                  ? 'FREE'
                  : 'Amount: ₹${service.price.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health & Medicine'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_cartCount item(s) in cart'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
                      color: AppColors.accent,
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Health,\nOur Priority',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.2)),
                      SizedBox(height: 6),
                      Text('Book healthcare services\nfrom the comfort of home',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Text('🏥', style: TextStyle(fontSize: 52)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Our Services',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),

          // Services grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _services.length,
              itemBuilder: (_, i) {
                final service = _services[i];
                return GestureDetector(
                  onTap: () => _showServiceDetail(service),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: service.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(service.icon,
                              color: service.color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(service.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFC107),
                                size: 13),
                            const SizedBox(width: 3),
                            Text(service.rating,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary)),
                            const Spacer(),
                            Text(
                              service.price == 0
                                  ? 'Free'
                                  : '₹${service.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: service.price == 0
                                    ? AppColors.success
                                    : AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Booking details form - shown when user taps "Book"
// ====================================================================
class _BookingDetailsForm extends StatefulWidget {
  final _ServiceItem service;
  final void Function(String name, String phone, String address) onSubmit;

  const _BookingDetailsForm({
    required this.service,
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
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
                    color: widget.service.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.service.icon,
                      color: widget.service.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Booking Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('for ${widget.service.name}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
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
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.service.color,
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
    );
  }
}
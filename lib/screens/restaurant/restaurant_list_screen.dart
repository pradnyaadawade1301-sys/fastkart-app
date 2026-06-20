// lib/screens/restaurant/restaurant_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/history_service.dart';
import '../../models/history_item.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCuisine = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showOrderOptions(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(restaurant.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('What would you like to do?',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => _DeliveryDetailsScreen(
                      restaurant: restaurant,
                    ),
                  ));
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Order Now',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/restaurant/${restaurant.id}/book');
                },
                icon: const Icon(Icons.table_restaurant),
                label: const Text('Book a Table'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          Consumer<RestaurantProvider>(
            builder: (context, provider, _) {
              final cuisines = ['All', ...{for (final r in provider.restaurants) ...r.categories}];
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cuisines.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cuisine = cuisines[index];
                    final isSelected = _selectedCuisine == cuisine;
                    return ChoiceChip(
                      label: Text(cuisine),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCuisine = cuisine),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Consumer<RestaurantProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = provider.restaurants.where((r) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      r.name.toLowerCase().contains(_searchQuery) ||
                      r.categories.any((c) => c.toLowerCase().contains(_searchQuery));
                  final matchesCuisine = _selectedCuisine == 'All' ||
                      r.categories.contains(_selectedCuisine);
                  return matchesSearch && matchesCuisine;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No restaurants found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final restaurant = filtered[index];
                    return _RestaurantCard(
                      restaurant: restaurant,
                      onOrderTap: () => _showOrderOptions(context, restaurant),
                      onTap: () => context.push('/restaurant/${restaurant.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DELIVERY DETAILS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryDetailsScreen extends StatefulWidget {
  final Restaurant restaurant;
  const _DeliveryDetailsScreen({required this.restaurant});

  @override
  State<_DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<_DeliveryDetailsScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _houseCtrl   = TextEditingController();
  final _areaCtrl    = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _noteCtrl    = TextEditingController();

  String _addressType   = 'Home';
  String _paymentMethod = 'Cash on Delivery';
  bool   _isLoading     = false;

  double get _minOrder => widget.restaurant.minOrder;
  double get _deliveryFee => widget.restaurant.deliveryFee;
  double get _total => _minOrder + _deliveryFee;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _houseCtrl,
                     _areaCtrl, _cityCtrl, _pincodeCtrl, _noteCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _isLoading = true);

    final address = DeliveryAddress(
      label: _addressType,
      fullAddress:
          '${_houseCtrl.text.trim()}, ${_areaCtrl.text.trim()}, '
          '${_cityCtrl.text.trim()} - ${_pincodeCtrl.text.trim()}',
    );

    // ✅ FIX: Backend API call hata diya (ApiService.placeOrder fail ho raha tha
    // kyunki yeh demo/mock app hai, real backend nahi hai). Ab seedha local
    // Order object banate hain — jaisa rides/hotels/flights screens karte hain.
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final paymentMethodEnum = _paymentMethod == 'Cash on Delivery'
        ? PaymentMethod.cash
        : _paymentMethod == 'UPI'
            ? PaymentMethod.upi
            : PaymentMethod.card;

    final order = Order(
      id: orderId,
      restaurantId: widget.restaurant.id,
      restaurantName: widget.restaurant.name,
      restaurantImage: widget.restaurant.imageUrl,
      items: [
        OrderItemModel(
          id: widget.restaurant.id,
          name: 'Order from ${widget.restaurant.name}',
          imageUrl: widget.restaurant.imageUrl,
          quantity: 1,
          price: _minOrder,
        ),
      ],
      subtotal: _minOrder,
      deliveryFee: _deliveryFee,
      discount: 0,
      total: _total,
      status: OrderStatus.confirmed,
      deliveryAddress: address,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 40)),
      paymentMethod: paymentMethodEnum,
      paymentStatus: paymentMethodEnum == PaymentMethod.cash
          ? PaymentStatus.pending
          : PaymentStatus.paid,
      otp: (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString(),
    );

    // OrderProvider ki local list mein bhi add karo (taaki Orders screen / tracking kaam kare)
    context.read<OrderProvider>().addLocalOrder(order);

    // ── Saved tab mein save karo ──────────────────────────────
    final isGrocery = widget.restaurant.id == 'grocery';
    await HistoryService.instance.saveItem(
      isGrocery
          ? HistoryService.makeGrocery(
              id: order.id,
              storeName: widget.restaurant.name,
              items: ['Order from ${widget.restaurant.name}'],
              amount: order.total,
              status: HistoryStatus.confirmed,
            )
          : HistoryService.makeFood(
              id: order.id,
              restaurant: widget.restaurant.name,
              location: _cityCtrl.text.trim(),
              items: ['Order from ${widget.restaurant.name}'],
              amount: order.total,
              status: HistoryStatus.confirmed,
              restaurantId: widget.restaurant.id,
            ),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => _OrderConfirmedScreen(
        order: order,
        customerName: _nameCtrl.text.trim(),
        paymentMethod: _paymentMethod,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Delivery Details',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          children: [

            // ── Restaurant badge ─────────────────────────────────────
            _Card(child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(widget.restaurant.imageUrl,
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 56, height: 56,
                        color: AppColors.divider,
                        child: const Icon(Icons.restaurant, color: AppColors.textHint))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(widget.restaurant.categories.join(' · '),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${widget.restaurant.deliveryTime} mins delivery',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ])),
            ])),
            const SizedBox(height: 16),

            // ── Personal Details ─────────────────────────────────────
            const _Label('👤  Personal Details'),
            _Card(child: Column(children: [
              _F(ctrl: _nameCtrl, label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
              _div(),
              _F(ctrl: _phoneCtrl, label: 'Phone Number',
                  icon: Icons.phone_outlined, type: TextInputType.phone,
                  fmt: [FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10)],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                    return null;
                  }),
              _div(),
              _F(ctrl: _emailCtrl, label: 'Email (optional)',
                  icon: Icons.email_outlined, type: TextInputType.emailAddress),
            ])),
            const SizedBox(height: 16),

            // ── Delivery Address ─────────────────────────────────────
            const _Label('📍  Delivery Address'),
            _Card(child: Column(children: [
              Row(children: ['Home', 'Work', 'Other'].map((t) {
                final sel = _addressType == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _addressType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border,
                            width: sel ? 1.5 : 1),
                      ),
                      child: Text(
                        t == 'Home' ? '🏠 Home' : t == 'Work' ? '💼 Work' : '📍 Other',
                        style: TextStyle(fontSize: 12,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? AppColors.primary : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 14),
              _F(ctrl: _houseCtrl, label: 'House / Flat / Building No.',
                  icon: Icons.home_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              _div(),
              _F(ctrl: _areaCtrl, label: 'Area / Street / Locality',
                  icon: Icons.location_city_outlined, maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              _div(),
              Row(children: [
                Expanded(child: _F(ctrl: _cityCtrl, label: 'City',
                    icon: Icons.location_on_outlined, noBorder: true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
                Container(width: 1, height: 50, color: AppColors.border),
                Expanded(child: _F(ctrl: _pincodeCtrl, label: 'Pincode',
                    icon: Icons.pin_drop_outlined,
                    type: TextInputType.number, noBorder: true,
                    fmt: [FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6)],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length != 6) return '6 digits';
                      return null;
                    })),
              ]),
              _div(),
              _F(ctrl: _noteCtrl, label: 'Delivery Note (optional)',
                  icon: Icons.note_outlined, maxLines: 2),
            ])),
            const SizedBox(height: 16),

            // ── Payment Method ───────────────────────────────────────
            const _Label('💳  Payment Method'),
            _Card(child: Column(
              children: ['Cash on Delivery', 'UPI', 'Credit / Debit Card']
                  .map((m) => RadioListTile<String>(
                        dense: true,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        title: Text(m, style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                        value: m,
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v!),
                      ))
                  .toList(),
            )),
            const SizedBox(height: 16),

            // ── Bill Summary ─────────────────────────────────────────
            const _Label('🧾  Bill Summary'),
            _Card(child: Column(children: [
              _row('Min Order', '₹${_minOrder.toStringAsFixed(0)}'),
              const SizedBox(height: 6),
              _row('Delivery Fee',
                  _deliveryFee == 0 ? 'FREE' : '₹${_deliveryFee.toStringAsFixed(0)}',
                  valueColor: _deliveryFee == 0 ? AppColors.success : null),
              const Divider(height: 20),
              _row('Total', '₹${_total.toStringAsFixed(0)}',
                  bold: true, large: true),
            ])),
          ],
        ),
      ),

      // ── Sticky bottom button ─────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12, offset: const Offset(0, -3))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total', style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
              Text('₹${_total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.black87),
                        SizedBox(width: 8),
                        Text('Confirm Order',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                                color: Colors.black87)),
                      ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _div() => const Divider(height: 1, thickness: 0.5, color: AppColors.border);

  Widget _row(String label, String value,
      {bool bold = false, bool large = false, Color? valueColor}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(
            fontSize: large ? 15 : 13, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(
            fontSize: large ? 17 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary)),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ORDER CONFIRMED SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _OrderConfirmedScreen extends StatefulWidget {
  final Order order;
  final String customerName;
  final String paymentMethod;

  const _OrderConfirmedScreen({
    required this.order,
    required this.customerName,
    required this.paymentMethod,
  });

  @override
  State<_OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<_OrderConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E7D32);
    final o = widget.order;
    final firstName = widget.customerName.isEmpty
        ? 'there'
        : widget.customerName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(children: [
              const Spacer(),

              // Animated check
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: green, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: green.withValues(alpha: 0.3),
                        blurRadius: 20, spreadRadius: 4)],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 62),
                ),
              ),
              const SizedBox(height: 24),
              Text('Order Confirmed! 🎉',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                      color: Colors.grey[900])),
              const SizedBox(height: 8),
              Text('Thank you, $firstName!\nYour order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 28),

              // Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  _infoRow('Order ID',
                      '#${o.id.substring(o.id.length > 6 ? o.id.length - 6 : 0)}'),
                  const Divider(height: 20),
                  _infoRow('Restaurant', o.restaurantName),
                  const SizedBox(height: 10),
                  _infoRow('Total', '₹${o.total.toStringAsFixed(0)}', bold: true),
                  const SizedBox(height: 10),
                  _infoRow('Payment', widget.paymentMethod),
                  const SizedBox(height: 10),
                  _infoRow('Deliver To', o.deliveryAddress.fullAddress, multiLine: true),
                ]),
              ),
              const SizedBox(height: 16),

              // ETA banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: Row(children: [
                  const Icon(Icons.delivery_dining_rounded,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Estimated Delivery',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(o.estimatedDelivery != null
                        ? '${o.estimatedDelivery!.hour.toString().padLeft(2, '0')}:${o.estimatedDelivery!.minute.toString().padLeft(2, '0')}'
                        : '30 – 40 minutes',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              // Cancel order button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context, o.id),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                  label: const Text('Cancel Order',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 10),
            ]),
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OrderProvider>().updateStatus(
                  orderId, OrderStatus.cancelled);
              Navigator.pop(context);
              Navigator.of(context).popUntil((r) => r.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Order has been cancelled'),
                backgroundColor: AppColors.error,
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {bool bold = false, bool multiLine = false}) =>
      Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500))),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: child);
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800,
            fontSize: 13, color: AppColors.textSecondary, letterSpacing: 0.3)));
}

class _F extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType type;
  final List<TextInputFormatter>? fmt;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool noBorder;

  const _F({required this.ctrl, required this.label, required this.icon,
      this.type = TextInputType.text, this.fmt, this.maxLines = 1,
      this.validator, this.noBorder = false});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl, keyboardType: type,
        inputFormatters: fmt, maxLines: maxLines, validator: validator,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
          border: InputBorder.none, enabledBorder: InputBorder.none,
          focusedBorder: noBorder ? InputBorder.none
              : UnderlineInputBorder(borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)),
          errorBorder: InputBorder.none, focusedErrorBorder: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 10, color: AppColors.error),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        ));
}

// ─────────────────────────────────────────────────────────────────────────────
//  RESTAURANT CARD  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onOrderTap;

  const _RestaurantCard({
    required this.restaurant,
    required this.onTap,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              restaurant.imageUrl,
              height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  height: 180, color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, size: 48)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(restaurant.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  Row(children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ]),
                const SizedBox(height: 4),
                Text(restaurant.categories.join(' • '),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${restaurant.deliveryTime} mins',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.currency_rupee, size: 14, color: Colors.grey[500]),
                  Text('Min ₹${restaurant.minOrder.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOrderTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Order Now'),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
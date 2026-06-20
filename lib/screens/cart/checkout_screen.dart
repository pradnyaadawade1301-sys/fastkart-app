// lib/screens/cart/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  String _payment = 'UPI';
  bool _placing = false;
  int _step = 0; // 0=info, 1=payment, 2=confirm

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text    = user.name;
      _phoneCtrl.text   = user.phone;
      _addressCtrl.text = user.defaultAddress;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  // ── Order Placement ───────────────────────────────────────────────────────

  Future<void> _placeOrder(CartProvider cart) async {
    if (_payment != 'COD') {
      // Online payment: mock processing dikhao
      setState(() => _placing = true);
      await Future.delayed(const Duration(seconds: 2)); // simulate payment
      if (!mounted) return;
    }
    await _finalizeOrder(cart);
  }

  Future<void> _finalizeOrder(CartProvider cart) async {
    if (!mounted) return;
    setState(() => _placing = true);

    final fullAddress = '${_addressCtrl.text}, ${_cityCtrl.text} - ${_pincodeCtrl.text}';

    final orderItems = cart.items.map((ci) => OrderItemModel(
      id: ci.food.id,
      name: ci.food.name,
      imageUrl: ci.food.imageUrl,
      quantity: ci.quantity,
      price: ci.food.price,
    )).toList();

    PaymentMethod pm = PaymentMethod.cash;
    if (_payment == 'UPI')        pm = PaymentMethod.upi;
    if (_payment == 'Wallet')     pm = PaymentMethod.wallet;
    if (_payment == 'Card')       pm = PaymentMethod.card;
    if (_payment == 'NetBanking') pm = PaymentMethod.card;

    Order? order;
    try {
      order = await context.read<OrderProvider>().placeOrder(
        restaurantId:    cart.restaurantId ?? '',
        restaurantName:  cart.restaurantName ?? 'Restaurant',
        restaurantImage: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop',
        items:           orderItems,
        subtotal:        cart.subtotal,
        deliveryFee:     cart.deliveryFee,
        discount:        cart.discount,
        total:           cart.total,
        deliveryAddress: DeliveryAddress(label: 'Home', fullAddress: fullAddress),
        paymentMethod:   pm,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _placing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order place nahi hua: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    cart.clear();
    if (!mounted) return;
    setState(() => _placing = false);

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Backend offline — order locally saved'),
          backgroundColor: AppColors.accent,
        ),
      );
      context.go('/orders');
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          const Text('Order Placed! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Order #${(order?.id ?? '').length > 6 ? (order?.id ?? '').substring((order?.id ?? '').length - 6) : (order?.id ?? '')}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text('Paid via $_payment',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/tracking/${order!.id}');
              },
              child: const Text('Track Order',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Back to Home'),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(children: [
        // Step indicator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          child: Row(children: List.generate(3, (i) {
            final labels = ['Delivery Info', 'Payment', 'Confirm'];
            final icons  = [Icons.person_rounded, Icons.payment_rounded, Icons.check_circle_rounded];
            final done   = i < _step;
            final active = i == _step;
            return Expanded(child: Row(children: [
              Expanded(child: Column(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: done ? AppColors.success : active ? AppColors.primary : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(done ? Icons.check_rounded : icons[i],
                      size: 18, color: (done || active) ? Colors.white : Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: active ? AppColors.primary : done ? AppColors.success : Colors.grey)),
              ])),
              if (i < 2)
                Expanded(child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: done ? AppColors.success : Colors.grey.shade200)),
            ]));
          })),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: _step == 0 ? _deliveryStep()
                  : _step == 1 ? _paymentStep(cart)
                  : _confirmStep(cart),
            ),
          ),
        ),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          color: Colors.white,
          child: Row(children: [
            if (_step > 0)
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
            if (_step > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _placing ? null : () => _handleNext(cart),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _placing
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black54))
                    : Text(
                        _step == 0 ? 'Continue to Payment'
                            : _step == 1 ? 'Review Order'
                            : _payment == 'COD'
                                ? 'Place Order (COD) · ₹${cart.total.toStringAsFixed(0)}'
                                : 'Pay ₹${cart.total.toStringAsFixed(0)} via $_payment',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _handleNext(CartProvider cart) {
    if (_step == 0) {
      if (_formKey.currentState?.validate() ?? false) setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 2);
    } else {
      _placeOrder(cart);
    }
  }

  // ── Step 0: Delivery Info ─────────────────────────────────────────────────
  Widget _deliveryStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Personal Information', Icons.person_rounded),
      const SizedBox(height: 12),
      _card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _field(_nameCtrl, 'Full Name', Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? 'Enter your name' : null),
          const SizedBox(height: 14),
          _field(_phoneCtrl, 'Mobile Number', Icons.phone_rounded,
              type: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Enter mobile number' : null),
        ]),
      )),
      const SizedBox(height: 16),
      _sectionTitle('Delivery Address', Icons.location_on_rounded),
      const SizedBox(height: 12),
      _card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _field(_addressCtrl, 'House / Flat / Building', Icons.home_rounded,
              validator: (v) => v!.isEmpty ? 'Enter address' : null),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _field(_cityCtrl, 'City', Icons.location_city_rounded,
                validator: (v) => v!.isEmpty ? 'Enter city' : null)),
            const SizedBox(width: 12),
            Expanded(child: _field(_pincodeCtrl, 'Pincode', Icons.pin_drop_rounded,
                type: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter pincode' : null)),
          ]),
        ]),
      )),
    ]);
  }

  // ── Step 1: Payment ───────────────────────────────────────────────────────
  Widget _paymentStep(CartProvider cart) {
    final methods = [
      {'id': 'UPI',        'title': 'UPI Payment',          'sub': 'GPay, PhonePe, Paytm',   'icon': Icons.account_balance_rounded,        'color': 0xFF4CAF50},
      {'id': 'Card',       'title': 'Credit / Debit Card',  'sub': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card_rounded,            'color': 0xFF2196F3},
      {'id': 'Wallet',     'title': 'FastKart Wallet',      'sub': 'Balance: ₹0',             'icon': Icons.account_balance_wallet_rounded, 'color': 0xFF9C27B0},
      {'id': 'NetBanking', 'title': 'Net Banking',          'sub': 'All major banks',         'icon': Icons.account_balance_outlined,       'color': 0xFFFF9800},
      {'id': 'COD',        'title': 'Cash on Delivery',     'sub': 'Pay when order arrives',  'icon': Icons.money_rounded,                  'color': 0xFF795548},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Select Payment Method', Icons.payment_rounded),
      const SizedBox(height: 12),
      ...methods.map((m) {
        final selected = _payment == m['id'];
        return GestureDetector(
          onTap: () => setState(() => _payment = m['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Color(m['color'] as int).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(m['icon'] as IconData, color: Color(m['color'] as int), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m['title'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(m['sub'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
            ]),
          ),
        );
      }),
      const SizedBox(height: 16),
      _sectionTitle('Price Summary', Icons.receipt_rounded),
      const SizedBox(height: 12),
      _card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _summaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(0)}'),
          _summaryRow('Delivery Fee',
              cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(0)}',
              valueColor: cart.deliveryFee == 0 ? AppColors.success : null),
          if (cart.discount > 0)
            _summaryRow('Discount', '-₹${cart.discount.toStringAsFixed(0)}', valueColor: AppColors.success),
          const Divider(height: 20),
          _summaryRow('Total Amount', '₹${cart.total.toStringAsFixed(0)}', bold: true, large: true),
        ]),
      )),
    ]);
  }

  // ── Step 2: Confirm ───────────────────────────────────────────────────────
  Widget _confirmStep(CartProvider cart) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
          SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Review your order',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success)),
            Text('Please verify all details before placing',
                style: TextStyle(fontSize: 11, color: AppColors.success)),
          ])),
        ]),
      ),
      const SizedBox(height: 16),

      _sectionTitle('Delivery Details', Icons.location_on_rounded),
      const SizedBox(height: 8),
      _card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _confirmRow(Icons.person_rounded, 'Name', _nameCtrl.text),
          _confirmRow(Icons.phone_rounded,  'Mobile', _phoneCtrl.text),
          _confirmRow(Icons.home_rounded,   'Address',
              '${_addressCtrl.text}, ${_cityCtrl.text} - ${_pincodeCtrl.text}'),
        ]),
      )),

      const SizedBox(height: 16),
      _sectionTitle('Order Items', Icons.restaurant_rounded),
      const SizedBox(height: 8),
      _card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.food.imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 48, height: 48,
                        color: AppColors.divider,
                        child: const Icon(Icons.fastfood, size: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.food.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('Qty: ${item.quantity}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Text('₹${item.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ]),
          )),
        ]),
      )),

      const SizedBox(height: 16),
      _sectionTitle('Payment & Total', Icons.payment_rounded),
      const SizedBox(height: 8),
      _card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _confirmRow(Icons.payment_rounded, 'Payment', _payment),
          const Divider(height: 20),
          _summaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(0)}'),
          _summaryRow('Delivery Fee',
              cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toStringAsFixed(0)}',
              valueColor: cart.deliveryFee == 0 ? AppColors.success : null),
          if (cart.discount > 0)
            _summaryRow('Discount', '-₹${cart.discount.toStringAsFixed(0)}', valueColor: AppColors.success),
          const Divider(height: 16),
          _summaryRow('Total Amount', '₹${cart.total.toStringAsFixed(0)}', bold: true, large: true),
        ]),
      )),

      const SizedBox(height: 16),
      GestureDetector(
        onTap: _showCancelDialog,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
            SizedBox(width: 8),
            Text('Cancel Order',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
      ),
      const SizedBox(height: 8),
    ]);
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to cancel? Your cart items will be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Continue')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); context.pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
  ]);

  Widget _card({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
    ),
    child: child,
  );

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _confirmRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Expanded(child: Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          maxLines: 2, overflow: TextOverflow.ellipsis)),
    ]),
  );

  Widget _summaryRow(String label, String value,
      {Color? valueColor, bool bold = false, bool large = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontSize: large ? 15 : 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(
              fontSize: large ? 17 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary)),
        ]),
      );
}
// lib/screens/payment/payment_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  const PaymentScreen({super.key, required this.amount, required this.orderId});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selected = 'upi';
  String _selectedUpi = 'gpay';
  bool _isProcessing = false;
  bool _success = false;
  final _upiCtrl = TextEditingController();

  final List<Map<String, dynamic>> _savedCards = [
    {'last4': '4242', 'brand': 'Visa', 'expiry': '12/26', 'icon': '💳'},
    {'last4': '8765', 'brand': 'Mastercard', 'expiry': '08/25', 'icon': '💳'},
  ];

  final List<Map<String, String>> _upiApps = [
    {'id': 'gpay', 'name': 'Google Pay', 'icon': '🟢'},
    {'id': 'phonepe', 'name': 'PhonePe', 'icon': '🟣'},
    {'id': 'paytm', 'name': 'Paytm', 'icon': '🔵'},
    {'id': 'bhim', 'name': 'BHIM', 'icon': '🟠'},
  ];

  @override
  void dispose() { _upiCtrl.dispose(); super.dispose(); }

  void _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isProcessing = false; _success = true; });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessView(amount: widget.amount, orderId: widget.orderId);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(children: [
        ListView(padding: const EdgeInsets.all(16), children: [
          // Amount card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('₹${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('Order #${widget.orderId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 20),

          // Wallet option
          _Section(title: 'FastKart Wallet', children: [
            _PayTile(
              icon: '💰', title: 'Wallet Balance', subtitle: 'Available: ₹450',
              selected: _selected == 'wallet',
              onTap: () => setState(() => _selected = 'wallet'),
              trailing: widget.amount > 450
                  ? const Text('Insufficient', style: TextStyle(color: Colors.red, fontSize: 11))
                  : null,
            ),
          ]),
          const SizedBox(height: 12),

          // UPI
          _Section(title: 'UPI', children: [
            ..._upiApps.map((u) => _PayTile(
              icon: u['icon']!, title: u['name']!, subtitle: 'Pay via ${u['name']}',
              selected: _selected == 'upi' && _selectedUpi == u['id'],
              onTap: () => setState(() { _selected = 'upi'; _selectedUpi = u['id']!; }),
            )),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _upiCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter UPI ID (e.g. name@upi)',
                  prefixIcon: const Icon(Icons.account_balance_rounded, size: 18),
                  filled: true, fillColor: const Color(0xFFF2F2F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                onTap: () => setState(() { _selected = 'upi_id'; _selectedUpi = 'custom'; }),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Cards
          _Section(title: 'Saved Cards', children: [
            ..._savedCards.map((c) => _PayTile(
              icon: c['icon'], title: '${c['brand']} •••• ${c['last4']}',
              subtitle: 'Expires ${c['expiry']}',
              selected: _selected == 'card_${c['last4']}',
              onTap: () => setState(() => _selected = 'card_${c['last4']}'),
            )),
            ListTile(
              onTap: () {},
              leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, color: AppColors.primary)),
              title: const Text('Add New Card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 12),

          // Net Banking / COD
          _Section(title: 'Other Options', children: [
            _PayTile(icon: '🏦', title: 'Net Banking', subtitle: 'All major banks supported',
                selected: _selected == 'netbanking', onTap: () => setState(() => _selected = 'netbanking')),
            _PayTile(icon: '💵', title: 'Cash on Delivery', subtitle: 'Pay when order arrives',
                selected: _selected == 'cod', onTap: () => setState(() => _selected = 'cod')),
          ]),
          const SizedBox(height: 100),
        ]),

        // Pay button
        Positioned(left: 16, right: 16, bottom: 20,
          child: SafeArea(
            top: false,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: _isProcessing
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                  : Text('Pay ₹${widget.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
      ),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Column(children: children),
      ),
    ]);
  }
}

class _PayTile extends StatelessWidget {
  final String icon, title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;
  const _PayTile({required this.icon, required this.title, required this.subtitle,
      required this.selected, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 40, height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF2F2F7),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: trailing ?? Radio<bool>(
        value: true, groupValue: selected,
        onChanged: (_) => onTap(),
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _SuccessView extends StatefulWidget {
  final double amount;
  final String orderId;
  const _SuccessView({required this.amount, required this.orderId});
  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _anim.forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ScaleTransition(scale: _scale,
          child: Container(width: 100, height: 100,
            decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 56))),
        const SizedBox(height: 24),
        const Text('Payment Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('₹${widget.amount.toStringAsFixed(0)} paid',
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('Order #${widget.orderId}', style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
        const SizedBox(height: 32),
        const Text('Redirecting to your orders...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ])),
    );
  }
}
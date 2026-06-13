// lib/screens/profile/vouchers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class _Voucher {
  final String code, title, description, expiry, category;
  final int discount;
  final bool isPercent, isUsed;
  final Color color;
  _Voucher({required this.code, required this.title, required this.description,
      required this.expiry, required this.category, required this.discount,
      this.isPercent = true, this.isUsed = false, required this.color});
}

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});
  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _codeCtrl = TextEditingController();

  final List<_Voucher> _vouchers = [
    _Voucher(code: 'FIRST50', title: '50% OFF', description: 'On your first order above ₹299',
        expiry: '31 Dec 2025', category: 'Food', discount: 50, color: const Color(0xFFFF6F00)),
    _Voucher(code: 'FRESH30', title: '30% OFF', description: 'On grocery orders above ₹199',
        expiry: '15 Dec 2025', category: 'Grocery', discount: 30, color: const Color(0xFF009688)),
    _Voucher(code: 'RIDE20', title: '₹20 OFF', description: 'On rides above ₹80',
        expiry: '20 Dec 2025', category: 'Rides', discount: 20, isPercent: false,
        color: const Color(0xFF2196F3)),
    _Voucher(code: 'MOVIE10', title: '10% OFF', description: 'On movie tickets',
        expiry: '25 Dec 2025', category: 'Movies', discount: 10, color: const Color(0xFFE91E63)),
    _Voucher(code: 'FLAT100', title: '₹100 OFF', description: 'On orders above ₹599',
        expiry: '10 Dec 2025', category: 'All', discount: 100, isPercent: false,
        color: const Color(0xFF7C4DFF)),
    _Voucher(code: 'USED50', title: '50% OFF', description: 'Welcome coupon',
        expiry: '01 Nov 2025', category: 'Food', discount: 50, isUsed: true,
        color: const Color(0xFF9E9E9E)),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); _codeCtrl.dispose(); super.dispose(); }

  List<_Voucher> get _active => _vouchers.where((v) => !v.isUsed).toList();
  List<_Voucher> get _used => _vouchers.where((v) => v.isUsed).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Vouchers & Coupons',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Active (${_active.length})'),
            Tab(text: 'Used (${_used.length})'),
          ],
        ),
      ),
      body: Column(children: [
        // Apply code
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  filled: true, fillColor: const Color(0xFFF2F2F7),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: const Icon(Icons.confirmation_number_rounded,
                      color: AppColors.textHint, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final code = _codeCtrl.text.trim().toUpperCase();
                final found = _vouchers.any((v) => v.code == code && !v.isUsed);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(found
                      ? '✅ Coupon "$code" applied!'
                      : '❌ Invalid or expired coupon code'),
                  backgroundColor: found ? AppColors.success : Colors.red,
                ));
                _codeCtrl.clear();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
        ),

        Expanded(
          child: TabBarView(controller: _tab, children: [
            // Active
            _active.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _active.length,
                    itemBuilder: (_, i) => _VoucherCard(voucher: _active[i]),
                  ),
            // Used
            _used.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _used.length,
                    itemBuilder: (_, i) => _VoucherCard(voucher: _used[i]),
                  ),
          ]),
        ),
      ]),
    );
  }

  Widget _emptyState() => const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('🎟️', style: TextStyle(fontSize: 56)),
    SizedBox(height: 16),
    Text('No vouchers here', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    SizedBox(height: 6),
    Text('Apply a code above to get discounts!',
        style: TextStyle(color: AppColors.textSecondary)),
  ]));
}

class _VoucherCard extends StatelessWidget {
  final _Voucher voucher;
  const _VoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final v = voucher;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: v.isUsed ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: v.isUsed ? [] : [
          BoxShadow(color: v.color.withValues(alpha: 0.15),
              blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Stack(children: [
        // Dashed separator notches
        Positioned(
          left: 90, top: 0, bottom: 0,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 14, height: 14,
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7), shape: BoxShape.circle,
                    border: Border.all(color: v.isUsed ? Colors.grey.shade300 : v.color.withValues(alpha: 0.2)))),
          ]),
        ),
        Row(children: [
          // Left - discount badge
          SizedBox(width: 90,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: v.isUsed ? Colors.grey.shade200 : v.color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${v.isPercent ? '' : '₹'}${v.discount}${v.isPercent ? '%' : ''}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                        color: v.isUsed ? AppColors.textHint : v.color)),
                Text('OFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: v.isUsed ? AppColors.textHint : v.color)),
              ]),
            ),
          ),

          // Right - details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(v.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                          color: v.isUsed ? AppColors.textHint : AppColors.textPrimary))),
                  if (!v.isUsed)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: v.code));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Code "${v.code}" copied!'),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: v.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: v.color.withValues(alpha: 0.3),
                              style: BorderStyle.solid),
                        ),
                        child: Row(children: [
                          Text(v.code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                              color: v.color)),
                          const SizedBox(width: 4),
                          Icon(Icons.copy_rounded, size: 11, color: v.color),
                        ]),
                      ),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(v.description, style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: v.isUsed ? Colors.grey.shade200 : v.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(v.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: v.isUsed ? AppColors.textHint : v.color)),
                  ),
                  const Spacer(),
                  Icon(Icons.schedule_rounded, size: 11,
                      color: v.isUsed ? AppColors.textHint : AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(v.isUsed ? 'Expired' : 'Expires ${v.expiry}',
                      style: TextStyle(fontSize: 10,
                          color: v.isUsed ? AppColors.textHint : AppColors.textSecondary)),
                ]),
              ]),
            ),
          ),
        ]),

        // Used overlay
        if (v.isUsed)
          Positioned.fill(child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              alignment: Alignment.center,
              color: Colors.white.withValues(alpha: 0.5),
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('USED', style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 3)),
                ),
              ),
            ),
          )),
      ]),
    );
  }
}
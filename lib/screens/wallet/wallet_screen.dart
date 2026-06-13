// lib/screens/wallet/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final List<Map<String, dynamic>> _transactions = [
    {'type': 'credit', 'title': 'Cashback - Punjabi Tadka', 'amount': 50.0, 'date': 'Today', 'icon': '💰'},
    {'type': 'debit', 'title': 'Order #ORD002', 'amount': -297.0, 'date': 'Today', 'icon': '🛵'},
    {'type': 'credit', 'title': 'Referral Bonus', 'amount': 100.0, 'date': 'Yesterday', 'icon': '🎁'},
    {'type': 'debit', 'title': 'Cab Ride - BKC to Andheri', 'amount': -127.0, 'date': 'Yesterday', 'icon': '🚕'},
    {'type': 'credit', 'title': 'Wallet Top-up', 'amount': 500.0, 'date': '3 days ago', 'icon': '➕'},
    {'type': 'debit', 'title': 'Movie Tickets - PVR Juhu', 'amount': -540.0, 'date': '4 days ago', 'icon': '🎬'},
    {'type': 'credit', 'title': 'Order Refund #ORD003', 'amount': 249.0, 'date': '5 days ago', 'icon': '↩️'},
  ];

  final List<int> _topupAmounts = [100, 200, 500, 1000, 2000, 5000];
  int? _selectedTopup;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('My Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [Tab(text: 'Balance & Transactions'), Tab(text: 'Add Money')],
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) => TabBarView(controller: _tab, children: [
          // Tab 1: Balance + transactions
          ListView(padding: const EdgeInsets.all(16), children: [
            // Balance card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF283593)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(children: [
                const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('₹${auth.user?.walletBalance.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _WalletAction(icon: Icons.add_rounded, label: 'Add Money',
                      onTap: () => _tab.animateTo(1)),
                  _WalletAction(icon: Icons.send_rounded, label: 'Send',
                      onTap: () {}),
                  _WalletAction(icon: Icons.history_rounded, label: 'History',
                      onTap: () {}),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // Points
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Text('🌟', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${auth.user?.points ?? 0} Reward Points',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF8F00))),
                  const Text('Worth ₹12.80 in discounts', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.w700))),
              ]),
            ),
            const SizedBox(height: 20),

            const Text('Transaction History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ..._transactions.map((t) {
              final isCredit = t['type'] == 'credit';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
                child: Row(children: [
                  Container(width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: isCredit ? AppColors.success.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(t['icon'] as String, style: const TextStyle(fontSize: 18)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(t['date'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                  Text('${isCredit ? '+' : ''}₹${(t['amount'] as double).abs().toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                          color: isCredit ? AppColors.success : Colors.red)),
                ]),
              );
            }),
          ]),

          // Tab 2: Add money
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Select Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, childAspectRatio: 2.2,
              crossAxisSpacing: 10, mainAxisSpacing: 10,
              children: _topupAmounts.map((amt) => GestureDetector(
                onTap: () => setState(() => _selectedTopup = amt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _selectedTopup == amt ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedTopup == amt ? AppColors.primary : AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                  ),
                  child: Center(child: Text('₹$amt',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          color: _selectedTopup == amt ? Colors.black87 : AppColors.textPrimary))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _selectedTopup = int.tryParse(v)),
                decoration: const InputDecoration(
                  hintText: 'Or enter custom amount',
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pay via
            const Text('Pay via', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...[
              {'icon': '🟢', 'name': 'Google Pay'},
              {'icon': '🟣', 'name': 'PhonePe'},
              {'icon': '💳', 'name': 'Debit/Credit Card'},
              {'icon': '🏦', 'name': 'Net Banking'},
            ].map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
              child: ListTile(
                leading: Text(p['icon']!, style: const TextStyle(fontSize: 24)),
                title: Text(p['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  if (_selectedTopup != null && _selectedTopup! > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('₹$_selectedTopup added to wallet via ${p['name']}!'),
                      backgroundColor: AppColors.success));
                  }
                },
              ),
            )),
            const SizedBox(height: 16),
            if (_selectedTopup != null && _selectedTopup! > 0)
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('₹$_selectedTopup added to wallet!'),
                  backgroundColor: AppColors.success)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Add ₹$_selectedTopup to Wallet',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              ),
          ]),
        ]),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _WalletAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(width: 44, height: 44,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
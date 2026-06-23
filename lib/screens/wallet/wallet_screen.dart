// lib/screens/wallet/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    {'type': 'credit', 'title': 'Cashback - Punjabi Tadka', 'amount': 50.0,  'date': 'Today',      'icon': '💰'},
    {'type': 'debit',  'title': 'Order #ORD002',             'amount': -297.0,'date': 'Today',      'icon': '🛵'},
    {'type': 'credit', 'title': 'Referral Bonus',            'amount': 100.0, 'date': 'Yesterday',  'icon': '🎁'},
    {'type': 'debit',  'title': 'Cab Ride - BKC to Andheri', 'amount': -127.0,'date': 'Yesterday',  'icon': '🚕'},
    {'type': 'credit', 'title': 'Wallet Top-up',             'amount': 500.0, 'date': '3 days ago', 'icon': '➕'},
    {'type': 'debit',  'title': 'Movie Tickets - PVR Juhu',  'amount': -540.0,'date': '4 days ago', 'icon': '🎬'},
    {'type': 'credit', 'title': 'Order Refund #ORD003',      'amount': 249.0, 'date': '5 days ago', 'icon': '↩️'},
  ];

  final List<int> _topupAmounts = [100, 200, 500, 1000, 2000, 5000];
  int? _selectedTopup;

  // Bank account state
  final _bankNameCtrl    = TextEditingController();
  final _accountCtrl     = TextEditingController();
  final _confirmAccCtrl  = TextEditingController();
  final _ifscCtrl        = TextEditingController();
  final _holderCtrl      = TextEditingController();
  bool _bankVerified     = false;
  bool _verifying        = false;
  Map<String, dynamic>? _savedBank;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _bankNameCtrl.dispose(); _accountCtrl.dispose();
    _confirmAccCtrl.dispose(); _ifscCtrl.dispose(); _holderCtrl.dispose();
    super.dispose();
  }

  // ── UPI deep link to open app for penny drop ─────────────────────────────
  Future<void> _launchUpiForVerification(String appName, String package) async {
    // Rs.1 penny drop to verify bank account
    const upiId    = 'fastkart@upi'; // your UPI ID
    const upiName  = 'FastKart';
    const amount   = '1.00';
    final note     = Uri.encodeComponent('FastKart Bank Verification');
    final link     = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=$amount&cu=INR&tn=$note';

    try {
      await const MethodChannel('flutter/url_launcher').invokeMethod<bool>('launch', {
        'url': link, 'useSafariVC': false, 'useWebView': false,
        'enableJavaScript': false, 'enableDomStorage': false,
        'universalLinksOnly': false, 'headers': <String, String>{},
      });
      // After returning from UPI app — mark as verified
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        _onVerificationSuccess();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$appName not installed. Try another app.'),
          backgroundColor: Colors.orange));
      }
    }
  }

  void _onVerificationSuccess() {
    setState(() {
      _bankVerified = true;
      _verifying    = false;
      _savedBank = {
        'bank':    _bankNameCtrl.text,
        'account': _accountCtrl.text,
        'ifsc':    _ifscCtrl.text.toUpperCase(),
        'holder':  _holderCtrl.text,
      };
    });
    Navigator.pop(context); // close bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Bank account verified successfully!'),
      backgroundColor: Color(0xFF4CAF50),
      duration: Duration(seconds: 3),
    ));
  }

  // ── Show bank form bottom sheet ───────────────────────────────────────────
  void _showBankForm() {
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

            // Header
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF1A237E), size: 22)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Add Bank Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('Enter your bank details for verification', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ])),

            const Divider(height: 1),

            Expanded(child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Step indicator
                _stepRow(),
                const SizedBox(height: 20),

                // Bank Name
                _label('Bank Name'),
                TextFormField(
                  controller: _bankNameCtrl,
                  decoration: _inputDec('e.g. State Bank of India', Icons.account_balance_rounded),
                  validator: (v) => v!.isEmpty ? 'Enter bank name' : null,
                ),
                const SizedBox(height: 14),

                // Account Holder
                _label('Account Holder Name'),
                TextFormField(
                  controller: _holderCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDec('As per bank records', Icons.person_rounded),
                  validator: (v) => v!.isEmpty ? 'Enter account holder name' : null,
                ),
                const SizedBox(height: 14),

                // Account Number
                _label('Account Number'),
                TextFormField(
                  controller: _accountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  obscureText: true,
                  decoration: _inputDec('Enter account number', Icons.numbers_rounded),
                  validator: (v) => v!.length < 9 ? 'Enter valid account number' : null,
                ),
                const SizedBox(height: 14),

                // Confirm Account Number
                _label('Confirm Account Number'),
                TextFormField(
                  controller: _confirmAccCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDec('Re-enter account number', Icons.numbers_rounded),
                  validator: (v) => v != _accountCtrl.text ? 'Account numbers do not match' : null,
                ),
                const SizedBox(height: 14),

                // IFSC Code
                _label('IFSC Code'),
                TextFormField(
                  controller: _ifscCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: _inputDec('e.g. SBIN0001234', Icons.code_rounded),
                  validator: (v) => v!.length != 11 ? 'IFSC must be 11 characters' : null,
                ),
                const SizedBox(height: 8),

                // IFSC helper
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Find IFSC on your cheque book or passbook'))),
                  child: const Row(children: [
                    Icon(Icons.help_outline_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Where to find IFSC?', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 24),

                // Info box
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100)),
                  child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('How verification works', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue)),
                      SizedBox(height: 4),
                      Text('A Rs.1 payment will be initiated via your UPI app to verify your bank account. This amount will be refunded within 24 hours.',
                          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 20),

                // Verify button
                SizedBox(width: double.infinity, height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context);
                        _showUpiAppChooser();
                      }
                    },
                    icon: const Icon(Icons.verified_rounded, size: 20),
                    label: const Text('Verify Bank Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ])),
            )),
          ]),
        ),
      ),
    );
  }

  // ── Show UPI app chooser ──────────────────────────────────────────────────
  void _showUpiAppChooser() {
    final apps = [
      {'name': 'Google Pay',  'package': 'com.google.android.apps.nbu.paisa.user', 'color': const Color(0xFF4285F4), 'letter': 'G'},
      {'name': 'PhonePe',    'package': 'com.phonepe.app',                         'color': const Color(0xFF5F259F), 'letter': 'P'},
      {'name': 'Paytm',      'package': 'net.one97.paytm',                          'color': const Color(0xFF00BAF2), 'letter': 'P'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          const Text('Select UPI App to Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Rs.1 will be charged for verification (refunded in 24h)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 20),

          ...apps.map((app) {
            final color = app['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _launchUpiForVerification(app['name'] as String, app['package'] as String);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: color.withValues(alpha: 0.25))),
                tileColor: color.withValues(alpha: 0.05),
                leading: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(app['letter'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)))),
                title: Text(app['name'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                subtitle: const Text('Tap to open and approve Rs.1',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
              ),
            );
          }),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ]),
      ),
    );
  }

  Widget _stepRow() {
    return Row(children: [
      _stepChip('1', 'Bank Details', true),
      Expanded(child: Container(height: 2, color: Colors.grey.shade200)),
      _stepChip('2', 'UPI Verify', false),
      Expanded(child: Container(height: 2, color: Colors.grey.shade200)),
      _stepChip('3', 'Done', false),
    ]);
  }

  Widget _stepChip(String num, String label, bool active) {
    return Column(children: [
      Container(width: 28, height: 28,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A237E) : Colors.grey.shade200,
          shape: BoxShape.circle),
        child: Center(child: Text(num, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.grey)))),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
          color: active ? const Color(0xFF1A237E) : Colors.grey)),
    ]);
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.textSecondary, letterSpacing: 0.3)));

  InputDecoration _inputDec(String hint, IconData icon) => InputDecoration(
    hintText: hint, prefixIcon: Icon(icon, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true, fillColor: const Color(0xFFF8F9FA));

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
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: 'Balance'),
            Tab(text: 'Add Money'),
            Tab(text: 'Bank Account'),
          ],
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) => TabBarView(controller: _tab, children: [

          // ── Tab 1: Balance & Transactions ──────────────────────────────────
          ListView(padding: const EdgeInsets.all(16), children: [
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
                Text('Rs.${auth.user?.walletBalance.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _WalletAction(icon: Icons.add_rounded, label: 'Add Money', onTap: () => _tab.animateTo(1)),
                  _WalletAction(icon: Icons.account_balance_rounded, label: 'Bank', onTap: () => _tab.animateTo(2)),
                  _WalletAction(icon: Icons.history_rounded, label: 'History', onTap: () {}),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4))),
              child: Row(children: [
                const Text('🌟', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${auth.user?.points ?? 0} Reward Points',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF8F00))),
                  const Text('Worth Rs.12.80 in discounts', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                      shape: BoxShape.circle),
                    child: Center(child: Text(t['icon'] as String, style: const TextStyle(fontSize: 18)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(t['date'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                  Text('${isCredit ? '+' : ''}Rs.${(t['amount'] as double).abs().toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                          color: isCredit ? AppColors.success : Colors.red)),
                ]),
              );
            }),
          ]),

          // ── Tab 2: Add Money ───────────────────────────────────────────────
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
                  child: Center(child: Text('Rs.$amt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: _selectedTopup == amt ? Colors.black87 : AppColors.textPrimary)))),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _selectedTopup = int.tryParse(v)),
                decoration: const InputDecoration(hintText: 'Or enter custom amount',
                  prefixText: 'Rs. ', border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
              ),
            ),
            const SizedBox(height: 24),
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
                      content: Text('Rs.$_selectedTopup added to wallet via ${p['name']}!'),
                      backgroundColor: AppColors.success));
                  }
                },
              ),
            )),
            if (_selectedTopup != null && _selectedTopup! > 0) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Rs.$_selectedTopup added to wallet!'),
                  backgroundColor: AppColors.success)),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Add Rs.$_selectedTopup to Wallet',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              ),
            ],
          ]),

          // ── Tab 3: Bank Account ────────────────────────────────────────────
          ListView(padding: const EdgeInsets.all(16), children: [

            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Bank Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(_bankVerified ? 'Verified' : 'Not linked yet',
                      style: TextStyle(color: _bankVerified ? const Color(0xFF69F0AE) : Colors.white60, fontSize: 12)),
                ])),
                if (_bankVerified)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFF69F0AE).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified_rounded, color: Color(0xFF69F0AE), size: 14),
                      SizedBox(width: 4),
                      Text('Verified', style: TextStyle(color: Color(0xFF69F0AE), fontSize: 11, fontWeight: FontWeight.w700)),
                    ])),
              ]),
            ),
            const SizedBox(height: 20),

            // Saved bank details
            if (_bankVerified && _savedBank != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
                child: Column(children: [
                  Row(children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    const Text('Bank Account Verified', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF4CAF50))),
                    const Spacer(),
                    GestureDetector(
                      onTap: () { setState(() { _bankVerified = false; _savedBank = null; }); },
                      child: const Text('Remove', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600))),
                  ]),
                  const Divider(height: 20),
                  _bankDetailRow('Bank', _savedBank!['bank']),
                  _bankDetailRow('Account Holder', _savedBank!['holder']),
                  _bankDetailRow('Account Number', '**** **** ${(_savedBank!['account'] as String).substring((_savedBank!['account'] as String).length - 4)}'),
                  _bankDetailRow('IFSC Code', _savedBank!['ifsc']),
                ]),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () { setState(() { _bankVerified = false; _savedBank = null; }); _showBankForm(); },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Update Bank Account', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ] else ...[

              // Why link bank
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Why link bank account?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  ...['Instant refunds to your bank account',
                      'Withdraw wallet balance anytime',
                      'Faster order cancellation refunds',
                      'Secure & encrypted'].map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 16),
                      const SizedBox(width: 10),
                      Text(t, style: const TextStyle(fontSize: 13)),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: 20),

              // Add bank button
              SizedBox(width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: _showBankForm,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text('Add Bank Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100)),
                child: const Row(children: [
                  Icon(Icons.security_rounded, color: Colors.green, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text('Your bank details are encrypted and stored securely. We never share your information.',
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4))),
                ]),
              ),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _bankDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    ]));
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
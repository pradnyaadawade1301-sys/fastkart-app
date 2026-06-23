// lib/widgets/payment_sheet.dart
// Shared payment bottom sheet — COD + UPI only
// Use: showPaymentBottomSheet(context, amount: total, onCOD: ..., onUPI: ...)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _upiId   = 'fastkart@upi'; // ← apna UPI ID yahan daalo
const String _upiName = 'FastKart';

Future<void> launchUpi(double amount) async {
  final link = 'upi://pay?pa=$_upiId'
      '&pn=${Uri.encodeComponent(_upiName)}'
      '&am=${amount.toStringAsFixed(2)}'
      '&cu=INR'
      '&tn=${Uri.encodeComponent("FastKart Payment")}';
  try {
    await const MethodChannel('flutter/url_launcher').invokeMethod<bool>('launch', {
      'url': link, 'useSafariVC': false, 'useWebView': false,
      'enableJavaScript': false, 'enableDomStorage': false,
      'universalLinksOnly': false, 'headers': <String, String>{},
    });
  } catch (_) {
    await Clipboard.setData(const ClipboardData(text: _upiId));
  }
}

/// Shows bottom sheet with COD + UPI options.
/// [onConfirm] called with 'COD' or 'UPI' when user taps confirm.
Future<String?> showPaymentBottomSheet(
  BuildContext context, {
  required double amount,
  required void Function(String method) onConfirm,
  String title = 'Select Payment',
}) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PaymentSheet(amount: amount, onConfirm: onConfirm, title: title),
  );
}

class _PaymentSheet extends StatefulWidget {
  final double amount;
  final void Function(String) onConfirm;
  final String title;
  const _PaymentSheet({required this.amount, required this.onConfirm, required this.title});
  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String _selected = 'COD';

  static const _primary = Color(0xFFFF6F00);

  final _upiApps = const [
    {'name': 'GPay',    'color': Color(0xFF4285F4)},
    {'name': 'PhonePe', 'color': Color(0xFF5F259F)},
    {'name': 'Paytm',   'color': Color(0xFF00BAF2)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

        Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Rs.${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _primary)),
        const SizedBox(height: 20),

        // COD option
        _option(
          id: 'COD',
          icon: Icons.money_rounded,
          color: const Color(0xFF795548),
          title: 'Cash on Delivery',
          subtitle: 'Pay when order arrives',
        ),
        const SizedBox(height: 10),

        // UPI option
        _option(
          id: 'UPI',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF4CAF50),
          title: 'UPI Payment',
          subtitle: 'GPay, PhonePe, Paytm',
        ),

        // UPI app buttons — show when UPI selected
        if (_selected == 'UPI') ...[
          const SizedBox(height: 16),
          Row(children: _upiApps.map((app) {
            final color = app['color'] as Color;
            final name  = app['name'] as String;
            return Expanded(child: GestureDetector(
              onTap: () => launchUpi(widget.amount),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3))),
                child: Column(children: [
                  Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(name[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)))),
                  const SizedBox(height: 6),
                  Text(name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                ]),
              ),
            ));
          }).toList()),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => launchUpi(widget.amount),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Open Any UPI App', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)), minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(height: 10),
          // Copy UPI ID
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: _upiId));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('UPI ID copied!'),
                backgroundColor: Color(0xFF4CAF50), duration: Duration(seconds: 2)));
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.copy_rounded, size: 15, color: _primary),
                SizedBox(width: 8),
                Expanded(child: Text(_upiId, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                Text('Copy', style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200)),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Colors.amber),
              SizedBox(width: 8),
              Expanded(child: Text('Pay in UPI app, then come back and tap Confirm.',
                  style: TextStyle(fontSize: 11, color: Colors.black87))),
            ])),
        ],

        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onConfirm(_selected);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text(
              _selected == 'COD' ? 'Confirm (Pay on Delivery)' : 'Confirm (Paid via UPI)',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          )),
      ]),
    );
  }

  Widget _option({required String id, required IconData icon, required Color color,
      required String title, required String subtitle}) {
    final sel = _selected == id;
    return GestureDetector(
      onTap: () => setState(() => _selected = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? _primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? _primary : Colors.grey.shade300, width: sel ? 2 : 1)),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
          if (sel) const Icon(Icons.check_circle_rounded, color: _primary, size: 22),
        ]),
      ),
    );
  }
}

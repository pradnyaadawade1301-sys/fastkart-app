// lib/screens/profile/payment_methods_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _methods = [
    {'id': '1', 'type': 'upi',  'label': 'Google Pay', 'detail': 'user@okicici',   'icon': '📱', 'isDefault': true},
    {'id': '2', 'type': 'card', 'label': 'HDFC Debit', 'detail': '**** **** 4321', 'icon': '💳', 'isDefault': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Wallet card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFFF6F00).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(children: [
              const Text('💰', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FastKart Wallet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('₹450.00 available', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Text('Add Money', style: TextStyle(color: Color(0xFFFF6F00), fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Saved Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ..._methods.map((m) => _MethodCard(
            data: m,
            onDelete: () => setState(() => _methods.remove(m)),
            onSetDefault: () => setState(() {
              for (var x in _methods) {
                x['isDefault'] = false;
              }
              m['isDefault'] = true;
            }),
          )),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    String selectedType = 'upi';
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('Add Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(children: [
            _typeBtn('upi', '📱 UPI', selectedType, (v) => setS(() => selectedType = v)),
            const SizedBox(width: 10),
            _typeBtn('card', '💳 Card', selectedType, (v) => setS(() => selectedType = v)),
            const SizedBox(width: 10),
            _typeBtn('netbanking', '🏦 NetBank', selectedType, (v) => setS(() => selectedType = v)),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: selectedType == 'upi' ? 'Enter UPI ID' : selectedType == 'card' ? 'Card Number' : 'Bank Name',
              filled: true, fillColor: const Color(0xFFF8F5F0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (ctrl.text.isEmpty) return;
                setState(() => _methods.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'type': selectedType,
                  'label': selectedType == 'upi' ? 'UPI' : selectedType == 'card' ? 'Card' : 'NetBanking',
                  'detail': ctrl.text,
                  'icon': selectedType == 'upi' ? '📱' : selectedType == 'card' ? '💳' : '🏦',
                  'isDefault': false,
                }));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: const Text('Save Method', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      )),
    );
  }

  Widget _typeBtn(String value, String label, String active, ValueChanged<String> onTap) {
    final isActive = value == active;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  const _MethodCard({required this.data, required this.onDelete, required this.onSetDefault});

  @override
  Widget build(BuildContext context) {
    final isDefault = data['isDefault'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? AppColors.primary : AppColors.border, width: isDefault ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(data['icon'] as String, style: const TextStyle(fontSize: 22))),
        ),
        title: Row(children: [
          Text(data['label'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
              child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        subtitle: Text(data['detail'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (v) { if (v == 'default') onSetDefault(); if (v == 'delete') onDelete(); },
        ),
      ),
    );
  }
}
// lib/screens/profile/addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {'id': '1', 'label': 'Home', 'line1': 'B-204, Sunrise Apartments, Andheri West', 'city': 'Mumbai', 'pincode': '400053', 'is_default': true, 'icon': '🏠'},
    {'id': '2', 'label': 'Work', 'line1': '14th Floor, One BKC, Bandra Kurla Complex', 'city': 'Mumbai', 'pincode': '400051', 'is_default': false, 'icon': '🏢'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('My Addresses', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _addresses.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('📍', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('No addresses saved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (_, i) => _AddressCard(
                data: _addresses[i],
                onDelete: () => setState(() => _addresses.removeAt(i)),
                onSetDefault: () => setState(() {
                  for (var a in _addresses) {
                    a['is_default'] = false;
                  }
                  _addresses[i]['is_default'] = true;
                }),
              ),
            ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final labelCtrl = TextEditingController();
    final line1Ctrl = TextEditingController();
    final cityCtrl  = TextEditingController();
    final pinCtrl   = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Text('Add New Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _field(labelCtrl, 'Label (Home / Work)', Icons.label_rounded),
            const SizedBox(height: 12),
            _field(line1Ctrl, 'Street Address', Icons.location_on_rounded),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(cityCtrl, 'City', Icons.location_city_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _field(pinCtrl, 'Pincode', Icons.pin_drop_rounded)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (line1Ctrl.text.isEmpty) return;
                  setState(() => _addresses.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'label': labelCtrl.text.isEmpty ? 'Other' : labelCtrl.text,
                    'line1': line1Ctrl.text,
                    'city': cityCtrl.text,
                    'pincode': pinCtrl.text,
                    'is_default': false,
                    'icon': '📍',
                  }));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save Address', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F5F0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  const _AddressCard({required this.data, required this.onDelete, required this.onSetDefault});

  @override
  Widget build(BuildContext context) {
    final isDefault = data['is_default'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? AppColors.primary : AppColors.border, width: isDefault ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${data['line1']}, ${data['city']} - ${data['pincode']}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
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
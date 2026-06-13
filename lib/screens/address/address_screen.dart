// lib/screens/profile/addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {'id': '1', 'type': 'Home', 'icon': Icons.home_rounded,
     'address': 'B-204, Sunrise Apartments, Andheri West, Mumbai - 400053',
     'isDefault': true},
    {'id': '2', 'type': 'Office', 'icon': Icons.business_rounded,
     'address': '5th Floor, Tech Park, Powai, Mumbai - 400076',
     'isDefault': false},
    {'id': '3', 'type': 'Other', 'icon': Icons.location_on_rounded,
     'address': 'Shop 12, Linking Road, Bandra West, Mumbai - 400050',
     'isDefault': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length + 1,
        itemBuilder: (_, i) {
          if (i == _addresses.length) return _addNewBtn(context);
          final addr = _addresses[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: addr['isDefault'] == true
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(addr['icon'] as IconData, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(addr['type'] as String,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  if (addr['isDefault'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text('Default', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(addr['address'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ])),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                onSelected: (val) {
                  if (val == 'default') {
                    setState(() {
                      for (var a in _addresses) {
                        a['isDefault'] = false;
                      }
                      addr['isDefault'] = true;
                    });
                  } else if (val == 'delete') {
                    setState(() => _addresses.remove(addr));
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete',
                      child: Text('Delete', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _addNewBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Add New Address', style: TextStyle(color: AppColors.primary,
              fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final ctrl = TextEditingController();
    String type = 'Home';
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20,
              MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Add New Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(children: ['Home', 'Office', 'Other'].map((t) => GestureDetector(
              onTap: () => setS(() => type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: type == t ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: type == t ? AppColors.primary : AppColors.border),
                ),
                child: Text(t, style: TextStyle(fontWeight: FontWeight.w600,
                    color: type == t ? Colors.black87 : AppColors.textSecondary)),
              ),
            )).toList()),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl, maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Full Address',
                hintText: 'Enter flat no, street, city, pincode',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.isNotEmpty) {
                    setState(() => _addresses.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'type': type,
                      'icon': Icons.location_on_rounded,
                      'address': ctrl.text,
                      'isDefault': false,
                    }));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Address added!'),
                        backgroundColor: AppColors.success));
                  }
                },
                child: const Text('Save Address',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              )),
          ]),
        ),
      ),
    );
  }
}
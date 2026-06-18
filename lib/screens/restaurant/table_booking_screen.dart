// lib/screens/restaurant/table_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../services/history_service.dart';
import '../../models/history_item.dart';

class TableBookingScreen extends StatefulWidget {
  final String restaurantId;
  const TableBookingScreen({super.key, required this.restaurantId});
  @override
  State<TableBookingScreen> createState() => _TableBookingScreenState();
}

class _TableBookingScreenState extends State<TableBookingScreen> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  int _guests = 2;
  int? _selectedTable;
  bool _confirmed = false;

  String _paymentMethod = 'Pay at Restaurant';
  final _paymentDetailCtrl = TextEditingController();

  final List<String> _times = ['12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM',
      '7:00 PM', '7:30 PM', '8:00 PM', '8:30 PM', '9:00 PM'];

  final List<Map<String, dynamic>> _tables = [
    {'id': 1, 'name': 'Table 1', 'capacity': 2, 'location': 'Window', 'available': true},
    {'id': 2, 'name': 'Table 2', 'capacity': 4, 'location': 'Center', 'available': true},
    {'id': 3, 'name': 'Table 3', 'capacity': 4, 'location': 'Center', 'available': false},
    {'id': 4, 'name': 'Table 4', 'capacity': 6, 'location': 'Private', 'available': true},
    {'id': 5, 'name': 'Table 5', 'capacity': 2, 'location': 'Outdoor', 'available': true},
    {'id': 6, 'name': 'Table 6', 'capacity': 8, 'location': 'Private', 'available': false},
  ];

  @override
  void dispose() {
    _paymentDetailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmed) {
      return _ConfirmedView(
        date: _date,
        time: _selectedTime!,
        guests: _guests,
        paymentMethod: _paymentMethod,
      );
    }

    final paymentReady = _paymentMethod == 'Pay at Restaurant' ||
        _paymentDetailCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Book a Table', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Restaurant info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: Row(children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('🍛', style: TextStyle(fontSize: 28)))),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Punjabi Tadka', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Text('Bandra West · ₹400 for two', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Row(children: [
                Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                Text(' 4.5 · 1,243 reviews', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        // Date picker
        const _SectionLabel(label: '1. Select Date'),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (_, i) {
              final d = DateTime.now().add(Duration(days: i + 1));
              final isSelected = _date.day == d.day && _date.month == d.month;
              final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return GestureDetector(
                onTap: () => setState(() { _date = d; _selectedTime = null; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(dayNames[d.weekday - 1], style: TextStyle(fontSize: 11,
                        color: isSelected ? Colors.black54 : AppColors.textSecondary)),
                    Text('${d.day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.black87 : AppColors.textPrimary)),
                    Text(_monthShort(d.month), style: TextStyle(fontSize: 10,
                        color: isSelected ? Colors.black54 : AppColors.textSecondary)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Guests
        const _SectionLabel(label: '2. Number of Guests'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: Row(children: [
            const Text('👥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text('$_guests ${_guests == 1 ? 'Guest' : 'Guests'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            _CounterBtn(Icons.remove_rounded, () { if (_guests > 1) setState(() => _guests--); }),
            const SizedBox(width: 8),
            Text('$_guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            _CounterBtn(Icons.add_rounded, () { if (_guests < 10) setState(() => _guests++); }, filled: true),
          ]),
        ),
        const SizedBox(height: 20),

        // Time slots
        const _SectionLabel(label: '3. Select Time'),
        Wrap(spacing: 8, runSpacing: 8, children: _times.map((t) {
          final isSelected = _selectedTime == t;
          return GestureDetector(
            onTap: () => setState(() => _selectedTime = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.black87 : AppColors.textPrimary)),
            ),
          );
        }).toList()),
        const SizedBox(height: 20),

        // Table selection
        const _SectionLabel(label: '4. Choose Your Table'),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, childAspectRatio: 2.4,
          crossAxisSpacing: 10, mainAxisSpacing: 10,
          children: _tables.map((t) {
            final available = t['available'] as bool;
            final isSelected = _selectedTable == t['id'];
            return GestureDetector(
              onTap: available ? () => setState(() => _selectedTable = t['id'] as int) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: !available ? Colors.grey.shade100 : isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Row(children: [
                  Text(available ? '🪑' : '🚫', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                        color: !available ? AppColors.textHint : isSelected ? Colors.black87 : AppColors.textPrimary)),
                    Text('${t['capacity']} pax · ${t['location']}',
                        style: TextStyle(fontSize: 10,
                            color: !available ? AppColors.textHint : isSelected ? Colors.black54 : AppColors.textSecondary)),
                  ]),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Payment method
        const _SectionLabel(label: '5. Payment Method'),
        Wrap(spacing: 8, runSpacing: 8, children: ['Pay at Restaurant', 'UPI', 'Card'].map((m) {
          final isSelected = _paymentMethod == m;
          return GestureDetector(
            onTap: () => setState(() {
              _paymentMethod = m;
              _paymentDetailCtrl.clear();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  m == 'Pay at Restaurant'
                      ? Icons.storefront_rounded
                      : m == 'UPI'
                          ? Icons.qr_code_rounded
                          : Icons.credit_card_rounded,
                  size: 16,
                  color: isSelected ? Colors.black87 : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(m, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.black87 : AppColors.textPrimary)),
              ]),
            ),
          );
        }).toList()),

        if (_paymentMethod != 'Pay at Restaurant') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
            child: TextField(
              controller: _paymentDetailCtrl,
              onChanged: (_) => setState(() {}),
              keyboardType: _paymentMethod == 'UPI' ? TextInputType.text : TextInputType.number,
              decoration: InputDecoration(
                labelText: _paymentMethod == 'UPI' ? 'UPI ID' : 'Card Number',
                hintText: _paymentMethod == 'UPI' ? 'yourname@upi' : '1234 5678 9012 3456',
                labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: (_selectedTime != null && _selectedTable != null && paymentReady)
              ? () {
                  // ── Saved tab mein save karo ──────────────────────────────
                  final tableName = _tables.firstWhere((t) => t['id'] == _selectedTable)['name'] as String;
                  HistoryService.instance.saveItem(
                    HistoryService.makeMore(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Table Booking — Punjabi Tadka',
                      subtitle: '${_date.day}/${_date.month}/${_date.year} · $_selectedTime',
                      description: '$tableName · $_guests guest${_guests == 1 ? '' : 's'} · $_paymentMethod',
                      amount: 0,
                      date: _date,
                      status: HistoryStatus.confirmed,
                    ),
                  );
                  setState(() => _confirmed = true);
                }
              : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            disabledBackgroundColor: AppColors.border,
          ),
          child: const Text('Confirm Booking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  String _monthShort(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
  );
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _CounterBtn(this.icon, this.onTap, {this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 30, height: 30,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: filled ? null : Border.all(color: AppColors.primary),
      ),
      child: Icon(icon, size: 16, color: filled ? Colors.black87 : AppColors.primary)),
  );
}

class _ConfirmedView extends StatefulWidget {
  final DateTime date;
  final String time;
  final int guests;
  final String paymentMethod;
  const _ConfirmedView({
    required this.date,
    required this.time,
    required this.guests,
    required this.paymentMethod,
  });
  @override
  State<_ConfirmedView> createState() => _ConfirmedViewState();
}

class _ConfirmedViewState extends State<_ConfirmedView> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _anim.forward();
  }
  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(scale: _scale,
            child: Container(width: 90, height: 90,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 50))),
          const SizedBox(height: 24),
          const Text('Table Booked!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Your reservation is confirmed', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
            child: Column(children: [
              const _BookingDetail('🍛', 'Restaurant', 'Punjabi Tadka'),
              _BookingDetail('📅', 'Date', '${widget.date.day}/${widget.date.month}/${widget.date.year}'),
              _BookingDetail('🕐', 'Time', widget.time),
              _BookingDetail('👥', 'Guests', '${widget.guests} ${widget.guests == 1 ? 'person' : 'people'}'),
              _BookingDetail('💳', 'Payment', widget.paymentMethod),
              _BookingDetail('🎫', 'Booking ID', '#TB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ]),
      )),
    );
  }
}

class _BookingDetail extends StatelessWidget {
  final String icon, label, value;
  const _BookingDetail(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  );
}
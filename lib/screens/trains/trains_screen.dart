// lib/screens/trains/trains_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';

class TrainsScreen extends StatefulWidget {
  const TrainsScreen({super.key});
  @override
  State<TrainsScreen> createState() => _TrainsScreenState();
}

class _TrainsScreenState extends State<TrainsScreen> {
  final trains = mockTrains();
  final List<Map<String, dynamic>> _myBookings = [];
  String _fromCity = 'Mumbai';
  String _toCity = 'Any';

  final cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad', 'Pune', 'Ahmedabad'];

  List<TrainModel> get _filtered {
    if (_toCity == 'Any') return trains;
    return trains.where((t) => t.to.contains(_toCity) || t.from.contains(_fromCity)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Train Booking 🚆', style: TextStyle(fontWeight: FontWeight.w800)),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black87,
            tabs: [Tab(text: 'Search Trains'), Tab(text: 'My Bookings')],
          ),
        ),
        body: TabBarView(children: [
          _searchTab(),
          _bookingsTab(),
        ]),
      ),
    );
  }

  Widget _searchTab() {
    return Column(children: [
      // Route selector
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => _pickCity(true),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('From', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(_fromCity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ]),
            ),
          )),
          GestureDetector(
            onTap: () => setState(() { final tmp = _fromCity; _fromCity = _toCity == 'Any' ? _fromCity : _toCity; _toCity = tmp; }),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 22),
            ),
          ),
          Expanded(child: GestureDetector(
            onTap: () => _pickCity(false),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('To', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(_toCity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ]),
            ),
          )),
        ]),
      ),

      Container(
        color: const Color(0xFFF8F5F0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          const Text('Today, 9 Jun 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${_filtered.length} trains found',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
      ),

      Expanded(
        child: _filtered.isEmpty
          ? const Center(child: Text('No trains found for this route', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _TrainCard(
                train: _filtered[i],
                onBook: (t, passengers, cls, payment, name, phone) {
                  final pnr = 'TR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                  setState(() => _myBookings.insert(0, {
                    'pnr': pnr, 'train': t, 'passengers': passengers,
                    'class': cls, 'payment': payment, 'name': name,
                    'phone': phone, 'status': 'Confirmed',
                    'total': t.price * passengers,
                  }));
                  return pnr;
                },
              ),
            ),
      ),
    ]);
  }

  void _pickCity(bool isFrom) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.all(16),
          child: Text(isFrom ? 'Select Origin' : 'Select Destination',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        if (!isFrom) ListTile(
          leading: const Icon(Icons.train_rounded, color: AppColors.primary),
          title: const Text('Any Destination'),
          onTap: () { setState(() => _toCity = 'Any'); Navigator.pop(context); },
        ),
        ...cities.map((c) => ListTile(
          leading: const Icon(Icons.location_city_rounded, color: AppColors.textSecondary),
          title: Text(c),
          onTap: () {
            setState(() { if (isFrom) {
              _fromCity = c;
            } else {
              _toCity = c;
            } });
            Navigator.pop(context);
          },
        )),
      ]),
    );
  }

  Widget _bookingsTab() {
    if (_myBookings.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('🚆', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No bookings yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text('Book a train to see it here', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBookings.length,
      itemBuilder: (_, i) {
        final b = _myBookings[i];
        final t = b['train'] as TrainModel;
        final cancelled = b['status'] == 'Cancelled';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cancelled ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('🚆', style: TextStyle(fontSize: 20)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.trainName, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('PNR: ${b['pnr']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cancelled ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(b['status'], style: TextStyle(
                    color: cancelled ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
            const Divider(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.departure, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(t.from, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(children: [
                const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                Text(t.duration, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(t.arrival, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(t.to, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('${b['passengers']} pax · ${b['class']} · ${b['payment']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Text('₹${b['total']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ]),
            if (!cancelled) ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => _cancelTicket(i),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('Cancel Ticket', style: TextStyle(color: AppColors.error, fontSize: 12)),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(
                  onPressed: () => _showPNRStatus(b),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('PNR Status', style: TextStyle(fontSize: 12)),
                )),
              ]),
            ],
          ]),
        );
      },
    );
  }

  void _cancelTicket(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Ticket?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Cancellation charges may apply. Refund in 5-7 working days.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              setState(() => _myBookings[index]['status'] = 'Cancelled');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ticket cancelled. Refund will be processed in 5-7 days.'),
                backgroundColor: AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPNRStatus(Map<String, dynamic> b) {
    final t = b['train'] as TrainModel;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('PNR Status', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _pnrRow('PNR Number', b['pnr']),
              _pnrRow('Status', b['status']),
              _pnrRow('Train', '${t.trainNumber} - ${t.trainName}'),
              _pnrRow('From', t.from),
              _pnrRow('To', t.to),
              _pnrRow('Departure', t.departure),
              _pnrRow('Arrival', t.arrival),
              _pnrRow('Class', b['class']),
              _pnrRow('Passengers', '${b['passengers']}'),
              _pnrRow('Passenger', b['name'].isEmpty ? 'Guest' : b['name']),
            ]),
          ),
        ]),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _pnrRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Flexible(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          textAlign: TextAlign.right)),
    ]),
  );
}

// ── Train Card ────────────────────────────────────────────────────────────────
class _TrainCard extends StatelessWidget {
  final TrainModel train;
  final String Function(TrainModel, int, String, String, String, String) onBook;
  const _TrainCard({required this.train, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(train.trainNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(train.trainName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(train.classType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(train.departure, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(train.from, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Expanded(child: Column(children: [
            const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            Text(train.duration, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(train.arrival, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(train.to, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('₹${train.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.accent)),
            Text('${train.availableSeats} seats left',
                style: TextStyle(fontSize: 11,
                    color: train.availableSeats < 15 ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w600)),
          ]),
          ElevatedButton(
            onPressed: () => _showBookingSheet(context),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Book Ticket'),
          ),
        ]),
      ]),
    );
  }

  void _showBookingSheet(BuildContext context) {
    int passengers = 1;
    String cls = train.classType;
    String payment = 'UPI';
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    int step = 0;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (step > 0) IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setS(() => step--)),
              const Text('🚆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(train.trainName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text('${train.from} → ${train.to}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const Divider(),

            Expanded(child: SingleChildScrollView(child: step == 0
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(train.departure, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text(train.from, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ])),
                      Column(children: [
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                        Text(train.duration, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ]),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(train.arrival, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text(train.to, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ])),
                    ])),
                  const SizedBox(height: 16),
                  const Text('Class', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: ['SL', '3A', '2A', '1A', 'CC'].map((c) => GestureDetector(
                      onTap: () => setS(() => cls = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: cls == c ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cls == c ? AppColors.primary : AppColors.border)),
                        child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: cls == c ? Colors.black87 : AppColors.textSecondary))),
                    )).toList()),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('Passengers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () { if (passengers > 1) setS(() => passengers--); }),
                    Text('$passengers', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () { if (passengers < 6) setS(() => passengers++); }),
                  ]),
                ])
              : step == 1
              ? Column(children: [
                  TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Passenger Name', prefixIcon: Icon(Icons.person_rounded), border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_rounded), border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft,
                    child: Text('Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 10),
                  ...['UPI', 'Card', 'Net Banking', 'IRCTC Wallet'].map((p) => GestureDetector(
                    onTap: () => setS(() => payment = p),
                    child: Container(margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: payment == p ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: payment == p ? AppColors.primary : AppColors.border)),
                      child: Row(children: [
                        Text(p, style: TextStyle(fontWeight: FontWeight.w700,
                            color: payment == p ? AppColors.primary : Colors.black87)),
                        const Spacer(),
                        if (payment == p) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                      ])),
                  )),
                ])
              : Column(children: [
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      _row('Train', '${train.trainNumber} - ${train.trainName}'),
                      _row('Route', '${train.from} → ${train.to}'),
                      _row('Departure', train.departure),
                      _row('Arrival', train.arrival),
                      _row('Class', cls),
                      _row('Passengers', '$passengers'),
                      _row('Passenger', nameCtrl.text.isEmpty ? 'Guest' : nameCtrl.text),
                      _row('Payment', payment),
                      const Divider(height: 20),
                      _row('Total', '₹${train.price * passengers}', bold: true),
                    ])),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final pnr = onBook(train, passengers, cls, payment, nameCtrl.text, phoneCtrl.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('🚆 ${train.trainName} booked! PNR: $pnr'),
                          backgroundColor: AppColors.success, duration: const Duration(seconds: 4)));
                      },
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text('Pay ₹${train.price * passengers}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    )),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                    )),
                ]),
            )),

            if (step < 2)
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => setS(() => step++),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(step == 0 ? 'Continue to Details' : 'Review Booking',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                )),
          ]),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Flexible(child: Text(value, style: TextStyle(fontSize: bold ? 16 : 12,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          color: bold ? AppColors.accent : Colors.black87),
          textAlign: TextAlign.right)),
    ]),
  );
}
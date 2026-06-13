// lib/screens/rides/rides_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});
  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final rides = mockRides();
  String? _selected;
  int _km = 5;
  final String _pickupCtrl = 'Current Location - Mumbai';
  String _dropCtrl = '';
  final bool _booked = false;
  String? _bookedRideId;
  final int _driverEta = 0;

  // PNR/Booking status
  final List<Map<String, dynamic>> _myBookings = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Rides & Taxi', style: TextStyle(fontWeight: FontWeight.w800)),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black87,
            tabs: [Tab(text: 'Book Ride'), Tab(text: 'My Bookings')],
          ),
        ),
        body: TabBarView(children: [
          _bookTab(),
          _bookingsTab(),
        ]),
      ),
    );
  }

  Widget _bookTab() {
    return Column(children: [
      // Location fields
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _locationField(Icons.my_location_rounded, _pickupCtrl, AppColors.success, true),
          const SizedBox(height: 8),
          _locationField(Icons.location_on_rounded, _dropCtrl.isEmpty ? 'Enter Drop Location' : _dropCtrl, AppColors.error, false),
        ]),
      ),

      // Distance slider
      Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Text('Distance:', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Slider(
            value: _km.toDouble(), min: 1, max: 30, divisions: 29,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _km = v.round()),
          )),
          Text('$_km km', style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),

      // Ride options
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          itemBuilder: (_, i) {
            final r = rides[i];
            final fare = r.baseFare + (r.perKm * _km);
            final isSelected = _selected == r.id;
            return GestureDetector(
              onTap: () => setState(() => _selected = r.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                ),
                child: Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(_rideEmoji(r.type), style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text(r.capacity, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${r.eta} min away', style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('₹$fare', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
                    Text('₹${r.perKm}/km', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),

      // Book button
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _selected == null ? null : () => _bookRide(),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text(_selected == null ? 'Select a Ride'
                : 'Book ${rides.firstWhere((r) => r.id == _selected).type}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]);
  }

  void _bookRide() {
    final ride = rides.firstWhere((r) => r.id == _selected);
    final fare = ride.baseFare + (ride.perKm * _km);
    final pnr = 'FK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        String payment = 'UPI';
        final nameCtrl = TextEditingController();
        final phoneCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setS) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_rideEmoji(ride.type), style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ride.type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('${ride.eta} min · ₹$fare · $_km km', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Passenger Name', prefixIcon: Icon(Icons.person_rounded),
                    border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_rounded),
                    border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const Text('Payment', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: ['UPI', 'Card', 'Cash'].map((p) => GestureDetector(
                onTap: () => setS(() => payment = p),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: payment == p ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: payment == p ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(p, style: TextStyle(fontWeight: FontWeight.w700,
                      color: payment == p ? AppColors.primary : AppColors.textSecondary)),
                ),
              )).toList()),
              const SizedBox(height: 16),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('₹$fare', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.accent)),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _myBookings.insert(0, {
                        'pnr': pnr, 'type': ride.type, 'fare': fare,
                        'km': _km, 'eta': ride.eta, 'payment': payment,
                        'status': 'Confirmed', 'time': DateTime.now(),
                        'name': nameCtrl.text.isEmpty ? 'Guest' : nameCtrl.text,
                      });
                      _selected = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${ride.type} booked! Driver arriving in ${ride.eta} min 🛵\nPNR: $pnr'),
                      backgroundColor: AppColors.success, duration: const Duration(seconds: 4)));
                  },
                  child: const Text('Confirm Booking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                )),
            ]),
          ),
        );
      },
    );
  }

  Widget _bookingsTab() {
    if (_myBookings.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('🚕', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No bookings yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text('Book a ride to see it here', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBookings.length,
      itemBuilder: (_, i) {
        final b = _myBookings[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_rideEmoji(b['type']), style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b['type'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text('PNR: ${b['pnr']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(b['status'], style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
            const Divider(height: 16),
            Row(children: [
              _infoChip(Icons.route_rounded, '${b['km']} km'),
              const SizedBox(width: 16),
              _infoChip(Icons.timer_rounded, '${b['eta']} min'),
              const SizedBox(width: 16),
              _infoChip(Icons.payment_rounded, b['payment']),
              const Spacer(),
              Text('₹${b['fare']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => setState(() => _myBookings[i]['status'] = 'Cancelled'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 8)),
                child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 12)),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                child: const Text('Track Driver', style: TextStyle(fontSize: 12)),
              )),
            ]),
          ]),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(children: [
    Icon(icon, size: 13, color: AppColors.textSecondary),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
  ]);

  Widget _locationField(IconData icon, String hint, Color color, bool isPickup) {
    return GestureDetector(
      onTap: isPickup ? null : () => _showLocationPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(hint, style: TextStyle(fontSize: 13,
              color: isPickup ? Colors.black87 : AppColors.textSecondary))),
          if (!isPickup) const Icon(Icons.edit_rounded, size: 14, color: AppColors.textHint),
        ]),
      ),
    );
  }

  void _showLocationPicker() {
    final locations = ['Bandra West', 'Andheri East', 'Dadar', 'Kurla', 'Airport T1', 'Airport T2', 'Nariman Point', 'Juhu Beach'];
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16),
          child: Text('Select Drop Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        ...locations.map((l) => ListTile(
          leading: const Icon(Icons.location_on_rounded, color: AppColors.error),
          title: Text(l),
          onTap: () { setState(() => _dropCtrl = l); Navigator.pop(context); },
        )),
      ]),
    );
  }

  String _rideEmoji(String type) {
    switch (type) {
      case 'Auto': return '🛺';
      case 'Mini': return '🚗';
      case 'Sedan': return '🚙';
      case 'SUV': return '🚐';
      case 'Bike': return '🏍️';
      default: return '🚕';
    }
  }
}
// lib/screens/bikes/bikes_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/history_service.dart';

class BikeShareModel {
  final String id, type, assetPath;
  final int pricePerHour;
  final double distance;
  final bool isAvailable;
  final String qrCode;

  const BikeShareModel({
    required this.id, required this.type, required this.assetPath,
    required this.pricePerHour, required this.distance,
    required this.isAvailable, required this.qrCode,
  });
}

List<BikeShareModel> _mockBikes() => [
  const BikeShareModel(id:'b1', type:'Electric Scooter', assetPath:'assets/images/electric_scooter.jpg', pricePerHour:40, distance:0.3, isAvailable:true, qrCode:'FK-SC-001'),
  const BikeShareModel(id:'b2', type:'City Bike', assetPath:'assets/images/city_bike.jpg', pricePerHour:25, distance:0.5, isAvailable:true, qrCode:'FK-CB-002'),
  const BikeShareModel(id:'b4', type:'Mountain Bike', assetPath:'assets/images/mountain_bike.jpg', pricePerHour:35, distance:1.2, isAvailable:true, qrCode:'FK-MB-004'),
];

class BikeScreen extends StatefulWidget {
  const BikeScreen({super.key});
  @override
  State<BikeScreen> createState() => _BikeScreenState();
}

class _BikeScreenState extends State<BikeScreen> {
  final bikes = _mockBikes();
  String? _activeRideId;
  DateTime? _rideStartTime;
  final List<Map<String, dynamic>> _rideHistory = [];

  int get _elapsedMinutes {
    if (_rideStartTime == null) return 0;
    return DateTime.now().difference(_rideStartTime!).inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Bike & Scooter', style: TextStyle(fontWeight: FontWeight.w800)),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black87,
            tabs: [Tab(text: 'Find Bikes'), Tab(text: 'Ride History')],
          ),
        ),
        body: TabBarView(children: [_findTab(), _historyTab()]),
      ),
    );
  }

  Widget _findTab() {
    return Column(children: [
      if (_activeRideId != null)
        Container(
          color: AppColors.success,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.electric_scooter_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ride in Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              Text('$_elapsedMinutes min elapsed', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            ElevatedButton(
              onPressed: _endRide,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: const Text('End Ride', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _stat('🛵', '${bikes.where((b) => b.isAvailable).length}', 'Available'),
          _stat('📍', '0.3 km', 'Nearest'),
          _stat('⚡', '₹25/hr', 'From'),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Row(children: [
          Text('Nearby Bikes & Scooters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bikes.length,
          itemBuilder: (_, i) {
            final b = bikes[i];
            final isActive = _activeRideId == b.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isActive ? Border.all(color: AppColors.success, width: 2) : null,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Image.asset(b.assetPath, width: 100, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 100, height: 90,
                        color: AppColors.divider, child: const Icon(Icons.electric_scooter_rounded, size: 40))),
                ),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(b.type, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: b.isAvailable ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(b.isAvailable ? 'Available' : 'In Use',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                color: b.isAvailable ? AppColors.success : Colors.grey))),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                      Text(' ${b.distance} km away', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('₹${b.pricePerHour}/hr', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.accent)),
                    ]),
                    const SizedBox(height: 8),
                    if (b.isAvailable && _activeRideId == null)
                      SizedBox(width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showUnlockSheet(b),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('Unlock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        )),
                    if (isActive)
                      Container(width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('🚴 Riding...', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800)))),
                  ]),
                )),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  void _showUnlockSheet(BikeShareModel bike) {
    final qrCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Unlock ${bike.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('₹${bike.pricePerHour}/hr · ${bike.distance} km away',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Container(width: 120, height: 120,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black87),
                    Text(bike.qrCode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  ])),
                const SizedBox(height: 12),
                const Text('Scan QR code on the vehicle', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('Or enter QR code manually:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: qrCtrl,
              decoration: InputDecoration(
                hintText: 'Enter QR code (e.g. ${bike.qrCode})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (qrCtrl.text.isEmpty || qrCtrl.text == bike.qrCode) {
                    Navigator.pop(context);
                    setState(() {
                      _activeRideId = bike.id;
                      _rideStartTime = DateTime.now();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${bike.type} unlocked! Ride started 🚴'),
                      backgroundColor: AppColors.success));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Invalid QR code. Try again.'),
                      backgroundColor: AppColors.error));
                  }
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_open_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Unlock & Start Ride', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
              )),
          ]),
        ),
      ),
    );
  }

  void _endRide() {
    final bike = bikes.firstWhere((b) => b.id == _activeRideId);
    final minutes = _elapsedMinutes;
    final cost = (bike.pricePerHour * minutes / 60).ceil();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Ride?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
          const SizedBox(height: 12),
          Text('Duration: $minutes min', style: const TextStyle(fontSize: 14)),
          Text('Cost: ₹$cost', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue Ride')),
          ElevatedButton(
            // ✅ FIXED: async + HistoryService call
            onPressed: () async {
              await HistoryService.instance.saveItem(
                HistoryService.makeRide(
                  id: 'bike_${DateTime.now().millisecondsSinceEpoch}',
                  from: 'Bike Station',
                  to: 'Drop Point',
                  driverName: bike.type,
                  distanceKm: (minutes * 0.25),
                  durationMins: minutes,
                  amount: cost.toDouble(),
                  isBike: true,
                ),
              );
              setState(() {
                _rideHistory.insert(0, {
                  'type': bike.type, 'minutes': minutes, 'cost': cost,
                  'time': DateTime.now(), 'status': 'Completed',
                });
                _activeRideId = null;
                _rideStartTime = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Ride ended! ₹$cost charged.'),
                backgroundColor: AppColors.success));
            },
            child: const Text('End & Pay'),
          ),
        ],
      ),
    );
  }

  Widget _historyTab() {
    if (_rideHistory.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('🚲', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No rides yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text('Unlock a bike to get started', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rideHistory.length,
      itemBuilder: (_, i) {
        final r = _rideHistory[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
          child: Row(children: [
            const Text('🚴', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['type'], style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${r['minutes']} min · ${r['status']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Text('₹${r['cost']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.accent)),
          ]),
        );
      },
    );
  }

  Widget _stat(String emoji, String val, String label) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 20)),
    Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);
}
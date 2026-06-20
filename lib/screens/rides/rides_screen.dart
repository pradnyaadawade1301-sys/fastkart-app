// lib/screens/rides/rides_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';
import '../../services/history_service.dart';
import 'ride_tracking_screen.dart'; // ✅ direct import for navigation

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});
  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final rides = mockRides();
  String? _selected;
  int _km = 5;
  String _pickup = 'Current Location - Mumbai';
  String _drop   = '';
  final List<Map<String, dynamic>> _myBookings = [];

  static const Map<String, Map<String, int>> _distanceMatrix = {
    'Current Location - Mumbai': {
      'Bandra West': 8, 'Andheri East': 12, 'Dadar': 6, 'Kurla': 14,
      'Airport T1': 15, 'Airport T2': 16, 'Nariman Point': 10, 'Juhu Beach': 14,
      'Powai': 18, 'Thane': 28, 'Navi Mumbai': 32, 'Borivali': 25,
      'Malad': 22, 'Goregaon': 20, 'Churchgate': 8, 'CST (Mumbai Central)': 7,
      'Worli': 5, 'Bhandup': 20, 'Turbhe': 35, 'Vikhroli': 18,
      'Ghatkopar': 16, 'Mulund': 24, 'Chembur': 15, 'Wadala': 10,
    },
    'Bandra West': {
      'Current Location - Mumbai': 8, 'Andheri East': 10, 'Dadar': 7,
      'Kurla': 12, 'Airport T1': 13, 'Airport T2': 14, 'Nariman Point': 12,
      'Juhu Beach': 6, 'Powai': 16, 'Thane': 26, 'Navi Mumbai': 30,
      'Borivali': 23, 'Malad': 20, 'Goregaon': 18, 'Churchgate': 10,
      'CST (Mumbai Central)': 9, 'Worli': 6, 'Bhandup': 18, 'Turbhe': 32,
      'Vikhroli': 16, 'Ghatkopar': 14, 'Mulund': 22, 'Chembur': 13, 'Wadala': 8,
    },
    'Andheri East': {
      'Current Location - Mumbai': 12, 'Bandra West': 10, 'Dadar': 14,
      'Kurla': 8, 'Airport T1': 3, 'Airport T2': 4, 'Nariman Point': 20,
      'Juhu Beach': 8, 'Powai': 10, 'Thane': 20, 'Navi Mumbai': 28,
      'Borivali': 14, 'Malad': 11, 'Goregaon': 8, 'Churchgate': 18,
      'CST (Mumbai Central)': 16, 'Worli': 15, 'Bhandup': 12, 'Turbhe': 25,
      'Vikhroli': 10, 'Ghatkopar': 8, 'Mulund': 16, 'Chembur': 14, 'Wadala': 16,
    },
    'Dadar': {
      'Current Location - Mumbai': 6, 'Bandra West': 7, 'Andheri East': 14,
      'Kurla': 10, 'Airport T1': 16, 'Airport T2': 17, 'Nariman Point': 8,
      'Juhu Beach': 14, 'Powai': 16, 'Thane': 22, 'Navi Mumbai': 26,
      'Borivali': 28, 'Malad': 25, 'Goregaon': 22, 'Churchgate': 5,
      'CST (Mumbai Central)': 4, 'Worli': 4, 'Bhandup': 16, 'Turbhe': 28,
      'Vikhroli': 14, 'Ghatkopar': 12, 'Mulund': 20, 'Chembur': 10, 'Wadala': 6,
    },
    'Kurla': {
      'Current Location - Mumbai': 14, 'Bandra West': 12, 'Andheri East': 8,
      'Dadar': 10, 'Airport T1': 8, 'Airport T2': 9, 'Nariman Point': 18,
      'Juhu Beach': 14, 'Powai': 8, 'Thane': 16, 'Navi Mumbai': 18,
      'Borivali': 20, 'Malad': 18, 'Goregaon': 14, 'Churchgate': 14,
      'CST (Mumbai Central)': 12, 'Worli': 12, 'Bhandup': 10, 'Turbhe': 18,
      'Vikhroli': 6, 'Ghatkopar': 4, 'Mulund': 12, 'Chembur': 8, 'Wadala': 12,
    },
    'Airport T1': {
      'Current Location - Mumbai': 15, 'Bandra West': 13, 'Andheri East': 3,
      'Dadar': 16, 'Kurla': 8, 'Airport T2': 2, 'Nariman Point': 22,
      'Juhu Beach': 7, 'Powai': 11, 'Thane': 18, 'Navi Mumbai': 26,
      'Borivali': 13, 'Malad': 10, 'Goregaon': 7, 'Churchgate': 20,
      'CST (Mumbai Central)': 18, 'Worli': 17, 'Bhandup': 11, 'Turbhe': 24,
      'Vikhroli': 9, 'Ghatkopar': 7, 'Mulund': 15, 'Chembur': 13, 'Wadala': 17,
    },
    'Nariman Point': {
      'Current Location - Mumbai': 10, 'Bandra West': 12, 'Andheri East': 20,
      'Dadar': 8, 'Kurla': 18, 'Airport T1': 22, 'Airport T2': 23,
      'Juhu Beach': 18, 'Powai': 22, 'Thane': 30, 'Navi Mumbai': 32,
      'Borivali': 34, 'Malad': 30, 'Goregaon': 28, 'Churchgate': 2,
      'CST (Mumbai Central)': 3, 'Worli': 6, 'Bhandup': 22, 'Turbhe': 34,
      'Vikhroli': 20, 'Ghatkopar': 18, 'Mulund': 26, 'Chembur': 14, 'Wadala': 10,
    },
    'Thane': {
      'Current Location - Mumbai': 28, 'Bandra West': 26, 'Andheri East': 20,
      'Dadar': 22, 'Kurla': 16, 'Airport T1': 18, 'Airport T2': 19,
      'Nariman Point': 30, 'Juhu Beach': 24, 'Powai': 12, 'Navi Mumbai': 14,
      'Borivali': 22, 'Malad': 20, 'Goregaon': 18, 'Churchgate': 28,
      'CST (Mumbai Central)': 26, 'Worli': 24, 'Bhandup': 6, 'Turbhe': 14,
      'Vikhroli': 10, 'Ghatkopar': 12, 'Mulund': 8, 'Chembur': 16, 'Wadala': 22,
    },
    'Bhandup': {
      'Current Location - Mumbai': 20, 'Bandra West': 18, 'Andheri East': 12,
      'Dadar': 16, 'Kurla': 10, 'Airport T1': 11, 'Airport T2': 12,
      'Nariman Point': 22, 'Juhu Beach': 18, 'Powai': 6, 'Thane': 6,
      'Navi Mumbai': 16, 'Borivali': 18, 'Malad': 16, 'Goregaon': 14,
      'Churchgate': 20, 'CST (Mumbai Central)': 18, 'Worli': 18,
      'Turbhe': 18, 'Vikhroli': 6, 'Ghatkopar': 8, 'Mulund': 5,
      'Chembur': 12, 'Wadala': 16,
    },
    'Turbhe': {
      'Current Location - Mumbai': 35, 'Bandra West': 32, 'Andheri East': 25,
      'Dadar': 28, 'Kurla': 18, 'Airport T1': 24, 'Airport T2': 25,
      'Nariman Point': 34, 'Juhu Beach': 30, 'Powai': 16, 'Thane': 14,
      'Navi Mumbai': 5, 'Borivali': 30, 'Malad': 28, 'Goregaon': 26,
      'Churchgate': 32, 'CST (Mumbai Central)': 30, 'Worli': 28,
      'Bhandup': 18, 'Vikhroli': 16, 'Ghatkopar': 18, 'Mulund': 16,
      'Chembur': 20, 'Wadala': 26,
    },
    'Powai': {
      'Current Location - Mumbai': 18, 'Bandra West': 16, 'Andheri East': 10,
      'Dadar': 16, 'Kurla': 8, 'Airport T1': 11, 'Airport T2': 12,
      'Nariman Point': 22, 'Juhu Beach': 16, 'Thane': 12, 'Navi Mumbai': 16,
      'Borivali': 18, 'Malad': 16, 'Goregaon': 13, 'Churchgate': 20,
      'CST (Mumbai Central)': 18, 'Worli': 17, 'Bhandup': 6, 'Turbhe': 16,
      'Vikhroli': 8, 'Ghatkopar': 10, 'Mulund': 10, 'Chembur': 14, 'Wadala': 18,
    },
    'Navi Mumbai': {
      'Current Location - Mumbai': 32, 'Bandra West': 30, 'Andheri East': 28,
      'Dadar': 26, 'Kurla': 18, 'Airport T1': 26, 'Airport T2': 27,
      'Nariman Point': 32, 'Juhu Beach': 32, 'Powai': 16, 'Thane': 14,
      'Borivali': 35, 'Malad': 32, 'Goregaon': 30, 'Churchgate': 30,
      'CST (Mumbai Central)': 28, 'Worli': 26, 'Bhandup': 16, 'Turbhe': 5,
      'Vikhroli': 18, 'Ghatkopar': 20, 'Mulund': 18, 'Chembur': 22, 'Wadala': 24,
    },
    'Borivali': {
      'Current Location - Mumbai': 25, 'Bandra West': 23, 'Andheri East': 14,
      'Dadar': 28, 'Kurla': 20, 'Airport T1': 13, 'Airport T2': 14,
      'Nariman Point': 34, 'Juhu Beach': 18, 'Powai': 18, 'Thane': 22,
      'Navi Mumbai': 35, 'Malad': 6, 'Goregaon': 10, 'Churchgate': 32,
      'CST (Mumbai Central)': 30, 'Worli': 28, 'Bhandup': 18, 'Turbhe': 30,
      'Vikhroli': 20, 'Ghatkopar': 22, 'Mulund': 20, 'Chembur': 26, 'Wadala': 28,
    },
    'Worli': {
      'Current Location - Mumbai': 5, 'Bandra West': 6, 'Andheri East': 15,
      'Dadar': 4, 'Kurla': 12, 'Airport T1': 17, 'Airport T2': 18,
      'Nariman Point': 6, 'Juhu Beach': 14, 'Powai': 17, 'Thane': 24,
      'Navi Mumbai': 26, 'Borivali': 28, 'Malad': 25, 'Goregaon': 22,
      'Churchgate': 4, 'CST (Mumbai Central)': 5, 'Bhandup': 18, 'Turbhe': 28,
      'Vikhroli': 16, 'Ghatkopar': 14, 'Mulund': 22, 'Chembur': 10, 'Wadala': 6,
    },
    'Ghatkopar': {
      'Current Location - Mumbai': 16, 'Bandra West': 14, 'Andheri East': 8,
      'Dadar': 12, 'Kurla': 4, 'Airport T1': 7, 'Airport T2': 8,
      'Nariman Point': 18, 'Juhu Beach': 14, 'Powai': 10, 'Thane': 12,
      'Navi Mumbai': 20, 'Borivali': 22, 'Malad': 18, 'Goregaon': 14,
      'Churchgate': 16, 'CST (Mumbai Central)': 14, 'Worli': 14,
      'Bhandup': 8, 'Turbhe': 18, 'Vikhroli': 4, 'Mulund': 10,
      'Chembur': 8, 'Wadala': 12,
    },
  };

  int _getDistance(String from, String to) {
    if (from == to) return 1;
    final fromMap = _distanceMatrix[from];
    if (fromMap != null && fromMap.containsKey(to)) return fromMap[to]!;
    final toMap = _distanceMatrix[to];
    if (toMap != null && toMap.containsKey(from)) return toMap[from]!;
    return 10;
  }

  void _updateDistance() {
    if (_drop.isNotEmpty) {
      setState(() => _km = _getDistance(_pickup, _drop).clamp(1, 60));
    }
  }

  final List<Map<String, String>> _locations = [
    {'name': 'Current Location - Mumbai', 'icon': '📍'},
    {'name': 'Bandra West',               'icon': '🏘️'},
    {'name': 'Andheri East',              'icon': '🏙️'},
    {'name': 'Dadar',                     'icon': '🚉'},
    {'name': 'Kurla',                     'icon': '🏢'},
    {'name': 'Airport T1',                'icon': '✈️'},
    {'name': 'Airport T2',                'icon': '✈️'},
    {'name': 'Nariman Point',             'icon': '🌊'},
    {'name': 'Juhu Beach',                'icon': '🏖️'},
    {'name': 'Powai',                     'icon': '🏞️'},
    {'name': 'Thane',                     'icon': '🏙️'},
    {'name': 'Navi Mumbai',               'icon': '🌆'},
    {'name': 'Borivali',                  'icon': '🌳'},
    {'name': 'Malad',                     'icon': '🏘️'},
    {'name': 'Goregaon',                  'icon': '🏢'},
    {'name': 'Churchgate',                'icon': '🏛️'},
    {'name': 'CST (Mumbai Central)',      'icon': '🚂'},
    {'name': 'Worli',                     'icon': '🌉'},
    {'name': 'Bhandup',                   'icon': '🏘️'},
    {'name': 'Turbhe',                    'icon': '🏭'},
    {'name': 'Ghatkopar',                 'icon': '🚇'},
    {'name': 'Vikhroli',                  'icon': '🏢'},
    {'name': 'Mulund',                    'icon': '🌿'},
    {'name': 'Chembur',                   'icon': '🏘️'},
    {'name': 'Wadala',                    'icon': '🚉'},
  ];

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
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: () => _showLocationPicker(isPickup: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded, color: AppColors.success, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PICKUP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(_pickup, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                ])),
                const Icon(Icons.edit_rounded, size: 14, color: AppColors.textHint),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Row(children: [
              Column(children: List.generate(3, (_) => Container(
                width: 2, height: 4, margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(1)),
              ))),
            ]),
          ),
          GestureDetector(
            onTap: () => _showLocationPicker(isPickup: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _drop.isEmpty ? AppColors.background : AppColors.error.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _drop.isEmpty ? AppColors.border : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.error, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('DROP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(
                    _drop.isEmpty ? 'Tap to enter drop location' : _drop,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: _drop.isEmpty ? AppColors.textHint : Colors.black87),
                  ),
                ])),
                Icon(_drop.isEmpty ? Icons.add_location_alt_rounded : Icons.edit_rounded,
                    size: 16, color: _drop.isEmpty ? AppColors.error : AppColors.textHint),
              ]),
            ),
          ),
        ]),
      ),
      Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          const Text('Distance:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 10),
          Expanded(
            child: _drop.isEmpty
                ? Slider(
                    value: _km.toDouble(), min: 1, max: 60, divisions: 59,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _km = v.round()),
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _km / 60,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Auto-calculated from locations',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$_km km',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13)),
          ),
        ]),
      ),
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
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                ),
                child: Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(_rideEmoji(r.type), style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(r.type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Selected', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                    Text(r.capacity, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${r.eta} min away',
                        style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('₹$fare',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
                    Text('₹${r.perKm}/km',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: (_selected == null || _drop.isEmpty) ? null : () => _bookRide(),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text(
              _drop.isEmpty ? 'Enter Drop Location First' :
              _selected == null ? 'Select a Ride' :
              'Book ${rides.firstWhere((r) => r.id == _selected).type}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    ]);
  }

  void _showLocationPicker({required bool isPickup}) {
    final searchCtrl = TextEditingController();
    String query = '';
    List<Map<String, String>> filtered = List.from(_locations);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          void doFilter(String q) {
            query = q;
            filtered = q.isEmpty
                ? List.from(_locations)
                : _locations.where((l) =>
                    l['name']!.toLowerCase().contains(q.toLowerCase())).toList();
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isPickup ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPickup ? Icons.my_location_rounded : Icons.location_on_rounded,
                      color: isPickup ? AppColors.success : AppColors.error, size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(isPickup ? 'Set Pickup Location' : 'Set Drop Location',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (val) {
                    final custom = val.trim();
                    if (custom.isNotEmpty) {
                      setState(() {
                        if (isPickup) { _pickup = custom; } else { _drop = custom; }
                        _updateDistance();
                      });
                      Navigator.pop(context);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: isPickup ? 'Type pickup area...' : 'Type drop area...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textHint),
                            onPressed: () { searchCtrl.clear(); setS(() => doFilter('')); })
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isPickup ? AppColors.success : AppColors.error, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (q) => setS(() => doFilter(q)),
                ),
              ),
              if (query.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GestureDetector(
                    onTap: () {
                      final custom = query.trim();
                      if (custom.isNotEmpty) {
                        setState(() {
                          if (isPickup) { _pickup = custom; } else { _drop = custom; }
                          _updateDistance();
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isPickup ? AppColors.success : AppColors.error).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isPickup ? AppColors.success : AppColors.error).withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        Icon(Icons.add_location_alt_rounded,
                            color: isPickup ? AppColors.success : AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Use "$query"',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          const Text('Tap to set as location',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ])),
                        Icon(Icons.check_circle_outline_rounded,
                            size: 18, color: isPickup ? AppColors.success : AppColors.error),
                      ]),
                    ),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text('No match for "$query"',
                            style: const TextStyle(color: AppColors.textSecondary)),
                        const Text('Tap above to use it directly',
                            style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final loc = filtered[i];
                          final isCurrent = loc['name'] == 'Current Location - Mumbai';
                          String distHint = '';
                          if (!isPickup && _pickup.isNotEmpty) {
                            final d = _getDistance(_pickup, loc['name']!);
                            distHint = '~$d km away';
                          }
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(child: Text(loc['icon']!, style: const TextStyle(fontSize: 18))),
                            ),
                            title: Text(loc['name']!,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                    color: isCurrent ? AppColors.success : Colors.black87)),
                            subtitle: distHint.isNotEmpty
                                ? Text(distHint,
                                    style: const TextStyle(fontSize: 11,
                                        color: AppColors.primary, fontWeight: FontWeight.w600))
                                : Text(isCurrent ? 'GPS location' : 'Mumbai, Maharashtra',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppColors.textHint),
                            onTap: () {
                              setState(() {
                                if (isPickup) { _pickup = loc['name']!; } else { _drop = loc['name']!; }
                                _updateDistance();
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ]),
          );
        },
      ),
    );
  }

  void _bookRide() {
    final ride = rides.firstWhere((r) => r.id == _selected);
    final fare = ride.baseFare + (ride.perKm * _km);
    final pnr  = 'FK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        String payment = 'UPI';
        final nameCtrl  = TextEditingController();
        final phoneCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setS) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_rideEmoji(ride.type), style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ride.type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('${ride.eta} min · ₹$fare · $_km km',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ])),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Row(children: [
                    const Icon(Icons.my_location_rounded, color: AppColors.success, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_pickup,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(children: List.generate(3, (_) =>
                      Container(width: 2, height: 4, margin: const EdgeInsets.symmetric(vertical: 1),
                          decoration: BoxDecoration(color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(1))))),
                  ),
                  Row(children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.error, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_drop,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Passenger Name',
                    prefixIcon: Icon(Icons.person_rounded), border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14))),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone_rounded), border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14))),
              const SizedBox(height: 14),
              const Text('Payment', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: ['UPI', 'Card', 'Cash'].map((p) => GestureDetector(
                onTap: () => setS(() => payment = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: payment == p ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: payment == p ? AppColors.primary : AppColors.border,
                        width: payment == p ? 2 : 1),
                  ),
                  child: Text(p, style: TextStyle(fontWeight: FontWeight.w700,
                      color: payment == p ? AppColors.primary : AppColors.textSecondary)),
                ),
              )).toList()),
              const SizedBox(height: 14),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('₹$fare',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.accent)),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await HistoryService.instance.saveItem(
                      HistoryService.makeRide(
                        id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
                        from: _pickup,
                        to: _drop,
                        driverName: 'FastKart Driver',
                        distanceKm: _km.toDouble(),
                        durationMins: ride.eta,
                        amount: fare.toDouble(),
                        isBike: false,
                      ),
                    );
                    setState(() {
                      _myBookings.insert(0, {
                        'pnr': pnr, 'type': ride.type, 'fare': fare,
                        'km': _km, 'eta': ride.eta, 'payment': payment,
                        'status': 'Confirmed', 'time': DateTime.now(),
                        'name': nameCtrl.text.isEmpty ? 'Guest' : nameCtrl.text,
                        'pickup': _pickup, 'drop': _drop,
                      });
                      _selected = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${ride.type} booked! Driver arriving in ${ride.eta} min 🚕\nPNR: $pnr'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 4),
                    ));
                  },
                  child: const Text('Confirm Booking',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
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
                Text('PNR: ${b['pnr']}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: b['status'] == 'Cancelled'
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(b['status'],
                    style: TextStyle(
                      color: b['status'] == 'Cancelled' ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.w700, fontSize: 12,
                    )),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.my_location_rounded, color: AppColors.success, size: 13),
                  const SizedBox(width: 6),
                  Expanded(child: Text(b['pickup'] ?? '',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.error, size: 13),
                  const SizedBox(width: 6),
                  Expanded(child: Text(b['drop'] ?? '',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                ]),
              ]),
            ),
            const Divider(height: 16),
            Row(children: [
              _infoChip(Icons.route_rounded, '${b['km']} km'),
              const SizedBox(width: 12),
              _infoChip(Icons.timer_rounded, '${b['eta']} min'),
              const SizedBox(width: 12),
              _infoChip(Icons.payment_rounded, b['payment']),
              const Spacer(),
              Text('₹${b['fare']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ]),
            const SizedBox(height: 10),
            if (b['status'] != 'Cancelled')
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => setState(() => _myBookings[i]['status'] = 'Cancelled'),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 12)),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(
                  // ✅ FIX: seedha RideTrackingScreen pe Navigator.push se navigate karo,
                  // saare required params ke saath. Pehle yeh context.push('/tracking/$pnr')
                  // use karta tha jo generic TrackingScreen (food order ke liye) pe le jaata
                  // tha — wahan order null hota tha aur '!' operator null pe crash kar deta tha.
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RideTrackingScreen(
                        pnr: b['pnr'] as String,
                        pickup: b['pickup'] as String,
                        drop: b['drop'] as String,
                        rideType: b['type'] as String,
                        fare: b['fare'] as int,
                        km: b['km'] as int,
                        eta: b['eta'] as int,
                        payment: b['payment'] as String,
                      ),
                    ),
                  ),
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

  String _rideEmoji(String type) {
    switch (type) {
      case 'Auto':  return '🛺';
      case 'Mini':  return '🚗';
      case 'Sedan': return '🚙';
      case 'SUV':   return '🚐';
      case 'Bike':  return '🏍️';
      default:      return '🚕';
    }
  }
}
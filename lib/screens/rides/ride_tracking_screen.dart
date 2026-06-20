// lib/screens/rides/ride_tracking_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_colors.dart';

class RideTrackingScreen extends StatefulWidget {
  final String pnr;
  final String pickup;
  final String drop;
  final String rideType;
  final int fare;
  final int km;
  final int eta;
  final String payment;

  const RideTrackingScreen({
    super.key,
    required this.pnr,
    required this.pickup,
    required this.drop,
    required this.rideType,
    required this.fare,
    required this.km,
    required this.eta,
    required this.payment,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with TickerProviderStateMixin {
  // Mumbai coords
  static const _pickupPos  = LatLng(19.0596, 72.8295); // Bandra West
  static const _dropPos    = LatLng(19.1136, 72.8697); // Andheri East

  late LatLng _driverPos;
  late int _etaMinutes;
  late String _driverName;
  late String _driverPhone;
  late String _vehicleNo;
  late double _rating;
  late int _totalRides;

  Timer? _moveTimer;
  Timer? _etaTimer;
  int _step = 0; // 0=arriving, 1=picked up, 2=on the way, 3=reached

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<String> _stepLabels = ['Driver Arriving', 'Picked Up', 'On the Way', 'Reached'];
  final List<IconData> _stepIcons = [
    Icons.directions_car_rounded,
    Icons.person_rounded,
    Icons.route_rounded,
    Icons.flag_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _driverPos    = const LatLng(19.0580, 72.8270); // driver starts nearby
    _etaMinutes   = widget.eta;
    _driverName   = _randomDriver();
    _driverPhone  = '98${_rand(10000000, 99999999)}';
    _vehicleNo    = 'MH 0${_rand(1, 9)} ${_randPlate()}';
    _rating       = 3.8 + (_rand(0, 12) / 10);
    _totalRides   = _rand(120, 3500);

    // Pulse animation for driver marker
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Move driver toward pickup every 3s
    _moveTimer = Timer.periodic(const Duration(seconds: 3), (_) => _moveDriver());

    // Count down ETA every 60s
    _etaTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_etaMinutes > 1) setState(() => _etaMinutes--);
    });
  }

  int _rand(int min, int max) => min + Random().nextInt(max - min);

  String _randPlate() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    final r = Random();
    return '${chars[r.nextInt(chars.length)]}${chars[r.nextInt(chars.length)]} '
        '${_rand(1000, 9999)}';
  }

  String _randomDriver() {
    const names = [
      'Raju Sharma', 'Suresh Patil', 'Anil Kumar', 'Vijay Singh',
      'Ramesh Yadav', 'Manoj Gupta', 'Deepak Nair', 'Sanjay More',
    ];
    return names[Random().nextInt(names.length)];
  }

  void _moveDriver() {
    if (!mounted) return;
    setState(() {
      final target = _step == 0 ? _pickupPos : _dropPos;
      final dLat   = (target.latitude  - _driverPos.latitude)  * 0.18;
      final dLng   = (target.longitude - _driverPos.longitude) * 0.18;
      _driverPos   = LatLng(_driverPos.latitude + dLat, _driverPos.longitude + dLng);

      // Advance step
      final distToTarget = const Distance().as(
          LengthUnit.Meter, _driverPos, target);
      if (_step == 0 && distToTarget < 100) {
        _step = 1;
        _showSnack('Driver has arrived! 🚕');
      } else if (_step == 2 && distToTarget < 100) {
        _step = 3;
        _moveTimer?.cancel();
        _showSnack('You have reached your destination! 🎉');
      }
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _etaTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _rideEmoji {
    switch (widget.rideType) {
      case 'Auto':  return '🛺';
      case 'Mini':  return '🚗';
      case 'Sedan': return '🚙';
      case 'SUV':   return '🚐';
      case 'Bike':  return '🏍️';
      default:      return '🚕';
    }
  }

  @override
  Widget build(BuildContext context) {
    final midLat = (_driverPos.latitude  + _dropPos.latitude)  / 2;
    final midLng = (_driverPos.longitude + _dropPos.longitude) / 2;

    return Scaffold(
      body: Stack(children: [
        // ── MAP ─────────────────────────────────────────────────────────────
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(midLat, midLng),
            initialZoom: 13.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fastkart.app',
            ),
            PolylineLayer(polylines: [
              Polyline(
                points: [_driverPos, _pickupPos, _dropPos],
                color: AppColors.primary.withValues(alpha: 0.7),
                strokeWidth: 4,
                isDotted: true,
              ),
            ]),
            MarkerLayer(markers: [
              // Pickup marker
              Marker(
                point: _pickupPos,
                width: 44, height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                ),
              ),
              // Drop marker
              Marker(
                point: _dropPos,
                width: 44, height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                ),
              ),
              // Driver marker (animated)
              Marker(
                point: _driverPos,
                width: 54, height: 54,
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10)],
                    ),
                    child: Center(
                      child: Text(_rideEmoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),

        // ── BACK BUTTON ──────────────────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
          ),
        ),

        // ── PNR BADGE ────────────────────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.confirmation_number_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(widget.pnr,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      fontFamily: 'monospace', color: AppColors.primary)),
            ]),
          ),
        ),

        // ── BOTTOM PANEL ─────────────────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 38, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),

              // Status + ETA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_stepIcons[_step], color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_stepLabels[_step],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      _step == 3 ? 'Have a great day! 🎉'
                          : _step == 0 ? 'Driver arriving in $_etaMinutes min'
                          : _step == 1 ? 'Starting your ride...'
                          : 'ETA $_etaMinutes min to destination',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ])),
                  if (_step < 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$_etaMinutes min',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                              color: AppColors.accent)),
                    ),
                ]),
              ),
              const SizedBox(height: 14),

              // Progress steps
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSteps(),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),

              // Driver info card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  // Avatar
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Center(child: Text(_rideEmoji, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_driverName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(_rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Text('· $_totalRides rides',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                    Text(_vehicleNo,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary,
                            fontFamily: 'monospace')),
                  ])),
                  // Call button
                  _iconBtn(Icons.phone_rounded, AppColors.success, () {
                    _showSnack('Calling $_driverName...');
                  }),
                  const SizedBox(width: 8),
                  // Chat button
                  _iconBtn(Icons.chat_bubble_outline_rounded, AppColors.primary, () {
                    _showSnack('Chat coming soon!');
                  }),
                ]),
              ),
              const SizedBox(height: 12),

              // Route info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Row(children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.pickup,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                      Expanded(child: Text(widget.drop,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const Divider(height: 14),
                    Row(children: [
                      _chip(Icons.route_rounded, '${widget.km} km'),
                      const SizedBox(width: 12),
                      _chip(Icons.payment_rounded, widget.payment),
                      const Spacer(),
                      Text('₹${widget.fare}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                              color: AppColors.accent)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // Bottom buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(children: [
                    if (_step < 2)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showCancelDialog(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel Ride',
                              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    if (_step < 2) const SizedBox(width: 10),
                    Expanded(
                      flex: _step < 2 ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _step == 1
                            ? () => setState(() { _step = 2; _etaMinutes = widget.km ~/ 3 + 5; })
                            : _step == 3
                                ? () => Navigator.pop(context)
                                : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _step == 1 ? 'Start Ride'
                              : _step == 3 ? 'Done'
                              : _step == 2 ? 'Ride in Progress...'
                              : 'Waiting for Driver...',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSteps() {
    return Row(
      children: List.generate(_stepLabels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final si = i ~/ 2;
          return Expanded(child: Container(height: 2,
              color: si < _step ? AppColors.primary : AppColors.divider));
        }
        final si   = i ~/ 2;
        final done = si < _step;
        final active = si == _step;
        return Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: active ? 30 : 26, height: active ? 30 : 26,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : active ? AppColors.primary : AppColors.divider,
              shape: BoxShape.circle,
              border: active ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3) : null,
            ),
            child: Icon(
              done ? Icons.check_rounded : _stepIcons[si],
              size: active ? 14 : 12,
              color: (done || active) ? Colors.white : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(_stepLabels[si],
              style: TextStyle(
                  fontSize: 7,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w400,
                  color: active ? AppColors.primary : done ? AppColors.textPrimary : AppColors.textHint)),
        ]);
      }),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Row(children: [
    Icon(icon, size: 13, color: AppColors.textSecondary),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
  ]);

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Ride?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Driver is on the way. Cancellation fee may apply.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep Ride')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
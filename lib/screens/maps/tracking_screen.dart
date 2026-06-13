import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/order_provider.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Mumbai, Bandra West - delivery destination
  static const _dest = LatLng(19.0596, 72.8295);

  // Driver path approaching destination (Bandra area)
  final List<LatLng> _path = const [
    LatLng(19.0650, 72.8340),
    LatLng(19.0638, 72.8328),
    LatLng(19.0625, 72.8318),
    LatLng(19.0615, 72.8310),
    LatLng(19.0605, 72.8302),
    LatLng(19.0596, 72.8295),
  ];

  final List<OrderStatus> _statuses = const [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.pickedUp,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  final List<String> _stepIcons  = ['✓', '🍳', '🛵', '📍', '🏠'];
  final List<String> _stepLabels = ['Confirmed', 'Preparing', 'Picked Up', 'On the Way', 'Delivered'];

  int _step = 0;
  OrderStatus _status = OrderStatus.confirmed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_step < _path.length - 1) _step++;
        final si = (_step / (_path.length / _statuses.length)).floor()
            .clamp(0, _statuses.length - 1);
        _status = _statuses[si];
        if (_step >= _path.length - 1) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  LatLng get _driverPos => _path[_step];

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>().byId(widget.orderId);

    return Scaffold(
      body: Stack(children: [
        // Map
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              (_driverPos.latitude + _dest.latitude) / 2,
              (_driverPos.longitude + _dest.longitude) / 2,
            ),
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.swiggy.app',
            ),
            PolylineLayer(polylines: [
              Polyline(
                points: [_driverPos, _dest],
                color: AppColors.mapRoute,
                strokeWidth: 4,
                isDotted: true,
              ),
            ]),
            MarkerLayer(markers: [
              // Home
              Marker(
                point: _dest,
                width: 44,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.black87, size: 20),
                ),
              ),
              // Driver
              Marker(
                point: _driverPos,
                width: 44,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: const Icon(Icons.delivery_dining,
                      color: AppColors.accent, size: 22),
                ),
              ),
            ]),
          ],
        ),

        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8)
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
          ),
        ),

        // Bottom panel
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4))
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),

              // Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status == OrderStatus.delivered
                          ? 'Order Delivered!'
                          : '${_status.label}  ·  ETA ${_eta()} min',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
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

              // Driver info
              if (order?.driverName != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.divider,
                      backgroundImage: order?.driverImage != null
                          ? NetworkImage(order!.driverImage!)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(order?.driverName ?? 'Driver',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const Text('Your delivery rider',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                    ),
                    _iconBtn(Icons.phone_rounded, AppColors.success),
                    const SizedBox(width: 10),
                    _iconBtn(Icons.chat_bubble_outline_rounded,
                        AppColors.primary),
                  ]),
                ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSteps() {
    final curIdx = _statuses.indexOf(_status);
    return Row(
      children: List.generate(_stepIcons.length * 2 - 1, (i) {
        if (i.isOdd) {
          final si = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: si < curIdx ? AppColors.primary : AppColors.divider,
            ),
          );
        }
        final si = i ~/ 2;
        final done = si <= curIdx;
        return Column(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_stepIcons[si],
                  style: TextStyle(
                      fontSize: 10,
                      color: done ? Colors.black87 : AppColors.textHint)),
            ),
          ),
          const SizedBox(height: 4),
          Text(_stepLabels[si],
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                  color: done ? AppColors.textPrimary : AppColors.textHint)),
        ]);
      }),
    );
  }

  Widget _iconBtn(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  int _eta() {
    final rem = _path.length - 1 - _step;
    return (rem * 3 / 60 * 60).round().clamp(1, 30);
  }
}
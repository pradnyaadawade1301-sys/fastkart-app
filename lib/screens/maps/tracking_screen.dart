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
  static const _defaultDest   = LatLng(19.0596, 72.8295);
  static const _defaultDriver = LatLng(19.0620, 72.8315);

  final List<String> _stepIcons  = ['✓', '🍳', '🛵', '📍', '🏠'];
  final List<String> _stepLabels = ['Confirmed', 'Preparing', 'Picked Up', 'On the Way', 'Delivered'];

  final List<OrderStatus> _statuses = const [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.pickedUp,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    // Real WebSocket tracking shuru karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startTracking(widget.orderId);
    });
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopTracking();
    super.dispose();
  }

  LatLng _driverPos(Order? order) {
    if (order?.driverLat != null && order?.driverLng != null) {
      return LatLng(order!.driverLat!, order.driverLng!);
    }
    return _defaultDriver;
  }

  LatLng _destPos(Order? order) {
    if (order?.deliveryAddress.lat != 0 && order?.deliveryAddress.lng != 0) {
      return LatLng(order!.deliveryAddress.lat, order.deliveryAddress.lng);
    }
    return _defaultDest;
  }

  int _statusIndex(OrderStatus status) {
    final i = _statuses.indexOf(status);
    return i < 0 ? 0 : i;
  }

  int _eta(Order? order) {
    if (order?.estimatedDelivery == null) return 30;
    final diff = order!.estimatedDelivery!.difference(DateTime.now()).inMinutes;
    return diff.clamp(1, 60);
  }

  @override
  Widget build(BuildContext context) {
    // consumer — WebSocket update aane pe rebuild hoga
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final order = provider.byId(widget.orderId);
        final driverPos = _driverPos(order);
        final destPos   = _destPos(order);
        final status    = order?.status ?? OrderStatus.confirmed;
        final curIdx    = _statusIndex(status);

        return Scaffold(
          body: Stack(children: [
            // ── Map ──────────────────────────────────────────────────────────
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  (driverPos.latitude  + destPos.latitude)  / 2,
                  (driverPos.longitude + destPos.longitude) / 2,
                ),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fastkart.app',
                ),
                PolylineLayer(polylines: [
                  Polyline(
                    points: [driverPos, destPos],
                    color: AppColors.mapRoute,
                    strokeWidth: 4,
                    isDotted: true,
                  ),
                ]),
                MarkerLayer(markers: [
                  // Home marker
                  Marker(
                    point: destPos,
                    width: 44, height: 44,
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
                  // Driver marker
                  Marker(
                    point: driverPos,
                    width: 44, height: 44,
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

            // ── Back button ──────────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: 40, height: 40,
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

            // ── Bottom panel ─────────────────────────────────────────────────
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
                    width: 38, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 14),

                  // Status + ETA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          status == OrderStatus.delivered
                              ? 'Order Delivered! 🎉'
                              : '${status.label}  ·  ETA ${_eta(order)} min',
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
                    child: _buildSteps(curIdx),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),

                  // Driver info (WebSocket se aata hai)
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
                          child: order?.driverImage == null
                              ? const Icon(Icons.person, size: 22)
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
      },
    );
  }

  Widget _buildSteps(int curIdx) {
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
        final si   = i ~/ 2;
        final done = si <= curIdx;
        return Column(children: [
          Container(
            width: 26, height: 26,
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
      width: 42, height: 42,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
// lib/screens/maps/maps_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_colors.dart';

class _MarkerData {
  final LatLng point;
  final String name;
  final double rating;
  const _MarkerData(this.point, this.name, this.rating);
}

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  // Mumbai, Bandra area
  static const _center = LatLng(19.0596, 72.8295);

  static const _markers = [
    _MarkerData(LatLng(19.0610, 72.8310), 'Swad Bhavan',     4.8),
    _MarkerData(LatLng(19.0580, 72.8275), 'Tandoor Express', 4.6),
    _MarkerData(LatLng(19.0620, 72.8320), 'Bombay Tadka',    4.5),
    _MarkerData(LatLng(19.0572, 72.8260), 'Desi Dhaba',      4.4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        backgroundColor: AppColors.primary,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Stack(children: [
        FlutterMap(
          options: const MapOptions(
              initialCenter: _center, initialZoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.swiggy.app',
            ),
            MarkerLayer(
              markers: [
                // User marker
                Marker(
                  point: _center,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.person_pin,
                        color: Colors.black87, size: 20),
                  ),
                ),
                // Restaurant markers
                ..._markers.map((m) => Marker(
                      point: m.point,
                      width: 60,
                      height: 55,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Text('⭐${m.rating}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.restaurant,
                              color: Colors.white, size: 13),
                        ),
                      ]),
                    )),
              ],
            ),
          ],
        ),

        // Bottom cards
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 170,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4))
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Nearby',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _markers.length,
                  itemBuilder: (_, i) {
                    final m = _markers[i];
                    return Container(
                      width: 155,
                      margin: const EdgeInsets.only(right: 12, bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 12, color: AppColors.star),
                          Text(' ${m.rating}',
                              style: const TextStyle(fontSize: 11)),
                        ]),
                      ]),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
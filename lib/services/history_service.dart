// lib/services/history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _key = 'fastkart_history';
  static HistoryService? _instance;

  static HistoryService get instance => _instance ??= HistoryService._();
  HistoryService._();

  Future<void> saveItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllItems();
    all.removeWhere((e) => e.id == item.id);
    all.insert(0, item);
    await prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<List<HistoryItem>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<HistoryItem>> getByCategory(HistoryCategory category) async {
    final all = await getAllItems();
    return all.where((e) => e.category == category).toList();
  }

  Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllItems();
    all.removeWhere((e) => e.id == id);
    await prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> updateStatus(String id, HistoryStatus status) async {
    final all = await getAllItems();
    final idx = all.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    all[idx] = all[idx].copyWith(status: status);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static HistoryItem makeFood({
    required String id, required String restaurant, required String location,
    required List<String> items, required double amount,
    HistoryStatus status = HistoryStatus.delivered, String? restaurantId,
  }) => HistoryItem(
    id: id, category: HistoryCategory.food,
    title: '$restaurant — $location', subtitle: '${items.length} items',
    description: items.join(' · '), amount: amount, date: DateTime.now(),
    status: status, extra: {'restaurantId': restaurantId ?? '', 'canReorder': true},
  );

  static HistoryItem makeMovie({
    required String id, required String movieName, required String cinema,
    required String seatInfo, required double amount, required DateTime showTime,
    HistoryStatus status = HistoryStatus.confirmed,
  }) => HistoryItem(
    id: id, category: HistoryCategory.movies, title: movieName,
    subtitle: '$cinema · $seatInfo', description: seatInfo,
    amount: amount, date: showTime, status: status, extra: {'cinema': cinema},
  );

  static HistoryItem makeHotel({
    required String id, required String hotelName, required String city,
    required String roomType, required int nights, required int guests,
    required double amount, required DateTime checkIn, required DateTime checkOut,
    HistoryStatus status = HistoryStatus.confirmed,
  }) => HistoryItem(
    id: id, category: HistoryCategory.hotels, title: hotelName,
    subtitle: '$city · $nights nights · $guests guests',
    description: '$roomType · $nights nights · $guests adults',
    amount: amount, date: checkIn, status: status,
    extra: {'checkIn': checkIn.toIso8601String(), 'checkOut': checkOut.toIso8601String(), 'roomType': roomType},
  );

  static HistoryItem makeLeisure({
    required String id, required String activityName, required String venue,
    required String details, required double amount, required DateTime date,
    HistoryStatus status = HistoryStatus.confirmed,
  }) => HistoryItem(
    id: id, category: HistoryCategory.leisure, title: activityName,
    subtitle: venue, description: details, amount: amount, date: date,
    status: status, extra: {'venue': venue},
  );

  static HistoryItem makeRide({
    required String id, required String from, required String to,
    required String driverName, required double distanceKm,
    required int durationMins, required double amount,
    HistoryStatus status = HistoryStatus.completed, bool isBike = false,
  }) => HistoryItem(
    id: id, category: isBike ? HistoryCategory.bike : HistoryCategory.ride,
    title: '$from → $to',
    subtitle: '${distanceKm.toStringAsFixed(1)} km · $durationMins mins',
    description: 'Driver: $driverName · ${distanceKm.toStringAsFixed(1)} km · $durationMins mins',
    amount: amount, date: DateTime.now(), status: status,
    extra: {'from': from, 'to': to, 'driver': driverName, 'distanceKm': distanceKm, 'durationMins': durationMins},
  );

  static HistoryItem makeTravel({
    required String id, required String route, required String airline,
    required String flightNo, required String classType, required int passengers,
    required String pnr, required double amount, required DateTime travelDate,
    HistoryStatus status = HistoryStatus.confirmed,
  }) => HistoryItem(
    id: id, category: HistoryCategory.travel, title: '$route · $airline',
    subtitle: '$passengers adult · $classType',
    description: '$flightNo · $classType · $passengers adult',
    amount: amount, date: travelDate, status: status,
    extra: {'pnr': pnr, 'flightNo': flightNo, 'airline': airline},
  );

  static HistoryItem makeGrocery({
    required String id, required String storeName, required List<String> items,
    required double amount, HistoryStatus status = HistoryStatus.delivered,
  }) => HistoryItem(
    id: id, category: HistoryCategory.grocery, title: '$storeName Order',
    subtitle: '${items.length} items', description: items.join(' · '),
    amount: amount, date: DateTime.now(), status: status, extra: {'canReorder': true},
  );

  static HistoryItem makeMore({
    required String id, required String title, required String subtitle,
    required String description, required double amount, required DateTime date,
    HistoryStatus status = HistoryStatus.success,
  }) => HistoryItem(
    id: id, category: HistoryCategory.more, title: title,
    subtitle: subtitle, description: description, amount: amount, date: date, status: status,
  );
}
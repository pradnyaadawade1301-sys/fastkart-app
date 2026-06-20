// lib/providers/favourites_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

// NOTE: favourite_provider.dart ko delete karo — yeh wala use karo.
// Saare screens mein FavouritesProvider hi use hona chahiye.

class FavouritesProvider extends ChangeNotifier {
  static const _key = 'fav_restaurant_ids';

  final List<Restaurant> _favourites = [];
  bool _loaded = false;

  List<Restaurant> get favourites => List.unmodifiable(_favourites);
  int get count => _favourites.length;

  bool isFavourite(String restaurantId) =>
      _favourites.any((r) => r.id == restaurantId);

  // App start hone pe SharedPreferences se load karo
  Future<void> loadFromStorage(List<Restaurant> allRestaurants) async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? [];
      for (final id in saved) {
        final found = allRestaurants.where((r) => r.id == id).toList();
        if (found.isNotEmpty && !isFavourite(id)) {
          _favourites.add(found.first);
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('FavouritesProvider load error: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _favourites.map((r) => r.id).toList());
    } catch (e) {
      if (kDebugMode) debugPrint('FavouritesProvider persist error: $e');
    }
  }

  void toggle(Restaurant restaurant) {
    final index = _favourites.indexWhere((r) => r.id == restaurant.id);
    if (index >= 0) {
      _favourites.removeAt(index);
    } else {
      _favourites.add(restaurant);
    }
    notifyListeners();
    _persist();
  }

  void addFavourite(Restaurant restaurant) {
    if (!isFavourite(restaurant.id)) {
      _favourites.add(restaurant);
      notifyListeners();
      _persist();
    }
  }

  void removeFavourite(String restaurantId) {
    _favourites.removeWhere((r) => r.id == restaurantId);
    notifyListeners();
    _persist();
  }
}
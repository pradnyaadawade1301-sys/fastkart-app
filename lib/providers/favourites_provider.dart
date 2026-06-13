// lib/providers/favourites_provider.dart
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/mock_data.dart';

class FavouritesProvider extends ChangeNotifier {
  final List<Restaurant> _favourites = [];

  List<Restaurant> get favourites => List.unmodifiable(_favourites);

  bool isFavourite(String restaurantId) =>
      _favourites.any((r) => r.id == restaurantId);

  void toggle(String restaurantId) {
    final index = _favourites.indexWhere((r) => r.id == restaurantId);
    if (index >= 0) {
      _favourites.removeAt(index);
    } else {
      final all = MockData.restaurants();
      final found = all.where((r) => r.id == restaurantId).toList();
      if (found.isNotEmpty) _favourites.add(found.first);
    }
    notifyListeners();
  }

  void addFavourite(Restaurant restaurant) {
    if (!isFavourite(restaurant.id)) {
      _favourites.add(restaurant);
      notifyListeners();
    }
  }

  void removeFavourite(String restaurantId) {
    _favourites.removeWhere((r) => r.id == restaurantId);
    notifyListeners();
  }

  int get count => _favourites.length;
}
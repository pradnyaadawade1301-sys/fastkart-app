// lib/providers/restaurant_provider.dart
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/mock_data.dart';

class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> _all = [];
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isLoaded = false; // ← ADDED
  String _query = '';
  String _selectedCategory = '';

  List<Restaurant> get restaurants => _filtered;
  List<BannerModel> get banners => _banners;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded; // ← ADDED
  String get query => _query;
  String get selectedCategory => _selectedCategory;

  List<Restaurant> get _filtered {
    var list = List<Restaurant>.from(_all);
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.categories.any((c) => c.toLowerCase().contains(q)))
          .toList();
    }
    if (_selectedCategory.isNotEmpty) {
      list = list
          .where((r) => r.categories.any(
              (c) => c.toLowerCase() == _selectedCategory.toLowerCase()))
          .toList();
    }
    return list;
  }

  Future<void> loadData() async {
    if (_isLoaded) return; // ← ADDED: pehle se loaded hai toh skip
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _all = MockData.restaurants();
    _banners = MockData.banners();
    _categories = MockData.categories();
    _isLoading = false;
    _isLoaded = true; // ← ADDED
    notifyListeners();
  }

  // ← ADDED: pull-to-refresh ke liye
  Future<void> refreshData() async {
    _isLoaded = false;
    await loadData();
  }

  Restaurant? byId(String id) {
    try {
      return _all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void search(String q) {
    _query = q;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = _selectedCategory == category ? '' : category;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final i = _all.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _all[i] = _all[i].copyWith(isFavorite: !_all[i].isFavorite);
      notifyListeners();
    }
  }

  List<Restaurant> topRated() {
    final list = List<Restaurant>.from(_all)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(5).toList();
  }
}
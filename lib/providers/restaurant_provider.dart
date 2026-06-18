// lib/providers/restaurant_provider.dart
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart'; // fallback ke liye

class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> _all = [];
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String _query = '';
  String _selectedCategory = '';
  String? _error;

  List<Restaurant> get restaurants => _filtered;
  List<BannerModel> get banners => _banners;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
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

  // ── Load Data — API se, fallback mock ──────────────────────────────────────
  Future<void> loadData() async {
    if (_isLoaded) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final backendOnline = await ApiService.isBackendOnline();

      if (backendOnline) {
        // Real API se data lo
        final data = await ApiService.getRestaurants();
        if (data != null && data.isNotEmpty) {
          _all = data.map((r) => _restaurantFromJson(r)).toList();
        } else {
          _all = MockData.restaurants(); // fallback
        }
      } else {
        // Backend offline — mock data use karo
        if (kDebugMode) debugPrint('⚠️ Backend offline, mock data use ho raha hai');
        _all = MockData.restaurants();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('loadData error: $e');
      _all = MockData.restaurants(); // error pe bhi mock fallback
      _error = 'Data load nahi hua, mock data dikh raha hai';
    }

    _banners = MockData.banners();     // banners abhi mock (CMS baad mein)
    _categories = MockData.categories(); // categories mock

    _isLoading = false;
    _isLoaded = true;
    notifyListeners();
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refreshData() async {
    _isLoaded = false;
    await loadData();
  }

  // ── Single restaurant detail (menu ke saath) ───────────────────────────────
  Future<Restaurant?> fetchRestaurantDetail(String id) async {
    try {
      final data = await ApiService.getRestaurant(id);
      if (data != null) return _restaurantFromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('fetchRestaurantDetail error: $e');
    }
    return byId(id); // local cache fallback
  }

  // ── Local helpers ──────────────────────────────────────────────────────────
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

  // ── JSON → Restaurant model ────────────────────────────────────────────────
  Restaurant _restaurantFromJson(Map<String, dynamic> r) {
    return Restaurant(
      id: r['id']?.toString() ?? '',
      name: r['name']?.toString() ?? '',
      imageUrl: r['image_url']?.toString() ?? r['imageUrl']?.toString() ?? '',
      coverUrl: r['cover_url']?.toString() ?? r['coverUrl']?.toString() ?? '',
      rating: (r['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount: (r['review_count'] as num?)?.toInt() ?? 0,
      deliveryTime: r['delivery_time']?.toString() ?? '30-40 min',
      deliveryFee: (r['delivery_fee'] as num?)?.toDouble() ?? 40.0,
      minOrder: (r['min_order'] as num?)?.toDouble() ?? 99.0,
      distance: r['distance']?.toString() ?? '2.5 km',
      isOpen: r['is_open'] as bool? ?? true,
      isFavorite: r['is_favorite'] as bool? ?? false,
      categories: List<String>.from(r['categories'] ?? r['tags'] ?? []),
      address: r['address']?.toString() ?? '',
      lat: (r['latitude'] as num?)?.toDouble() ?? 0.0,
      lng: (r['longitude'] as num?)?.toDouble() ?? 0.0,
      menu: _menuFromJson(r['menu']),
      tags: List<String>.from(r['tags'] ?? []),
      description: r['description']?.toString() ?? '',
    );
  }

  List<FoodItem> _menuFromJson(dynamic menuData) {
    if (menuData == null) return [];
    try {
      return (menuData as List).map((item) => FoodItem(
        id: item['id']?.toString() ?? '',
        name: item['name']?.toString() ?? '',
        description: item['description']?.toString() ?? '',
        imageUrl: item['image_url']?.toString() ?? '',
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (item['original_price'] as num?)?.toDouble() ?? 0.0,
        category: item['category']?.toString() ?? '',
        isPopular: item['is_popular'] as bool? ?? false,
        isNew: item['is_new'] as bool? ?? false,
        rating: (item['rating'] as num?)?.toDouble() ?? 0.0,
        soldCount: (item['sold_count'] as num?)?.toInt() ?? 0,
        restaurantId: item['restaurant_id']?.toString() ?? '',
      )).toList();
    } catch (_) {
      return [];
    }
  }
}
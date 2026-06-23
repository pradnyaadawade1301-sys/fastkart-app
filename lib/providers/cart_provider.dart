// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/app_models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  String _promoCode = '';
  double _discount = 0;

  List<CartItem> get items => _items;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  String get promoCode => _promoCode;
  double get discount => _discount;

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;
  double get subtotal => _items.fold(0, (sum, i) => sum + i.totalPrice);
  double get deliveryFee => subtotal >= 300 ? 0 : 40;
  double get total => subtotal + deliveryFee - _discount;

  void addItem(FoodItem food, {int quantity = 1, List<FoodOptionItem>? options, String note = ''}) {
    final idx = _items.indexWhere((i) => i.food.id == food.id);
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _restaurantId ??= food.restaurantId;
      _restaurantName ??= food.name;
      _items.add(CartItem(food: food, quantity: quantity, selectedOptions: options ?? [], note: note));
    }
    notifyListeners();
  }

  void updateQuantity(String foodId, int qty) {
    final idx = _items.indexWhere((i) => i.food.id == foodId);
    if (idx < 0) return;
    if (qty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx].quantity = qty;
    }
    if (_items.isEmpty) _reset();
    notifyListeners();
  }

  int quantityOf(String foodId) =>
      _items.firstWhere((i) => i.food.id == foodId,
          orElse: () => CartItem(food: const FoodItem(
              id: '', name: '', description: '', imageUrl: '',
              price: 0, category: '', restaurantId: ''))).quantity;

  void applyPromo(String code) {
    final promos = {'FIRST50': 50.0, 'SAVE20': 20.0, 'FREEDEL': 40.0, 'FRESHKART': 30.0};
    if (promos.containsKey(code.toUpperCase())) {
      _promoCode = code.toUpperCase();
      _discount = promos[code.toUpperCase()]!;
      notifyListeners();
    }
  }

  void removePromo() {
    _promoCode = '';
    _discount = 0;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _reset();
    notifyListeners();
  }

  void _reset() {
    _restaurantId = null;
    _restaurantName = null;
    _promoCode = '';
    _discount = 0;
  }
}
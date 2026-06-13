// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  bool isLoading = false;
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get activeOrders => _orders.where((o) => o.status.isActive).toList();
  List<Order> get pastOrders => _orders.where((o) => o.status == OrderStatus.delivered).toList();
  List<Order> get cancelledOrders => _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  Future<void> loadOrders() async {
    if (_orders.isNotEmpty) return;
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _orders.addAll(MockData.sampleOrders());
    isLoading = false;
    notifyListeners();
  }

  Order? byId(String id) {
    try { return _orders.firstWhere((o) => o.id == id); } catch (_) { return null; }
  }

  Order? getById(String id) => byId(id);

  Future<Order?> placeOrder({
    required String restaurantId,
    required String restaurantName,
    required String restaurantImage,
    required List<OrderItemModel> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    double discount = 0,
    String? couponCode,
    required DeliveryAddress deliveryAddress,
    PaymentMethod paymentMethod = PaymentMethod.cash,
  }) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    final order = Order(
      id: 'ord${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantImage: restaurantImage,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      couponCode: couponCode,
      total: total,
      status: OrderStatus.placed,
      deliveryAddress: deliveryAddress,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 40)),
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == PaymentMethod.cash ? PaymentStatus.pending : PaymentStatus.paid,
      otp: (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString(),
    );
    _orders.insert(0, order);
    isLoading = false;
    notifyListeners();
    return order;
  }

  void updateStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: status);
    notifyListeners();
  }
}
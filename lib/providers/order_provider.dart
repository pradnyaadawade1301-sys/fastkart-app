// lib/providers/order_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class OrderProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  final List<Order> _orders = [];

  // WebSocket tracking
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSub;
  String? _trackingOrderId;

  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();
  List<Order> get pastOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).toList();
  List<Order> get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  // ── Load orders from API ───────────────────────────────────────────────────
  Future<void> loadOrders() async {
    if (_orders.isNotEmpty) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ApiService.getOrders();
      if (data != null) {
        _orders.clear();
        _orders.addAll(data.map((o) => _orderFromJson(o)));
      }
    } catch (e) {
      error = 'Orders load nahi hue: $e';
      if (kDebugMode) debugPrint('loadOrders error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refreshOrders() async {
    _orders.clear();
    await loadOrders();
  }

  // ── Place Order ────────────────────────────────────────────────────────────
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
    error = null;
    notifyListeners();

    try {
      final orderData = {
        'restaurant_id': restaurantId,
        'items': items.map((i) => {
          'menu_item_id': i.id,
          'quantity': i.quantity,
        }).toList(),
        'delivery_address': deliveryAddress.fullAddress,
        'delivery_latitude': deliveryAddress.lat,
        'delivery_longitude': deliveryAddress.lng,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        'payment_method': _paymentMethodStr(paymentMethod),
      };

      final response = await ApiService.placeOrder(orderData);

      if (response != null) {
        final order = Order(
          id: response['order_id']?.toString() ?? '',
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          restaurantImage: restaurantImage,
          items: items,
          subtotal: (response['subtotal'] as num?)?.toDouble() ?? subtotal,
          deliveryFee: (response['delivery_fee'] as num?)?.toDouble() ?? deliveryFee,
          discount: (response['discount'] as num?)?.toDouble() ?? discount,
          couponCode: couponCode,
          total: (response['total'] as num?)?.toDouble() ?? total,
          status: _parseStatus(response['status']?.toString()),
          deliveryAddress: deliveryAddress,
          createdAt: DateTime.now(),
          estimatedDelivery: response['estimated_delivery'] != null
              ? DateTime.tryParse(response['estimated_delivery'].toString())
              : DateTime.now().add(const Duration(minutes: 40)),
          paymentMethod: paymentMethod,
          paymentStatus: paymentMethod == PaymentMethod.cash
              ? PaymentStatus.pending
              : PaymentStatus.paid,
          otp: (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString(),
        );

        _orders.insert(0, order);
        isLoading = false;
        notifyListeners();

        // WebSocket tracking start karo
        startTracking(order.id);

        return order;
      }
    } catch (e) {
      error = 'Order place nahi hua: $e';
      if (kDebugMode) debugPrint('placeOrder error: $e');
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  // ── Cancel Order ───────────────────────────────────────────────────────────
  Future<bool> cancelOrder(String orderId) async {
    try {
      final success = await ApiService.cancelOrder(orderId);
      if (success) {
        updateStatus(orderId, OrderStatus.cancelled);
        stopTracking();
        return true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('cancelOrder error: $e');
    }
    return false;
  }

  // ── WebSocket Tracking ─────────────────────────────────────────────────────
  void startTracking(String orderId) {
    if (_trackingOrderId == orderId) return; // already tracking
    stopTracking();

    _trackingOrderId = orderId;

    try {
      // ws://10.0.2.2:8080/api/v1/orders/track/ws/{order_id}
      final wsUrl = ApiConfig.baseUrl
          .replaceFirst('http', 'ws')
          .replaceFirst('/api/v1', '') +
          '/api/v1/orders/track/ws/$orderId';

      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _wsSub = _wsChannel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message.toString()) as Map<String, dynamic>;
            _handleTrackingUpdate(orderId, data);
          } catch (e) {
            if (kDebugMode) debugPrint('WS parse error: $e');
          }
        },
        onError: (e) {
          if (kDebugMode) debugPrint('WS error: $e');
        },
        onDone: () {
          if (kDebugMode) debugPrint('WS closed for order: $orderId');
        },
      );

      if (kDebugMode) debugPrint('✅ WS tracking started: $orderId');
    } catch (e) {
      if (kDebugMode) debugPrint('WS connect error: $e');
    }
  }

  void stopTracking() {
    _wsSub?.cancel();
    _wsChannel?.sink.close();
    _wsChannel = null;
    _wsSub = null;
    _trackingOrderId = null;
  }

  void _handleTrackingUpdate(String orderId, Map<String, dynamic> data) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    final order = _orders[idx];
    final newStatus = _parseStatus(data['status']?.toString());
    final driverLat = (data['driver_lat'] as num?)?.toDouble();
    final driverLng = (data['driver_lng'] as num?)?.toDouble();

    _orders[idx] = order.copyWith(
      status: newStatus,
      driverName: data['driver_name']?.toString() ?? order.driverName,
      driverPhone: data['driver_phone']?.toString() ?? order.driverPhone,
      driverImage: data['driver_image']?.toString() ?? order.driverImage,
      driverLat: driverLat ?? order.driverLat,
      driverLng: driverLng ?? order.driverLng,
    );

    notifyListeners();

    // Delivered ho gaya toh tracking band karo
    if (newStatus == OrderStatus.delivered) {
      stopTracking();
    }
  }

  // ── Local helpers ──────────────────────────────────────────────────────────
  Order? byId(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Order? getById(String id) => byId(id);

  void updateStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: status);
    notifyListeners();
  }

  // ── JSON → Order ───────────────────────────────────────────────────────────
  Order _orderFromJson(Map<String, dynamic> o) {
    return Order(
      id: o['id']?.toString() ?? '',
      restaurantId: o['restaurant_id']?.toString() ?? '',
      restaurantName: o['restaurant_name']?.toString() ?? '',
      restaurantImage: o['restaurant_image']?.toString() ?? '',
      items: _itemsFromJson(o['items']),
      subtotal: (o['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (o['delivery_fee'] as num?)?.toDouble() ?? 0,
      discount: (o['discount'] as num?)?.toDouble() ?? 0,
      couponCode: o['coupon_code']?.toString(),
      total: (o['total_amount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(o['status']?.toString()),
      deliveryAddress: DeliveryAddress(
        label: 'Home',
        fullAddress: o['delivery_address']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(o['created_at']?.toString() ?? '') ?? DateTime.now(),
      estimatedDelivery: o['estimated_delivery_time'] != null
          ? DateTime.tryParse(o['estimated_delivery_time'].toString())
          : null,
      paymentMethod: _parsePaymentMethod(o['payment_method']?.toString()),
      paymentStatus: o['payment_status'] == 'paid'
          ? PaymentStatus.paid
          : PaymentStatus.pending,
      otp: '',
    );
  }

  List<OrderItemModel> _itemsFromJson(dynamic items) {
    if (items == null) return [];
    try {
      return (items as List).map((i) => OrderItemModel(
        id: i['menu_item_id']?.toString() ?? '',
        name: i['item_name']?.toString() ?? '',
        imageUrl: i['image_url']?.toString() ?? '',
        price: (i['item_price'] as num?)?.toDouble() ?? 0,
        quantity: (i['quantity'] as num?)?.toInt() ?? 1,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready':
      case 'picked_up': return OrderStatus.pickedUp;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      case 'pending_payment':
      case 'pending':
      default: return OrderStatus.placed;
    }
  }

  PaymentMethod _parsePaymentMethod(String? method) {
    switch (method) {
      case 'razorpay': return PaymentMethod.upi;
      case 'wallet': return PaymentMethod.wallet;
      case 'cod':
      default: return PaymentMethod.cash;
    }
  }

  String _paymentMethodStr(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi: return 'razorpay';
      case PaymentMethod.wallet: return 'wallet';
      case PaymentMethod.cash:
      default: return 'cod';
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
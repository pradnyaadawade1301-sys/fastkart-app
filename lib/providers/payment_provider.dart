// lib/providers/payment_provider.dart
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required double amount,
    required String method, // 'upi', 'card', 'cash', 'wallet'
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return {'success': true, 'order_id': orderId};
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
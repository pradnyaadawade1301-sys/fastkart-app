// lib/services/stripe_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String kStripeBaseUrl = 'http://192.168.1.29:8080';

class StripeService {
  StripeService._();
  static final instance = StripeService._();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String orderId,
    required String description,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not logged in');

      // Step 1: Backend se PaymentIntent lo
      final intentRes = await http.post(
        Uri.parse('$kStripeBaseUrl/api/payments/stripe/intent'), // ✅ fixed
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'order_id': orderId,
          'amount': amount,
          'currency': 'inr',
        }),
      );

      if (intentRes.statusCode != 200) {
        throw Exception('Payment initiation failed');
      }

      final data = jsonDecode(intentRes.body);
      final clientSecret = data['client_secret'] as String;
      final paymentIntentId = data['payment_intent_id'] as String;

      // Step 2: Stripe Payment Sheet initialize karo
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FastKart',
          style: ThemeMode.light,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'IN',
            currencyCode: 'INR',
            testEnv: true,
          ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFFF6F00),
            ),
          ),
        ),
      );

      // Step 3: Payment Sheet dikhao
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Backend se verify karo
      final verifyRes = await http.post(
        Uri.parse('$kStripeBaseUrl/api/payments/stripe/verify'), // ✅ fixed
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'order_id': orderId,
          'payment_intent_id': paymentIntentId,
        }),
      );

      return verifyRes.statusCode == 200;

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }
}
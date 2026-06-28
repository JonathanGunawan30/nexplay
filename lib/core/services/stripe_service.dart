import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nexplay/core/constants/constants.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  final Dio _dio = Dio();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return AppConstants.stripeBaseUrl;
  }

  Future<bool> makePayment({
    required double amount,
    required String currency,
    required String email,
    required String name,
    required String gameName,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('Stripe is only supported on Android and iOS.');
      return false;
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/create-payment-intent',
        data: {
          'amount': (amount * 100).toInt(),
          'currency': currency,
        },
      );

      if (response.data == null || response.data['clientSecret'] == null) {
        return false;
      }

      final String clientSecret = response.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'NexPlay Gaming',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _dio.post(
        '$_baseUrl/send-invoice',
        data: {
          'email': email,
          'name': name,
          'gameName': gameName,
          'amount': (amount * 100).toInt(),
          'currency': currency,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Stripe Error: $e');
      if (e is StripeException) {
        debugPrint('Stripe Exception: ${e.error.localizedMessage}');
      }
      return false;
    }
  }
}

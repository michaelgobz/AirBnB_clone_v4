import 'package:flutter/material.dart';
import 'package:kin_music_player_app/services/network/api/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  bool isLoading = false;

  PaymentApiService paymentApiService = PaymentApiService();

  Future saveUserPaymentAndTrackInfo({
    required double paymentAmount,
    required String paymentMethod,
    required String paymentState,
    required String trackId,
    required Function onPaymentCompleteFunction,
  }) async {
    isLoading = true;

    await paymentApiService.saveUserPaymentAndTrackInfo(
      paymentAmount: paymentAmount,
      paymentMethod: paymentMethod,
      paymentState: paymentState,
      trackId: trackId,
    );

    isLoading = false;

    notifyListeners();
  }
}

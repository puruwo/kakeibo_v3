import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_frequency_controller.g.dart';

@riverpod
class PaymentFrequencyControllerNotifier extends _$PaymentFrequencyControllerNotifier {
  @override
  PaymentFrequencyValue build() {
    return PaymentFrequencyValue.fromDB(
      intervalNumber: 1,
      intervalUnitNumber: 1,
    );
  }

  void setData(PaymentFrequencyValue newState) {
    state = newState;
  }
}
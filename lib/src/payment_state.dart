// Global payment state management to prevent duplicate callbacks
class PaymentState {
  static final PaymentState _instance = PaymentState._internal();
  factory PaymentState() => _instance;
  PaymentState._internal();

  bool _paymentCompleted = false;

  bool get isPaymentCompleted => _paymentCompleted;

  void markPaymentCompleted() {
    print('🔒 Marking payment as completed globally');
    _paymentCompleted = true;
  }

  void resetPaymentState() {
    print('🔄 Resetting payment state');
    _paymentCompleted = false;
  }
}

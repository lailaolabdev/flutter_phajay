import 'package:flutter/material.dart';

class PaymentLinkScreen extends StatelessWidget {
  final String paymentUrl;

  const PaymentLinkScreen({Key? key, required this.paymentUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PhaJay Payment")),
      body: Center(child: Text("Payment URL: $paymentUrl")),
    );
  }
}

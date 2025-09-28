import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:flutter_phajay/src/qr_payment_screen.dart';

class PaymentLinkScreen extends StatelessWidget {
  final int amount;
  final String description;
  final String publicKey;

  const PaymentLinkScreen({
    Key? key,
    required this.amount,
    required this.description,
    required this.publicKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'packages/flutter_phajay/assets/logo-phajay.png',
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select For Payment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'The transaction has been successfully verified\nfor authenticity and security.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Total Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatThousand(amount)} LAK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'September 27, 2025   23:26:25',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Your safety is our top priority\nRest assured that your payment is secure. Be confident that your information will always be protected.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 30),

              // Banks Payment List
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Banks Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              BankTile(
                bankName: 'JDB',
                amount: amount,
                description: description,
                publicKey: publicKey,
              ),
              BankTile(
                bankName: 'LDB',
                amount: amount,
                description: description,
                publicKey: publicKey,
              ),
              BankTile(
                bankName: 'BCEL',
                amount: amount,
                description: description,
                publicKey: publicKey,
              ),
              BankTile(
                bankName: 'INDOCHINA BANK',
                amount: amount,
                description: description,
                publicKey: publicKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BankTile extends StatelessWidget {
  final int amount;
  final String description;
  final String publicKey;
  final String bankName;

  const BankTile({
    super.key,
    required this.bankName,
    required this.amount,
    required this.description,
    required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.account_balance, color: Colors.blue),
        title: Text(
          bankName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Payment processed through bank account'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRPaymentScreen(
                bankName: bankName,
                amount: amount,
                description: description,
                publicKey: publicKey,
              ),
            ),
          );
        },
      ),
    );
  }
}

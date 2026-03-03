import 'package:flutter/material.dart';
import 'package:flutter_phajay/flutter_phajay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: PhajayTheme.lightTheme, // Apply Noto Sans Lao theme
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool useCustomCallbacks = true; // Toggle this to test different approaches
  bool showPaymentScreen = false; // Control which screen to show

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showPaymentScreen) {
      // Show Payment Screen
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Payment',
            style: PhajayTheme.heading2.copyWith(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                showPaymentScreen = false;
              });
            },
          ),
        ),
        body: PaymentLinkScreen(
          amount: int.tryParse(_amountController.text) ?? 1,
          description: _descriptionController.text.isEmpty
              ? "Test Payment from Flutter Phajay"
              : _descriptionController.text,
          publicKey:
              // r"$2b$10$21qCgkB4ZX6HFUNZUrEya./tVYF0SqDEqXg3Q.gCvAuuSw5NTSelm",
              r"$2a$10$7pBgohWIIovcMxeAr7ItX.W1TkCkSIFZeRIjkTb3ZPvooztM8Kl0S",
          orderNo: "ORDER${DateTime.now().millisecondsSinceEpoch}",
          tag1: "flutter_test",
          tag2: "phajay_package",
          tag3: "v0.0.15",
          onPaymentSuccess: () {
            print('🔔 onPaymentSuccess called');

            // Reset to form screen
            setState(() {
              showPaymentScreen = false;
            });

            // Show success popup
            _showCustomSuccessPopup();
          },
          onPaymentError: (error) {
            // Reset to form screen
            setState(() {
              showPaymentScreen = false;
            });

            // Show error popup
            _showCustomErrorPopup(error);
            print('Payment error: $error');
          },
        ),
      );
    }

    // Show Form Screen
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter PhaJay Payment',
          style: PhajayTheme.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.payment, size: 48, color: Colors.blue),
                    SizedBox(height: 12),
                    Text(
                      'PhaJay Payment Gateway',
                      style: PhajayTheme.heading1.copyWith(
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Enter payment details to proceed',
                      style: PhajayTheme.bodyText.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Amount (LAK)',
                  hintText: 'Enter amount in Lao Kip',
                  prefixIcon: Icon(Icons.monetization_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Description Input
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter payment description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Pay Button
              ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 24),
                    SizedBox(width: 12),
                    Text('Pay Now', style: PhajayTheme.buttonText),
                  ],
                ),
              ),

              // Extra space at bottom to ensure button is accessible
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom > 0
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.grey.shade600,
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              child: Icon(Icons.keyboard_hide, color: Colors.white),
            )
          : null,
    );
  }

  void _validateAndProceed() {
    final amount = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    // Validation
    if (amount.isEmpty) {
      _showErrorSnackBar('Please enter an amount');
      return;
    }

    final parsedAmount = int.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      _showErrorSnackBar('Please enter a valid amount greater than 0');
      return;
    }

    if (description.isEmpty) {
      _showErrorSnackBar('Please enter a description');
      return;
    }

    // Proceed to payment
    setState(() {
      showPaymentScreen = true;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showCustomSuccessPopup() {
    print('🔥 _showCustomSuccessPopup called');

    final amount = int.tryParse(_amountController.text) ?? 0;
    final description = _descriptionController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'ຊໍາລະສໍາເລັດ!',
                style: PhajayTheme.heading3,
              ), // Payment Success in Lao
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ຈໍານວນເງິນ: $amount LAK', style: PhajayTheme.bodyText),
              Text('ລາຍລະອຽດ: $description', style: PhajayTheme.bodyText),
              SizedBox(height: 16),
              Text(
                'ຂອບໃຈທີ່ໃຊ້ບໍລິການຂອງເຮົາ',
                style: PhajayTheme.bodyTextSmall,
              ),
              SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // You can add more navigation logic here
              },
              child: Text(
                'ຕົກລົງ',
                style: PhajayTheme.buttonText.copyWith(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCustomErrorPopup(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('ຂໍ້ຜິດພາດ', style: PhajayTheme.heading3), // Error in Lao
            ],
          ),
          content: Text(error, style: PhajayTheme.bodyText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ຕົກລົງ',
                style: PhajayTheme.buttonText.copyWith(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}

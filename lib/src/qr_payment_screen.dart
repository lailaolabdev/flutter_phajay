import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPaymentScreen extends StatelessWidget {
  const QRPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.access_time, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Waiting For Payment',
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'packages/flutter_phajay/assets/en.png', // <- replace with your flag icon
              height: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '123.00 LAK',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Transaction Code',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            const Text(
              '7613382b-5c60-4e9c-af43-b72c20db7e61',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Countdown timer (static example)
            const Text(
              '00 : 29 : 53',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // QR and payment section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Pay with bank app',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'packages/flutter_phajay/assets/jdb.png', // your bank logo
                    height: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Or Scan QR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  // Replace with actual QR image (use qr_flutter for generated QR)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: QrImageView(
                        data: '1234567890',
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Save QR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Save QR logic
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Note section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Note :\nTransfer not available for cross-bank sometimes',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '1. “Press Save QR Code” or take a screenshot of the QR code',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class QRPaymentScreen extends StatefulWidget {
  final int amount;
  final String description;
  final String publicKey;
  final String bankName;

  const QRPaymentScreen({
    super.key,
    required this.amount,
    required this.description,
    required this.publicKey,
    required this.bankName,
  });

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen> {
  String? qrData; // will hold the QR string from API
  bool isLoading = true;
  String? error;

  late Duration duration;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _generateQr();
    duration = Duration(minutes: 30);
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final seconds = duration.inSeconds - 1;
        if (seconds < 0) {
          timer?.cancel();
        } else {
          duration = Duration(seconds: seconds);
        }
      });
    });
  }

  Future<void> _generateQr() async {
    try {
      // Adjust body and headers to match your backend requirements
      final response = await http.post(
        Uri.parse(
          'https://payment-gateway.lailaolab.com/v1/api/payment/generate-jdb-qr',
        ),
        headers: {
          'Content-Type': 'application/json',
          'secretKey':
              r"$2b$10$21qCgkB4ZX6HFUNZUrEya./tVYF0SqDEqXg3Q.gCvAuuSw5NTSelm",
        },
        body: jsonEncode({
          'amount': widget.amount,
          "description": widget.description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API returns JSON like { "qrString": "..." }
        print(data);
        setState(() {
          qrData = data['qrCode'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error ${response.statusCode}: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

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
            Text(
              '${formatThousand(widget.amount)} LAK',
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
            Text(
              "${widget.description}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Countdown timer (static example)
            Text(
              formatTime(duration),
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
                        data: qrData ?? 'Loading...',
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
                      label: const Text('Open Bank App'),
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
                  const SizedBox(height: 12),
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

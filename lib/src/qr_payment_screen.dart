import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? linkData; // will hold the QR string from API
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
      print("Generating QR code...");
      print(widget.bankName);
      String bankUrl;
      if (widget.bankName == "JDB") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-jdb-qr';
      }
      if (widget.bankName == "BCEL") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-bcel-qr';
      }
      if (widget.bankName == "LDB") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-ldb-qr';
      }
      if (widget.bankName == "INDOCHINA BANK") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-ib-qr';
      } else {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-jdb-qr';
      }
      final response = await http.post(
        Uri.parse(bankUrl),
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
        listenToBankSocket(data['transactionId']);
        setState(() {
          qrData = data['qrCode'];
          linkData = data['link'];
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

  listenToBankSocket(transactionId) {
    print("Start listening to bank socket...");
    Socket socket = io(
      "https://payment-gateway.lailaolab.com",
      OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build(),
    );
    socket.connect(); // Explicitly connect the socket
    socket.onConnect((_) {
      print('Connected to socket server');
      socket.emit('msg', 'test');
    });

    socket.on('join::${transactionId}', (data) {
      print('Received data for join::${transactionId}: $data');
      if (data['message'] == 'SUCCESS') {
        // Payment successful, navigate or show success message
        print('Payment Successful!');
        if (mounted) {
          Navigator.of(context).pop(context);
        }
      } else if (data['message'] == 'FAILED') {
        // Payment failed, navigate or show failure message
        print('Payment Failed!');
      }
    });

    socket.onDisconnect((_) => print('Disconnected from socket server'));
    socket.onConnectError((error) => print('Connection error: $error'));
    socket.onError((error) => print('Socket error: $error'));
  }

  void openJDBDeeplink(link) async {
    final url = Uri.parse(link);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens in browser or JDB app
      );
    } else {
      print('❌ Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    String logoPath = 'packages/flutter_phajay/assets/logo-phajay.png';
    if (widget.bankName == "JDB") {
      logoPath = 'packages/flutter_phajay/assets/jdb.png';
    }
    if (widget.bankName == "BCEL") {
      logoPath = 'packages/flutter_phajay/assets/bcel.png';
    }
    if (widget.bankName == "LDB") {
      logoPath = 'packages/flutter_phajay/assets/ldb.png';
    }
    if (widget.bankName == "INDOCHINA BANK") {
      logoPath = 'packages/flutter_phajay/assets/indochina.png';
    } else {
      logoPath = 'packages/flutter_phajay/assets/jdb.png';
    }

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
                    logoPath, // your bank logo
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
                        openJDBDeeplink(linkData);
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

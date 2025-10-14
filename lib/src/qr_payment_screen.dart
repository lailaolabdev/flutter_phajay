import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

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
      } else if (widget.bankName == "BCEL") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-bcel-qr';
      } else if (widget.bankName == "LDB") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-ldb-qr';
      } else if (widget.bankName == "INDOCHINA BANK") {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-ib-qr';
      } else {
        bankUrl =
            'https://payment-gateway.lailaolab.com/v1/api/payment/generate-jdb-qr';
      }
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(bankUrl),
        headers: {
          'Content-Type': 'application/json',
          'secretKey': widget.publicKey, // Use the provided public key
        },
        body: jsonEncode({
          'amount': widget.amount,
          'description': widget.description,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API returns JSON like { "qrString": "..." }
        print(data);
        listenToBankSocket(data['transactionId']);
        setState(() {
          qrData = data['qrCode'];
          linkData = data['link'];
        });
      } else {
        setState(() {
          error = 'Error ${response.statusCode}: ${response.reasonPhrase}';
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: const Text('Payment Successful'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'packages/flutter_phajay/assets/payment-sucess.json',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thank you for your payment. You will be redirected shortly.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(); // Close the dialog immediately
                      Navigator.of(context).pop(); // Navigate back
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );

          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Navigate back
            }
          });
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
    } else if (widget.bankName == "BCEL") {
      logoPath = 'packages/flutter_phajay/assets/bcel.png';
    } else if (widget.bankName == "LDB") {
      logoPath = 'packages/flutter_phajay/assets/ldb.png';
    } else if (widget.bankName == "INDOCHINA BANK") {
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
                  if (isLoading)
                    Center(
                      child: Lottie.asset(
                        'packages/flutter_phajay/assets/loading_animation.json',
                        width: 100,
                        height: 100,
                      ),
                    )
                  else
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
                          foregroundColor:
                              Colors.grey.shade800, // Set to a darker grey
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_to_mobile_rounded),
                      label: const Text('Open Bank App'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Color(0xFF1E3C72),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () => openJDBDeeplink(linkData),
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
                        backgroundColor: Color(0xFF1E3C72),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {}, // TODO: Save QR logic
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

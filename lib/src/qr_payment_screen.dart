import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:flutter_phajay/src/payment_state.dart';
import 'package:flutter_phajay/src/config.dart';
import 'package:flutter_phajay/src/theme.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class QRPaymentScreen extends StatefulWidget {
  final int amount;
  final String description;
  final String publicKey;
  final String bankName;
  final String? linkCode;
  final Function() onPaymentSuccess;
  final Function(String error) onPaymentError;

  const QRPaymentScreen({
    super.key,
    required this.amount,
    required this.description,
    required this.publicKey,
    required this.bankName,
    this.linkCode,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen> {
  String? qrData; // will hold the QR string from API
  String? linkData; // will hold the QR string from API
  bool isLoading = true;
  String? error;

  // Service charge data
  Map<String, dynamic>? serviceChargeData;
  int displayAmount = 0; // จำนวนเงินที่จะแสดง (originalAmount หรือ totalAmount)

  late Duration duration;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    displayAmount = widget.amount; // เริ่มต้นด้วย amount เดิม
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

      // Map payment methods to API endpoints according to web logic
      if (widget.bankName == "JDB" ||
          widget.bankName == "PromtPay" ||
          widget.bankName == "Lao QR" ||
          widget.bankName == "Thai QR" ||
          widget.bankName == "UnionPay" ||
          widget.bankName == "KHQR" ||
          widget.bankName == "NAPAS") {
        bankUrl = PhajayConfig.generateJdbQr;
      } else if (widget.bankName == "BCEL") {
        bankUrl = PhajayConfig.generateBcelQr;
      } else if (widget.bankName == "INDOCHINA BANK" ||
          widget.bankName == "Indochina Bank") {
        bankUrl = PhajayConfig.generateIbQr;
      } else if (widget.bankName == "LDB") {
        bankUrl = PhajayConfig.generateLdbQr;
      } else if (widget.bankName == "STB") {
        bankUrl = PhajayConfig.generateStbQr;
      } else {
        // Default fallback to JDB endpoint
        bankUrl = PhajayConfig.generateJdbQr;
      }
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(bankUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'linkCode': widget.linkCode}),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ตรวจสอบว่ามี serviceCharge data หรือไม่
        if (data['serviceCharge'] != null) {
          setState(() {
            serviceChargeData = data['serviceCharge'];
            // ใช้ totalAmount แทน amount เดิม เมื่อมี serviceCharge
            displayAmount = (serviceChargeData!['totalAmount'] as num?)?.toInt() ?? widget.amount;
          });
        }

        // Assuming API returns JSON like { "qrString": "..." }
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
    Socket socket = IO.io(
      PhajayConfig.baseUrl,
      OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build(),
    );
    socket.connect(); // Explicitly connect the socket
    socket.onConnect((_) {
      socket.emit('msg', 'test');
    });

    socket.on('join::$transactionId', (data) {
      print('Received data for join::$transactionId: $data');
      if (data['message'] == 'SUCCESS') {
        // Check if payment callback already called to prevent duplicates using global state
        if (!PaymentState().isPaymentCompleted && mounted) {
          print('🎉 Socket SUCCESS received - calling callback');
          PaymentState().markPaymentCompleted();

          // Call the required success callback
          Navigator.of(context).pop();
          widget.onPaymentSuccess();
        } else {
          print('⚠️ Socket SUCCESS received but payment already completed');
        }
      } else if (data['message'] == 'FAILED') {
        // Call the required error callback
        final errorMsg = 'Payment failed';
        widget.onPaymentError(errorMsg);
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
    String logoPath = 'packages/flutter_phajay/assets/logo_phajay.png';
    if (widget.bankName == "JDB") {
      logoPath = 'packages/flutter_phajay/assets/jdb.png';
    } else if (widget.bankName == "BCEL") {
      logoPath = 'packages/flutter_phajay/assets/bcel.png';
    } else if (widget.bankName == "LDB") {
      logoPath = 'packages/flutter_phajay/assets/ldb.png';
    } else if (widget.bankName == "STB") {
      logoPath = 'packages/flutter_phajay/assets/stb-logo.png';
    } else if (widget.bankName == "INDOCHINA BANK" ||
        widget.bankName == "Indochina Bank") {
      logoPath = 'packages/flutter_phajay/assets/indochina.png';
    } else if (widget.bankName == "PromtPay") {
      logoPath = 'packages/flutter_phajay/assets/PromptPay-logo.png';
    } else if (widget.bankName == "Lao QR") {
      logoPath = 'packages/flutter_phajay/assets/lao_qr.png';
    } else if (widget.bankName == "Thai QR") {
      logoPath = 'packages/flutter_phajay/assets/thai_qr.png';
    } else if (widget.bankName == "UnionPay") {
      logoPath = 'packages/flutter_phajay/assets/UnionPay-logo.png';
    } else if (widget.bankName == "KHQR") {
      logoPath = 'packages/flutter_phajay/assets/khor-qr-logo.jpeg';
    } else if (widget.bankName == "NAPAS") {
      logoPath = 'packages/flutter_phajay/assets/napas.png';
    } else if (widget.bankName == "ALIPAY") {
      logoPath = 'packages/flutter_phajay/assets/alipay.png';
    } else if (widget.bankName == "WECHATPAY") {
      logoPath = 'packages/flutter_phajay/assets/wechatpay.png';
    } else {
      logoPath = 'packages/flutter_phajay/assets/logo_phajay.png';
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
            if (isLoading) ...[
              Lottie.asset(
                'packages/flutter_phajay/assets/loading_animation.json',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 8),
              Text(
                'Loading Amount...',
                style: PhajayTheme.bodyText.copyWith(color: Colors.grey),
              ),
            ] else ...[
              Text(
                '${formatThousand(displayAmount)} LAK',
                style: PhajayTheme.heading1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Description',
              style: PhajayTheme.bodyTextSmall.copyWith(color: Colors.black54),
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
                        child: isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'packages/flutter_phajay/assets/loading_animation.json',
                                    width: 80,
                                    height: 80,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Generating QR...',
                                    style: PhajayTheme.caption.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            : QrImageView(
                                data: qrData ?? 'Loading...',
                                version: QrVersions.auto,
                                size: 200.0,
                                foregroundColor: Colors
                                    .grey
                                    .shade800, // Set to a darker grey
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

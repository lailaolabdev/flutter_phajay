import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:flutter_phajay/src/payment_state.dart';
import 'package:flutter_phajay/src/config.dart';
import 'package:flutter_phajay/src/theme.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

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
            displayAmount =
                serviceChargeData!['totalAmount']?.toInt() ?? widget.amount;
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
    Socket socket = io.io(
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

    socket.onDisconnect((_) {});
    socket.onConnectError((error) {});
    socket.onError((error) {});
  }

  void openJDBDeeplink(link) async {
    if (link != null && link.isNotEmpty) {
      try {
        final Uri uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: Show the link in SnackBar if can't launch
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot open bank app. Link: $link'),
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    // Can implement clipboard copy if needed
                  },
                ),
              ),
            );
          }
        }
      } catch (e) {
        // Error handling: Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening bank app: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // No link available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank app link not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'packages/flutter_phajay/assets/loading_animation.json',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text('Generating QR Code...', style: PhajayTheme.bodyText),
            ],
          ),
        ),
      );
    }

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
          children: [
            Icon(Icons.access_time, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Waiting For Payment',
              style: PhajayTheme.heading2.copyWith(color: Colors.black87),
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
              '${formatThousand(displayAmount)} LAK',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // แสดงข้อมูล service charge หากมี
            if (serviceChargeData != null) ...[
              const SizedBox(height: 8),
              _buildServiceChargeInfo(),
            ],
            const SizedBox(height: 8),
            const Text(
              'Transaction Code',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
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
                  // if (isLoading)
                  //   Center(
                  //     child: Lottie.asset(
                  //       'packages/flutter_phajay/assets/loading_animation.json',
                  //       width: 100,
                  //       height: 100,
                  //     ),
                  //   )
                  // else
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
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.grey.shade800,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.grey.shade800,
                        ),
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

  Widget _buildServiceChargeInfo() {
    if (serviceChargeData == null) return const SizedBox.shrink();

    final originalAmount = serviceChargeData!['originalAmount']?.toInt() ?? 0;
    final serviceCharge = serviceChargeData!['serviceCharge'];
    final totalAmount = serviceChargeData!['totalAmount']?.toInt() ?? 0;

    if (serviceCharge == null) return const SizedBox.shrink();

    final chargeAmount = serviceCharge['amount']?.toInt() ?? 0;
    final chargeType = serviceCharge['type'] ?? '';
    final chargePercentage = serviceCharge['percentage']?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Original Amount:',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                '${formatThousand(originalAmount)} LAK',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Fee${chargeType == 'PERCENTAGE' && chargePercentage > 0 ? ' ($chargePercentage%)' : ''}:',
                style: const TextStyle(fontSize: 14, color: Colors.orange),
              ),
              Text(
                '+${formatThousand(chargeAmount)} LAK',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Colors.orange),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${formatThousand(totalAmount)} LAK',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

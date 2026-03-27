import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:flutter_phajay/src/payment_state.dart';
import 'package:flutter_phajay/src/config.dart';
import 'package:flutter_phajay/src/theme.dart';
import 'package:flutter_phajay/l10n/app_localizations.dart';
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

  // Helper method to format error message from API response
  String _formatErrorMessage(String message) {
    if (!mounted) return message;
    
    final localizations = AppLocalizations.of(context)!;
    
    // Check for exact matches with localization keys
    switch (message.toLowerCase()) {
      case 'orderno is required as string':
        return localizations.orderNoIsRequired;
      case 'amount is required.':
      case 'amount is required':
        return localizations.amountIsRequired;
      case 'amount must be a valid number.':
      case 'amount must be a valid number':
        return localizations.amountMustBeValidNumber;
      case 'description is required':
        return localizations.descriptionIsRequired;
      case 'amount must be between 1 and 999 for non-kyc users.':
      case 'amount must be between 1 and 999 for non-kyc users':
        return localizations.amountMustBeBetween1And999ForNonKyc;
      case 'amount exceeds the limit of 100,000,000 for kyc users.':
      case 'amount exceeds the limit of 100,000,000 for kyc users':
        return localizations.amountExceedsLimitForKycUsers;
      case 'amount must be greater than 1 for kyc users.':
      case 'amount must be greater than 1 for kyc users':
        return localizations.amountMustBeGreaterThan1ForKyc;
      case 'amount exceeds the limit,can\'t be more than 999 lak for banned users.':
      case 'amount exceeds the limit,can\'t be more than 999 lak for banned users':
        return localizations.amountExceedsLimitForBannedUsers;
      case 'affiliate percent must be between 0 and 90.':
      case 'affiliate percent must be between 0 and 90':
        return localizations.affiliatePercentMustBeBetween0And90;
      case 'amount must be greater than affiliatedata amount':
        return localizations.amountMustBeGreaterThanAffiliateAmount;
      case 'user not found.':
      case 'user not found':
        return localizations.userNotFound;
      case 'rate limit exceeded. max 20 transactions/day allowed.':
      case 'rate limit exceeded. max 20 transactions/day allowed':
        return localizations.rateLimitExceeded;
      case 'internal_server_error':
        return localizations.internalServerError;
      case 'payment is not found':
        return localizations.paymentNotFound;
      case 'description must not contain lao or thai text':
        return localizations.descriptionMustNotContainLaoOrThaiText;
      case 'transaction is expired':
        return localizations.transactionIsExpired;
      case 'jdb_error_not_success':
        return localizations.jdbErrorNotSuccess;
      case 'failed to generate qr data':
        return localizations.failedToGenerateQrData;
      case 'description must not contain \'-\' character.':
      case 'description must not contain \'-\' character':
        return localizations.descriptionMustNotContainDashCharacter;
      case 'description must not exceed 25 characters.':
      case 'description must not exceed 25 characters':
        return localizations.descriptionMustNotExceed25Characters;
      case 'credit card payment is not allowed for non kyc user':
        return localizations.creditCardPaymentNotAllowedForNonKyc;
      case 'exchange_not_found':
        return localizations.exchangeNotFound;
      case 'amount_not_found':
        return localizations.amountNotFound;
      case 'callback_setting_not_found':
        return localizations.callbackSettingNotFound;
      default:
        // Check if message is in UPPERCASE_WITH_UNDERSCORE format
        if (message.contains('_') && message == message.toUpperCase()) {
          // Convert AMOUNT_NOT_FOUND to Amount not found as fallback
          return message
              .toLowerCase()
              .split('_')
              .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
              .join(' ');
        }
        return message;
    }
  }

  // Error message extraction helper
  String _extractErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String? errorMessage;
      
      // Priority: detail > message > HTTP status
      if (responseData.containsKey('detail') && 
          responseData['detail'] != null && 
          responseData['detail'].toString().isNotEmpty) {
        errorMessage = responseData['detail'].toString();
      }
      else if (responseData.containsKey('message') && 
          responseData['message'] != null && 
          responseData['message'].toString().isNotEmpty) {
        errorMessage = responseData['message'].toString();
      }
      
      if (errorMessage != null) {
        return _formatErrorMessage(errorMessage);
      }
    } catch (e) {
      // JSON parsing failed, return default HTTP error
    }
    
    // Default HTTP error message
    return response.reasonPhrase ?? 'Unknown error';
  }

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
      print("test1");

      final response = await http.post(
        Uri.parse(bankUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'linkCode': widget.linkCode}),
      );

      setState(() {
        isLoading = false;
      });
      print("test2: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("QR code generated successfully: ${response.body}");
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
        print("Failed to generate QR code: ${response.statusCode} - ${response.body}");
        final errorMessage = _extractErrorMessage(response);
        setState(() {
          error = errorMessage;
        });
        // Show error in SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: PhajayTheme.bodyText.copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error generating QR code: $e");
      final errorMessage = e.toString();
      setState(() {
        error = errorMessage;
        isLoading = false;
      });
      // Show error in SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $errorMessage', style: PhajayTheme.bodyText.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void openDeepLink(link) async {
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
          children: [
            const Icon(Icons.access_time, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.waitingForPayment,
              style: const TextStyle(color: Colors.black87, fontSize: 18),
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
                AppLocalizations.of(context)!.generatingPaymentLink,
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
              AppLocalizations.of(context)!.description,
              style: PhajayTheme.bodyTextSmall.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              "${widget.description}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Text(
              formatTime(duration),
              style: const TextStyle(
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
                  Text(
                    AppLocalizations.of(context)!.payWithBankApp,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    logoPath, // your bank logo
                    height: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.orScanQR,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                                    AppLocalizations.of(context)!.generatingQR,
                                    style: PhajayTheme.caption.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            : (qrData != null && qrData!.isNotEmpty)
                                ? QrImageView(
                                    data: qrData!,
                                    version: QrVersions.auto,
                                    size: 200.0,
                                    foregroundColor: Colors
                                        .grey
                                        .shade800, // Set to a darker grey
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        AppLocalizations.of(context)!.qrCodeNotGenerated,
                                        style: PhajayTheme.bodyTextSmall.copyWith(
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            qrData = null;
                                            error = null;
                                          });
                                          _generateQr();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: Text(AppLocalizations.of(context)!.tryAgain),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_to_mobile_rounded),
                      label: Text(AppLocalizations.of(context)!.openBankApp),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1E3C72),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: (isLoading || linkData == null || linkData!.isEmpty)
                          ? null
                          : () => openDeepLink(linkData),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: Text(AppLocalizations.of(context)!.saveQR),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1E3C72),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: (isLoading || qrData == null || qrData!.isEmpty)
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
              child: Text(
                AppLocalizations.of(context)!.note,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.qrInstructions,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

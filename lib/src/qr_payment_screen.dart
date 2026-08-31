import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:flutter_phajay/src/payment_state.dart';
import 'package:flutter_phajay/src/config.dart';
import 'package:flutter_phajay/src/theme.dart';
import 'package:flutter_phajay/l10n/app_localizations.dart';
import 'package:gal/gal.dart';
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
  final String? bankUrl;
  final Function() onPaymentSuccess;
  final Function(String error) onPaymentError;

  const QRPaymentScreen({
    super.key,
    required this.amount,
    required this.description,
    required this.publicKey,
    required this.bankName,
    this.linkCode,
    this.bankUrl,
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
  bool isSavingQr = false;
  String? error;

  final GlobalKey _qrExportBoundaryKey = GlobalKey();

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
              .map(
                (word) => word.isEmpty
                    ? ''
                    : word[0].toUpperCase() + word.substring(1),
              )
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
      } else if (responseData.containsKey('message') &&
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

      if (widget.bankUrl != null && widget.bankUrl!.isNotEmpty) {
        bankUrl = widget.bankUrl!;
      } else if (widget.bankName == "JDB" ||
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
        print("QR code generated successfully: ${response.body}");
        final data = jsonDecode(response.body);

        // ตรวจสอบว่ามี serviceCharge data หรือไม่
        if (data['serviceCharge'] != null) {
          setState(() {
            serviceChargeData = data['serviceCharge'];
            // ใช้ totalAmount แทน amount เดิม เมื่อมี serviceCharge
            displayAmount =
                (serviceChargeData!['totalAmount'] as num?)?.toInt() ??
                widget.amount;
          });
        }

        // Assuming API returns JSON like { "qrString": "..." }
        listenToBankSocket(data['transactionId']);
        setState(() {
          qrData = data['qrCode'];
          linkData = data['link'];
        });
      } else {
        print(
          "Failed to generate QR code: ${response.statusCode} - ${response.body}",
        );
        final errorMessage = _extractErrorMessage(response);
        setState(() {
          error = errorMessage;
        });
        // Show error in SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: PhajayTheme.bodyText.copyWith(color: Colors.white),
              ),
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
            content: Text(
              '${AppLocalizations.of(context)!.error}: $errorMessage',
              style: PhajayTheme.bodyText.copyWith(color: Colors.white),
            ),
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

  String _resolveBankLogoPath() {
    switch (widget.bankName) {
      case "JDB":
        return 'packages/flutter_phajay/assets/jdb.png';
      case "BCEL":
        return 'packages/flutter_phajay/assets/bcel.png';
      case "LDB":
        return 'packages/flutter_phajay/assets/ldb.png';
      case "STB":
        return 'packages/flutter_phajay/assets/stb-logo.png';
      case "INDOCHINA BANK":
      case "Indochina Bank":
        return 'packages/flutter_phajay/assets/indochina.png';
      case "PromtPay":
        return 'packages/flutter_phajay/assets/PromptPay-logo.png';
      case "Lao QR":
        return 'packages/flutter_phajay/assets/lao_qr.png';
      case "Thai QR":
        return 'packages/flutter_phajay/assets/thai_qr.png';
      case "UnionPay":
        return 'packages/flutter_phajay/assets/UnionPay-logo.png';
      case "KHQR":
        return 'packages/flutter_phajay/assets/khor-qr-logo.jpeg';
      case "NAPAS":
        return 'packages/flutter_phajay/assets/napas.png';
      case "ALIPAY":
        return 'packages/flutter_phajay/assets/alipay.png';
      case "WECHATPAY":
        return 'packages/flutter_phajay/assets/wechatpay.png';
      default:
        return 'packages/flutter_phajay/assets/logo_phajay.png';
    }
  }

  /// Branded card rendered off-screen and captured as the image that gets
  /// saved to the device gallery. Kept larger/richer than the compact
  /// on-screen QR since it has to stand on its own once shared or saved.
  Widget _buildQrExportCard() {
    return RepaintBoundary(
      key: _qrExportBoundaryKey,
      child: Container(
        width: 340,
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset(
                'packages/flutter_phajay/assets/logo_phajay.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 20),
            Text(
              '${formatThousand(displayAmount)} LAK',
              style: PhajayTheme.heading1.copyWith(
                fontSize: 26,
                color: const Color(0xFF1E3C72),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: PhajayTheme.bodyTextSmall.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: (qrData != null && qrData!.isNotEmpty)
                  ? QrImageView(
                      data: qrData!,
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey.shade800,
                    )
                  : const SizedBox(width: 220, height: 220),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Image.asset(
                    _resolveBankLogoPath(),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.bankName,
                  style: PhajayTheme.bodyTextSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Secured by PhaJay',
                  style: PhajayTheme.caption.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Future<void> _saveQrCode() async {
    if (isSavingQr) return;
    setState(() {
      isSavingQr = true;
    });

    try {
      final boundary =
          _qrExportBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('QR code not ready');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to encode QR code image');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          throw StateError('PHOTO_PERMISSION_DENIED');
        }
      }

      await Gal.putImageBytes(
        pngBytes,
        name: 'phajay_qr_${DateTime.now().millisecondsSinceEpoch}',
        album: 'Phajay',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.qrSavedSuccess,
              style: PhajayTheme.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving QR code: $e');
      if (mounted) {
        final isPermissionDenied =
            e is GalException && e.type == GalExceptionType.accessDenied ||
            (e is StateError && e.message == 'PHOTO_PERMISSION_DENIED');
        final message = isPermissionDenied
            ? AppLocalizations.of(context)!.photoPermissionDenied
            : AppLocalizations.of(context)!.qrSaveFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: PhajayTheme.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSavingQr = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String logoPath = _resolveBankLogoPath();

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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  style: PhajayTheme.bodyTextSmall.copyWith(
                    color: Colors.black54,
                  ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: Image.asset(
                          logoPath, // your bank logo
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.orScanQR,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
                                        AppLocalizations.of(
                                          context,
                                        )!.generatingQR,
                                        style: PhajayTheme.caption.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : (qrData != null && qrData!.isNotEmpty)
                                ? Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(8),
                                    child: QrImageView(
                                      data: qrData!,
                                      version: QrVersions.auto,
                                      size: 200.0,
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors
                                          .grey
                                          .shade800, // Set to a darker grey
                                    ),
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
                                        AppLocalizations.of(
                                          context,
                                        )!.qrCodeNotGenerated,
                                        style: PhajayTheme.bodyTextSmall
                                            .copyWith(color: Colors.red),
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
                                        label: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.tryAgain,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                          label: Text(
                            AppLocalizations.of(context)!.openBankApp,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF1E3C72),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed:
                              (isLoading ||
                                  linkData == null ||
                                  linkData!.isEmpty)
                              ? null
                              : () => openDeepLink(linkData),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: isSavingQr
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(AppLocalizations.of(context)!.saveQR),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF1E3C72),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed:
                              (isLoading ||
                                  isSavingQr ||
                                  qrData == null ||
                                  qrData!.isEmpty)
                              ? null
                              : _saveQrCode,
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
          // Rendered off-screen purely so it can be captured as the image
          // saved to the gallery; RepaintBoundary.toImage() rasterizes this
          // layer directly regardless of it being positioned off-canvas.
          if (qrData != null && qrData!.isNotEmpty)
            Positioned(left: -9999, top: 0, child: _buildQrExportCard()),
        ],
      ),
    );
  }
}

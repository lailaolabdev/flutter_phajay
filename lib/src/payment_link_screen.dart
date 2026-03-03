import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phajay/src/helper.dart';
import 'package:flutter_phajay/src/qr_payment_screen.dart';
import 'package:flutter_phajay/src/payment_state.dart';
import 'package:flutter_phajay/src/credit_card_webview_screen.dart';
import 'package:flutter_phajay/src/config.dart';
import 'package:flutter_phajay/src/theme.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:lottie/lottie.dart';

class PaymentLinkScreen extends StatefulWidget {
  final int amount;
  final String description;
  final String publicKey;
  final String? orderNo;
  final String? tag1;
  final String? tag2;
  final String? tag3;
  final Function() onPaymentSuccess;
  final Function(String error) onPaymentError;

  const PaymentLinkScreen({
    super.key,
    required this.amount,
    required this.description,
    required this.publicKey,
    this.orderNo,
    this.tag1,
    this.tag2,
    this.tag3,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  @override
  State<PaymentLinkScreen> createState() => _PaymentLinkScreenState();
}

class _PaymentLinkScreenState extends State<PaymentLinkScreen>
    with WidgetsBindingObserver {
  bool isLoadingPaymentLink = false;
  bool isLoadingCreditCard = false; // เพิ่มตัวแปรสำหรับ credit card loading
  String? errorMessage;
  String? userId;
  String? linkCode;
  String? paymentLinkUrl;
  Timer? _statusCheckTimer;
  Map<String, dynamic>? paymentLinkData;

  // Deep link handling
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    // Reset global flag for new payment session
    PaymentState().resetPaymentState();
    WidgetsBinding.instance.addObserver(this);
    _generatePaymentLink();

    // Initialize app links listener
    _initAppLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusCheckTimer?.cancel();
    _linkSubscription?.cancel(); // Cancel deep link subscription
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check payment status when app comes back to foreground
    if (state == AppLifecycleState.resumed && linkCode != null) {
      _checkPaymentStatus(linkCode!);
    }
  }

  String? _extractLinkCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['linkCode'];
    } catch (e) {
      return null;
    }
  }

  Future<void> _checkPaymentStatus(String linkCode) async {
    try {
      final response = await http.get(
        Uri.parse('${PhajayConfig.getTransaction}/$linkCode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payment = data['payment'];

        if (payment != null) {
          final status = payment['status'];
          final paymentUserId = payment['user'];

          if (status == 'PAYMENT_COMPLETED') {
            // Check if payment callback already called to prevent duplicates
            if (!PaymentState().isPaymentCompleted) {
              print('✅ Payment completed detected by timer - calling callback');
              PaymentState().markPaymentCompleted();
              _statusCheckTimer?.cancel(); // Stop the timer

              // Call the required success callback
              widget.onPaymentSuccess();
            } else {
              print('⚠️ Payment already completed - skipping callback');
            }
          } else if (status == 'CLOSED') {
            // Call the required error callback
            final errorMsg = 'Transaction is expired';
            widget.onPaymentError(errorMsg);
          } else {
            // Store userId for future use and fetch payment methods
            setState(() {
              userId = paymentUserId;
            });
            // Fetch payment methods data
            if (paymentUserId != null) {
              await _getPaymentLinkData(paymentUserId);
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently or use debugPrint in debug mode
      if (mounted) {
        // Could potentially show error to user in debug mode
        // debugPrint('Error checking payment status: $e');
      }
    }
  }

  // Add periodic check for payment status when user returns from external browser
  void _startPaymentStatusCheck() {
    if (linkCode != null) {
      print('🔄 Starting payment status timer check');
      _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (
        timer,
      ) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        print('⏱️ Timer checking payment status...');
        await _checkPaymentStatus(linkCode!);

        // Stop checking if payment completed, expired, or error occurred
        if (PaymentState().isPaymentCompleted ||
            errorMessage?.contains('Transaction is expired') == true) {
          print('🛑 Stopping timer - payment completed or expired');
          timer.cancel();
        }
      });
    }
  }

  Future<void> _getPaymentLinkData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${PhajayConfig.getPaymentMethods}/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'SUCCESSFULLY' && data['data'] != null) {
          setState(() {
            paymentLinkData = data['data'];
          });
        }
      }
    } catch (e) {
      // Handle error silently or use debugPrint in debug mode
      // debugPrint('Error fetching payment link data: $e');
    }
  }

  void _initAppLinks() async {
    _appLinks = AppLinks();

    // Listen for incoming links when app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );

    // Handle link when app is launched from deep link
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  void _handleIncomingLink(Uri uri) {
    print('📱 Deep link received: $uri');

    // Parse the deep link
    // Expected format: phajay://payment?status=success&linkCode=xxx&amount=xxx
    if (uri.scheme == 'phajay' && uri.host == 'payment') {
      final status = uri.queryParameters['status'];

      if (status == 'success') {
        // Payment successful via credit card
        if (!PaymentState().isPaymentCompleted) {
          print('🎉 Credit card payment successful via deep link');
          PaymentState().markPaymentCompleted();
          _statusCheckTimer?.cancel();

          // Call success callback
          widget.onPaymentSuccess();
        }
      } else if (status == 'failed' || status == 'error') {
        // Payment failed
        final errorMsg =
            uri.queryParameters['error'] ?? 'Credit card payment failed';
        widget.onPaymentError(errorMsg);
      }
    }
  }

  bool _isWechatAlipayMethod(String methodKey) {
    final wechatAlipayMethods = [
      'WECHATPAY',
      'Wechat',
      'WeChat',
      'ALIPAY',
      'Alipay',
    ];
    return wechatAlipayMethods.contains(methodKey);
  }

  Future<void> _handleCreditCardPayment(String bankName) async {
    if (linkCode == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment link not available', style: PhajayTheme.bodyText.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Show Lottie loading instead of SnackBar
      if (mounted) {
        setState(() {
          isLoadingCreditCard = true;
        });
      }

      final response = await http.post(
        Uri.parse(PhajayConfig.creditCardPayment),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'linkCode': linkCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['paymentUrl'] != null) {
          final paymentUrl = data['paymentUrl'] as String;

          // Hide loading before navigation
          if (mounted) {
            setState(() {
              isLoadingCreditCard = false;
            });
          }

          // Navigate to WebView screen instead of external browser
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreditCardWebViewScreen(
                  paymentUrl: paymentUrl,
                  onPaymentSuccess: widget.onPaymentSuccess,
                  onPaymentError: widget.onPaymentError,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            setState(() {
              isLoadingCreditCard = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No payment URL received'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingCreditCard = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: HTTP ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCreditCard = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleWechatAlipayPayment(String bankName) async {
    if (linkCode == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment link not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing ${bankName.toLowerCase()} payment...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final response = await http.post(
        Uri.parse(PhajayConfig.wechatAlipayPayment),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'linkCode': linkCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Create form data URL for submission
        final formData = <String, String>{};
        data.forEach((key, value) {
          formData[key.toString()] = value.toString();
        });

        // Create URL-encoded form data
        final formBody = formData.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&');

        // Submit form to external payment URL using POST request
        final formResponse = await http.post(
          Uri.parse('https://bcel.la:9094/test'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: formBody,
        );

        if (formResponse.statusCode == 200 || formResponse.statusCode == 302) {
          // Handle redirect or success response
          // For Flutter, we might need to launch the URL instead
          final uri = Uri.parse('https://bcel.la:9094/test');
          if (await canLaunchUrl(uri)) {
            // Launch with form data as query parameters for GET request
            final queryParams = Uri(queryParameters: formData);
            final urlWithParams =
                'https://bcel.la:9094/test?${queryParams.query}';
            await launchUrl(
              Uri.parse(urlWithParams),
              mode: LaunchMode.externalApplication,
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment redirect failed: HTTP ${formResponse.statusCode}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: HTTP ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPaymentMethods() {
    if (paymentLinkData == null) {
      return const SizedBox.shrink();
    }

    final paymentGroups = paymentLinkData!['paymentGroups'] as List<dynamic>?;
    if (paymentGroups == null || paymentGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort groups by order
    paymentGroups.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

    return Column(
      children: paymentGroups
          .where((group) => group['visible'] == true)
          .map((group) => _buildPaymentGroup(group))
          .toList(),
    );
  }

  Widget _buildPaymentGroup(Map<String, dynamic> group) {
    final groupName = group['name'] as String;
    final methods = group['methods'] as List<dynamic>?;

    if (methods == null || methods.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter and sort methods
    final visibleMethods = methods
        .where((method) => method['visible'] == true)
        .where(
          (method) => !_isWechatAlipayMethod(method['key']),
        ) // Hide WeChat/Alipay methods
        .toList();

    visibleMethods.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

    if (visibleMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    // Map group names to display names
    String displayName;
    switch (groupName) {
      case 'BANKS':
        displayName = 'Banks Payment';
        break;
      case 'CREDIT_CARDS':
        displayName = 'Credit Cards';
        break;
      case 'QR_PAYMENTS':
        displayName = 'QR Payments';
        break;
      case 'WALLETS':
        displayName = 'Wallets';
        break;
      default:
        displayName = groupName;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          displayName,
          style: PhajayTheme.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...visibleMethods.map(
          (method) => BankTile(
            bankName: method['key'],
            amount: widget.amount,
            subtitle: method['description'],
            description: widget.description,
            publicKey: widget.publicKey,
            logoUrl: method['logo'],
            linkCode: linkCode,
            serviceCharge: method['serviceCharge'], // เพิ่ม serviceCharge
            onCreditCardPayment: _handleCreditCardPayment,
            onWechatAlipayPayment: _handleWechatAlipayPayment,
            onPaymentSuccess: widget.onPaymentSuccess,
            onPaymentError: widget.onPaymentError,
          ),
        ),
      ],
    );
  }

  Future<void> _generatePaymentLink() async {
    setState(() {
      isLoadingPaymentLink = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(PhajayConfig.createPaymentLink),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode(widget.publicKey))}',
        },
        body: jsonEncode({
          if (widget.orderNo != null) 'orderNo': widget.orderNo,
          'amount': widget.amount,
          'description': widget.description,
          if (widget.tag1 != null) 'tag1': widget.tag1,
          if (widget.tag2 != null) 'tag2': widget.tag2,
          if (widget.tag3 != null) 'tag3': widget.tag3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'SUCCESSFULLY' && data['redirectURL'] != null) {
          final redirectUrl = data['redirectURL'] as String;

          // Extract linkCode from redirectURL
          final extractedLinkCode = _extractLinkCodeFromUrl(redirectUrl);

          if (extractedLinkCode != null) {
            setState(() {
              linkCode = extractedLinkCode;
              paymentLinkUrl = redirectUrl;
            });

            // Check payment status first
            await _checkPaymentStatus(extractedLinkCode);

            // Payment link generated successfully
            // No redirect needed - just start monitoring payment status
            if (errorMessage == null) {
              _startPaymentStatusCheck();
            }
          } else {
            setState(() {
              errorMessage = 'Failed to extract link code from payment URL';
            });
          }
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to generate payment link';
          });
        }
      } else {
        setState(() {
          errorMessage =
              'HTTP ${response.statusCode}: Failed to generate payment link';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoadingPaymentLink = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPaymentLink) {
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
              Text('Generating Payment Link...', style: PhajayTheme.bodyText),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Payment Link Generation Failed',
                  style: PhajayTheme.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: PhajayTheme.bodyTextSmall.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _generatePaymentLink,
                  icon: const Icon(Icons.refresh),
                  label: Text('Retry', style: PhajayTheme.buttonText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      errorMessage = null;
                    });
                  },
                  child: Text('Continue with QR Payment', style: PhajayTheme.buttonText.copyWith(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
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
                        'packages/flutter_phajay/assets/logo_phajay.png',
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Text('Select For Payment', style: PhajayTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The transaction has been successfully verified\nfor authenticity and security.',
                    textAlign: TextAlign.center,
                    style: PhajayTheme.bodyTextSmall.copyWith(
                      color: Colors.black87,
                    ),
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
                        Text(
                          'Total Amount',
                          style: PhajayTheme.bodyText.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${formatThousand(widget.amount)} LAK',
                          style: PhajayTheme.heading1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat(
                            'MMMM dd, yyyy   HH:mm:ss',
                          ).format(DateTime.now()),
                          style: PhajayTheme.bodyTextSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Your safety is our top priority\nRest assured that your payment is secure. Be confident that your information will always be protected.',
                    textAlign: TextAlign.center,
                    style: PhajayTheme.bodyTextSmall.copyWith(
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Dynamic Payment Methods from API
                  _buildPaymentMethods(),
                ],
              ),
            ),
          ),

          // Credit Card Loading Overlay
          if (isLoadingCreditCard)
            Container(
              // color: Colors.black.withOpacity(0.7),
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'packages/flutter_phajay/assets/loading_animation.json',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Processing Credit Card Payment...',
                      style: PhajayTheme.bodyText.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BankTile extends StatelessWidget {
  final int amount;
  final String description;
  final String publicKey;
  final String subtitle;
  final String bankName;
  final String? logoUrl;
  final String? linkCode;
  final Map<String, dynamic>? serviceCharge; // เพิ่ม serviceCharge
  final Function(String)? onCreditCardPayment;
  final Function(String)? onWechatAlipayPayment;
  final Function() onPaymentSuccess;
  final Function(String error) onPaymentError;

  const BankTile({
    super.key,
    required this.bankName,
    required this.amount,
    required this.description,
    required this.publicKey,
    required this.subtitle,
    this.logoUrl,
    this.linkCode,
    this.serviceCharge, // เพิ่ม serviceCharge parameter
    this.onCreditCardPayment,
    this.onWechatAlipayPayment,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  bool _isCreditCardPayment(String bankName) {
    final creditCardTypes = [
      'CREDIT CARD',
      'Credit Card',
      'MASTERCARD',
      'MasterCard',
      'VISA',
      'Visa',
    ];
    return creditCardTypes.contains(bankName);
  }

  bool _isWechatAlipayPayment(String bankName) {
    final wechatAlipayTypes = [
      'WECHATPAY',
      'Wechat',
      'WeChat',
      'ALIPAY',
      'Alipay',
    ];
    return wechatAlipayTypes.contains(bankName);
  }

  String? _getServiceChargeText() {
    if (serviceCharge == null || serviceCharge!['enabled'] != true) {
      return null;
    }

    final chargeType = serviceCharge!['chargeType'] as String? ?? 'PERCENTAGE';
    final chargeAmount = serviceCharge!['amount'] as num? ?? 0;

    if (chargeAmount <= 0) {
      return null;
    }

    if (chargeType == 'FIXED') {
      final formattedAmount = chargeAmount >= 1000
          ? '${(chargeAmount / 1000).toStringAsFixed(chargeAmount % 1000 == 0 ? 0 : 1)}K'
          : chargeAmount.toInt().toString();
      return 'Fee: $formattedAmount LAK';
    } else {
      return 'Fee: ${chargeAmount.toStringAsFixed(1)}%';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use logoUrl if provided, otherwise use the legacy logo mapping
    Widget logoWidget;

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      // Use network image for API-provided logos
      logoWidget = Image.network(
        '${PhajayConfig.uploadsPath}/$logoUrl',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to legacy logo mapping if network image fails
          return Image.asset(
            _getLegacyLogoPath(),
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          );
        },
      );
    } else {
      // Use legacy logo mapping
      logoWidget = Image.asset(
        _getLegacyLogoPath(),
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      );
    }

    // Get service charge text if applicable
    final serviceChargeText = _getServiceChargeText();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: SizedBox(width: 40, height: 40, child: logoWidget),
        title: Text(
          bankName,
          style: PhajayTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: PhajayTheme.bodyTextSmall),
            if (serviceChargeText != null) ...[
              const SizedBox(height: 4),
              Text(
                serviceChargeText,
                style: PhajayTheme.caption.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Check if this is a credit card payment method
          if (_isCreditCardPayment(bankName)) {
            if (onCreditCardPayment != null) {
              onCreditCardPayment!(bankName);
            }
          } else if (_isWechatAlipayPayment(bankName)) {
            // Check if this is a WeChat/Alipay payment method
            if (onWechatAlipayPayment != null) {
              onWechatAlipayPayment!(bankName);
            }
          } else {
            // Navigate to QR payment screen for other methods
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRPaymentScreen(
                  bankName: bankName,
                  amount: amount,
                  description: description,
                  publicKey: publicKey,
                  linkCode: linkCode,
                  onPaymentSuccess: onPaymentSuccess,
                  onPaymentError: onPaymentError,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _getLegacyLogoPath() {
    if (bankName == "JDB") {
      return 'packages/flutter_phajay/assets/jdb-logo.png';
    } else if (bankName == "BCEL") {
      return 'packages/flutter_phajay/assets/bcel-logo.png';
    } else if (bankName == "LDB") {
      return 'packages/flutter_phajay/assets/ldb-logo.png';
    } else if (bankName == "STB") {
      return 'packages/flutter_phajay/assets/stb-logo.png';
    } else if (bankName == "INDOCHINA BANK" || bankName == "Indochina Bank") {
      return 'packages/flutter_phajay/assets/ib-logo.png';
    } else if (bankName == "CREDIT CARD" || bankName == "Credit Card") {
      return 'packages/flutter_phajay/assets/credit-card.png';
    } else if (bankName == "MASTERCARD" || bankName == "MasterCard") {
      return 'packages/flutter_phajay/assets/master-logo.png';
    } else if (bankName == "VISA" || bankName == "Visa") {
      return 'packages/flutter_phajay/assets/visa-logo.png';
    } else if (bankName == "ALIPAY" || bankName == "Alipay") {
      return 'packages/flutter_phajay/assets/alipay-logo.png';
    } else if (bankName == "WECHATPAY" || bankName == "Wechat") {
      return 'packages/flutter_phajay/assets/wechat-logo.png';
    } else if (bankName == "PROMTPAY" || bankName == "PromtPay") {
      return 'packages/flutter_phajay/assets/promt-pay-logo.png';
    } else if (bankName == "LAO QR" || bankName == "Lao QR") {
      return 'packages/flutter_phajay/assets/lao-qr-logo.png';
    } else if (bankName == "KHQR" || bankName == "Khqr") {
      return 'packages/flutter_phajay/assets/khor-qr-logo.jpeg';
    } else if (bankName == "THAI QR" || bankName == "Thai QR") {
      return 'packages/flutter_phajay/assets/Thai-qr.webp';
    } else if (bankName == "UNIONPAY" || bankName == "UnionPay") {
      return 'packages/flutter_phajay/assets/union-pay.png';
    } else if (bankName == "NAPAS" || bankName == "Napas") {
      return 'packages/flutter_phajay/assets/Napas.jfif';
    } else {
      return 'packages/flutter_phajay/assets/logo_phajay.png';
    }
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  final String linkCode;
  final int amount;

  const PaymentSuccessScreen({
    super.key,
    required this.linkCode,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Payment Success',
          style: PhajayTheme.bodyText.copyWith(color: Colors.black87),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: PhajayTheme.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Amount: ${formatThousand(amount)} LAK',
                style: PhajayTheme.heading2.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transaction ID: $linkCode',
                style: PhajayTheme.bodyTextSmall.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: PhajayTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

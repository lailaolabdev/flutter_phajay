// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectForPayment => 'Select For Payment';

  @override
  String get transactionVerified =>
      'The transaction has been successfully verified\nfor authenticity and security.';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get safetyMessage =>
      'Your safety is our top priority\nRest assured that your payment is secure. Be confident that your information will always be protected.';

  @override
  String get generatingPaymentLink => 'Generating Payment Link...';

  @override
  String get processingCreditCard => 'Processing Credit Card Payment...';

  @override
  String get paymentLinkNotAvailable => 'Payment link not available';

  @override
  String get minimumAmountRequired =>
      'Minimum amount for credit card payment is 5,000 LAK';

  @override
  String get minimumRequired => 'Minimum 5,000 LAK required';

  @override
  String get banksPayment => 'Banks Payment';

  @override
  String get creditCards => 'Credit Cards';

  @override
  String get qrPayments => 'QR Payments';

  @override
  String get wallets => 'Wallets';

  @override
  String get fee => 'Fee';

  @override
  String get noPaymentUrlReceived => 'No payment URL received from server';

  @override
  String processingPayment(String bankName) {
    return 'Processing $bankName payment...';
  }

  @override
  String get paymentSuccess => 'Payment Success';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get amount => 'Amount';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get done => 'Done';

  @override
  String get waitingForPayment => 'Waiting for payment...';

  @override
  String get paymentCompleted => 'Payment completed!';

  @override
  String get paymentCancelled => 'Payment cancelled';

  @override
  String get paymentExpired => 'Payment expired';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get close => 'Close';

  @override
  String get description => 'Description';

  @override
  String get payWithBankApp => 'Pay with bank app';

  @override
  String get orScanQR => 'Or Scan QR';

  @override
  String get generatingQR => 'Generating QR...';

  @override
  String get qrCodeNotGenerated => 'QR code not generated';

  @override
  String get openBankApp => 'Open Bank App';

  @override
  String get saveQR => 'Save QR';

  @override
  String get note => 'Note :\nTransfer not available for cross-bank sometimes';

  @override
  String get qrInstructions =>
      '1. \"Press Save QR Code\" or take a screenshot of the QR code';

  @override
  String get error => 'Error';

  @override
  String get orderNoIsRequired => 'OrderNo is required as String';

  @override
  String get amountIsRequired => 'Amount is required';

  @override
  String get amountMustBeValidNumber => 'Amount must be a valid number';

  @override
  String get descriptionIsRequired => 'Description is required';

  @override
  String get amountMustBeBetween1And999ForNonKyc =>
      'Amount must be between 1 and 999 for non-KYC users';

  @override
  String get amountExceedsLimitForKycUsers =>
      'Amount exceeds the limit of 100,000,000 for KYC users';

  @override
  String get amountMustBeGreaterThan1ForKyc =>
      'Amount must be greater than 1 for KYC users';

  @override
  String get amountExceedsLimitForBannedUsers =>
      'Amount exceeds the limit, can\'t be more than 999 LAK for banned users';

  @override
  String get affiliatePercentMustBeBetween0And90 =>
      'Affiliate percent must be between 0 and 90';

  @override
  String get amountMustBeGreaterThanAffiliateAmount =>
      'Amount must be greater than affiliate data amount';

  @override
  String get userNotFound => 'User not found';

  @override
  String get rateLimitExceeded =>
      'Rate limit exceeded. Max 20 transactions/day allowed';

  @override
  String get internalServerError => 'Internal server error';

  @override
  String get paymentNotFound => 'Payment is not found';

  @override
  String get descriptionMustNotContainLaoOrThaiText =>
      'Description must not contain Lao or Thai text';

  @override
  String get transactionIsExpired => 'Transaction is expired';

  @override
  String get jdbErrorNotSuccess => 'JDB error not success';

  @override
  String get failedToGenerateQrData => 'Failed to generate QR data';

  @override
  String get descriptionMustNotContainDashCharacter =>
      'Description must not contain \'-\' character';

  @override
  String get descriptionMustNotExceed25Characters =>
      'Description must not exceed 25 characters';

  @override
  String get creditCardPaymentNotAllowedForNonKyc =>
      'Credit card payment is not allowed for non kyc user';

  @override
  String get exchangeNotFound => 'Exchange not found';

  @override
  String get amountNotFound => 'Amount not found';

  @override
  String get callbackSettingNotFound => 'Callback setting not found';
}

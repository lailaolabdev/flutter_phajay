import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lo'),
  ];

  /// Title for payment selection screen
  ///
  /// In en, this message translates to:
  /// **'Select For Payment'**
  String get selectForPayment;

  /// Message indicating transaction verification
  ///
  /// In en, this message translates to:
  /// **'The transaction has been successfully verified\nfor authenticity and security.'**
  String get transactionVerified;

  /// Label for total amount
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Safety assurance message
  ///
  /// In en, this message translates to:
  /// **'Your safety is our top priority\nRest assured that your payment is secure. Be confident that your information will always be protected.'**
  String get safetyMessage;

  /// Loading message while generating payment link
  ///
  /// In en, this message translates to:
  /// **'Generating Payment Link...'**
  String get generatingPaymentLink;

  /// Loading message for credit card processing
  ///
  /// In en, this message translates to:
  /// **'Processing Credit Card Payment...'**
  String get processingCreditCard;

  /// Error message when payment link is not available
  ///
  /// In en, this message translates to:
  /// **'Payment link not available'**
  String get paymentLinkNotAvailable;

  /// Error message for minimum amount requirement
  ///
  /// In en, this message translates to:
  /// **'Minimum amount for credit card payment is 5,000 LAK'**
  String get minimumAmountRequired;

  /// Short minimum amount message
  ///
  /// In en, this message translates to:
  /// **'Minimum 5,000 LAK required'**
  String get minimumRequired;

  /// Title for bank payment methods
  ///
  /// In en, this message translates to:
  /// **'Banks Payment'**
  String get banksPayment;

  /// Title for credit card payment methods
  ///
  /// In en, this message translates to:
  /// **'Credit Cards'**
  String get creditCards;

  /// Title for QR payment methods
  ///
  /// In en, this message translates to:
  /// **'QR Payments'**
  String get qrPayments;

  /// Title for wallet payment methods
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// Label for transaction fee
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// Error message when payment URL is not received
  ///
  /// In en, this message translates to:
  /// **'No payment URL received from server'**
  String get noPaymentUrlReceived;

  /// Loading message for payment processing
  ///
  /// In en, this message translates to:
  /// **'Processing {bankName} payment...'**
  String processingPayment(String bankName);

  /// Title for payment success screen
  ///
  /// In en, this message translates to:
  /// **'Payment Success'**
  String get paymentSuccess;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// Label for amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for transaction ID
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Status message while waiting for payment
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment...'**
  String get waitingForPayment;

  /// Payment completion message
  ///
  /// In en, this message translates to:
  /// **'Payment completed!'**
  String get paymentCompleted;

  /// Payment cancellation message
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// Payment expiration message
  ///
  /// In en, this message translates to:
  /// **'Payment expired'**
  String get paymentExpired;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Text for pay with bank app button
  ///
  /// In en, this message translates to:
  /// **'Pay with bank app'**
  String get payWithBankApp;

  /// Text for QR scan option
  ///
  /// In en, this message translates to:
  /// **'Or Scan QR'**
  String get orScanQR;

  /// Loading message while generating QR
  ///
  /// In en, this message translates to:
  /// **'Generating QR...'**
  String get generatingQR;

  /// Error message when QR code fails to generate
  ///
  /// In en, this message translates to:
  /// **'QR code not generated'**
  String get qrCodeNotGenerated;

  /// Open bank app button text
  ///
  /// In en, this message translates to:
  /// **'Open Bank App'**
  String get openBankApp;

  /// Save QR button text
  ///
  /// In en, this message translates to:
  /// **'Save QR'**
  String get saveQR;

  /// Note about cross-bank transfers
  ///
  /// In en, this message translates to:
  /// **'Note :\nTransfer not available for cross-bank sometimes'**
  String get note;

  /// Instructions for QR code usage
  ///
  /// In en, this message translates to:
  /// **'1. \"Press Save QR Code\" or take a screenshot of the QR code'**
  String get qrInstructions;

  /// General error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Error when orderNo field is missing or invalid
  ///
  /// In en, this message translates to:
  /// **'OrderNo is required as String'**
  String get orderNoIsRequired;

  /// Error when amount field is missing
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountIsRequired;

  /// Error when amount is not a valid number
  ///
  /// In en, this message translates to:
  /// **'Amount must be a valid number'**
  String get amountMustBeValidNumber;

  /// Error when description field is missing
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionIsRequired;

  /// Error for amount limits for non-KYC users
  ///
  /// In en, this message translates to:
  /// **'Amount must be between 1 and 999 for non-KYC users'**
  String get amountMustBeBetween1And999ForNonKyc;

  /// Error for amount exceeding KYC user limits
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds the limit of 100,000,000 for KYC users'**
  String get amountExceedsLimitForKycUsers;

  /// Error for minimum amount for KYC users
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 1 for KYC users'**
  String get amountMustBeGreaterThan1ForKyc;

  /// Error for amount limits for banned users
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds the limit, can\'t be more than 999 LAK for banned users'**
  String get amountExceedsLimitForBannedUsers;

  /// Error for invalid affiliate percentage
  ///
  /// In en, this message translates to:
  /// **'Affiliate percent must be between 0 and 90'**
  String get affiliatePercentMustBeBetween0And90;

  /// Error when amount is less than affiliate amount
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than affiliate data amount'**
  String get amountMustBeGreaterThanAffiliateAmount;

  /// Error when user doesn't exist
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Error for daily transaction limit exceeded
  ///
  /// In en, this message translates to:
  /// **'Rate limit exceeded. Max 20 transactions/day allowed'**
  String get rateLimitExceeded;

  /// Internal server error message
  ///
  /// In en, this message translates to:
  /// **'Internal server error'**
  String get internalServerError;

  /// Error when payment record is not found
  ///
  /// In en, this message translates to:
  /// **'Payment is not found'**
  String get paymentNotFound;

  /// Error for invalid characters in description
  ///
  /// In en, this message translates to:
  /// **'Description must not contain Lao or Thai text'**
  String get descriptionMustNotContainLaoOrThaiText;

  /// Error when transaction has expired
  ///
  /// In en, this message translates to:
  /// **'Transaction is expired'**
  String get transactionIsExpired;

  /// JDB bank specific error
  ///
  /// In en, this message translates to:
  /// **'JDB error not success'**
  String get jdbErrorNotSuccess;

  /// Error when QR code generation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to generate QR data'**
  String get failedToGenerateQrData;

  /// Error for dash character in description
  ///
  /// In en, this message translates to:
  /// **'Description must not contain \'-\' character'**
  String get descriptionMustNotContainDashCharacter;

  /// Error for description length limit
  ///
  /// In en, this message translates to:
  /// **'Description must not exceed 25 characters'**
  String get descriptionMustNotExceed25Characters;

  /// Error for credit card payment restriction
  ///
  /// In en, this message translates to:
  /// **'Credit card payment is not allowed for non kyc user'**
  String get creditCardPaymentNotAllowedForNonKyc;

  /// Error when exchange rate is not found
  ///
  /// In en, this message translates to:
  /// **'Exchange not found'**
  String get exchangeNotFound;

  /// Error when amount data is missing
  ///
  /// In en, this message translates to:
  /// **'Amount not found'**
  String get amountNotFound;

  /// Error when callback configuration is missing
  ///
  /// In en, this message translates to:
  /// **'Callback setting not found'**
  String get callbackSettingNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lo'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lo':
      return AppLocalizationsLo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

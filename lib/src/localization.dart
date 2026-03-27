import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

enum PhajayLanguage { lao, english }

class PhajayLocalizations extends ChangeNotifier {
  static final PhajayLocalizations _instance = PhajayLocalizations._internal();
  PhajayLocalizations._internal();
  factory PhajayLocalizations() => _instance;
  
  static PhajayLanguage _currentLanguage = PhajayLanguage.english;
  
  static PhajayLanguage get currentLanguage => _currentLanguage;
  
  static void setLanguage(PhajayLanguage language) {
    _currentLanguage = language;
    _instance.notifyListeners();
  }
  
  static Locale get locale {
    return _currentLanguage == PhajayLanguage.lao 
        ? const Locale('lo') 
        : const Locale('en');
  }
  
  // Helper to get AppLocalizations instance  
  static AppLocalizations? of(BuildContext context) {
    return AppLocalizations.of(context);
  }
  
  // Note: We now use Flutter's standard localization system with ARB files.
  // All strings are available through AppLocalizations.of(context)!.propertyName
  // 
  // Example usage:
  // AppLocalizations.of(context)!.selectForPayment
  // AppLocalizations.of(context)!.tryAgain
  // AppLocalizations.of(context)!.processingPayment(bankName)
  
  static List<LocalizationsDelegate> get localizationsDelegates {
    return [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }
  
  static List<Locale> get supportedLocales {
    return const [
      Locale('en'),
      Locale('lo'),
    ];
  }
}

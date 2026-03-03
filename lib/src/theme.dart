import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhajayTheme {
  /// Get Noto Sans Lao text theme
  static TextTheme get notoSansLaoTextTheme {
    return GoogleFonts.notoSansLaoTextTheme();
  }

  /// Get Noto Sans Lao text style
  static TextStyle notoSansLao({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextDecoration? decoration,
    double? height,
  }) {
    try {
      return GoogleFonts.notoSansLao(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        height: height,
      );
    } catch (e) {
      print('Error loading Noto Sans Lao: $e');
      // Fallback to default font
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        height: height,
      );
    }
  }

  /// Get theme data with Noto Sans Lao font
  static ThemeData get lightTheme {
    return ThemeData(
      textTheme: notoSansLaoTextTheme,
      primaryTextTheme: notoSansLaoTextTheme,
      fontFamily: GoogleFonts.notoSansLao().fontFamily,
    );
  }

  /// Common text styles with Noto Sans Lao
  static TextStyle get heading1 =>
      notoSansLao(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87);

  static TextStyle get heading2 =>
      notoSansLao(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87);

  static TextStyle get heading3 =>
      notoSansLao(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);

  static TextStyle get bodyText => 
      notoSansLao(fontSize: 16, color: Colors.black87);

  static TextStyle get bodyTextSmall => 
      notoSansLao(fontSize: 14, color: Colors.black87);

  static TextStyle get caption => 
      notoSansLao(fontSize: 12, color: Colors.black54);

  /// Button text style
  static TextStyle get buttonText =>
      notoSansLao(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white);

  /// Input text style
  static TextStyle get inputText => 
      notoSansLao(fontSize: 16, color: Colors.black87);
}

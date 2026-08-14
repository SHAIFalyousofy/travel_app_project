import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // لاستخدام خطوط جوجل بسهولة

class AppTheme {
  static const String _arabicFontFamily =
      'Cairo'; // يجب أن يتطابق مع الاسم في pubspec.yaml

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blueAccent, // اختر لونك الأساسي
      scaffoldBackgroundColor: Colors.grey[100],
      fontFamily: _arabicFontFamily,
      textTheme: GoogleFonts.getTextTheme(
              _arabicFontFamily, ThemeData.light().textTheme)
          .copyWith(
        // يمكنك تخصيص أنماط معينة هنا إذا أردت
        displayLarge:
            TextStyle(fontFamily: _arabicFontFamily, color: Colors.black87),
        bodyMedium:
            TextStyle(fontFamily: _arabicFontFamily, color: Colors.black87),
      ),
      appBarTheme: AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, // لون الأيقونات والنص في AppBar
        titleTextStyle: GoogleFonts.cairo(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
        labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
        hintStyle: GoogleFonts.cairo(color: Colors.grey[500]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
      )),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.blueAccent, // يمكن أن يكون مختلفًا في الوضع المظلم
      scaffoldBackgroundColor: Colors.grey[900],
      fontFamily: _arabicFontFamily,
      textTheme: GoogleFonts.getTextTheme(
              _arabicFontFamily, ThemeData.dark().textTheme)
          .copyWith(
        displayLarge:
            TextStyle(fontFamily: _arabicFontFamily, color: Colors.white),
        bodyMedium:
            TextStyle(fontFamily: _arabicFontFamily, color: Colors.white70),
      ),
      appBarTheme: AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.cairo(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[700]!)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
        labelStyle: GoogleFonts.cairo(color: Colors.grey[400]),
        hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
      )),
    );
  }
}

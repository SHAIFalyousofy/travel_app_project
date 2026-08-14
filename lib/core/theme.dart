import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // لاستخدام google_fonts

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.teal, // يمكنك تغيير هذا اللون الأساسي
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100], // لون خلفية الشاشات
      fontFamily: GoogleFonts.cairo().fontFamily, // استخدام خط Cairo كخط أساسي
      appBarTheme: AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.teal, // لون شريط العنوان
        foregroundColor: Colors.white, // لون نص وأيقونات شريط العنوان
        titleTextStyle: GoogleFonts.cairo(
          // نمط نص عنوان شريط العنوان
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, // لون خلفية الأزرار المرتفعة
          foregroundColor: Colors.white, // لون نص الأزرار المرتفعة
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
        ),
        labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
        hintStyle: GoogleFonts.cairo(color: Colors.grey[500]),
      ),
      // يمكنك إضافة المزيد من تخصيصات الثيم هنا
    );
  }

  // يمكنك إضافة darkTheme لاحقًا إذا أردت
  // static ThemeData get darkTheme { ... }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app_project/features/home/home_screen.dart'; // استيراد HomeScreen
// import 'package:travel_app_project/features/auth/login_screen.dart'; // استيراد LoginPage
import 'package:intl/date_symbol_data_local.dart'; // للتهيئة
import 'package:intl/intl.dart'; // لاستخدام DateFormat لاحقًا إذا احتجت
import 'package:travel_app_project/features/onboarding/onboarding_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد shared_preferences
import 'package:travel_app_project/features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // تأكد من تهيئة Flutter قبل الوصول إلى shared_preferences

  // تهيئة تنسيقات التاريخ للغة العربية (للتأكد من عملها في جميع الشاشات)
  await initializeDateFormatting('ar_SA', null);
  Intl.defaultLocale = 'ar_SA';

  // التحقق مما إذا كان المستخدم مسجلاً للدخول بالفعل
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('user_id'); // معرف المستخدم المحفوظ
  final bool hasSeenOnboarding =
      prefs.getBool('has_seen_onboarding') ?? false; // هل شاهد شاشة الترحيب؟

  // تحديد الشاشة الأولية بناءً على حالة تسجيل الدخول وحالة شاشة الترحيب
  Widget initialScreen;
  if (userId != null && userId.isNotEmpty) {
    // إذا كان هناك معرف مستخدم محفوظ، انتقل إلى الشاشة الرئيسية مباشرة
    initialScreen = const HomeScreen();
  } else {
    // إذا لم يكن المستخدم مسجلاً للدخول
    if (!hasSeenOnboarding) {
      // إذا لم يشاهد شاشة الترحيب من قبل، انتقل إليها أولاً
      initialScreen = const OnboardingScreen();
    } else {
      // إذا شاهد شاشة الترحيب ولكن لم يسجل الدخول، انتقل إلى صفحة تسجيل الدخول
      initialScreen = const LoginPage();
    }
  }

  runApp(DevicePreview(
    enabled: true,
    builder: (context) => MyApp(initialScreen: initialScreen),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder,
      title: 'Travel App',
      debugShowCheckedModeBanner: false, // إخفاء شريط Debug
      theme: ThemeData(
        primarySwatch: Colors.orange, // يمكن تخصيص اللون الأساسي
        primaryColor: const Color(0xFFFFA726), // اللون البرتقالي الأساسي
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // يمكنك إضافة خط Cairo كخط افتراضي للتطبيق هنا إذا أردت
        fontFamily: GoogleFonts.cairo().fontFamily,
      ),
      home: initialScreen, // استخدام الشاشة الأولية المحددة
    );
  }
}

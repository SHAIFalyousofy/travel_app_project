import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد shared_preferences
import 'package:travel_app_project/features/auth/login_screen.dart'; // تأكد من أن هذا يشير إلى login_screen.dart

class OnboardingPageItem {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageItem> _onboardingPages = [
    OnboardingPageItem(
      imagePath:
          'assets/images/login_background.png', // صورة المسافر مع الحقيبة
      title: 'لننطلق في رحلة!',
      description:
          'اكتشف العالم معنا. نوفر لك أفضل الأدوات لتخطيط مغامراتك القادمة بسهولة وأمان.',
    ),
    OnboardingPageItem(
      imagePath: 'assets/images/onboarding_2.jpeg', // صورة الخريطة والبوصلة
      title: 'خطط لرحلتك القادمة',
      description:
          'ابحث عن أفضل عروض الطيران والفنادق، واحجز كل ما تحتاجه في مكان واحد.',
    ),
  ];

  static const Color primaryOrange = Color(0xFFFFA726);
  static const Color titleDarkBlue = Color(0xFF0A2540);
  static const Color descriptionGrey = Color(0xFF546E7A);
  static const Color inactiveDotColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        if (mounted) {
          setState(() {
            _currentPage = _pageController.page!.round();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // دالة للانتقال إلى صفحة تسجيل الدخول وحفظ حالة مشاهدة الترحيب
  void _finishOnboardingAndNavigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'has_seen_onboarding', true); // حفظ أن المستخدم شاهد الترحيب
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) {
                    final item = _onboardingPages[index];
                    return _buildOnboardingPage(
                      context,
                      item: item,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage < _onboardingPages.length - 1
                        ? TextButton(
                            onPressed:
                                _finishOnboardingAndNavigateToLogin, // ينتقل مباشرة للدخول
                            child: Text(
                              "تخطــي",
                              style: GoogleFonts.cairo(
                                  fontSize: screenWidth * 0.04,
                                  color: descriptionGrey,
                                  fontWeight: FontWeight.w600),
                            ))
                        : SizedBox(
                            width: screenWidth *
                                0.2), // للحفاظ على التوازن عندما يكون "ابدأ الآن" فقط

                    DotsIndicator(
                      dotsCount: _onboardingPages.length,
                      position: _currentPage.toDouble(),
                      decorator: DotsDecorator(
                        color: inactiveDotColor,
                        activeColor: primaryOrange,
                        size: const Size.square(10.0),
                        activeSize: const Size(20.0, 10.0),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        spacing: const EdgeInsets.symmetric(horizontal: 4.0),
                      ),
                    ),

                    SizedBox(
                      width: screenWidth * 0.3,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _onboardingPages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } else {
                            _finishOnboardingAndNavigateToLogin(); // ينتقل بعد الانتهاء
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          _currentPage < _onboardingPages.length - 1
                              ? "التالـي"
                              : "ابدأ الآن",
                          style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context, {
    required OnboardingPageItem item,
    required double screenHeight,
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.1),
          Expanded(
            flex: 5,
            child: Container(
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.06),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: screenWidth * 0.075,
                    fontWeight: FontWeight.bold,
                    color: titleDarkBlue,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.042,
                      color: descriptionGrey,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

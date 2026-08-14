import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
// لاحقًا، سنقوم بإنشاء HomeScreen للانتقال إليها
// import 'package:travel_app_project/features/home/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travel_app_project/features/auth/login_screen.dart'; // للعودة إلى صفحة تسجيل الدخول
import 'package:travel_app_project/features/home/home_screen.dart'; // للانتقال بعد التسجيل الناجح

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // لتأكيد كلمة المرور

  // URL الخاص بالـ PHP API للتسجيل
  // تأكد من تحديث هذا الرابط ليتوافق مع عنوان IP الخاص بجهازك
  final String _registerApiUrl = 'http://localhost/travel_api/register.php';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true; // لإخفاء/إظهار تأكيد كلمة المرور

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimationContent;

  static const Color primaryOrange = Color(0xFFFFA726);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimationContent =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(_registerApiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (responseData['success']) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    responseData['message'] ?? 'تم التسجيل بنجاح.',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: GoogleFonts.cairo().fontFamily),
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                ),
              );
              // بعد التسجيل الناجح، يمكن الانتقال إلى الشاشة الرئيسية أو شاشة تسجيل الدخول
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    responseData['message'] ?? 'فشل التسجيل. حاول مرة أخرى.',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: GoogleFonts.cairo().fontFamily),
                  ),
                  backgroundColor: Colors.redAccent[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'خطأ في الخادم: ${response.statusCode}. ${responseData['message'] ?? ''}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.cairo().fontFamily),
                ),
                backgroundColor: Colors.redAccent[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ غير متوقع: ${e.toString()}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.cairo().fontFamily)),
              backgroundColor: Colors.redAccent[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // صورة الخلفية (يمكنك تغييرها إذا أردت صورة مختلفة للتسجيل)
            Positioned.fill(
              child: Image.asset(
                'assets/images/login.jpeg',
                fit: BoxFit.cover,
              ),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimationContent,
                child: Center(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: screenHeight * 0.1),

                        Text(
                          "إنشاء حساب",
                          style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.09,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),

                        Container(
                          padding: const EdgeInsets.all(25.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: _customInputDecoration(
                                    hintText: "البريد الإلكتروني",
                                    icon: Icons.email_outlined,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.04),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "حقل البريد الإلكتروني مطلوب";
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return "الرجاء إدخال بريد إلكتروني صحيح";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.025),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: _customInputDecoration(
                                    hintText: "كلمة المرور",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscureTextToggle:
                                        _togglePasswordVisibility,
                                    isObscure: _obscurePassword,
                                  ),
                                  obscureText: _obscurePassword,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.04),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "حقل كلمة المرور مطلوب";
                                    }
                                    if (value.length < 6) {
                                      return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.025),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: _customInputDecoration(
                                    hintText: "تأكيد كلمة المرور",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscureTextToggle:
                                        _toggleConfirmPasswordVisibility,
                                    isObscure: _obscureConfirmPassword,
                                  ),
                                  obscureText: _obscureConfirmPassword,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.04),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "حقل تأكيد كلمة المرور مطلوب";
                                    }
                                    if (value != _passwordController.text) {
                                      return "كلمة المرور وتأكيدها غير متطابقين";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.018),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 3.0,
                                  ),
                                  onPressed: _isLoading ? null : _registerUser,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white)),
                                        )
                                      : Text(
                                          "إنشاء حساب",
                                          style: GoogleFonts.cairo(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        // رابط "لديك حساب بالفعل؟ تسجيل الدخول"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "لديك حساب بالفعل؟ ",
                              style: GoogleFonts.cairo(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: screenWidth * 0.038),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  // استخدم pushReplacement لمنع العودة إلى شاشة التسجيل بزر الرجوع
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: Text(
                                "تسجيل الدخول",
                                style: GoogleFonts.cairo(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _customInputDecoration({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? obscureTextToggle,
    bool isObscure = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.cairo(
          color: Colors.grey[500],
          fontSize: MediaQuery.of(context).size.width * 0.038),
      prefixIcon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12.0, end: 8.0),
        child: Icon(icon, color: Colors.grey[600], size: 22),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: obscureTextToggle,
            )
          : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryOrange, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
    );
  }
}

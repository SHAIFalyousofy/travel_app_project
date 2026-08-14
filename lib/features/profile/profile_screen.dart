import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart'; // لجلب user_id

import 'package:travel_app_project/features/profile/models/user_model.dart'; // استيراد نموذج المستخدم

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryOrange = Color(0xFFFFA726);

  final String _getUserProfileApiUrl =
      'http://localhost/travel_api/get_user_profile.php';
  final String _updateUserProfileApiUrl =
      'http://localhost/travel_api/update_user_profile.php';

  UserProfile? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isEditing = false; // لتحديد ما إذا كانت الشاشة في وضع التعديل

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _profileImageUrlController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'معرف المستخدم غير موجود. يرجى تسجيل الدخول.';
          _isLoading = false;
        });
        return;
      }

      final response =
          await http.get(Uri.parse('$_getUserProfileApiUrl?user_id=$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _userProfile = UserProfile.fromJson(responseData['data']);
            _nameController.text = _userProfile?.name ?? '';
            _emailController.text = _userProfile?.email ?? '';
            _phoneController.text = _userProfile?.phoneNumber ?? '';
            _profileImageUrlController.text =
                _userProfile?.profileImageUrl ?? '';
          });
        } else {
          setState(() {
            _errorMessage =
                responseData['message'] ?? 'فشل جلب بيانات الملف الشخصي.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'خطأ في الخادم: ${response.statusCode}.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
        });
      }
      print('Error fetching user profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'معرف المستخدم غير موجود. يرجى تسجيل الدخول.';
          _isLoading = false;
        });
        return;
      }

      final updatedData = {
        'user_id': userId,
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'profile_image_url': _profileImageUrlController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(_updateUserProfileApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    responseData['message'] ?? 'تم تحديث الملف الشخصي بنجاح.',
                    style: GoogleFonts.cairo(color: Colors.white)),
                backgroundColor: Colors.green[600],
              ),
            );
            setState(() {
              _isEditing = false; // الخروج من وضع التعديل
            });
            _fetchUserProfile(); // إعادة جلب البيانات للتأكد من التحديث
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    responseData['message'] ?? 'فشل تحديث الملف الشخصي.',
                    style: GoogleFonts.cairo(color: Colors.white)),
                backgroundColor: Colors.redAccent[700],
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الخادم: ${response.statusCode}.',
                  style: GoogleFonts.cairo(color: Colors.white)),
              backgroundColor: Colors.redAccent[700],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع أثناء التحديث: ${e.toString()}',
                style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: Colors.redAccent[700],
          ),
        );
      }
      print('Error updating user profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ملفي الشخصي',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryOrange,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // إذا خرجنا من وضع التعديل، أعد تعيين الحقول للقيم الأصلية
                    _nameController.text = _userProfile?.name ?? '';
                    _phoneController.text = _userProfile?.phoneNumber ?? '';
                    _profileImageUrlController.text =
                        _userProfile?.profileImageUrl ?? '';
                  }
                });
              },
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                color: Colors.red,
                                fontSize: screenWidth * 0.04),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _fetchUserProfile,
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            label: Text('أعد المحاولة',
                                style: GoogleFonts.cairo(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _userProfile == null
                    ? Center(
                        child: Text('لا توجد بيانات ملف شخصي.',
                            style: GoogleFonts.cairo()))
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // صورة الملف الشخصي
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: screenWidth * 0.18,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      _userProfile!.profileImageUrl != null &&
                                              _userProfile!
                                                  .profileImageUrl!.isNotEmpty
                                          ? CachedNetworkImageProvider(
                                              _userProfile!.profileImageUrl!)
                                          : null,
                                  child: _userProfile!.profileImageUrl ==
                                              null ||
                                          _userProfile!.profileImageUrl!.isEmpty
                                      ? Icon(Icons.person,
                                          size: screenWidth * 0.15,
                                          color: Colors.grey[600])
                                      : null,
                                ),
                                if (_isEditing)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: CircleAvatar(
                                      backgroundColor: primaryOrange,
                                      radius: screenWidth * 0.05,
                                      child: IconButton(
                                        icon: Icon(Icons.camera_alt,
                                            color: Colors.white,
                                            size: screenWidth * 0.03),
                                        onPressed: () {
                                          // TODO: إضافة منطق اختيار الصورة من المعرض/الكاميرا
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'وظيفة تحميل الصورة قريباً!',
                                                  style: GoogleFonts.cairo(
                                                      color: Colors.white)),
                                              backgroundColor: primaryOrange,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // حقول معلومات المستخدم
                            _buildProfileField(
                              context,
                              label: 'الاسم',
                              icon: Icons.person_outline,
                              controller: _nameController,
                              isEditable: _isEditing,
                            ),
                            _buildProfileField(
                              context,
                              label: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              controller: _emailController,
                              isEditable:
                                  false, // البريد الإلكتروني غير قابل للتعديل عادةً
                            ),
                            _buildProfileField(
                              context,
                              label: 'رقم الهاتف',
                              icon: Icons.phone_outlined,
                              controller: _phoneController,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                            _buildProfileField(
                              context,
                              label: 'رابط صورة الملف الشخصي',
                              icon: Icons.image_outlined,
                              controller: _profileImageUrlController,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.url,
                            ),
                            SizedBox(height: screenHeight * 0.04),

                            if (_isEditing)
                              ElevatedButton(
                                onPressed: _updateUserProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.1,
                                      vertical: screenHeight * 0.018),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5.0,
                                ),
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
                                        'حفظ التغييرات',
                                        style: GoogleFonts.cairo(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditable, // إذا لم يكن في وضع التعديل، يكون للقراءة فقط
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: screenWidth * 0.04),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
          prefixIcon: Icon(icon, color: primaryOrange),
          filled: true,
          fillColor: isEditable
              ? Colors.white
              : Colors.grey[100], // خلفية مختلفة للوضع غير القابل للتعديل
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: isEditable
                ? const BorderSide(color: Colors.grey, width: 1.0)
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: primaryOrange, width: 2.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
        ),
      ),
    );
  }
}

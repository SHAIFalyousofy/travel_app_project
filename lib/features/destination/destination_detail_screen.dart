import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:travel_app_project/features/destination/models/destination_model.dart'; // استيراد نموذج الوجهة المحدث

class DestinationDetailScreen extends StatefulWidget {
  final Destination
      destination; // الوجهة الأولية التي تم تمريرها من الشاشة الرئيسية

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  // الألوان المستخدمة
  static const Color primaryOrange = Color(0xFFFFA726);

  // URL الخاص بالـ PHP API لجلب تفاصيل الوجهة
  // تأكد من تحديث هذا الرابط ليتوافق مع عنوان IP الخاص بجهازك
  final String _destinationDetailsApiUrl =
      'http://localhost/travel_api/get_destination_details.php';

  Destination? _detailedDestination; // تفاصيل الوجهة الكاملة بعد جلبها من API
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDestinationDetails();
  }

  Future<void> _fetchDestinationDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
          Uri.parse('$_destinationDetailsApiUrl?id=${widget.destination.id}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _detailedDestination = Destination.fromJson(responseData['data']);
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'فشل جلب تفاصيل الوجهة.';
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
      print('Error fetching destination details: $e'); // لغرض التصحيح
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true, // لجعل المحتوى يمتد خلف الـ AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent, // AppBar شفاف
          elevation: 0,
          leading: IconButton(
            // زر العودة
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                            onPressed: _fetchDestinationDetails,
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
                : _detailedDestination == null
                    ? Center(
                        child: Text('لا توجد تفاصيل لعرضها.',
                            style: GoogleFonts.cairo()))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // صورة الوجهة الرئيسية
                            Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: _detailedDestination!.mainImageUrl,
                                  height: screenHeight * 0.4,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: screenHeight * 0.4,
                                    color: Colors.grey[200],
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: primaryOrange)),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: screenHeight * 0.4,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported,
                                        size: 80, color: Colors.grey),
                                  ),
                                ),
                                // تدرج لوني أسود في الأسفل لجعل النصوص واضحة
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: screenHeight * 0.15,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // اسم الوجهة والبلد والتقييم
                                Positioned(
                                  bottom: screenHeight * 0.02,
                                  right: screenWidth * 0.04,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _detailedDestination!.name,
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.07,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(
                                                blurRadius: 3,
                                                color: Colors.black54)
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _detailedDestination!.country,
                                        style: GoogleFonts.cairo(
                                          color: Colors.white70,
                                          fontSize: screenWidth * 0.04,
                                          shadows: const [
                                            Shadow(
                                                blurRadius: 2,
                                                color: Colors.black54)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end, // محاذاة لليمين
                                        children: [
                                          Text(
                                            '${_detailedDestination!.rating} (${_detailedDestination!.reviewCount} تقييم)',
                                            style: GoogleFonts.cairo(
                                              color: Colors.amber,
                                              fontSize: screenWidth * 0.035,
                                              fontWeight: FontWeight.bold,
                                              shadows: const [
                                                Shadow(
                                                    blurRadius: 2,
                                                    color: Colors.black54)
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(Icons.star,
                                              color: Colors.amber,
                                              size: screenWidth * 0.04),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // باقي التفاصيل
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // الوصف
                                  Text(
                                    'الوصف:',
                                    style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _detailedDestination!.description,
                                    style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.038,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(height: 20),

                                  // معلومات إضافية
                                  _buildInfoRow(
                                    context,
                                    Icons.calendar_today_rounded,
                                    'أفضل وقت للزيارة:',
                                    _detailedDestination!.bestTimeToVisit ??
                                        'غير متاح',
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.wb_sunny_outlined,
                                    'الطقس:',
                                    _detailedDestination!.weather ?? 'غير متاح',
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.category_outlined,
                                    'التصنيف:',
                                    _detailedDestination!.categoryName ?? 'عام',
                                  ),
                                  const SizedBox(height: 20),

                                  // المميزات
                                  if (_detailedDestination!
                                      .features.isNotEmpty) ...[
                                    Text(
                                      'مميزات الوجهة:',
                                      style: GoogleFonts.cairo(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing:
                                          10.0, // المسافة الأفقية بين العناصر
                                      runSpacing:
                                          10.0, // المسافة الرأسية بين الصفوف
                                      textDirection: TextDirection
                                          .rtl, // لضمان ترتيب العناصر من اليمين لليسار
                                      children: _detailedDestination!.features
                                          .map((feature) {
                                        return _buildFeatureChip(context,
                                            feature.icon, feature.title);
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // معرض الصور
                                  if (_detailedDestination!
                                      .galleryImages.isNotEmpty) ...[
                                    Text(
                                      'معرض الصور:',
                                      style: GoogleFonts.cairo(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: screenHeight * 0.15,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _detailedDestination!
                                            .galleryImages.length,
                                        itemBuilder: (context, index) {
                                          final imageUrl = _detailedDestination!
                                              .galleryImages[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: screenWidth * 0.3,
                                                height: screenHeight * 0.15,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  primaryOrange)),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 30,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // زر الحجز (مثال)
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'سيتم الانتقال لصفحة الحجز قريباً لوجهة ${_detailedDestination!.name}',
                                              style: GoogleFonts.cairo(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: primaryOrange,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: const EdgeInsets.fromLTRB(
                                                15, 5, 15, 20),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.1,
                                            vertical: screenHeight * 0.018),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        elevation: 5.0,
                                      ),
                                      child: Text(
                                        'احجز الآن - ${_detailedDestination!.price.toStringAsFixed(0)} ${_detailedDestination!.currency}',
                                        style: GoogleFonts.cairo(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20), // مسافة سفلية
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  // دالة مساعدة لبناء صفوف المعلومات
  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryOrange, size: screenWidth * 0.05),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              textDirection: TextDirection.rtl, // لضمان محاذاة النص بشكل صحيح
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' $value',
                    style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء شرائح المميزات (Feature Chips)
  Widget _buildFeatureChip(BuildContext context, String icon, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: screenWidth * 0.04)),
          const SizedBox(width: 5),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: screenWidth * 0.035,
              color: primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

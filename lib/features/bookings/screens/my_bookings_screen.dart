import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // لجلب user_id
import 'package:intl/intl.dart' as intl; // لتنسيق التاريخ
import 'package:travel_app_project/features/bookings/models/booking_model.dart'; // استيراد نموذج الحجز

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  static const Color primaryOrange = Color(0xFFFFA726);

  final String _getUserBookingsApiUrl =
      'http://localhost/travel_api/get_user_bookings.php';

  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _currentUserId; // لتخزين معرف المستخدم الحالي

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchBookings();
  }

  Future<void> _loadUserIdAndFetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');

    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      _fetchUserBookings();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'الرجاء تسجيل الدخول لعرض حجوزاتك.';
      });
    }
  }

  Future<void> _fetchUserBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        setState(() {
          _errorMessage = 'معرف المستخدم غير موجود.';
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(Uri.parse('$_getUserBookingsApiUrl?user_id=$_currentUserId'));
      print(
          'DEBUG: MyBookings API URL: $_getUserBookingsApiUrl?user_id=$_currentUserId'); // DEBUG
      print(
          'DEBUG: MyBookings response status: ${response.statusCode}'); // DEBUG
      print('DEBUG: MyBookings response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _bookings = (responseData['data'] as List)
                .map((e) => Booking.fromJson(e))
                .toList();
            print(
                'DEBUG: Successfully parsed ${_bookings.length} bookings.'); // DEBUG
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'فشل جلب الحجوزات.';
            print(
                'DEBUG: MyBookings API returned success: false or no data: ${responseData['message']}'); // DEBUG
          });
        }
      } else {
        setState(() {
          _errorMessage = 'خطأ في الخادم: ${response.statusCode}.';
          print(
              'DEBUG: MyBookings API server error: ${response.statusCode}'); // DEBUG
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
          print('DEBUG: Error fetching bookings: $e'); // DEBUG
        });
      }
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('حجوزاتي', style: GoogleFonts.cairo(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryOrange,
          elevation: 0,
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
                            onPressed: _fetchUserBookings,
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
                : _bookings.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد حجوزات حالياً.',
                          style: GoogleFonts.cairo(
                              fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return BookingCard(
                              booking: booking); // استخدام BookingCard
                        },
                      ),
      ),
    );
  }
}

// ويدجت لعرض بطاقة الحجز
class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const Color primaryOrange = Color(0xFFFFA726);

    String bookingTitle =
        'حجز ${booking.bookingType == 'flight' ? 'رحلة طيران' : booking.bookingType == 'hotel' ? 'فندق' : 'باقة'}';
    String bookingSubtitle = '';

    // التصحيح هنا: استخدام ?. للوصول الآمن إلى الخصائص الاختيارية
    if (booking.bookingType == 'flight') {
      bookingTitle =
          'رحلة طيران ${booking.flightNumber ?? ''}'; // استخدام ?? '' للتعامل مع null
      bookingSubtitle =
          '${booking.departureCityName ?? ''} إلى ${booking.arrivalCityName ?? ''}'; // استخدام ?? ''
    } else if (booking.bookingType == 'hotel') {
      // TODO: عند إضافة الفنادق، قم بتحديث هذا
      bookingTitle = 'حجز فندق';
      bookingSubtitle = 'تفاصيل الفندق...';
    }

    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case 'confirmed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'مؤكد';
        break;
      case 'pending':
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
        break;
      case 'cancelled':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'ملغي';
        break;
      default:
        statusIcon = Icons.info_outline;
        statusColor = Colors.grey;
        statusText = 'غير معروف';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // TODO: الانتقال إلى شاشة تفاصيل الحجز (مستقبلاً)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('سيتم عرض تفاصيل الحجز رقم ${booking.id} قريباً!',
                  style: GoogleFonts.cairo(color: Colors.white)),
              backgroundColor: primaryOrange,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bookingTitle,
                    style: GoogleFonts.cairo(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(statusIcon,
                          color: statusColor, size: screenWidth * 0.04),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        statusText,
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.035, color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
              if (bookingSubtitle.isNotEmpty) ...[
                SizedBox(height: screenWidth * 0.01),
                Text(
                  bookingSubtitle,
                  style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.038, color: Colors.grey[700]),
                ),
              ],
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تاريخ الحجز:',
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600]),
                      ),
                      Text(
                        intl.DateFormat('yyyy-MM-dd HH:mm')
                            .format(booking.bookingDate),
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'المبلغ الإجمالي:',
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600]),
                      ),
                      Text(
                        '${booking.totalPrice.toStringAsFixed(0)} ${booking.currency}',
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

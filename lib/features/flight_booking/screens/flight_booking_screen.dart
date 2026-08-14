import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // لجلب user_id

import 'package:travel_app_project/features/flight_booking/models/flight_model.dart';
import 'package:travel_app_project/features/bookings/screens/booking_confirmation_screen.dart'; // التعديل هنا: استيراد شاشة التأكيد

class FlightBookingScreen extends StatefulWidget {
  final Flight flight;

  const FlightBookingScreen({super.key, required this.flight});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  static const Color primaryOrange = Color(0xFFFFA726);

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  final String _createBookingApiUrl =
      'http://localhost/travel_api/create_flight_booking.php'; // تأكد من عنوان IP الصحيح

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportNumberController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _createBooking() async {
    // التحقق من أن الحقول ليست فارغة (يمكن إضافة تحقق أكثر تعقيدًا)
    if (_fullNameController.text.trim().isEmpty ||
        _passportNumberController.text.trim().isEmpty ||
        _nationalityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('الرجاء ملء جميع حقول بيانات المسافر.',
                style: GoogleFonts.cairo())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage =
              'معرف المستخدم غير موجود. يرجى تسجيل الدخول مرة أخرى.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_errorMessage,
                  style: GoogleFonts.cairo(color: Colors.white)),
              backgroundColor: Colors.red),
        );
        return;
      }

      final Map<String, dynamic> passengerDetails = {
        'full_name': _fullNameController.text.trim(),
        'passport_number': _passportNumberController.text.trim(),
        'nationality': _nationalityController.text.trim(),
      };

      final Map<String, dynamic> bookingData = {
        'user_id': userId,
        'flight_id': widget.flight.id,
        'booking_date': intl.DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.now()), // تاريخ الحجز الحالي
        'total_price': widget.flight.price,
        'currency': widget.flight.currency,
        'details_json': passengerDetails, // تفاصيل المسافر كـ JSON
      };

      print(
          'DEBUG: Sending booking request: ${jsonEncode(bookingData)}'); // DEBUG
      final response = await http.post(
        Uri.parse(_createBookingApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(bookingData),
      );

      print('DEBUG: Booking response status: ${response.statusCode}'); // DEBUG
      print('DEBUG: Booking response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    responseData['message'] ?? 'تم تأكيد الحجز بنجاح!',
                    style: GoogleFonts.cairo(color: Colors.white)),
                backgroundColor: Colors.green[600],
              ),
            );

            // التعديل هنا: الانتقال إلى شاشة تأكيد الحجز
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(
                  bookingId: responseData['booking_id']?.toString() ??
                      'N/A', // تأكد أن الـ API يعيد booking_id
                  flightNumber: widget.flight.flightNumber,
                  totalPrice: widget.flight.price.toStringAsFixed(0),
                  currency: widget.flight.currency,
                ),
              ),
              (Route<dynamic> route) => false, // إزالة جميع الشاشات السابقة
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    responseData['message'] ??
                        'فشل تأكيد الحجز. حاول مرة أخرى.',
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
            content: Text('حدث خطأ غير متوقع أثناء الحجز: ${e.toString()}',
                style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: Colors.redAccent[700],
          ),
        );
      }
      print('Error creating booking: $e');
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
          title: Text('تأكيد حجز الرحلة',
              style: GoogleFonts.cairo(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص الرحلة:',
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildSummaryRow(
                          context, 'الخطوط الجوية:', widget.flight.airline),
                      _buildSummaryRow(
                          context, 'الرحلة:', widget.flight.flightNumber),
                      _buildSummaryRow(context, 'من:',
                          '${widget.flight.departureCity.name} (${widget.flight.departureCity.iataCode})'),
                      _buildSummaryRow(context, 'إلى:',
                          '${widget.flight.arrivalCity.name} (${widget.flight.arrivalCity.iataCode})'),
                      _buildSummaryRow(
                          context,
                          'تاريخ المغادرة:',
                          intl.DateFormat('yyyy-MM-dd')
                              .format(widget.flight.departureTime)),
                      _buildSummaryRow(context, 'السعر الإجمالي:',
                          '${widget.flight.price.toStringAsFixed(0)} ${widget.flight.currency}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بيانات المسافر (الركاب):',
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildTextField(
                        context,
                        controller: _fullNameController,
                        label: 'الاسم الكامل',
                        icon: Icons.person_outline,
                      ),
                      _buildTextField(
                        context,
                        controller: _passportNumberController,
                        label: 'رقم جواز السفر',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.text,
                      ),
                      _buildTextField(
                        context,
                        controller: _nationalityController,
                        label: 'الجنسية',
                        icon: Icons.flag_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.018),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : Text('تأكيد الحجز',
                          style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: screenWidth * 0.04, color: Colors.black87),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: screenWidth * 0.04),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
          prefixIcon: Icon(icon, color: primaryOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
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

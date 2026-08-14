import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app_project/features/home/home_screen.dart'; // للعودة إلى الشاشة الرئيسية

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String flightNumber;
  final String totalPrice;
  final String currency;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.flightNumber,
    required this.totalPrice,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const Color primaryOrange = Color(0xFFFFA726);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تأكيد الحجز',
              style: GoogleFonts.cairo(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryOrange,
          automaticallyImplyLeading: false, // إخفاء زر الرجوع التلقائي
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: screenWidth * 0.25,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'تم تأكيد حجزك بنجاح!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'شكراً لك على حجز رحلتك معنا.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildConfirmationDetailRow(
                      context,
                      'رقم الحجز:',
                      bookingId,
                      screenWidth,
                    ),
                    _buildConfirmationDetailRow(
                      context,
                      'رقم الرحلة:',
                      flightNumber,
                      screenWidth,
                    ),
                    _buildConfirmationDetailRow(
                      context,
                      'المبلغ المدفوع:',
                      '$totalPrice $currency',
                      screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    ElevatedButton(
                      onPressed: () {
                        // العودة إلى الشاشة الرئيسية وإزالة جميع الشاشات السابقة
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'العودة إلى الرئيسية',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationDetailRow(
      BuildContext context, String label, String value, double screenWidth) {
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
                fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

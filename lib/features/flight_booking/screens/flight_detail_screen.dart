import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:travel_app_project/features/flight_booking/models/flight_model.dart';
import 'package:travel_app_project/features/flight_booking/screens/flight_booking_screen.dart'; // استيراد شاشة الحجز

class FlightDetailScreen extends StatelessWidget {
  final Flight flight;

  const FlightDetailScreen({super.key, required this.flight});

  // دالة مساعدة لحساب المدة بتنسيق ساعة:دقيقة
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}س ${remainingMinutes}د';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الرحلة ${flight.flightNumber}',
              style: GoogleFonts.cairo(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFA726),
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
                        'الخطوط الجوية: ${flight.airline}',
                        style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildDetailRow(
                        context,
                        Icons.flight_takeoff,
                        'المغادرة:',
                        '${flight.departureCity.name} (${flight.departureCity.iataCode ?? ''})',
                        intl.DateFormat('yyyy-MM-dd HH:mm')
                            .format(flight.departureTime),
                      ),
                      _buildDetailRow(
                        context,
                        Icons.flight_land,
                        'الوصول:',
                        '${flight.arrivalCity.name} (${flight.arrivalCity.iataCode ?? ''})',
                        intl.DateFormat('yyyy-MM-dd HH:mm')
                            .format(flight.arrivalTime),
                      ),
                      _buildDetailRow(
                        context,
                        Icons.timer,
                        'المدة:',
                        _formatDuration(flight.durationMinutes),
                      ),
                      _buildDetailRow(
                        context,
                        Icons.alt_route,
                        'التوقفات:',
                        flight.stops == 0 ? 'مباشرة' : '${flight.stops} توقف',
                      ),
                      _buildDetailRow(
                        context,
                        Icons.chair,
                        'الفئة:',
                        flight.travelClass == 'Economy'
                            ? 'اقتصادي'
                            : flight.travelClass == 'Business'
                                ? 'أعمال'
                                : 'أولى',
                      ),
                      _buildDetailRow(
                        context,
                        Icons.event_seat,
                        'المقاعد المتاحة:',
                        flight.availableSeats.toString(),
                      ),
                      const Divider(height: 20, thickness: 1),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'السعر: ${flight.price.toStringAsFixed(0)} ${flight.currency}',
                          style: GoogleFonts.cairo(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFA726)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // التعديل هنا: الانتقال لصفحة الحجز الفعلية
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FlightBookingScreen(flight: flight),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.018),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: Text('احجز هذه الرحلة',
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value1,
      [String? value2]) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFA726), size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                Text(
                  value1,
                  style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.038, color: Colors.grey[700]),
                ),
                if (value2 != null)
                  Text(
                    value2,
                    style: GoogleFonts.cairo(
                        fontSize: screenWidth * 0.035, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

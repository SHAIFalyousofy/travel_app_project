import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HotelSearchScreen extends StatelessWidget {
  const HotelSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('البحث عن فنادق', style: GoogleFonts.cairo()),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFA726),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_rounded, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'شاشة البحث عن الفنادق قيد الإنشاء.',
                style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'ترقبوا المزيد من الميزات قريباً!',
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

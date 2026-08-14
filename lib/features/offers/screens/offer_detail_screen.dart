import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl; // لتنسيق التاريخ

import 'package:travel_app_project/features/offers/models/offer_model.dart'; // استيراد نموذج العرض

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;

  const OfferDetailScreen({super.key, required this.offer});

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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: offer.imageUrl,
                    height: screenHeight * 0.35,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: screenHeight * 0.35,
                      color: Colors.grey[200],
                      child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFFFFA726))),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: screenHeight * 0.35,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image,
                          size: 80, color: Colors.grey),
                    ),
                  ),
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
                  Positioned(
                    bottom: screenHeight * 0.02,
                    right: screenWidth * 0.04,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          offer.title,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(blurRadius: 3, color: Colors.black54)
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenHeight * 0.006),
                          decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(offer.discount,
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل العرض:',
                      style: GoogleFonts.cairo(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.description,
                      style: GoogleFonts.cairo(
                        fontSize: screenWidth * 0.038,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    if (offer.validUntil != null) ...[
                      _buildInfoRow(
                        context,
                        Icons.date_range_rounded,
                        'صالح حتى:',
                        intl.DateFormat('dd MMMM yyyy', 'ar')
                            .format(offer.validUntil!),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (offer.termsAndConditions != null &&
                        offer.termsAndConditions!.isNotEmpty) ...[
                      Text(
                        'الشروط والأحكام:',
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer.termsAndConditions!,
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.038,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 20),
                    ],
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم تفعيل العرض على ${offer.title}!',
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFFFFA726),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1,
                              vertical: screenHeight * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5.0,
                        ),
                        child: Text(
                          'احجز العرض الآن',
                          style: GoogleFonts.cairo(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFA726), size: screenWidth * 0.05),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              textDirection: TextDirection.rtl,
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
}

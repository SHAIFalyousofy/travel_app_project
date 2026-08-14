import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app_project/features/destination/models/destination_model.dart'; // استيراد نموذج الوجهة

class CategoryDestinationsScreen extends StatelessWidget {
  final String categoryTitle;
  final String categoryIcon;
  final List<Destination> allDestinations; // قائمة بجميع الوجهات

  const CategoryDestinationsScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.allDestinations,
  });

  @override
  Widget build(BuildContext context) {
    // تصفية الوجهات بناءً على التصنيف المختار
    final filteredDestinations = allDestinations
        .where((dest) => dest.categoryName == categoryTitle)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '$categoryIcon $categoryTitle',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFA726), // نفس اللون البرتقالي
          foregroundColor: Colors.white,
        ),
        body: filteredDestinations.isEmpty
            ? Center(
                child: Text(
                  'لا توجد وجهات في هذا التصنيف حالياً.',
                  style:
                      GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredDestinations.length,
                itemBuilder: (context, index) {
                  final destination = filteredDestinations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination.country,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // يمكنك إضافة المزيد من التفاصيل أو صورة هنا
                          Align(
                            alignment:
                                Alignment.bottomLeft, // محاذاة لليسار في RTL
                            child: Text(
                              '${destination.price.toStringAsFixed(0)} ${destination.currency}',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFA726),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

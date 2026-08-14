import 'package:flutter/material.dart';

class DestinationDetailsPage extends StatelessWidget {
  const DestinationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 🔝 Header Image + Back + Share
              Stack(
                children: [
                  Container(
                    height: screenWidth * 0.6,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://picsum.photos/800/400"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              // 📦 Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان والتقييم
                      Text(
                        "🌄 البتراء – الأردن",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star_half, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Text("(1250 تقييم)"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // وصف الوجهة
                      const Text(
                        "📖 وصف الوجهة:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "البتراء هي مدينة أثرية تقع جنوب الأردن، وتعد من عجائب العالم السبع الجديدة. تتميز بمعالمها المنحوتة في الصخور الوردية وأجوائها التاريخية الفريدة.",
                      ),

                      const SizedBox(height: 20),

                      // ✅ المميزات
                      const Text("✅ المميزات:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          FeatureChip(label: "🛜 واي فاي"),
                          FeatureChip(label: "🧭 جولات سياحية"),
                          FeatureChip(label: "🍽️ طعام محلي"),
                          FeatureChip(label: "🧒 مناسب للأطفال"),
                          FeatureChip(label: "🌍 مرشدين متعددين اللغات"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // صور إضافية
                      const Text("🖼️ صور إضافية:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://picsum.photos/100/100?random=$index"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // وقت الزيارة والطقس
                      const Text("📅 وقت الزيارة المثالي: أكتوبر – إبريل"),
                      const SizedBox(height: 4),
                      const Text("☀️ الطقس: معتدل ومشمس"),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ✅ زر الحجز ثابت بأسفل الشاشة
        bottomSheet: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.blue[800],
            ),
            icon: const Icon(Icons.calendar_today),
            label: const Text("📅 احجز الآن – 150 د.أ"),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final String label;

  const FeatureChip({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.blue[50],
      label: Text(label),
    );
  }
}

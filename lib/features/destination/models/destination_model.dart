// نموذج لخصائص الوجهة (مثل "آثار تاريخية")
class Feature {
  final String icon;
  final String title;

  Feature({required this.icon, required this.title});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      icon: json['feature_icon'],
      title: json['feature_title'],
    );
  }
}

// نموذج الوجهة
class Destination {
  final String id;
  final String name;
  final String country;
  final String mainImageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final String? bestTimeToVisit; // يمكن أن يكون null
  final String? weather; // يمكن أن يكون null
  final double price;
  final String currency;
  final String? categoryName; // اسم التصنيف
  final List<Feature> features; // قائمة بالمميزات
  final List<String> galleryImages; // قائمة بروابط صور المعرض

  Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.mainImageUrl,
    required this.description,
    required this.rating,
    required this.reviewCount,
    this.bestTimeToVisit,
    this.weather,
    required this.price,
    required this.currency,
    this.categoryName,
    required this.features,
    required this.galleryImages,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    // تحليل قائمة المميزات
    var featuresList = json['features'] as List?;
    List<Feature> parsedFeatures = featuresList != null
        ? featuresList.map((i) => Feature.fromJson(i)).toList()
        : [];

    // تحليل قائمة صور المعرض
    var galleryList = json['gallery_images'] as List?;
    List<String> parsedGalleryImages = galleryList != null
        ? galleryList.map((i) => i.toString()).toList()
        : [];

    return Destination(
      id: json['id'].toString(),
      name: json['name'],
      country: json['country'],
      mainImageUrl: json['main_image_url'] ?? '', // تأكد من وجود قيمة افتراضية
      description: json['description'] ?? 'لا يوجد وصف متاح.',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
      bestTimeToVisit: json['best_time_to_visit'],
      weather: json['weather'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      currency: json['currency'] ?? '\$',
      categoryName: json['category_name'],
      features: parsedFeatures,
      galleryImages: parsedGalleryImages,
    );
  }
}

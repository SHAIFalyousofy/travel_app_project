class Offer {
  final String id;
  final String title;
  final String imageUrl;
  final String discount;
  final String description;
  final DateTime? validUntil; // يمكن أن يكون null
  final String? termsAndConditions; // يمكن أن يكون null

  Offer({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.discount,
    required this.description,
    this.validUntil,
    this.termsAndConditions,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'].toString(),
      title: json['title'] ?? 'عرض غير معروف',
      imageUrl:
          json['image_url'] ?? '', // تأكد من استخدام 'image_url' كما في الـ API
      discount: json['discount'] ?? 'لا يوجد خصم',
      description: json['description'] ?? 'لا يوجد وصف متاح لهذا العرض.',
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'])
          : null,
      termsAndConditions: json['terms_and_conditions'],
    );
  }
}

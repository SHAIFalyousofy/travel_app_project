class City {
  final String id;
  final String name;
  final String country;
  final String? iataCode;

  City(
      {required this.id,
      required this.name,
      required this.country,
      this.iataCode});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      iataCode: json['iata_code'],
    );
  }

  // دالة لمساعدتنا في عرض المدينة في واجهة المستخدم (مثال: في حقل النص)
  @override
  String toString() {
    return '$name, $country ${iataCode != null ? '(${iataCode!})' : ''}';
  }
}

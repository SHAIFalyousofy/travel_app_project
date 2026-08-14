import 'dart:convert'; // لاستخدام jsonDecode

class Booking {
  final String id;
  final String userId;
  final String bookingType; // 'flight', 'hotel', 'package'
  final String itemId; // معرف الرحلة أو الفندق أو الباقة
  final DateTime bookingDate;
  final double totalPrice;
  final String currency;
  final String status; // 'confirmed', 'pending', 'cancelled'
  final Map<String, dynamic>? details; // لتخزين تفاصيل إضافية كـ JSON

  // حقول إضافية لعرض تفاصيل الحجز (خاصة بالرحلات في هذه المرحلة)
  final String? flightNumber;
  final String? airline;
  final String? departureCityName;
  final String? arrivalCityName;

  Booking({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.itemId,
    required this.bookingDate,
    required this.totalPrice,
    required this.currency,
    required this.status,
    this.details,
    this.flightNumber,
    this.airline,
    this.departureCityName,
    this.arrivalCityName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      bookingType: json['booking_type'] ?? 'unknown',
      itemId: json['item_id'].toString(),
      bookingDate: DateTime.parse(json['booking_date']),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      currency: json['currency'] ?? '\$',
      status: json['status'] ?? 'pending',
      // التصحيح هنا: يتم تحويل json['details_json'] مباشرة إلى Map<String, dynamic>
      // بدلاً من محاولة jsonDecode مرة أخرى، لأنه قد يكون بالفعل Map من الـ API
      details: json['details_json'] is Map<String, dynamic>
          ? json['details_json'] as Map<String, dynamic>
          : (json['details_json'] != null && json['details_json'] is String
              ? jsonDecode(json['details_json']) as Map<String, dynamic>
              : null),

      // تحليل الحقول الإضافية من الـ JSON (تأكد من مطابقة الأسماء هنا لأسماء المفاتيح في الـ API)
      flightNumber: json['flight_number'],
      airline: json['airline'],
      departureCityName: json['departure_city_name'],
      arrivalCityName: json['arrival_city_name'],
    );
  }

  // دالة مساعدة لتحويل الكائن إلى JSON لإرساله إلى الـ API (لعملية الإنشاء)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'booking_type': bookingType,
      'item_id': itemId,
      'booking_date': bookingDate.toIso8601String(),
      'total_price': totalPrice,
      'currency': currency,
      'status': status,
      'details_json': details != null ? jsonEncode(details) : null,
    };
  }
}

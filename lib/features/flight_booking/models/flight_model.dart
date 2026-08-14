import 'package:travel_app_project/features/flight_booking/models/city_model.dart'; // استيراد نموذج المدينة

class Flight {
  final String id;
  final String flightNumber;
  final String airline;
  final City departureCity;
  final City arrivalCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int durationMinutes;
  final double price;
  final String currency;
  final int stops;
  final String travelClass;
  final int availableSeats;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.price,
    required this.currency,
    required this.stops,
    required this.travelClass,
    required this.availableSeats,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'].toString(),
      flightNumber: json['flight_number'] ?? '',
      airline: json['airline'] ?? '',
      departureCity:
          City.fromJson(json['departure_city'] as Map<String, dynamic>),
      arrivalCity: City.fromJson(json['arrival_city'] as Map<String, dynamic>),
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      durationMinutes: int.tryParse(json['duration_minutes'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      currency: json['currency'] ?? '\$',
      stops: int.tryParse(json['stops'].toString()) ?? 0,
      travelClass: json['travel_class'] ?? 'Economy',
      availableSeats: int.tryParse(json['available_seats'].toString()) ?? 0,
    );
  }
}

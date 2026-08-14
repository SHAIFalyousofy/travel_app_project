import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart' as intl; // لتنسيق التاريخ

import 'package:travel_app_project/features/flight_booking/models/city_model.dart';
import 'package:travel_app_project/features/flight_booking/models/flight_model.dart';
import 'package:travel_app_project/features/flight_booking/screens/flight_booking_screen.dart';
import 'package:travel_app_project/features/flight_booking/screens/flight_detail_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  static const Color primaryOrange = Color(0xFFFFA726);

  City? _departureCity;
  City? _arrivalCity;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengers = 1;
  String _travelClass = 'Economy'; // الخيارات: Economy, Business, First

  final TextEditingController _departureCityController =
      TextEditingController();
  final TextEditingController _arrivalCityController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _passengersController =
      TextEditingController(text: '1');

  final String _getCitiesApiUrl = 'http://localhost/travel_api/get_cities.php';
  final String _searchFlightsApiUrl =
      'http://localhost/travel_api/search_flights.php';

  List<Flight> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _passengersController.text = _passengers.toString();
  }

  @override
  void dispose() {
    _departureCityController.dispose();
    _arrivalCityController.dispose();
    _departureDateController.dispose();
    _returnDateController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  // دالة لعرض منتقي المدن
  Future<void> _showCityPicker(BuildContext context,
      {required bool isDeparture}) async {
    List<City> cities = [];
    try {
      final response = await http.get(Uri.parse(_getCitiesApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          cities = (responseData['data'] as List)
              .map((e) => City.fromJson(e))
              .toList();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'فشل جلب المدن.',
                    style: GoogleFonts.cairo())),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ في الخادم: ${response.statusCode}',
                  style: GoogleFonts.cairo())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطأ في الاتصال: $e', style: GoogleFonts.cairo())),
      );
    }

    final City? selectedCity = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true, // لجعل الشيت يمتد لأعلى قدر الإمكان
      builder: (BuildContext context) {
        return _CitySelectionBottomSheet(cities: cities);
      },
    );

    if (selectedCity != null) {
      setState(() {
        if (isDeparture) {
          _departureCity = selectedCity;
          _departureCityController.text = selectedCity.name;
        } else {
          _arrivalCity = selectedCity;
          _arrivalCityController.text = selectedCity.name;
        }
      });
    }
  }

  // دالة لعرض منتقي التاريخ
  Future<void> _selectDate(BuildContext context,
      {required bool isDepartureDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange, // لون التحديد
              onPrimary: Colors.white, // لون النص على التحديد
              onSurface: Colors.black, // لون النص العادي
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: primaryOrange), // لون أزرار النص
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDepartureDate) {
          _departureDate = picked;
          // التصحيح هنا: استخدام 'en_US' لضمان تنسيق الأرقام الإنجليزية
          _departureDateController.text =
              intl.DateFormat('yyyy-MM-dd', 'en_US').format(picked);
        } else {
          _returnDate = picked;
          // التصحيح هنا: استخدام 'en_US' لضمان تنسيق الأرقام الإنجليزية
          _returnDateController.text =
              intl.DateFormat('yyyy-MM-dd', 'en_US').format(picked);
        }
      });
    }
  }

  // دالة لإجراء البحث عن الرحلات
  Future<void> _searchFlights() async {
    if (_departureCity == null ||
        _arrivalCity == null ||
        _departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'الرجاء إدخال مدينة المغادرة والوصول وتاريخ المغادرة.',
                style: GoogleFonts.cairo())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      final Map<String, dynamic> queryParams = {
        'departure_city_id': _departureCity!.id,
        'arrival_city_id': _arrivalCity!.id,
        // التصحيح هنا: استخدام 'en_US' لضمان تنسيق الأرقام الإنجليزية عند إرسالها للـ API
        'departure_date':
            intl.DateFormat('yyyy-MM-dd', 'en_US').format(_departureDate!),
        'passengers': _passengers.toString(),
        'travel_class': _travelClass,
      };
      if (_returnDate != null) {
        // التصحيح هنا: استخدام 'en_US' لضمان تنسيق الأرقام الإنجليزية
        queryParams['return_date'] =
            intl.DateFormat('yyyy-MM-dd', 'en_US').format(_returnDate!);
      }

      final uri =
          Uri.parse(_searchFlightsApiUrl).replace(queryParameters: queryParams);
      print('DEBUG: Sending flight search request to URL: $uri'); // DEBUG
      final response = await http.get(uri);
      print(
          'DEBUG: Flight search response status: ${response.statusCode}'); // DEBUG
      print('DEBUG: Flight search response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _searchResults = (responseData['data'] as List)
                .map((e) => Flight.fromJson(e))
                .toList();
            print(
                'DEBUG: Successfully parsed ${_searchResults.length} flights.'); // DEBUG
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'فشل البحث عن الرحلات.';
            _searchResults = [];
            print(
                'DEBUG: Flight search API returned success: false or no data: ${responseData['message']}'); // DEBUG
          });
        }
      } else {
        setState(() {
          _errorMessage = 'خطأ في الخادم: ${response.statusCode}.';
          _searchResults = [];
          print(
              'DEBUG: Flight search API server error: ${response.statusCode}'); // DEBUG
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع أثناء البحث: ${e.toString()}';
          _searchResults = [];
          print('DEBUG: Error during flight search: $e'); // DEBUG
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('البحث عن رحلات طيران',
              style: GoogleFonts.cairo(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryOrange,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCityInputField(
                        context,
                        controller: _departureCityController,
                        label: 'مدينة المغادرة',
                        icon: Icons.flight_takeoff,
                        onTap: () =>
                            _showCityPicker(context, isDeparture: true),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildCityInputField(
                        context,
                        controller: _arrivalCityController,
                        label: 'مدينة الوصول',
                        icon: Icons.flight_land,
                        onTap: () =>
                            _showCityPicker(context, isDeparture: false),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateInputField(
                              context,
                              controller: _departureDateController,
                              label: 'تاريخ المغادرة',
                              icon: Icons.calendar_today,
                              onTap: () =>
                                  _selectDate(context, isDepartureDate: true),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: _buildDateInputField(
                              context,
                              controller: _returnDateController,
                              label: 'تاريخ العودة (اختياري)',
                              icon: Icons.calendar_today,
                              onTap: () =>
                                  _selectDate(context, isDepartureDate: false),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildPassengersAndClassInput(context),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: _searchFlights,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.15,
                              vertical: screenHeight * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5.0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              )
                            : Text(
                                'البحث عن رحلات',
                                style: GoogleFonts.cairo(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryOrange))
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                      color: Colors.red,
                                      fontSize: screenWidth * 0.04),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _searchFlights,
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  label: Text('أعد المحاولة',
                                      style: GoogleFonts.cairo(
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _hasSearched && _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد رحلات مطابقة لمعايير البحث.',
                                style: GoogleFonts.cairo(
                                    fontSize: 18, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.02),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final flight = _searchResults[index];
                                return FlightCard(
                                    flight: flight); // استخدام FlightCard
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء حقول إدخال المدينة
  Widget _buildCityInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true, // لجعل الحقل غير قابل للكتابة مباشرة
      textAlign: TextAlign.right,
      style:
          GoogleFonts.cairo(fontSize: MediaQuery.of(context).size.width * 0.04),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: primaryOrange),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    if (label == 'مدينة المغادرة') {
                      _departureCity = null;
                    } else {
                      _arrivalCity = null;
                    }
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryOrange, width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      ),
      onTap: onTap,
    );
  }

  // دالة مساعدة لبناء حقول إدخال التاريخ
  Widget _buildDateInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      textAlign: TextAlign.right,
      style:
          GoogleFonts.cairo(fontSize: MediaQuery.of(context).size.width * 0.04),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: primaryOrange),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    if (label == 'تاريخ المغادرة') {
                      _departureDate = null;
                    } else {
                      _returnDate = null;
                    }
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryOrange, width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      ),
      onTap: onTap,
    );
  }

  // دالة مساعدة لبناء حقول عدد الركاب وفئة السفر
  Widget _buildPassengersAndClassInput(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _passengersController,
            readOnly: true,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: screenWidth * 0.04),
            decoration: InputDecoration(
              labelText: 'الركاب',
              labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
              prefixIcon: Icon(Icons.person_outline, color: primaryOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: primaryOrange, width: 2.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            ),
            onTap: () async {
              // منتقي عدد الركاب بسيط
              int? selected = await showDialog<int>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('عدد الركاب', style: GoogleFonts.cairo()),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (_passengers > 1) _passengers--;
                                  _passengersController.text =
                                      _passengers.toString();
                                });
                              },
                            ),
                            Text('$_passengers',
                                style: GoogleFonts.cairo(fontSize: 20)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _passengers++;
                                  _passengersController.text =
                                      _passengers.toString();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(_passengers);
                        },
                        child: Text('تأكيد',
                            style: GoogleFonts.cairo(color: primaryOrange)),
                      ),
                    ],
                  );
                },
              );
              if (selected != null) {
                setState(() {
                  _passengers = selected;
                  _passengersController.text = _passengers.toString();
                });
              }
            },
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _travelClass,
            decoration: InputDecoration(
              labelText: 'فئة السفر',
              labelStyle: GoogleFonts.cairo(color: Colors.grey[700]),
              prefixIcon: Icon(Icons.chair_outlined, color: primaryOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: primaryOrange, width: 2.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            ),
            items: <String>['Economy', 'Business', 'First'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                    value == 'Economy'
                        ? 'اقتصادي'
                        : value == 'Business'
                            ? 'أعمال'
                            : 'أولى',
                    style: GoogleFonts.cairo()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _travelClass = newValue!;
              });
            },
            style: GoogleFonts.cairo(
                fontSize: screenWidth * 0.04, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

// ويدجت منتقي المدن (BottomSheet)
class _CitySelectionBottomSheet extends StatefulWidget {
  final List<City> cities;

  const _CitySelectionBottomSheet({required this.cities});

  @override
  State<_CitySelectionBottomSheet> createState() =>
      _CitySelectionBottomSheetState();
}

class _CitySelectionBottomSheetState extends State<_CitySelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = widget.cities.where((city) {
        return city.name.toLowerCase().contains(query) ||
            city.country.toLowerCase().contains(query) ||
            (city.iataCode?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.8, // ارتفاع الشيت
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            // مقبض السحب
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'اختر مدينة',
            style: GoogleFonts.cairo(
                fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: screenHeight * 0.02),
          TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              hintText: 'ابحث عن مدينة...',
              hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return ListTile(
                  title: Text(city.name,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${city.country} ${city.iataCode != null ? '(${city.iataCode!})' : ''}',
                      style: GoogleFonts.cairo(color: Colors.grey[600])),
                  onTap: () {
                    Navigator.pop(context, city); // إرجاع المدينة المختارة
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ويدجت لعرض بطاقة الرحلة في النتائج
class FlightCard extends StatelessWidget {
  final Flight flight;

  const FlightCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // دالة مساعدة لحساب المدة بتنسيق ساعة:دقيقة
    String _formatDuration(int minutes) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}س ${remainingMinutes}د';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightDetailScreen(
                  flight: flight), // الانتقال لصفحة تفاصيل الرحلة
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    flight.airline,
                    style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    flight.flightNumber,
                    style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intl.DateFormat('HH:mm').format(flight.departureTime),
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        flight.departureCity.iataCode ??
                            flight.departureCity.name,
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        flight.departureCity.country,
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _formatDuration(flight.durationMinutes),
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                      Icon(Icons.flight_takeoff,
                          color: const Color(0xFFFFA726),
                          size: screenWidth * 0.06),
                      Text(
                        flight.stops == 0 ? 'مباشرة' : '${flight.stops} توقف',
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        intl.DateFormat('HH:mm').format(flight.arrivalTime),
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        flight.arrivalCity.iataCode ?? flight.arrivalCity.name,
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        flight.arrivalCity.country,
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${flight.price.toStringAsFixed(0)} ${flight.currency}',
                    style: GoogleFonts.cairo(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA726),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: الانتقال لصفحة الحجز
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: Text('احجز الآن',
                        style: GoogleFonts.cairo(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

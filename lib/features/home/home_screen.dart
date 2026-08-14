import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد shared_preferences

import 'package:travel_app_project/features/auth/login_screen.dart';
import 'package:travel_app_project/features/bookings/screens/my_bookings_screen.dart';
import 'package:travel_app_project/features/destination/destination_detail_screen.dart';
import 'package:travel_app_project/features/destination/models/destination_model.dart';
import 'package:travel_app_project/features/flight_booking/flight_search_screen.dart';
import 'package:travel_app_project/features/hotel_booking/hotel_search_screen.dart';
import 'package:travel_app_project/features/offers/models/offer_model.dart';
import 'package:travel_app_project/features/offers/screens/offer_detail_screen.dart';
import 'package:travel_app_project/features/profile/profile_screen.dart';
import 'package:travel_app_project/features/search/search_screen.dart';
import '../category/screens/category_destinations_screen.dart';

// تعريف نموذج Category (للتأكيد، يجب أن يكون في ملفه الخاص عادةً)
class Category {
  final String id;
  final String title;
  final String icon;

  Category({required this.id, required this.title, required this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      title: json['title'],
      icon: json['icon'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _offerPageController = PageController();
  int _currentOfferSlide = 0;

  static const Color primaryOrange = Color(0xFFFFA726);

  final String _offersApiUrl = 'http://localhost/travel_api/get_offers.php';
  final String _categoriesApiUrl =
      'http://localhost/travel_api/get_categories.php';
  final String _destinationsApiUrl =
      'http://localhost/travel_api/get_destinations.php';

  List<Offer> _offers = [];
  List<Category> _categories = [];
  List<Destination> _destinations = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await Future.wait([
        _fetchOffers(),
        _fetchCategories(),
        _fetchDestinations(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل في تحميل البيانات: ${e.toString()}';
        });
      }
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchOffers() async {
    try {
      final response = await http.get(Uri.parse(_offersApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _offers = (responseData['data'] as List)
                .map((e) => Offer.fromJson(e))
                .toList();
          });
        } else {
          throw Exception(responseData['message'] ?? 'فشل جلب العروض');
        }
      } else {
        throw Exception('فشل الخادم في جلب العروض: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بجلب العروض: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(_categoriesApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _categories = (responseData['data'] as List)
                .map((e) => Category.fromJson(e))
                .toList();
          });
        } else {
          throw Exception(responseData['message'] ?? 'فشل جلب التصنيفات');
        }
      } else {
        throw Exception('فشل الخادم في جلب التصنيفات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بجلب التصنيفات: $e');
    }
  }

  Future<void> _fetchDestinations() async {
    try {
      final response = await http.get(Uri.parse(_destinationsApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _destinations = (responseData['data'] as List).map((e) {
              final destination = Destination.fromJson(e);
              print(
                  'Destination: ${destination.name}, Image URL: ${destination.mainImageUrl}');
              return destination;
            }).toList();
          });
        } else {
          print(
              'Destinations API returned success: false or no data: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'فشل جلب الوجهات');
        }
      } else {
        print('Destinations API server error: ${response.statusCode}');
        throw Exception('فشل الخادم في جلب الوجهات: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _fetchDestinations: $e');
      throw Exception('خطأ في الاتصال بجلب الوجهات: $e');
    }
  }

  @override
  void dispose() {
    _offerPageController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: 'ابحث عن وجهة، مدينة أو فندق...',
          hintStyle: GoogleFonts.cairo(
              color: Colors.grey[600], fontSize: screenWidth * 0.035),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenWidth * 0.035),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
      ),
    );
  }

  Widget _buildOfferSlider(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_offers.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.22,
          child: PageView.builder(
            controller: _offerPageController,
            onPageChanged: (index) =>
                setState(() => _currentOfferSlide = index),
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferDetailScreen(offer: offer),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: offer.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: primaryOrange)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7)
                            ]))),
                        Positioned(
                          bottom: screenHeight * 0.02,
                          right: screenWidth * 0.04,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(offer.title,
                                  style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                            blurRadius: 2,
                                            color: Colors.black54)
                                      ])),
                              const SizedBox(height: 3),
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
                                        fontSize: screenWidth * 0.03,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _offers.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentOfferSlide == entry.key
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.4)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_categories.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text('التصنيفات',
              style: GoogleFonts.cairo(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        SizedBox(height: screenHeight * 0.015),
        SizedBox(
          height: screenHeight * 0.13,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: false,
            itemCount: _categories.length,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDestinationsScreen(
                        categoryTitle: category.title,
                        categoryIcon: category.icon,
                        allDestinations: _destinations,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: screenWidth * 0.14,
                        height: screenWidth * 0.14,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2))),
                        child: Center(
                            child: Text(category.icon,
                                style:
                                    TextStyle(fontSize: screenWidth * 0.055))),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Text(category.title,
                          style: GoogleFonts.cairo(
                              fontSize: screenWidth * 0.03,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopDestinations(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_destinations.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text('أفضل الوجهات',
              style: GoogleFonts.cairo(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        SizedBox(height: screenHeight * 0.015),
        SizedBox(
          height: screenHeight * 0.28,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _destinations.length,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            itemBuilder: (context, index) {
              final dest = _destinations[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DestinationDetailScreen(destination: dest),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.45,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Card(
                    elevation: 3.0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: dest.mainImageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: screenHeight * 0.15,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: primaryOrange)),
                          ),
                          errorWidget: (context, url, error) {
                            print(
                                'CachedNetworkImage Error for ${dest.name}: $error, URL: ${dest.mainImageUrl}');
                            return Container(
                              height: screenHeight * 0.15,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dest.name,
                                  style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(dest.country,
                                  style: GoogleFonts.cairo(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${dest.price.toStringAsFixed(0)} ${dest.currency}',
                                      style: GoogleFonts.cairo(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  Row(
                                    children: [
                                      Text('${dest.rating}',
                                          style: GoogleFonts.cairo(
                                              fontSize: screenWidth * 0.03,
                                              color: Colors.amber[700],
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 2),
                                      Icon(Icons.star,
                                          color: Colors.amber[700],
                                          size: screenWidth * 0.035),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _quickAccessButton(
              context, Icons.flight_takeoff_rounded, 'رحلات طيران', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FlightSearchScreen()));
          }),
          _quickAccessButton(context, Icons.hotel_rounded, 'فنادق', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HotelSearchScreen()));
          }),
        ],
      ),
    );
  }

  Widget _quickAccessButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ElevatedButton.icon(
          icon: Icon(icon,
              size: screenWidth * 0.05, color: Theme.of(context).primaryColor),
          label: Text(label,
              style: GoogleFonts.cairo(
                  fontSize: screenWidth * 0.035,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600)),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            foregroundColor: Theme.of(context).primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
            side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageWidgets() {
    return [
      ExploreTabWidget(
        searchBar: _buildSearchBar(context),
        offerSlider: _buildOfferSlider(context),
        categories: _buildCategories(context),
        topDestinations: _buildTopDestinations(context),
        quickAccessButtons: _buildQuickAccessButtons(context),
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRefresh: _fetchData,
      ),
      Scaffold(
          appBar: AppBar(title: Text('الخريطة', style: GoogleFonts.cairo())),
          body: Center(
              child:
                  Text('شاشة الخريطة (قريباً)', style: GoogleFonts.cairo()))),
      MyBookingsScreen(),
      Scaffold(
        appBar: AppBar(
          title: Text('حسابي', style: GoogleFonts.cairo()),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout), // أيقونة تسجيل الخروج
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                // الدالة التي تُنفذ عند الضغط على زر تسجيل الخروج
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(
                    'user_id'); // مسح معرف المستخدم من shared_preferences

                if (mounted) {
                  // العودة إلى صفحة تسجيل الدخول وإزالة جميع الصفحات السابقة من المكدس
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            )
          ],
        ),
        body: Center(child: ProfileScreen()),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageWidgets = _buildPageWidgets();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: IndexedStack(
          index: _selectedIndex,
          children: pageWidgets,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'استكشف'),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'الخريطة'),
            BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Icon(Icons.event_note),
                label: 'حجوزاتي'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'حسابي'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 8.0,
          selectedLabelStyle:
              GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
        ),
      ),
    );
  }
}

class ExploreTabWidget extends StatelessWidget {
  final Widget searchBar;
  final Widget offerSlider;
  final Widget categories;
  final Widget topDestinations;
  final Widget quickAccessButtons;
  final bool isLoading;
  final String errorMessage;
  final Future<void> Function() onRefresh;

  const ExploreTabWidget({
    super.key,
    required this.searchBar,
    required this.offerSlider,
    required this.categories,
    required this.topDestinations,
    required this.quickAccessButtons,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    String welcomeMessage = 'أهلاً بك في تطبيق السفر!';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: _HomeScreenState.primaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04, vertical: 10.0),
                child: Text(
                  welcomeMessage,
                  style: GoogleFonts.cairo(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              searchBar,
              const SizedBox(height: 15),
              isLoading
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                          color: _HomeScreenState.primaryOrange),
                    ))
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  errorMessage,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                      color: Colors.red,
                                      fontSize: screenWidth * 0.04),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: onRefresh,
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  label: Text('أعد المحاولة',
                                      style: GoogleFonts.cairo(
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _HomeScreenState.primaryOrange,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            offerSlider,
                            const SizedBox(height: 25),
                            categories,
                            const SizedBox(height: 25),
                            topDestinations,
                            const SizedBox(height: 20),
                            quickAccessButtons,
                            const SizedBox(height: 20),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

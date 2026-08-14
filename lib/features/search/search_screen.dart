import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:travel_app_project/features/destination/models/destination_model.dart';
import 'package:travel_app_project/features/destination/destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color primaryOrange = Color(0xFFFFA726);

  final TextEditingController _searchController = TextEditingController();
  final String _searchApiUrl =
      'http://localhost/travel_api/search_destinations.php'; // تأكد من عنوان IP الصحيح

  List<Destination> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasSearched = false; // لتتبع ما إذا كان المستخدم قد أجرى بحثًا بالفعل

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$_searchApiUrl?query=${Uri.encodeComponent(query)}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          setState(() {
            _searchResults = (responseData['data'] as List)
                .map((e) => Destination.fromJson(e))
                .toList();
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'فشل البحث عن الوجهات.';
            _searchResults = [];
          });
        }
      } else {
        setState(() {
          _errorMessage = 'خطأ في الخادم: ${response.statusCode}.';
          _searchResults = [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع أثناء البحث: ${e.toString()}';
          _searchResults = [];
        });
      }
      print('Error performing search: $e');
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('البحث عن وجهة',
              style: GoogleFonts.cairo(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryOrange,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: 'ابحث عن وجهة، مدينة أو فندق...',
                  hintStyle: GoogleFonts.cairo(
                      color: Colors.grey[600], fontSize: screenWidth * 0.035),
                  prefixIcon: Icon(Icons.search, color: primaryOrange),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch(''); // مسح النتائج عند مسح النص
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.035),
                ),
                onSubmitted: (value) =>
                    _performSearch(value), // البحث عند الضغط على Enter
                onChanged: (value) {
                  // يمكن إضافة بحث فوري هنا إذا أردت، لكن onSubmitted أفضل للأداء
                  // if (value.isEmpty) _performSearch('');
                },
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
                                  onPressed: () =>
                                      _performSearch(_searchController.text),
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
                                'لا توجد نتائج مطابقة لبحثك.',
                                style: GoogleFonts.cairo(
                                    fontSize: 18, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04),
                              itemBuilder: (context, index) {
                                final destination = _searchResults[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  elevation: 3.0,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: InkWell(
                                    // استخدام InkWell لجعل البطاقة قابلة للنقر
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DestinationDetailScreen(
                                                  destination: destination),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: destination.mainImageUrl,
                                            width: screenWidth * 0.25,
                                            height: screenWidth *
                                                0.25 *
                                                0.75, // نسبة عرض إلى ارتفاع
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              primaryOrange)),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 30,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.04),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  destination.name,
                                                  style: GoogleFonts.cairo(
                                                      fontSize:
                                                          screenWidth * 0.045,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  destination.country,
                                                  style: GoogleFonts.cairo(
                                                      fontSize:
                                                          screenWidth * 0.035,
                                                      color: Colors.grey[600]),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${destination.price.toStringAsFixed(0)} ${destination.currency}',
                                                      style: GoogleFonts.cairo(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryOrange),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${destination.rating}',
                                                          style: GoogleFonts.cairo(
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.035,
                                                              color: Colors
                                                                  .amber[700],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Icon(Icons.star,
                                                            color: Colors
                                                                .amber[700],
                                                            size: screenWidth *
                                                                0.038),
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
            ),
          ],
        ),
      ),
    );
  }
}

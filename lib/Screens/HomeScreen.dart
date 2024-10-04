import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bookbliss_final/Screens/your_shelf.dart';
import 'package:bookbliss_final/Screens/profile.dart';
import 'package:bookbliss_final/Screens/bookNest.dart';
import 'package:bookbliss_final/Screens/reviews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookbliss_final/Screens/challenges.dart';
import 'package:bookbliss_final/Widget/CustomBottomNavigationBar.dart';

import '../Widget/CustomBottomNavigationBar.dart'; // Ensure this import is correct

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _reviews = [];
  List<dynamic> _groups = [];
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchReviews();
  }

  Future<void> fetchGroups() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        var response = await http.get(
          Uri.parse('http://172.20.10.4:8000/api/groups'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          setState(() {
            _groups = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
          print('Error loading groups: ${response.body}');
        }
      } catch (error) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print('Error: $error');
      }
    } else {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Token not found');
    }
  }

  Future<void> fetchReviews() async {
    final url = Uri.parse('http://172.20.10.4:8000/api/reviews');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _reviews = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        hasError = true;
      });
    }
  }

  Widget _buildGroupList() {
    if (_groups.isEmpty) {
      return Center(
        child: Text('No groups available.', style: TextStyle(color: Colors.white)),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          final imageUrl = 'http://172.20.10.4:8000/storage/${group['image']}';

          final isValidUrl = imageUrl.isNotEmpty &&
              (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              child: Container(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isValidUrl
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey,
                          child: Center(child: Text('No Image')),
                        );
                      },
                    )
                        : Container(
                      height: 120,
                      color: Colors.grey,
                      child: Center(child: Text('No Image')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['name'] ?? 'No name available',
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            group['description'] ?? 'No description available',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Implement join group logic here
                            },
                            child: Text('Join'),
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
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return Center(
        child: Text('No reviews available.', style: TextStyle(color: Colors.white)),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      review['review_text'] ?? 'No content available',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Rating: ${review['rating'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(Icons.arrow_forward, color: Colors.black, size: 24),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSectionTitle("Groups", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookNest(
                          currentIndex: _selectedIndex,
                          onItemTapped: _onItemTapped,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildGroupList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Reviews", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReviewsScreen()),
                    );
                  }),
                  const SizedBox(height: 10),
                  if (hasError)
                    Center(child: Text('Failed to load reviews.', style: TextStyle(color: Colors.red))),
                  _buildReviewList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Challenges", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChallengesScreen()),
                    );
                  }),
                  const SizedBox(height: 10),
                  // Add your Challenges widget here if needed
                ],
              ),
            ),
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: _selectedIndex,
              onItemTapped: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }


  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Book Bliss',
            style: GoogleFonts.caveat(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

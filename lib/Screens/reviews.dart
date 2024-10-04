import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookbliss_final/Screens/AddReviewScreen.dart';

class ReviewsScreen extends StatefulWidget {
  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final url = Uri.parse('http://172.20.10.4:8000/api/reviews');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          _reviews = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        backgroundColor: Colors.white // Consistent color scheme
      ),
      body: SafeArea(
        child: _reviews.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Row(
                    children: [
                      // Image on the left side
                      if (review['review_image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'http://172.20.10.4:8000/storage/' + review['review_image'],
                            height: 150,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(width: 16), // Space between image and text

                      // Text and ratings on the right side
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['user'] != null ? review['user']['name'] : 'Anonymous', // Access user name if available
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              review['book_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${review['rating']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Icon(Icons.star, color: Colors.orange, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              review['review_text'] ?? '',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                              textAlign: TextAlign.justify,
                              maxLines: 3, // Limit to 3 lines for brevity
                              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                            ),
                            SizedBox(height: 8),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add review screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReviewScreen()),
          );
        },
        backgroundColor: Color(0xFF987D5F),
        child: Icon(Icons.add),
      ),
    );
  }
}

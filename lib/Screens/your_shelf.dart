import 'package:bookbliss_final/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookbliss_final/Widget/CustomBottomNavigationBar.dart';
import 'package:bookbliss_final/Screens/add_book.dart';
import 'package:bookbliss_final/Widget/BaseScreen.dart';

class YourShelf extends StatefulWidget {

  @override
  _YourShelfState createState() => _YourShelfState();
}

class _YourShelfState extends State<YourShelf> {
  List<dynamic> wantToRead = [];
  List<dynamic> wantToBuy = [];
  List<dynamic> favorites = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<bool> isTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? expiry = prefs.getInt('token_expiry');

    if (token == null || expiry == null || DateTime.now().millisecondsSinceEpoch >= expiry) {
      return false; // Token is not valid or expired
    }
    return true; // Token is valid
  }

  Future<void> _refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken != null) {
      try {
        var response = await http.post(
          Uri.parse('http://172.20.10.4:8000/api/refresh-token'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'refresh_token': refreshToken,
          }),
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          String newToken = data['data']['token'];
          int expiry = DateTime.now().millisecondsSinceEpoch + (3600 * 1000); // 1 hour expiry

          prefs.setString('token', newToken);
          prefs.setInt('token_expiry', expiry);
        }
      } catch (error) {
        print('Error refreshing token: $error');
      }
    }
  }

  Future<void> fetchBooks() async {
    final String apiUrl = 'http://172.20.10.4:8000/api/books-all';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (!await isTokenValid()) {
        await _refreshToken();
        token = prefs.getString('token'); // Get the new token after refresh
      }

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch token. Please log in again.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> allBooks = json.decode(response.body);

        setState(() {
          wantToRead = allBooks.where((book) => book['status'] == 'want_to_read').toList();
          wantToBuy = allBooks.where((book) => book['status'] == 'want_to_buy').toList();
          favorites = allBooks.where((book) => book['status'] == 'favorites').toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load books. Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching books: $e';
      });
    }
  }

  Widget buildBookCard(dynamic book) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book['cover_image'] != null
                  ? Image.network(
                'http://172.20.10.4:8000/storage/' + book['cover_image'],
                width: 80,
                height: 120,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 80,
                height: 120,
                color: Colors.grey[300],
                child: Icon(Icons.book, size: 40, color: Colors.grey[700]),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] ?? 'No Title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    book['author'] ?? 'Unknown Author',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategorySection(String title, List<dynamic> books, {bool showAddButton = false}) {
    return books.isNotEmpty
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (showAddButton) // Only show the button for "Want to Read"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddBookScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDBB6B0), // Customize button color
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text('Add books'), // Button text
                  ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return buildBookCard(books[index]);
            },
          ),
        ],
      ),
    )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 2,
      onItemTapped: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Your Shelf'), // Title of the screen
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(

                  )),
                ); // Go back to the previous screen
              },
            ),
            backgroundColor: Color(0xFFDBB6B0), // Customize AppBar color
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFFDBB6B0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBookScreen()),
              );
            },
            child: Icon(Icons.add, size: 28),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildCategorySection('Want to Read', wantToRead, showAddButton: true),
                      buildCategorySection('Want to Buy', wantToBuy),
                      buildCategorySection('Favorites', favorites),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookbliss_final/Screens/add_group.dart';
import '../Widget/BaseScreen.dart';

class BookNest extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  BookNest({required this.currentIndex, required this.onItemTapped});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<BookNest> {
  List<dynamic> groups = [];
  String? token;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Future<void> _loadGroups() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    await _loadToken();

    if (token != null) {
      try {
        var response = await http.get(
          Uri.parse('http://172.20.10.4:8000/api/groups'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          setState(() {
            groups = jsonResponse['data'];
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

  Future<void> _joinGroup(int groupId) async {
    String? token = await _getToken();

    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        print('Error: User ID is null');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: User ID is missing'),
        ));
        return;
      }

      try {
        var response = await http.post(
          Uri.parse('http://172.20.10.4:8000/api/groups/$groupId/join'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'user_id': userId,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Successfully joined group'),
          ));
        } else {
          // Handle different response codes appropriately
          print('Error joining group: ${response.statusCode}, ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error joining group: ${response.body}'),
          ));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred while joining the group: $error'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Token not found'),
      ));
    }
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
          prefs.setString('token', newToken);
        }
      } catch (error) {
        print('Error during token refresh: $error');
      }
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Widget _buildGroupCard(group) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Add vertical margin
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity, // Make the card take full width
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
          children: [
            // Circular image
            ClipOval(
              child: group['image'] != null
                  ? Image.network(
                'http://172.20.10.4:8000/storage/${group['image']}',
                fit: BoxFit.cover,
                height: 60, // Height for the circular image
                width: 60,  // Width for the circular image
              )
                  : Container(
                height: 60,
                width: 60,
                color: Colors.grey,
                child: Center(child: Text('No Image')),
              ),
            ),
            SizedBox(width: 14), // Space between image and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name
                  Text(
                    group['name'],
                    style: TextStyle(
                      fontSize: 17, // Increased font size for better visibility
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Limit to 1 line
                  ),
                  SizedBox(height: 4),
                  // Group description
                  Expanded(
                    child: Text(
                      group['description'] ?? 'No description available',
                      style: TextStyle(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4, // Limit to 2 lines
                    ),
                  ),
                ],
              ),
            ),
            // Join button
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () => _joinGroup(group['id']),
                child: Text('Join', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xFFFADBAD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  @override
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: widget.currentIndex,
      onItemTapped: widget.onItemTapped,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Groups'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadGroups,
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGroupScreen()),
                );
              },
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading groups', style: TextStyle(color: Colors.red, fontSize: 18)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadGroups,
                child: Text('Retry'),
              ),
            ],
          ),
        )
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Use 1 column for larger cards
            childAspectRatio: 3, // Increased aspect ratio for taller cards
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(groups[index]);
          },
        ),
      ),
    );
  }
}

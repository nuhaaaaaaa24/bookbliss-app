import 'package:bookbliss_final/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? bio;
  List<String> genres = [];
  List<String> availableGenres = ['Fiction', 'Non-Fiction', 'Fantasy', 'Sci-Fi', 'Romance'];

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      var response = await http.get(
        Uri.parse('http://172.20.10.4:8000/api/user-profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          name = data['data']['name'];
          email = data['data']['email'];
          bio = data['data']['bio'];
          genres = List<String>.from(data['data']['genre']);
          nameController.text = name!;
          emailController.text = email!;
          bioController.text = bio ?? '';
        });
      } else {
        print('Error loading profile: ${response.body}');
      }
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      var response = await http.put(
        Uri.parse('http://172.20.10.4:8000/api/user-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'email': emailController.text,
          'bio': bioController.text,
          'genre': genres,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          name = data['data']['name'];
          email = data['data']['email'];
          bio = data['data']['bio'];
          genres = List<String>.from(data['data']['genre']);
          isEditing = false;
        });
      } else {
        print('Error updating profile: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        leading: IconButton( // Back arrow button
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );// Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar and Name Section
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundColor: Colors.blueAccent.withOpacity(0.3), // Add a background color
                      child: CircleAvatar(
                        radius: screenWidth * 0.13,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          size: screenWidth * 0.12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  isEditing
                      ? TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  )
                      : Text(
                    name ?? "Loading...",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  isEditing
                      ? TextFormField(
                    controller: bioController,
                    decoration: InputDecoration(
                      labelText: "Bio",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  )
                      : Text(
                    bio ?? 'User Bio/Description',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Profile Details (Email, Bio, etc.)
            _buildProfileDetailCard("Email", emailController, screenWidth),

            // Genres Field
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genres',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  isEditing
                      ? Wrap(
                    spacing: 8.0,
                    children: availableGenres.map((genre) {
                      return ChoiceChip(
                        label: Text(genre),
                        selected: genres.contains(genre),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              genres.add(genre);
                            } else {
                              genres.remove(genre);
                            }
                          });
                        },
                      );
                    }).toList(),
                  )
                      : genres.isNotEmpty
                      ? Wrap(
                    spacing: 8.0,
                    children: genres
                        .map(
                          (genre) => Chip(
                        label: Text(genre),
                        backgroundColor: Colors.blueAccent,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    )
                        .toList(),
                  )
                      : Text(
                    'No genres selected',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailCard(String label, TextEditingController controller, double screenWidth, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      child: Container(
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          color: Colors.grey[200],
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                isEditing
                    ? TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Enter your $label',
                  ),
                )
                    : Text(
                  controller.text.isNotEmpty ? controller.text : "Loading...",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

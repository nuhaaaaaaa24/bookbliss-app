import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddGroupScreen extends StatefulWidget {
  @override
  _AddGroupScreenState createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isCreatingGroup = false;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> _createGroup() async {
    if (token == null) {
      print('Token not found');
      return;
    }

    setState(() {
      isCreatingGroup = true;
    });

    try {
      var response = await http.post(
        Uri.parse('http://172.20.10.4:8000/api/create-groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'description': descriptionController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Group successfully created
        print('Group created successfully');
        Navigator.pop(context); // Close the form screen
      } else {
        print('Error creating group: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isCreatingGroup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Group Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Group Description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: isCreatingGroup ? null : _createGroup,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: isCreatingGroup
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}

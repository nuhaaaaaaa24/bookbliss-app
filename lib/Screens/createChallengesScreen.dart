import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddChallengeScreen extends StatefulWidget {
  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  int goal = 1;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load the user ID from shared preferences
  }

  // Load user ID from shared preferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
  }

  // Send data to the backend to create a challenge
  Future<void> _createChallenge() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://your-api-url/challenges');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'title': title,
          'description': description,
          'goal': goal,
          'start_date': DateTime.now().toString(),
          'end_date': DateTime.now().add(Duration(days: 30)).toString(), // Assuming a 30-day challenge
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // Pop the screen after challenge is created
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Challenge created successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create challenge'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Challenge'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Goal (Number of books)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    goal = int.tryParse(value) ?? 1;
                  });
                },
                validator: (value) {
                  if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid goal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createChallenge,
                child: Text('Create Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

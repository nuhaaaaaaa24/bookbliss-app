import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _sendPasswordResetLink() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
        _successMessage = '';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://172.20.10.4:8000/api/password/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _successMessage = data['message'];
        _errorMessage = '';
      });
    } else {
      final data = json.decode(response.body);
      setState(() {
        _errorMessage = data['message'];
        _successMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F2E9), // Off-white background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Center(
              child: Text(
                'Forgot Password',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40.0),
            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                hintStyle: TextStyle(color: Colors.black38),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Error message
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            // Success message
            if (_successMessage.isNotEmpty)
              Text(
                _successMessage,
                style: TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 100.0),
            // Send Reset Link button
            ElevatedButton(
              onPressed: _sendPasswordResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2B1700), // Green color for the button
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Send Reset Link',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookbliss_final/Screens/HomeScreen.dart';
import 'package:bookbliss_final/Screens/RegistrationScreen.dart';
import 'package:bookbliss_final/Screens/ForgotPasswordScree.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.4:8000/api/user-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('token_expiry', DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(
        )),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid email or password';
      });
    }
  }

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 100.0),
            Center(
              child: Column(
                children: [
                  Text(
                    'Book Bliss',
                    style: TextStyle(
                      fontFamily: 'Cursive',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headline1?.color,
                    ),
                  ),
                  Text(
                    'A world of books',
                    style: TextStyle(
                      fontFamily: 'Sans-serif',
                      fontSize: 18,
                      color: Theme.of(context).textTheme.subtitle1?.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100.0),
            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black38),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                filled: true,
                fillColor: isDarkMode ? Colors.black12 : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black, width: 2.0),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.0),
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black38),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                filled: true,
                fillColor: isDarkMode ? Colors.black12 : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black, width: 2.0),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 20.0),
            // Error message
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 80.0),
            // Login button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6A1B9A), // Purple button color
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Log in',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20.0),
            // Forgot Password link
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF6A1B9A)),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

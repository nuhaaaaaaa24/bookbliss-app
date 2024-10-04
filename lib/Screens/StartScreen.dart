import 'package:flutter/material.dart';
import 'package:bookbliss_final/Screens/RegistrationScreen.dart';
import 'package:bookbliss_final/Screens/loginScreen.dart';

class StartScreen extends StatefulWidget {
  final VoidCallback toggleTheme; // Accept the toggleTheme function

  StartScreen({required this.toggleTheme}); // Constructor to receive the function

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    Color buttonColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).textTheme.bodyText2?.color ?? Colors.black;
    Color subtitleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.black;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Book Bliss',
                          style: TextStyle(
                            fontFamily: 'Cursive',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Where Book Lovers Belong',
                          style: TextStyle(
                            fontSize: 26,
                            fontFamily: 'Cursive',
                            color: subtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return RegistrationScreen();
                      }));
                    },
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return LoginScreen();
                          }));
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            color: buttonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: textColor,
                ),
                onPressed: widget.toggleTheme, // Use the widget property to access toggleTheme
              ),
            ),
          ],
        ),
      ),
    );
  }
}

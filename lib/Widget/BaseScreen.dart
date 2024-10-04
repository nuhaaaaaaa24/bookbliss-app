import 'package:flutter/material.dart';
import 'package:bookbliss_final/Widget/CustomBottomNavigationBar.dart';

class BaseScreen extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final Widget child;

  BaseScreen({required this.currentIndex, required this.onItemTapped, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}

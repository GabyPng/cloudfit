import 'package:flutter/material.dart';
import '../core/constants.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightPurple,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.assignment, color: Colors.white70),
          Icon(Icons.star, color: Colors.white70),
          Icon(Icons.person, color: Colors.white70),
        ],
      ),
    );
  }
}
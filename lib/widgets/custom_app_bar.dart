import 'package:flutter/material.dart';

//custom app bar widget that looks like minimal top navigation bar
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //add padding inside the bar
      padding:  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      //styling the background and bottom border


      decoration: const BoxDecoration(
        color: Colors.white, //white background
        border: Border(
        bottom: BorderSide(
          color: Color(0xFFEEEEEE),
        ),
        ),
        ),


      child: Row(


        // Spread items: first on the left, last on the right, text in the middle
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [


        // Left: a menu (hamburger) icon
        const Icon(
        Icons.menu,
        size: 24,
        color: Colors.black87,
      ),


      // Center: the title text of the app
      const Text(
        'Minimal Social',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600, // semi-bold
          color: Colors.black87,
        ),
      ),

    // Right: a small circular profile placeholder
    Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
    color: Colors.grey[300], // light gray background
    borderRadius: BorderRadius.circular(16), // make it circular
    ),
    child: const Icon(
    Icons.person, // user avatar icon
    size: 16,
    color: Colors.black54, // slightly faded black
          ),
        ),
      ],
     ),
    );
  }
}

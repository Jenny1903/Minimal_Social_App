import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/Pages/user_profile_page.dart';

class ClickableUsername extends StatelessWidget {
  final String username;
  final TextStyle? style;
  final bool showAtSymbol;

  const ClickableUsername({
    super.key,
    required this.username,
    this.style,
    this.showAtSymbol = true,
  });

  Future<String?> _findUserIdByUsername(String username) async {
    try {
      print('Searching for username: $username');

      //find user where username field equals our username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      //check if we found a user
      if (querySnapshot.docs.isEmpty) {
        print('User not found: $username');
        return null;
      }

      //get the user ID from the document
      final userId = querySnapshot.docs.first.id;
      print('Found user ID: $userId for username: $username');

      return userId;
    } catch (e) {
      print('Error finding user: $e');
      return null;
    }
  }

  //function ~ handle username taps
  Future<void> _onUsernameTap(BuildContext context) async {
    print('👆 Username tapped: $username');

    //show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      //find the user ID
      final userId = await _findUserIdByUsername(username);

      //close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // If user found, navigate to their profile
      if (userId != null && context.mounted) {
        print('Navigating to profile for user: $username');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: userId),
          ),
        );
      } else if (context.mounted) {
        //user not found - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User @$username not found'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      //close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      //show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //when tapped, call _onUsernameTap
      onTap: () => _onUsernameTap(context),

      //make the text look clickable
      child: Text(
        showAtSymbol ? '@$username' : username,
        style:
            style ??
            TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              //underline to show it's clickable
            ),
      ),
    );
  }
}

Future<String?> _findUserIdByUsername(String username) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.id;
  } catch (e) {
    return null;
  }
}

//appearance
class ClickableUsernameStyled extends StatelessWidget {
  final String username;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final bool showUnderline;

  const ClickableUsernameStyled({
    super.key,
    required this.username,
    this.fontSize = 14,
    this.color,
    this.fontWeight = FontWeight.bold,
    this.showUnderline = false,
  });

  Future<void> _onUsernameTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final userId = await _findUserIdByUsername(username);

    if (context.mounted) Navigator.pop(context);

    if (userId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(userId: userId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onUsernameTap(context),
      child: Text(
        '@$username',
        style: TextStyle(
          fontSize: fontSize,
          color: color ?? Theme.of(context).colorScheme.secondary,
          fontWeight: fontWeight,
          decoration: showUnderline ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

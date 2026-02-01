import 'package:flutter/material.dart';

class whoLikedSheet extends StatelessWidget {
  final List<String> likes;

  const whoLikedSheet({
    super.key,
  required this.likes,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }
}

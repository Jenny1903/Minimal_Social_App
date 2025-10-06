import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
      child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.search, 'Search'),
                _buildNavItem(2, Icons.add, 'Create'),
                _buildNavItem(3, Icons.notifications, 'Alerts'),
                _buildNavItem(4, Icons.person, 'Profile'),

              ],
            ),
          ),
        ),
      );
  }

  Widget _buildNavItem(int index, IconData icon, String label){
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.grey[600],
            ),
          ),
        ],
      ),
    );

  }
}

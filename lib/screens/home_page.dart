import 'package:flutter/material.dart';
import 'package:social_app/widgets/custom_app_bar.dart';
import 'package:social_app/widgets/profile_section.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/feed_section.dart';
import 'package:social_app/data/sample_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(),
              ProfileSection(user: SampleData.currentUser),
              Expanded(
                  child: FeedSection(posts: SampleData.posts),
              )
            ],
          ),
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index ),
      ),
    );
  }
}

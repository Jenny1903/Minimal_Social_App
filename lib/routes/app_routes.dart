import 'package:flutter/material.dart';
import 'package:social_app/pages/home_page.dart';
import 'package:social_app/pages/user_profile_page.dart';
import 'package:social_app/pages/edit_profile_page.dart';
import 'package:social_app/pages/settings_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      editProfile: (context) => const EditProfilePage(),
      settings: (context) => const SettingsPage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case profile:
        final userId = settings.arguments as String?;
        if (userId == null) return null;
        return MaterialPageRoute(
          builder: (context) => UserProfilePage(userId: userId),
        );
      default:
        return null;
    }
  }
}


import 'package:flutter/material.dart';
import 'package:social_app/Pages/edit_profile_page.dart';
import 'package:social_app/Pages/settings_page.dart';
import 'package:social_app/Pages/user_profile_page.dart';

class AppRoutes {
  // Route names
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String userProfile = '/user-profile';

  // Get routes (without '/' home route to avoid conflict)
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      editProfile: (context) => const EditProfilePage(),
      settings: (context) => const SettingsPage(),
      // Note: userProfile uses onGenerateRoute instead
    };
  }

  // Dynamic route generation for routes with parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case userProfile:
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
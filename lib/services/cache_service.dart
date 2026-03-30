import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CacheService {
  static const String _userDataPrefix = 'user_';
  static const String _postPrefix = 'post_';
  static const String _feedPrefix = 'feed_';

  //Cache duration in hours
  static const int _cacheDuration = 24;

  //save user data to cache
  //this stores user profile info locally
  Future<void> cacheUserData(String userId, Map<String, dynamic> data) async {
    try {
      print('Caching user data for: $userId');

      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
        '$_userDataPrefix$userId',
        jsonEncode(cacheData),
      );

      print('User data cached');
    } catch (e) {
      print('Error caching user data: $e');
    }
  }

}

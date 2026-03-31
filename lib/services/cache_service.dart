import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _userDataPrefix = 'user_';
  static const String _postPrefix = 'post_';
  static const String _feedPrefix = 'feed_';

  //Cache duration in hours
  static const int _cacheDuration = 24;

  //Save user data to cache
  //This stores user profile info locally
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

  //Get user data from cache
  //Returns cached data if valid, null if expired or not found
  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    try {
      print('Checking cache for user: $userId');

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_userDataPrefix$userId');

      if (cached == null) {
        print('No cached data found');
        return null;
      }

      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(cacheData['cachedAt'] as String);
      final age = DateTime.now().difference(cachedAt);

      //Check if cache is still valid
      if (age.inHours > _cacheDuration) {
        print('Cache expired (${age.inHours} hours old)');
        await clearUserCache(userId);
        return null;
      }

      print('Cache hit (${age.inHours} hours old)');
      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      print('Error reading cache: $e');
      return null;
    }
  }

  //Cache post data
  Future<void> cachePost(String postId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
        '$_postPrefix$postId',
        jsonEncode(cacheData),
      );
    } catch (e) {
      print('Error caching post: $e');
    }
  }

  //Get cached post
  Future<Map<String, dynamic>?> getCachedPost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_postPrefix$postId');

      if (cached == null) return null;

      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(cacheData['cachedAt'] as String);
      final age = DateTime.now().difference(cachedAt);

      if (age.inHours > _cacheDuration) {
        await clearPostCache(postId);
        return null;
      }

      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      print('Error reading post cache: $e');
      return null;
    }
  }

  //Cache feed (list of post IDs)
  //This stores which posts to show in the feed
  Future<void> cacheFeed(List<String> postIds) async {
    try {
      print('Caching feed (${postIds.length} posts)');

      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'postIds': postIds,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
        _feedPrefix,
        jsonEncode(cacheData),
      );

      print('Feed cached');
    } catch (e) {
      print('Error caching feed: $e');
    }
  }

  //Get cached feed
  Future<List<String>?> getCachedFeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_feedPrefix);

      if (cached == null) {
        print('No cached feed');
        return null;
      }

      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(cacheData['cachedAt'] as String);
      final age = DateTime.now().difference(cachedAt);

      // Feed cache expires faster (1 hour)
      if (age.inHours > 1) {
        print('Feed cache expired');
        await clearFeedCache();
        return null;
      }

      print('Feed cache hit');
      return List<String>.from(cacheData['postIds']);
    } catch (e) {
      print('Error reading feed cache: $e');
      return null;
    }
  }

  //Clear specific user cache
  Future<void> clearUserCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_userDataPrefix$userId');
      print('Cleared cache for user: $userId');
    } catch (e) {
      print('Error clearing user cache: $e');
    }
  }

  //Clear specific post cache
  Future<void> clearPostCache(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_postPrefix$postId');
    } catch (e) {
      print('Error clearing post cache: $e');
    }
  }

  //Clear feed cache
  Future<void> clearFeedCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_feedPrefix);
      print('Feed cache cleared');
    } catch (e) {
      print('Error clearing feed cache: $e');
    }
  }

  //Clear all cache
  Future<void> clearAllCache() async {
    try {
      print('🗑Clearing all cache...');
      final prefs = await SharedPreferences.getInstance();

      //Get all keys
      final keys = prefs.getKeys();

      //Remove all cache keys
      for (final key in keys) {
        if (key.startsWith(_userDataPrefix) ||
            key.startsWith(_postPrefix) ||
            key.startsWith(_feedPrefix)) {
          await prefs.remove(key);
        }
      }

      print('All cache cleared');
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  //Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int userCacheCount = 0;
      int postCacheCount = 0;
      int feedCacheCount = 0;

      for (final key in keys) {
        if (key.startsWith(_userDataPrefix)) userCacheCount++;
        if (key.startsWith(_postPrefix)) postCacheCount++;
        if (key.startsWith(_feedPrefix)) feedCacheCount++;
      }

      return {
        'users': userCacheCount,
        'posts': postCacheCount,
        'feeds': feedCacheCount,
        'total': userCacheCount + postCacheCount + feedCacheCount,
      };
    } catch (e) {
      return {
        'users': 0,
        'posts': 0,
        'feeds': 0,
        'total': 0,
      };
    }
  }
}

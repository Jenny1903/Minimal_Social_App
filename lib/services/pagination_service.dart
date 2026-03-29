import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaginationService {
  final FirebaseFirestore _firestore;
  final int pageSize;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PaginationService({
    FirebaseFirestore? firestore,
    this.pageSize = 10,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  //Check if there are more posts to load
  bool get hasMore => _hasMore;

  //Check if currently loading
  bool get isLoading => _isLoading;

  //Load first page of posts
  // Returns: List of post documents
  Future<List<DocumentSnapshot>> loadFirstPage() async {
    print('Loading first page (${pageSize} posts)');

    _isLoading = true;
    _lastDocument = null;
    _hasMore = true;

    try {
      final snapshot = await _firestore
          .collection('Posts')
          .orderBy('TimeStamp', descending: true)
          .limit(pageSize)
          .get();

      final docs = snapshot.docs;

      if (docs.isEmpty) {
        _hasMore = false;
        print('No posts found');
      } else {
        _lastDocument = docs.last;
        _hasMore = docs.length == pageSize;
        print('Loaded ${docs.length} posts');
      }

      _isLoading = false;
      return docs;
    } catch (e) {
      print('Error loading first page: $e');
      _isLoading = false;
      return [];
    }
  }

  // Load next page of posts
  // Call this when user scrolls to bottom
  Future<List<DocumentSnapshot>> loadNextPage() async {
    if (!_hasMore || _isLoading || _lastDocument == null) {
      print('⚠Cannot load more (hasMore: $_hasMore, isLoading: $_isLoading)');
      return [];
    }

    print('Loading next page...');
    _isLoading = true;

    try {
      final snapshot = await _firestore
          .collection('Posts')
          .orderBy('TimeStamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(pageSize)
          .get();

      final docs = snapshot.docs;

      if (docs.isEmpty) {
        _hasMore = false;
        print('No more posts');
      } else {
        _lastDocument = docs.last;
        _hasMore = docs.length == pageSize;
        print('Loaded ${docs.length} more posts');
      }

      _isLoading = false;
      return docs;
    } catch (e) {
      print('Error loading next page: $e');
      _isLoading = false;
      return [];
    }
  }

  //Reset pagination
  //Call this when refreshing the feed
  void reset() {
    print('Resetting pagination');
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
  }

  //Load user's posts with pagination
  Future<List<DocumentSnapshot>> loadUserPosts(
      String userId, {
        bool isFirstPage = true,
      }) async {
    if (!isFirstPage && (!_hasMore || _isLoading)) {
      return [];
    }

    _isLoading = true;

    try {
      Query query = _firestore
          .collection('Posts')
          .where('userId', isEqualTo: userId)
          .orderBy('TimeStamp', descending: true);

      if (!isFirstPage && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.limit(pageSize).get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = docs.last;
        _hasMore = docs.length == pageSize;
      }

      _isLoading = false;
      return docs;
    } catch (e) {
      print('Error loading user posts: $e');
      _isLoading = false;
      return [];
    }
  }
}

//SCROLL CONTROLLER HELPER
// Detects when user scrolls to bottom
class PaginationScrollController extends ScrollController {
  final VoidCallback onLoadMore;
  final double threshold;
  // Load more when this close to bottom (0.0-1.0)

  PaginationScrollController({
    required this.onLoadMore,
    this.threshold = 0.8, // Load when 80% scrolled
  }) {
    addListener(_scrollListener);
  }

  void _scrollListener() {
    if (position.pixels >= position.maxScrollExtent * threshold) {
      print('Scroll threshold reached, loading more...');
      onLoadMore();
    }
  }

  @override
  void dispose() {
    removeListener(_scrollListener);
    super.dispose();
  }
}

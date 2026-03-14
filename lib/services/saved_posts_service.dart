import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';

class SavedPostsService {
  final FirebaseFirestore _firestore;
  final String? _userId;

  SavedPostsService(this._firestore, this._userId);

  //save a post
  Future<void> savePost(String postId) async {
    if (_userId == null) {
      throw Exception('Must be logged in to save posts');
    }

    try {
      await _firestore
          .collection('Users')
          .doc(_userId)
          .collection('SavedPosts')
          .doc(postId)
          .set({
        'postId': postId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving post: $e');
      rethrow;
    }
  }

  //unsave a post
  Future<void> unsavePost(String postId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('Users')
          .doc(_userId)
          .collection('SavedPosts')
          .doc(postId)
          .delete();
    } catch (e) {
      print('Error unsaving post: $e');
    }
  }

  //check if post is saved
  Stream<bool> isPostSaved(String postId) {
    if (_userId == null) return Stream.value(false);

    return _firestore
        .collection('Users')
        .doc(_userId)
        .collection('SavedPosts')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  //get saved posts
  Stream<List<String>> getSavedPostIds() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('Users')
        .doc(_userId)
        .collection('SavedPosts')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  //get saved posts with full data
  Stream<QuerySnapshot> getSavedPostsStream() async* {
    if (_userId == null) {
      yield* Stream.value(
        await _firestore.collection('Posts').limit(0).get(),
      );
      return;
    }

    await for (var savedSnapshot in _firestore
        .collection('Users')
        .doc(_userId)
        .collection('SavedPosts')
        .orderBy('savedAt', descending: true)
        .snapshots()) {

      if (savedSnapshot.docs.isEmpty) {
        yield await _firestore.collection('Posts').limit(0).get();
        continue;
      }

      final postIds = savedSnapshot.docs.map((doc) => doc.id).toList();

      //fetch actual posts
      final posts = await _firestore
          .collection('Posts')
          .where(FieldPath.documentId, whereIn: postIds)
          .get();

      yield posts;
    }
  }
}

//provider
final savedPostsServiceProvider = Provider<SavedPostsService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authState = ref.watch(authStateProvider);

  String? userId;
  authState.whenData((user) {
    userId = user?.uid;
  });

  return SavedPostsService(firestore, userId);
});

//check if specific post is saved
final isPostSavedProvider = StreamProvider.family<bool, String>((ref, postId) {
  final service = ref.watch(savedPostsServiceProvider);
  return service.isPostSaved(postId);
});

//stream of saved posts
final savedPostsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final service = ref.watch(savedPostsServiceProvider);
  return service.getSavedPostsStream();
});
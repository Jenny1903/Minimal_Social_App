import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';

class CommentsService {
  final FirebaseFirestore _firestore;
  final String? _userId;
  final String? _username;

  CommentsService(this._firestore, this._userId, this._username);

  //add comment
  Future<void> addComment(String postId, String text) async {
    print('addComment called - postId: $postId, text: $text');
    print('userId: $_userId, username: $_username');

    if (_userId == null) {
      print('Error: User not logged in');
      throw Exception('Must be logged in to comment');
    }

    if (text.trim().isEmpty) {
      print('Error: Comment text is empty');
      throw Exception('Comment cannot be empty');
    }

    try {
      print('Adding comment to Firestore...');

      //add comment to subcollection
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .add({
        'userId': _userId,
        'username': _username ?? 'Anonymous',
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Comment added to subcollection');

      //increment comment count on post
      await _firestore.collection('Posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      print('Comment count incremented');
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  //delete comment
  Future<void> deleteComment(String postId, String commentId) async {
    if (_userId == null) {
      throw Exception('Must be logged in to delete');
    }

    try {
      //delete comment
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .doc(commentId)
          .delete();

      //decrement comment count
      await _firestore.collection('Posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  //get comments stream
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .orderBy('timestamp', descending: false) // Oldest first
        .snapshots();
  }

  //get comments (non-stream version for compatibility)
  Stream<QuerySnapshot> getComments(String postId) {
    return getCommentsStream(postId);
  }
}

//providers
final commentsServiceProvider = Provider<CommentsService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authState = ref.watch(authStateProvider);

  String? userId;
  String? username;

  authState.whenData((user) {
    userId = user?.uid;
    print('CommentsService - userId: $userId');
  });

  final userDataState = ref.watch(currentUserDataProvider);
  if (userDataState.hasValue && userDataState.value != null) {
    final userData = userDataState.value!.data() as Map<String, dynamic>?;
    username = userData?['username'];
    print('CommentsService - username: $username');
  }

  return CommentsService(firestore, userId, username);
});

//stream of comments for a specific post
final commentsStreamProvider = StreamProvider.family<QuerySnapshot, String>((ref, postId) {
  final commentsService = ref.watch(commentsServiceProvider);
  return commentsService.getCommentsStream(postId);
});
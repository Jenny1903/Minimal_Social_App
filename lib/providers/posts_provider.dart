import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';

class PostsService {
  final FirebaseFirestore _firestore;
  final String? _userId;
  final String? _username;

  PostsService(this._firestore, this._userId, this._username);

  //add post
  Future<void> addPost(String message, {List<String>? imageUrls}) async {
    if (_userId == null) {
      throw Exception('Must be logged in to post');
    }

    if (message.trim().isEmpty && (imageUrls == null || imageUrls.isEmpty)) {
      throw Exception('Post cannot be empty');
    }

    final postData = {
      'userId': _userId,
      'username': _username ?? 'Anonymous',
      'PostMessage': message.trim(),
      'TimeStamp': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'commentCount': 0,
    };

    if (imageUrls != null && imageUrls.isNotEmpty) {
      postData['images'] = imageUrls;
    }

    await _firestore.collection('Posts').add(postData);
  }

  //delete post
  Future<void> deletePost(String postId) async {
    if (_userId == null) {
      throw Exception('Must be logged in to delete');
    }

    try {
      final postRef = _firestore.collection('Posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final postData = postDoc.data() as Map<String, dynamic>;

      //check if user owns the post
      if (postData['userId'] != _userId) {
        throw Exception('You can only delete your own posts');
      }

      //delete likes subcollection
      final likesSnapshot = await postRef.collection('Likes').get();
      for (var like in likesSnapshot.docs) {
        await like.reference.delete();
      }

      //delete comments subcollection
      final commentsSnapshot = await postRef.collection('Comments').get();
      for (var comment in commentsSnapshot.docs) {
        await comment.reference.delete();
      }

      //delete the post
      await postRef.delete();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  //update post
  Future<void> updatePost(String postId, String newMessage) async {
    if (_userId == null) {
      throw Exception('Must be logged in to update');
    }

    if (newMessage.trim().isEmpty) {
      throw Exception('Post message cannot be empty');
    }

    final postRef = _firestore.collection('Posts').doc(postId);
    final postDoc = await postRef.get();

    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final postData = postDoc.data() as Map<String, dynamic>;

    //check if user owns the post
    if (postData['userId'] != _userId) {
      throw Exception('You can only edit your own posts');
    }

    await postRef.update({
      'PostMessage': newMessage.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  //get posts stream (all posts)
  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('Posts')
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  //get user's posts stream
  Stream<QuerySnapshot> getUserPostsStream(String userId) {
    return _firestore
        .collection('Posts')
        .where('userId', isEqualTo: userId)
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  //get single post
  Future<DocumentSnapshot> getPost(String postId) {
    return _firestore.collection('Posts').doc(postId).get();
  }
}

//provider
final postsServiceProvider = Provider<PostsService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authState = ref.watch(authStateProvider);

  String? userId;
  String? username;

  authState.whenData((user) {
    userId = user?.uid;
  });

  final userDataState = ref.watch(currentUserDataProvider);
  if (userDataState.hasValue && userDataState.value != null) {
    final userData = userDataState.value!.data() as Map<String, dynamic>?;
    username = userData?['username'];
  }

  return PostsService(firestore, userId, username);
});

//stream provider for all posts
final postsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final postsService = ref.watch(postsServiceProvider);
  return postsService.getPostsStream();
});

//stream provider for user posts
final userPostsStreamProvider = StreamProvider.family<QuerySnapshot, String>((ref, userId) {
  final postsService = ref.watch(postsServiceProvider);
  return postsService.getUserPostsStream(userId);
});
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';


final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});


class PostsService {
  final FirebaseFirestore _firestore;
  final String? _userEmail;

  //constructor receives Firestore and current user email
  PostsService(this._firestore, this._userEmail);

  //get reference to Posts collection
  CollectionReference get _postsCollection => _firestore.collection('Posts');

  //add a post
  Future<void> addPost(String message) async {
    if (_userEmail == null) {
      throw Exception('User must be logged in to post');
    }

    await _postsCollection.add({
      'UserEmail': _userEmail,
      'PostMessage': message,
      'TimeStamp': Timestamp.now(),
      'Likes': [],
    });
  }

  //get post stream
  Stream<QuerySnapshot> getPostsStream() {
    return _postsCollection
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  //delete a post
  Future<void> deletePost(String postId) async {
    return _postsCollection.doc(postId).delete();
  }

  //update a post
  Future<void> updatePost(String postId, String newMessage) async {
    return _postsCollection.doc(postId).update({
      'PostMessage': newMessage,
      'TimeStamp': Timestamp.now(),
    });
  }

  //========== TOGGLE LIKE ON A POST ==========
  Future<void> toggleLike(String postId) async {
    if (_userEmail == null){
      throw Exception('User must be logged in to like posts');
    }
    final postDoc = _postsCollection.doc(postId);
    final postSnapshot = await postDoc.get();

    if (!postSnapshot.exists) {
      throw Exception('Post not found');
    }

    final postData = postSnapshot.data() as Map<String, dynamic>?;

    List<String> likes = [];
    if (postData != null && postData.containsKey('Likes')) {
      likes = List<String>.from(postData['Likes']);
    }
    

    //check if user already liked this post
    if (likes.contains(_userEmail)) {

      //unlike: Remove user from likes array
      likes.remove(_userEmail);
    } else {

      //like: Add user to likes array
      likes.add(_userEmail!);
    }

    //update the post with new likes array
    return postDoc.update({
      'Likes': likes,
    });
  }

  //check if user liked a post
  bool hasUserLiked(List<dynamic> likes) {
    if (_userEmail == null) return false;
    return likes.contains(_userEmail);
  }
}


final postsServiceProvider = Provider<PostsService>((ref) {
  //watch the Firestore instance
  final firestore = ref.watch(firestoreProvider);

  //watch the auth STATE to get current user email
  //this way it updates automatically when user logs in/out
  final authState = ref.watch(authStateProvider);

  //get email from auth state (will be null if not logged in)
  final userEmail = authState.value?.email;

  //create and return PostsService
  return PostsService(firestore, userEmail);
});



final postsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  //get the PostsService
  final postsService = ref.watch(postsServiceProvider);

  // Return the stream of posts
  return postsService.getPostsStream();
});


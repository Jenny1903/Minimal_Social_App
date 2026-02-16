import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';

//firestore provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

//posts service ~ Professional Structure

class PostsService {
  final FirebaseFirestore _firestore;
  final String? _userId;
  final String? _userEmail;
  final String? _username;

  PostsService(this._firestore, this._userId, this._userEmail, this._username);

  //make userId accessible for providers
  String? get userId => _userId;

  CollectionReference get _postsCollection => _firestore.collection('Posts');

  //add a post
  Future<void> addPost(String message, {List<String>? imageUrls}) async {
    if (_userId == null) {
      throw Exception('User must be logged in to post');
    }

    await _postsCollection.add({
      'userId': _userId,
      'userEmail': _userEmail,
      'username': _username ?? 'Anonymous',
      'PostMessage': message,
      'TimeStamp': Timestamp.now(),
      'likeCount': 0,
    });
  }

  //get posts stream
  Stream<QuerySnapshot> getPostsStream() {
    return _postsCollection
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  //toggle like
  Future<void> toggleLike(String postId) async {
    if (_userId == null) {
      throw Exception('User must be logged in to like posts');
    }

    final postDoc = _postsCollection.doc(postId);
    final likeDoc = postDoc.collection('Likes').doc(_userId);

    //check if user already liked
    final likeSnapshot = await likeDoc.get();

    if (likeSnapshot.exists) {
      //UNLIKE: Remove like document
      await likeDoc.delete();

      //decrement like count
      await postDoc.update({
        'likeCount': FieldValue.increment(-1),
      });

    } else {
      //LIKE: Create like document
      await likeDoc.set({
        'userId': _userId,
        'userEmail': _userEmail,
        'username': _username ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });

      //increment like count
      await postDoc.update({
        'likeCount': FieldValue.increment(1),
      });
    }
  }

  //check if user liked a post
  Future<bool> hasUserLiked(String postId) async {
    if (_userId == null) return false;

    final likeDoc = await _postsCollection
        .doc(postId)
        .collection('Likes')
        .doc(_userId)
        .get();

    return likeDoc.exists;
  }

  //getting- who liked the post
  Stream<QuerySnapshot> getPostLikes(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('Likes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //delete post
  Future<void> deletePost(String postId) async {
    // Delete all likes first
    final likesSnapshot = await _postsCollection
        .doc(postId)
        .collection('Likes')
        .get();

    for (var doc in likesSnapshot.docs) {
      await doc.reference.delete();
    }

    //delete the post
    await _postsCollection.doc(postId).delete();
  }
}

//posts service provider
final postsServiceProvider = Provider<PostsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  //get user data (with username)
  final userDataState = ref.watch(currentUserDataProvider);
  final userData = userDataState.value?.data() as Map<String, dynamic>?;

  return PostsService(
    firestore,
    user?.uid,
    user?.email,
    userData?['username'],
  );
});

//posts stream provider
final postsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final postsService = ref.watch(postsServiceProvider);
  return postsService.getPostsStream();
});

//individual post like provider
final postLikesProvider = StreamProvider.family<QuerySnapshot, String>((ref, postId) {
  final postsService = ref.watch(postsServiceProvider);
  return postsService.getPostLikes(postId);
});

//check if user liked provider
final hasUserLikedProvider = StreamProvider.family<bool, String>((ref, postId) async* {
  final postsService = ref.watch(postsServiceProvider);
  final userId = postsService.userId;

  if (userId == null) {
    yield false;
    return;
  }

  //stream the like document - updates in real-time!
  await for (var snapshot in FirebaseFirestore.instance
      .collection('Posts')
      .doc(postId)
      .collection('Likes')
      .doc(userId)
      .snapshots()) {
    yield snapshot.exists;
  }
});
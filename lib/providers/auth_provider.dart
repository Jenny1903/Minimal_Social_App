import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // 👈 ADD THIS
import 'package:flutter_riverpod/flutter_riverpod.dart';


//create a Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

//stream the current user's authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  //get the FirebaseAuth instance from our provider above
  final auth = ref.watch(firebaseAuthProvider);

  //return a stream that emits whenever auth state changes
  return auth.authStateChanges();
});


//create the Auth Service (Business Logic)


class AuthService {
  final FirebaseAuth _auth;

  //constructor receives FirebaseAuth instance
  AuthService(this._auth);

  //get current user
  User? get currentUser => _auth.currentUser;

  //sign in
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      //handle specific errors
      throw _handleAuthException(e);
    }
  }

  //sign up
  Future<void> signUp(String email, String password, String username) async {
    try {
      //create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //create user document in Firestore with username
      await _createUserDocument(userCredential, username);

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  //create user document
  Future<void> _createUserDocument(UserCredential userCredential, String username) async {
    if (userCredential.user != null) {
      print('   Creating user document:');
      print('   UID: ${userCredential.user!.uid}');
      print('   Email: ${userCredential.user!.email}');
      print('   Username: $username');

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'username': username,
        'bio': '',
        'profilePicture': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print(' User document created successfully');
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //error handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}


//automatically gets the FirebaseAuth instance we defined earlier

final authServiceProvider = Provider<AuthService>((ref) {
  //watch the firebaseAuthProvider to get FirebaseAuth instance
  final auth = ref.watch(firebaseAuthProvider);

  //create and return AuthService with that instance
  return AuthService(auth);
});


//user's Firestore document which has username

final currentUserDataProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }

      //stream the user's document from Firestore
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots();
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});


//simple provider to get just the username
final currentUsernameProvider = Provider<String?>((ref) {
  final userDataState = ref.watch(currentUserDataProvider);

  if (userDataState.hasValue && userDataState.value != null) {
    final userData = userDataState.value!.data() as Map<String, dynamic>?;
    return userData?['username'];
  }

  return null;
});


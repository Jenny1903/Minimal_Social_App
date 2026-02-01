import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});


final authStateProvider = StreamProvider<User?>((ref) {
  //get the FirebaseAuth instance from our provider above
  final auth = ref.watch(firebaseAuthProvider);

  //return a stream that emits whenever auth state changes
  return auth.authStateChanges();
});



class AuthService {
  final FirebaseAuth _auth;

  //constructor receives FirebaseAuth instance
  AuthService(this._auth);

  //get current user
  User? get currentUser => _auth.currentUser;

  //========== SIGN IN ==========
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      throw _handleAuthException(e);
    }
  }

  //SIGN UP
  Future<void> signUp(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //create user document in firestore with username
      await _createUserDocument(userCredential, username);

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  //CREATE USER DOCUMENT
  Future<void> _createUserDocument(UserCredential userCredential, String username) async{
    if (userCredential.user != null){
      await FirebaseFirestore.instance
          .collection('User')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'username': username,
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  //SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //ERROR HANDLING
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

//provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {

  final auth = ref.watch(firebaseAuthProvider);

  return AuthService(auth);
});

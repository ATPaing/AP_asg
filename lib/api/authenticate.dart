import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSignIn {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<Object?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential; // Sign in successful
    } on FirebaseAuthException catch (e) {
      return e.message; // Return an error message
    }
  }
}

class FirebaseLogout {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
library auth;

import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  // Auth(
  //   FirebaseAuth? firebaseAuth,
  // ) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // final FirebaseAuth _firebaseAuth;

  static Future<void> signIn(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}

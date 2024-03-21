import 'package:firebase_auth/firebase_auth.dart';

class AnonAuthProvider {

  Future<void> logIn() async {
    await FirebaseAuth.instance.signInAnonymously();
  }
}
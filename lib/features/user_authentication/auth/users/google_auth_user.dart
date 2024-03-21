import 'package:firebase_auth/firebase_auth.dart';

import '../utils/name_helper.dart';
import 'app_user.dart';

class GoogleAuthUser extends AppUser {
  String? email;
  String firstName;
  String? lastName;

  GoogleAuthUser(
      {required super.id,
      required this.email,
      required this.firstName,
      required this.lastName});

  factory GoogleAuthUser.fromFirebase(User firebaseUser) {
    return GoogleAuthUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      firstName: extractFirstName(firebaseUser.displayName!),
      lastName: extractLastName(firebaseUser.displayName!),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';

import '../utils/name_helper.dart';
import 'app_user.dart';

class EmailAuthUser extends AppUser {
  String firstName;
  String? lastName;
  String? email;
  bool isVerified;

  EmailAuthUser(
      {required super.id,
      required this.email,
      required this.isVerified,
      required this.firstName,
      required this.lastName});

  factory EmailAuthUser.fromFirebase(User firebaseUser) {
    return EmailAuthUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      isVerified: firebaseUser.emailVerified,
      firstName: extractFirstName(firebaseUser.displayName!),
      lastName: extractLastName(firebaseUser.displayName!),
    );
  }
}

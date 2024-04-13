import 'package:firebase_auth/firebase_auth.dart';

import '../../../../utils/helper/name_helper.dart';
import 'app_user.dart';

class GoogleAuthUser extends AppUser {
  GoogleAuthUser(
      {required super.id,
      required super.email,
      required super.firstName,
      required super.lastName});

  factory GoogleAuthUser.fromFirebase(User firebaseUser) {
    return GoogleAuthUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      firstName: extractFirstName(firebaseUser.displayName!),
      lastName: extractLastName(firebaseUser.displayName!),
    );
  }
}

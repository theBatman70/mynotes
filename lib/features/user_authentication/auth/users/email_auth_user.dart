import 'package:firebase_auth/firebase_auth.dart';

import '../../../../utils/helper/name_helper.dart';
import 'app_user.dart';

class EmailAuthUser extends AppUser {
  bool isVerified;

  EmailAuthUser(
      {required super.id,
      required super.firstName,
      required super.lastName,
      required super.email,
      required this.isVerified});

  factory EmailAuthUser.fromFirebase(User user) {
    return EmailAuthUser(
      id: user.uid,
      isVerified: user.emailVerified,
      email: user.email,
      firstName: extractFirstName(user.displayName!),
      lastName: extractLastName(user.displayName!),
    );
  }
}

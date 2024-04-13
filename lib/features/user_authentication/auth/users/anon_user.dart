import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';

class AnonUser extends AppUser {
  AnonUser({super.firstName, super.lastName, required super.id});

  factory AnonUser.fromFirebase(User user) => AnonUser(id: user.uid);
}

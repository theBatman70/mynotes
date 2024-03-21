import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';

class AnonUser extends AppUser {
  final String? firstName;
  final String? lastName;

  AnonUser({this.firstName, this.lastName, required super.id});

  factory AnonUser.fromFirebase(User user) => AnonUser(id: user.uid);
}

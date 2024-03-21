
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;

  const AppUser({required this.id});

  factory AppUser.fromFirebase(User user) =>
      AppUser(id : user.uid);
}
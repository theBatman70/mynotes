import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/cupertino.dart';
import 'package:mynotes/features/user_authentication/auth/auth_exceptions.dart';
import 'package:mynotes/features/user_authentication/auth/auth_providers/anon_auth_provider.dart';
import 'package:mynotes/features/user_authentication/auth/auth_providers/email_auth_provider.dart';
import 'package:mynotes/features/user_authentication/auth/auth_providers/google_auth_provider.dart';
import 'package:mynotes/features/user_authentication/auth/users/anon_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/email_auth_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/app_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/google_auth_user.dart';
import 'package:mynotes/firebase_options.dart';

class FirebaseAuthService {
  AppUser? _currentAppUser;

  AppUser? get currentAppUser {
    return _currentAppUser;
  }

  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    updateAppUser();
  }

  User? get currentFirebaseUser => FirebaseAuth.instance.currentUser;

  Future<AppUser?> signInWithGoogle() async {
    await GoogleSignInProvider().signInWithGoogle();
    return updateAppUser();
  }

  Future<AppUser?> logInWithEmail(
      {required String email, required String password}) async {
    await EmailAuthProvider().logInWithEmail(email: email, password: password);
    return updateAppUser();
  }

  Future<void> sendEmailVerification() async {
    await EmailAuthProvider().sendEmailVerification(currentFirebaseUser);
  }

  Future<void> createEmailUser(
      {required String email, required String password}) async {
    await EmailAuthProvider()
        .createUserWithEmail(email: email, password: password);
  }

  Future<AppUser?> logInAnonymously() async {
    await AnonAuthProvider().logIn();
    return updateAppUser();
  }

  Future<void> logOut() async {
    if (currentFirebaseUser != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInException();
    }
  }

  AppUser? updateAppUser() {
    debugPrint('reached updateApp User before process');
    debugPrint('providerData is => ${currentFirebaseUser!.providerData}');
    if (currentFirebaseUser != null) {
      final providerId = currentFirebaseUser!.providerData.isNotEmpty ? currentFirebaseUser!.providerData.first.providerId : null;
      if (providerId == null) {
        _currentAppUser = AnonUser.fromFirebase(currentFirebaseUser!);
      } else if (providerId == 'password') {
        _currentAppUser = EmailAuthUser.fromFirebase(currentFirebaseUser!);
      } else if (providerId == 'google.com') {
        _currentAppUser = GoogleAuthUser.fromFirebase(currentFirebaseUser!);
      }
      return _currentAppUser;
    }
    return null;
  }
}

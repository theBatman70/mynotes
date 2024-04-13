import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mynotes/features/user_authentication/auth/auth_exceptions.dart';
import 'package:mynotes/features/user_authentication/auth/firebase_auth_service.dart';
import 'package:mynotes/features/user_authentication/auth/users/anon_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/app_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/email_auth_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/google_auth_user.dart';
import 'package:mynotes/utils/helper/name_helper.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? emailVerificationTimer;

  AuthBloc(FirebaseAuthService service) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      await service.initialize();
      emit(const AuthStateInitialized());
      final currentAppUser = service.currentAppUser;
      if (currentAppUser != null) {
        if (currentAppUser is EmailAuthUser) {
          if (currentAppUser.isVerified) {
            return emit(EmailUserLoggedIn(currentAppUser));
          } else {
            return emit(EmailNeedsVerification(currentAppUser));
          }
        } else if (currentAppUser is GoogleAuthUser) {
          return emit(GoogleUserLoggedIn(currentAppUser));
        } else if (currentAppUser is AnonUser) {
          return emit(AnonUserLoggedIn(currentAppUser));
        }
      } else if (currentAppUser == null) {
        return emit(const AuthStateLoggedOut());
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      emit(const AuthStateLoading());
      await service.signInWithGoogle();
      final currentAppUser = service.currentAppUser as GoogleAuthUser?;
      emit(const AuthStateLoadingDone());

      if (currentAppUser != null) {
        return emit(GoogleUserLoggedIn(currentAppUser));
      } else {
        /* User cancelled the sign-in process */
        return emit(const AuthStateLoggedOut());
      }
    });
    on<LoginAnonymously>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        final currentAppUser = await service.logInAnonymously();
        emit(const AuthStateLoadingDone());
        if (currentAppUser != null) {
          return emit(AnonUserLoggedIn(currentAppUser as AnonUser));
        }
      } on Exception catch (e) {
        emit(const AuthStateLoadingDone());
        return emit(AuthFailure(e, 'Failed to Login. Please try again later.'));
      }
    });
    on<LoginWithEmail>((event, emit) async {
      emit(const AuthStateLoading());
      String? message;
      try {
        final EmailAuthUser? emailAuthUser = await service.logInWithEmail(
            email: event.email, password: event.password) as EmailAuthUser?;
        emit(const AuthStateLoadingDone());
        if (emailAuthUser != null) {
          if (!emailAuthUser.isVerified) {
            return emit(EmailNeedsVerification(emailAuthUser));
          }
          return emit(EmailUserLoggedIn(emailAuthUser));
        }
      } on Exception catch (e) {
        if (e is UserNotFoundAuthException) {
          message = 'User Not Found.';
        } else if (e is InvalidEmailAuthException) {
          message = 'The given email is invalid. Please check.';
        } else if (e is WrongPasswordAuthException) {
          message = 'The password is incorrect for the given email ID.';
        } else if (e is UserDisabledAuthException) {
          message = 'Sorry, the user has been disabled.';
        } else if (e is GenericAuthException) {
          message =
              'An Error Occurred. Make sure your credentials are correct.';
        } else {
          message = e.toString();
        }
        emit(const AuthStateLoadingDone());
        return emit(AuthFailure(e, message));
      }
    });
    on<CreateEmailUser>((event, emit) async {
      String? message;
      try {
        emit(const AuthStateLoading());
        final name = compileName(event.firstName, event.lastName);
        final emailUser = await service.createEmailUser(
            email: event.email, password: event.password, name: name);
        emit(const AuthStateLoadingDone());
        emit(const EmailUserCreated());
        return emit(EmailNeedsVerification(emailUser));
      } on Exception catch (e) {
        if (e is EmailAlreadyInUseAuthException) {
          message = 'This email is already in use.';
        } else if (e is InvalidEmailAuthException) {
          message = 'The given email is invalid. Please check.';
        } else if (e is WeakPasswordAuthException) {
          message = 'Weak password';
        } else {
          message = e.toString();
        }
        emit(const AuthStateLoadingDone());
        return emit(AuthFailure(e, message));
      }
    });

    on<UpdateName>((event, emit) async {
      try {
        await service.currentFirebaseUser?.updateDisplayName(event.name);
        await service.currentFirebaseUser?.reload();
        final user = service.updateAppUser();
        if (user != null) {
          emit(AnonUserLoggedIn(user as AnonUser));
        } else {
          debugPrint("Name not updated");
        }
      } on Exception catch (e) {
        emit(AuthFailure(e, e.toString()));
      }
    });

    on<SendUserEmailVerification>((event, emit) async {
      var completer = Completer();
      await service.sendEmailVerification();
      debugPrint('Sent Email Verification.');

      final EmailAuthUser emailAuthUser =
          service.currentAppUser as EmailAuthUser;
      emailVerificationTimer =
          Timer.periodic(const Duration(seconds: 2), (Timer t) async {
        final User? user = service.currentFirebaseUser;
        if (user != null) {
          await user.reload();
          final isEmailVerified = user.emailVerified;
          if (isEmailVerified) {
            t.cancel();
            debugPrint("Email has been verified!");
            emailAuthUser.isVerified = true;
            emit(EmailUserLoggedIn(emailAuthUser));
            completer.complete();
          } else {
            debugPrint('Not Verified Yet.');
          }
        } else {
          t.cancel();
          completer.completeError(UserNotFoundAuthException());
        }
      });
      return completer.future;
    });

    on<CancelEmailVerification>((event, emit) async {
      emailVerificationTimer?.cancel();
      debugPrint('Stopped Email Verification Listener');
    });
    on<AuthEventLogout>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await service.logOut();
        debugPrint('reached Logout event');
        emit(const AuthStateLoadingDone());
        return emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(const AuthStateLoadingDone());
        return emit(AuthStateLogOutFailure(e));
      }
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mynotes/features/user_authentication/auth/auth_exceptions.dart';
import 'package:mynotes/features/user_authentication/auth/firebase_auth_service.dart';
import 'package:mynotes/features/user_authentication/auth/users/anon_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/app_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/email_auth_user.dart';
import 'package:mynotes/features/user_authentication/auth/users/google_auth_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
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
        }
        return emit(AuthStateLoggedIn(currentAppUser));
      } else if (currentAppUser == null) {
        return emit(const AuthStateLoggedOut());
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      emit(const AuthStateLoading());
      await service.signInWithGoogle();
      final currentAppUser = service.currentAppUser as GoogleAuthUser?;

      if (currentAppUser != null) {
        emit(const AuthStateLoadingDone());
        return emit(GoogleUserLoggedIn(currentAppUser));
      } else {
        /* User cancelled the sign-in process */
        return;
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
        final currentAppUser = await service.logInWithEmail(
            email: event.email, password: event.password);
        emit(const AuthStateLoadingDone());
        if (currentAppUser != null) {
          return emit(EmailUserLoggedIn(currentAppUser as EmailAuthUser));
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
        await service.createEmailUser(
            email: event.email, password: event.password);
        return emit(const EmailUserCreated());
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
        emit(AuthFailure(e, message));
      }
    });
    on<SendUserEmailVerification>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await service.sendEmailVerification();
      } on Exception catch (e) {
        return emit(AuthFailure(e, 'Email Verification not sent.'));
      }
      return emit(EmailVerificationSent(event.user));
    });
    on<AuthEventLogout>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await service.logOut();
        return emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        return emit(AuthStateLogOutFailure(e));
      }
    });
  }
}

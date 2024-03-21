part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoadingDone extends AuthState {
  const AuthStateLoadingDone();
}

class AuthStateInitialized extends AuthState {
  const AuthStateInitialized();
}

class AuthStateLoggedIn extends AuthState {
  final AppUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

class AuthFailure extends AuthStateLoggedOut {
  final Exception exception;
  final String message;
  const AuthFailure(this.exception, this.message);
}

class InEmailLoginPage extends AuthStateLoggedOut {
  const InEmailLoginPage();
}

class AuthStateLogOutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogOutFailure(this.exception);
}

class GoogleUserLoggedIn extends AuthStateLoggedIn {
  final GoogleAuthUser googleAuthUser;
  const GoogleUserLoggedIn(this.googleAuthUser) : super(googleAuthUser);
}

class EmailUserLoggedIn extends AuthStateLoggedIn {
  final EmailAuthUser emailAuthUser;
  const EmailUserLoggedIn(this.emailAuthUser) : super(emailAuthUser);
}

class EmailUserCreated extends AuthState {
  const EmailUserCreated();
}

class EmailNeedsVerification extends AuthState {
  final EmailAuthUser emailAuthUser;
  const EmailNeedsVerification(this.emailAuthUser);
}

class EmailVerificationSent extends EmailNeedsVerification {
  const EmailVerificationSent(super.emailAuthUser);
}

class AuthStateEmailVerified extends AuthState {
  final EmailAuthUser emailAuthUser;
  const AuthStateEmailVerified(this.emailAuthUser);}

class AnonUserLoggedIn extends AuthStateLoggedIn {
  final AnonUser anonUser;
  const AnonUserLoggedIn(this.anonUser) : super(anonUser);
}

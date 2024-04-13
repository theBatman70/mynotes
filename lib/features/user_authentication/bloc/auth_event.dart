part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogin extends AuthEvent {
  const AuthEventLogin();
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

class LoginWithGoogle extends AuthEventLogin {
  const LoginWithGoogle();
}

class GoToEmailLoginPage extends AuthEvent {
  const GoToEmailLoginPage();
}

class LoginWithEmail extends AuthEventLogin {
  final String email;
  final String password;
  const LoginWithEmail(this.email, this.password);
}

class CreateEmailUser extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const CreateEmailUser(
      this.email, this.password, this.firstName, this.lastName);
}

class UpdateName extends AuthEvent {
  final String name;
  const UpdateName(this.name);
}

class SendUserEmailVerification extends AuthEvent {
  const SendUserEmailVerification();
}

class CancelEmailVerification extends AuthEvent {
  const CancelEmailVerification();
}

class LoginAnonymously extends AuthEventLogin {
  const LoginAnonymously();
}

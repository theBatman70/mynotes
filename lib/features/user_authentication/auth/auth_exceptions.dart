// Register Auth Exceptions

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class UserNullException implements Exception {
  @override
  String toString() => 'User created successfully but user is null';
}

// Login Auth Exceptions

class WrongPasswordAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class UserDisabledAuthException implements Exception {}

// Generic Auth Exception

class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}

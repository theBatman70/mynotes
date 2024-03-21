// Register Auth Exceptions

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

// Login Auth Exceptions

class WrongPasswordAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class UserDisabledAuthException implements Exception {}

// Generic Auth Exception

class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}

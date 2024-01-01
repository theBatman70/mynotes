import 'package:mynotes/services/crud/crud_constants.dart';

class DatabaseUser {
  final int userId;
  final String email;
  const DatabaseUser({
    required this.userId,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : userId = map[userIdColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User, ID - $userId, e-mail - $email';

  @override
  bool operator ==(covariant DatabaseUser other) {
    return userId == other.userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

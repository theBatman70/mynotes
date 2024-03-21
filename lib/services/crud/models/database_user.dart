import 'package:mynotes/services/crud/crud_constants.dart';

class DatabaseUser {
  final String userId;
  const DatabaseUser({
    required this.userId,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : userId = map[userIdColumn] as String;

  @override
  String toString() => 'User, ID - $userId';

  @override
  bool operator ==(covariant DatabaseUser other) {
    return userId == other.userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

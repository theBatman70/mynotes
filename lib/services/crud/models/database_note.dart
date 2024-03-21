import 'package:mynotes/services/crud/crud_constants.dart';

class DatabaseNote {
  final int noteId;
  final String userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;
  DatabaseNote({
    required this.noteId,
    required this.userId,
    required this.title,
    required this.text,
    required this.isSyncedWithCloud,
  });

  // Turn a row from the Database into our instance type
  DatabaseNote.fromRow(Map<String, Object?> map)
      : noteId = map[noteIdColumn] as int,
        userId = map[userIdColumn] as String,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 0 ? false : true;

  @override
  String toString() =>
      'Note, ID - $noteId, User ID - $userId, isSyncedWithCloud - $isSyncedWithCloud, text - $text';

  @override
  bool operator ==(covariant DatabaseNote other) => noteId == other.noteId;

  @override
  int get hashCode => noteId.hashCode;
}

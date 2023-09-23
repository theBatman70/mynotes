import 'package:mynotes/services/auth/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';
import 'crud_constants.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    // Check if note exists.
    await getNote(noteId: note.id);

    final updatesCount = await db.update(
      notesTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: 'noteId = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(noteId: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final note =
        await db.query(notesTable, where: 'noteId = ?', whereArgs: [noteId]);
    if (note.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(note.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    // Throw Exception if database is already open.
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      // Open our database
      final docsPath =
          await getApplicationDocumentsDirectory(); // get the docs path of the current app
      final dbPath = join(docsPath.path,
          dbName); // connect our db to the docs path of the current app
      final db = await openDatabase(dbPath);
      _db = db;

      // Create if tables don't exist already
      await db.execute(createUsersTable);
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    db.close();
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(usersTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    // Check if given email already exists.
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(
      usersTable,
      {
        emailColumn: email.toLowerCase(),
      },
    );

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    // Check if given email exists.
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesNotExist();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // Make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserDoesNotExist();
    }

    const text = '';
    // create the note
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
        id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
    return note;
  }

  Future<void> deleteNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User, ID - $id, e-mail - $email';
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;
  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 0 ? false : true;

  @override
  String toString() =>
      'Note, ID - $id, User ID - $userId, isSyncedWithCloud - $isSyncedWithCloud, text - $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

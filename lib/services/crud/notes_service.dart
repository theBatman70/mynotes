import 'dart:async';

import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';
import 'crud_constants.dart';

class NotesService {
  Database? _db;
  List<DatabaseNote> _notes = [];

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  static final NotesService _shared = NotesService._sharedInstance();

  factory NotesService() => _shared;

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on UserDoesNotExist {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Check if note exists.
    await getNote(noteId: note.noteId);

    final updatesCount = await db.update(
      notesTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: 'noteId = ?',
      whereArgs: [note.noteId],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(noteId: note.noteId);
      _notes.removeWhere((note) => note.noteId == updatedNote.noteId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final noteRow =
        await db.query(notesTable, where: 'noteId = ?', whereArgs: [noteId]);
    if (noteRow.isEmpty) {
      throw CouldNotFindNote();
    } else {
      // take the data form the map into our DatabaseNote
      final note = DatabaseNote.fromRow(noteRow.first);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
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

      // Cache the Notes
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    db.close();
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(usersTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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

    return DatabaseUser(userId: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserDoesNotExist();
    }

    const text = '';
    // insert into the notes table
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.userId,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
        noteId: noteId,
        userId: owner.userId,
        text: text,
        isSyncedWithCloud: true);

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int noteId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.noteId == noteId);
      _notesStreamController.add(_notes);
    }
  }
}

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

class DatabaseNote {
  final int noteId;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;
  DatabaseNote({
    required this.noteId,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : noteId = map[noteIdColumn] as int,
        userId = map[userIdColumn] as int,
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

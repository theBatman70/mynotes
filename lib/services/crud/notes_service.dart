import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:mynotes/utils/extensions/filter_stream.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';
import 'crud_constants.dart';
import 'models/database_note.dart';
import 'models/database_user.dart';

class NotesService {
  Database? _db;
  late DatabaseUser _user;
  List<DatabaseNote> _notes = [];

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  static final NotesService _shared = NotesService._sharedInstance();

  factory NotesService() => _shared;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        return note.userId == _user.userId;
      });

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  // Get User from the Database or Create one in it if not found.
  Future<DatabaseUser> getOrCreateUser({required String id}) async {
    try {
      final user = await getUser(id: id);
      _user = user;
      return user;
    } on UserDoesNotExist {
      final createdUser = await createUser(id: id);
      _user = createdUser;
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  // Add the notes from the Database to our instance variable and StreamController
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  // Update the given note in the Database
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String title,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Check if note exists.
    await getNote(noteId: note.noteId);

    final updatesCount = await db.update(
      notesTable,
      {textColumn: text, titleColumn: title, isSyncedWithCloudColumn: 0},
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

  // Fetch the notes from the Database
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

      final db = await openDatabase(
        dbPath,
        version: 5,
        onCreate: (db, version) async {
          await db.execute(createUsersTable);
          await db.execute(createNotesTable);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < newVersion) {
            // Create a temporary table with the new schema
            await db.execute(createTempNotesTableUpgraded);

            // Copy data from the old table to the temporary table
            await db.execute(insertOldNotesToNewTemp);

            // Drop the old table
            await db.execute(dropNotesTable);

            // Rename the temporary table to the original table name
            await db.execute(renameNotesTempToNotes);
          }
        },
      );
      _db = db;
      debugPrint(dbPath);

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

  Future<DatabaseUser> createUser({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Check if given ID already exists.
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'userId = ?',
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(
      usersTable,
      {
        userIdColumn: id,
      },
    );

    if (userId != 0) {
      return DatabaseUser(userId: id);
    }

    throw CouldNotCreateUser();
  }

  Future<DatabaseUser> getUser({required String id}) async {

    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Check if given id exists.
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'userId = ?',
      whereArgs: [id]
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
    final dbUser = await getUser(id: owner.userId);
    if (dbUser != owner) {
      throw UserDoesNotExist();
    }

    const text = '';
    const title = '';
    // insert into the notes table
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.userId,
      textColumn: text,
      titleColumn: title,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
        noteId: noteId,
        userId: owner.userId,
        title: title,
        text: text,
        isSyncedWithCloud: true);

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required List<int> noteIDs}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'noteId IN (${noteIDs.map((_) => '?').join(', ')})',
      whereArgs: noteIDs,
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      for (var noteID in noteIDs) {
        _notes.removeWhere((note) => note.noteId == noteID);
      }
      _notesStreamController.add(_notes);
    }
  }
}

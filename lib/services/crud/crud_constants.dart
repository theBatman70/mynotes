// Constants for DB SELECT
const dbName = 'notes.db';
const notesTable = 'notes';
const usersTable = 'users';
const noteIdColumn = 'noteId';
const emailColumn = 'email';
const userIdColumn = 'userId';
const titleColumn = 'title';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';

// DB Table Creation Commands

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	"noteId"	INTEGER NOT NULL,
	"userId"	INTEGER NOT NULL,
  "title" TEXT,
	"text"	TEXT NOT NULL,
	"isSyncedWithCloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("noteId" AUTOINCREMENT),
	FOREIGN KEY("userId") REFERENCES "users"("userId")
);''';

const createUsersTable = '''CREATE TABLE IF NOT EXISTS "users" (
	"userId"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("userId" AUTOINCREMENT)
);''';

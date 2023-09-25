// Constants for DB SELECT
const dbName = 'notes.db';
const notesTable = 'notes';
const usersTable = 'users';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user-id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';

// DB Table Creation Commands

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	"noteId"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("noteId" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);''';

const createUsersTable = '''CREATE TABLE IF NOT EXISTS "users" (
	"userId"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("userId" AUTOINCREMENT)
);''';

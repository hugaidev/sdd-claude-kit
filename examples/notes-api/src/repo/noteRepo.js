import { DatabaseSync } from 'node:sqlite';
import { randomUUID } from 'node:crypto';
import { encodeCursor, decodeCursor } from './cursor.js';

// Note repository: persistence (BR-006). WAL mode and synchronous=FULL make
// acknowledged writes durable across process restarts.
export function createNoteRepo(dbFile) {
  const db = new DatabaseSync(dbFile);
  db.exec('PRAGMA journal_mode = WAL');
  db.exec('PRAGMA synchronous = FULL');
  db.exec(`CREATE TABLE IF NOT EXISTS notes (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    created_at TEXT NOT NULL
  )`);
  db.exec('CREATE INDEX IF NOT EXISTS notes_created_at_desc ON notes (created_at DESC)');

  const insertStmt = db.prepare(
    'INSERT INTO notes (id, title, body, created_at) VALUES (?, ?, ?, ?)',
  );

  const deleteStmt = db.prepare('DELETE FROM notes WHERE id = ?');

  // BR-002: created_at descending, ties by id ascending; keyset pagination.
  const firstPageStmt = db.prepare(
    'SELECT id, title, body, created_at FROM notes ORDER BY created_at DESC, id ASC LIMIT ?',
  );
  const nextPageStmt = db.prepare(
    `SELECT id, title, body, created_at FROM notes
     WHERE created_at < ? OR (created_at = ? AND id > ?)
     ORDER BY created_at DESC, id ASC LIMIT ?`,
  );

  return {
    insert({ title, body }) {
      const note = { id: randomUUID(), title, body, created_at: new Date().toISOString() };
      insertStmt.run(note.id, note.title, note.body, note.created_at);
      return note;
    },
    // Returns { items, next_cursor }; throws InvalidCursorError on a bad cursor.
    list({ limit, cursor }) {
      let rows;
      if (cursor === undefined || cursor === null) {
        rows = firstPageStmt.all(limit + 1);
      } else {
        const after = decodeCursor(cursor);
        rows = nextPageStmt.all(after.created_at, after.created_at, after.id, limit + 1);
      }
      const hasMore = rows.length > limit;
      const items = rows.slice(0, limit).map((r) => ({ ...r }));
      const next_cursor = hasMore ? encodeCursor(items[items.length - 1]) : null;
      return { items, next_cursor };
    },
    // BR-003: hard delete; returns false (and changes nothing) when the note is missing.
    remove(id) {
      return Number(deleteStmt.run(id).changes) > 0;
    },
    close() {
      db.close();
    },
  };
}

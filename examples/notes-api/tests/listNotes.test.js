import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { createNoteRepo } from '../src/repo/noteRepo.js';
import { createNoteService } from '../src/service/noteService.js';
import { createApp } from '../src/http/app.js';
import { encodeCursor, decodeCursor } from '../src/repo/cursor.js';

let dir, dbFile, repo, server, base;

before(async () => {
  dir = mkdtempSync(join(tmpdir(), 'notes-list-test-'));
  dbFile = join(dir, 'notes.db');
  repo = createNoteRepo(dbFile);
  server = createApp(createNoteService(repo));
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  base = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((r) => server.close(r));
  repo.close();
  rmSync(dir, { recursive: true, force: true });
});

const list = (query = '') => fetch(`${base}/v1/notes${query}`);

// Inserts rows with controlled timestamps (the repository stamps "now" itself).
function seed(rows) {
  const db = new DatabaseSync(dbFile);
  const stmt = db.prepare('INSERT INTO notes (id, title, body, created_at) VALUES (?, ?, ?, ?)');
  db.exec('BEGIN'); // one transaction: autocommit per row is slow and would block the event loop
  for (const r of rows) stmt.run(r.id, r.title, 'lorem', r.created_at);
  db.exec('COMMIT');
  db.close();
}

const uuid = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const at = (i) => new Date(Date.UTC(2026, 0, 1, 0, 0, i)).toISOString();

test('TEST-002 empty store gives an empty page', async () => {
  const res = await list();
  assert.equal(res.status, 200);
  assert.deepEqual(await res.json(), { items: [], next_cursor: null });
});

test('TEST-002 invalid limit or cursor gives 400 VALIDATION_ERROR', async () => {
  for (const q of [
    '?limit=0',
    '?limit=101',
    '?limit=abc',
    '?limit=1.5',
    '?limit=-1',
    '?limit=',
    '?cursor=garbage',
    '?cursor=',
    `?cursor=${Buffer.from('["x","y"]').toString('base64url')}`,
    `?cursor=${Buffer.from('not json').toString('base64url')}`,
  ]) {
    const res = await list(q);
    assert.equal(res.status, 400, q);
    const err = (await res.json()).error;
    assert.equal(err.code, 'VALIDATION_ERROR', q);
    assert.ok(err.details.length > 0, q);
  }
});

test('TEST-002 pages of 10, 10 and 7 newest first, no repeats or skips, ties by id', async () => {
  const rows = [];
  for (let i = 1; i <= 25; i++) rows.push({ id: uuid(i), title: `note-${i}`, created_at: at(i) });
  // two extra notes share note 17's timestamp, inserted in reverse id order; the
  // tie group (ids 17, 901, 902) straddles the first page boundary (items 9 to 11)
  const tie = at(17);
  rows.push({ id: uuid(902), title: 'note-tie-b', created_at: tie });
  rows.push({ id: uuid(901), title: 'note-tie-a', created_at: tie });
  seed(rows);

  const expected = [...rows]
    .sort((a, b) =>
      a.created_at < b.created_at ? 1 : a.created_at > b.created_at ? -1 : a.id < b.id ? -1 : 1,
    )
    .map((r) => r.id);

  const sizes = [];
  const seen = [];
  let cursor = null;
  do {
    const res = await list(`?limit=10${cursor ? `&cursor=${encodeURIComponent(cursor)}` : ''}`);
    assert.equal(res.status, 200);
    const page = await res.json();
    sizes.push(page.items.length);
    seen.push(...page.items.map((n) => n.id));
    for (const n of page.items) {
      assert.deepEqual(Object.keys(n).sort(), ['body', 'created_at', 'id', 'title']);
    }
    cursor = page.next_cursor;
  } while (cursor !== null);

  assert.deepEqual(sizes, [10, 10, 7]);
  assert.equal(new Set(seen).size, 27);
  assert.deepEqual(seen, expected);
  // equal timestamps are ordered by id ascending, across the page boundary
  assert.deepEqual(seen.slice(8, 11), [uuid(17), uuid(901), uuid(902)]);
});

test('default limit is 20 and next_cursor is null on an exact last page', async () => {
  let page = await (await list()).json();
  assert.equal(page.items.length, 20);
  assert.notEqual(page.next_cursor, null);
  page = await (await list('?limit=27')).json();
  assert.equal(page.items.length, 27);
  assert.equal(page.next_cursor, null);
  page = await (await list('?limit=100')).json();
  assert.equal(page.items.length, 27);
});

test('cursor encoding round-trips and rejects malformed input', () => {
  const c = encodeCursor({ created_at: at(5), id: uuid(5) });
  assert.deepEqual(decodeCursor(c), { created_at: at(5), id: uuid(5) });
  assert.throws(() => decodeCursor('garbage'));
  assert.throws(() => decodeCursor(''));
});

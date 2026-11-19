import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { createNoteRepo } from '../src/repo/noteRepo.js';
import { createNoteService } from '../src/service/noteService.js';
import { createApp } from '../src/http/app.js';

let dir, dbFile, repo, server, base;

before(async () => {
  dir = mkdtempSync(join(tmpdir(), 'notes-test-'));
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

const post = (body, type = 'application/json') =>
  fetch(`${base}/v1/notes`, { method: 'POST', headers: { 'Content-Type': type }, body });

const count = () => {
  const db = new DatabaseSync(dbFile);
  const n = db.prepare('SELECT COUNT(*) AS n FROM notes').get().n;
  db.close();
  return n;
};

test('TEST-001 create note: success and all rejection cases', async () => {
  // (a) valid
  let res = await post(JSON.stringify({ title: 'note-001', body: 'hello' }));
  assert.equal(res.status, 201);
  const note = await res.json();
  assert.match(note.id, /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
  assert.equal(note.title, 'note-001');
  assert.equal(note.body, 'hello');
  assert.equal(new Date(note.created_at).toISOString(), note.created_at);

  // (b) empty title
  res = await post(JSON.stringify({ title: '', body: 'x' }));
  assert.equal(res.status, 400);
  let err = (await res.json()).error;
  assert.equal(err.code, 'VALIDATION_ERROR');
  assert.equal(err.details[0].field, 'title');

  // (c) title of 121 characters
  res = await post(JSON.stringify({ title: 'a'.repeat(121), body: 'x' }));
  assert.equal(res.status, 400);
  err = (await res.json()).error;
  assert.equal(err.code, 'VALIDATION_ERROR');
  assert.equal(err.details[0].field, 'title');

  // (d) body of 10001 characters
  res = await post(JSON.stringify({ title: 'note-002', body: 'b'.repeat(10001) }));
  assert.equal(res.status, 400);
  err = (await res.json()).error;
  assert.equal(err.details[0].field, 'body');

  // (e) text/plain
  res = await post(JSON.stringify({ title: 'note-003', body: 'x' }), 'text/plain');
  assert.equal(res.status, 415);
  assert.equal((await res.json()).error.code, 'UNSUPPORTED_MEDIA_TYPE');

  // (f) malformed JSON
  res = await post('{not json');
  assert.equal(res.status, 400);
  assert.equal((await res.json()).error.code, 'VALIDATION_ERROR');

  // (g) body above 1 MiB
  res = await post(JSON.stringify({ title: 'note-004', body: 'z'.repeat(1024 * 1024 + 1) }));
  assert.equal(res.status, 413);
  assert.equal((await res.json()).error.code, 'PAYLOAD_TOO_LARGE');

  assert.equal(count(), 1);
});

test('edge cases: boundaries, trimming, whitespace title, missing and non-string fields', async () => {
  let res = await post(JSON.stringify({ title: '  padded  ', body: '' }));
  assert.equal(res.status, 201);
  assert.equal((await res.json()).title, 'padded');

  res = await post(JSON.stringify({ title: 'a'.repeat(120), body: 'b'.repeat(10000) }));
  assert.equal(res.status, 201);

  res = await post(JSON.stringify({ title: '   ', body: 'x' }));
  assert.equal(res.status, 400);

  res = await post(JSON.stringify({ title: 'ok' }));
  assert.equal(res.status, 400);
  assert.equal((await res.json()).error.details[0].field, 'body');

  res = await post(JSON.stringify({ title: 5, body: 'x' }));
  assert.equal(res.status, 400);

  res = await post(JSON.stringify([1]));
  assert.equal(res.status, 400);

  res = await post(JSON.stringify({ title: '', body: 'b'.repeat(10001) }));
  assert.deepEqual(
    (await res.json()).error.details.map((d) => d.field),
    ['title', 'body'],
  );
});

test('unknown route returns the standard NOT_FOUND envelope', async () => {
  const res = await fetch(`${base}/v1/nope`);
  assert.equal(res.status, 404);
  assert.equal((await res.json()).error.code, 'NOT_FOUND');
});
